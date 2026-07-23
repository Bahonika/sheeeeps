import 'dart:async';
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';

import '../../data/sources/pasture_client_source.dart';
import '../../shared/game_config.dart';
import '../net/net_message.dart';
import '../net/world_snapshot.dart';
import '../ports/game_ports.dart';
import '../state/dog_state.dart';
import '../state_managers/dogs_state_manager.dart';
import '../state_managers/flock_state_manager.dart';
import '../state_managers/lobby_state_manager.dart';
import '../state_managers/nav_state_manager.dart';
import '../state_managers/round_state_manager.dart';

class _Sample {
  const _Sample(this.t, this.snapshot);
  final double t;
  final WorldSnapshot snapshot;
}

/// 2nd-order coordinator for a pasture (Stage 3) web session. Like the LAN
/// client it is both the view's tick port (advancing snapshot interpolation each
/// frame) and its input port (serialising local commands to the server) — the
/// client runs no simulation, only mirrors the server's authoritative state into
/// the flock/dogs/lobby/round managers the overlays read.
///
/// It differs from [ClientNetInteractor] in two ways: it dials a single fixed
/// server URL over the cross-platform [PastureClientSource] (web-safe), and it
/// mirrors the persistent-world round (phase/timer/scoreboard/day record) rather
/// than a one-shot game result.
class PastureClientNetInteractor
    implements AsyncLifecycle, GameTickPort, GameInputPort {
  PastureClientNetInteractor({
    required PastureClientSource client,
    required LobbyStateManager lobby,
    required DogsStateManager dogs,
    required FlockStateManager flock,
    required RoundStateManager round,
    required NavStateManager nav,
    required String playerName,
    required String url,
  })  : _client = client,
        _lobby = lobby,
        _dogs = dogs,
        _flock = flock,
        _round = round,
        _nav = nav,
        _playerName = playerName,
        _url = url;

  final PastureClientSource _client;
  final LobbyStateManager _lobby;
  final DogsStateManager _dogs;
  final FlockStateManager _flock;
  final RoundStateManager _round;
  final NavStateManager _nav;
  final String _playerName;
  final String _url;

  final List<_Sample> _samples = [];
  double _clock = 0;
  bool _ended = false;

  StreamSubscription<Uint8List>? _inboundSub;
  StreamSubscription<void>? _closedSub;

  // Reused interpolation scratch (reallocated only when the head-count changes).
  Float32List _x = Float32List(0);
  Float32List _y = Float32List(0);
  Float32List _vx = Float32List(0);
  Float32List _vy = Float32List(0);
  Uint8List _phase = Uint8List(0);
  Uint8List _variant = Uint8List(0);

  @override
  Future<void> init() async {
    try {
      await _client.connect(_url);
    } on Object {
      await _fail('Не удалось подключиться к пастбищу. Попробуй позже.');
      return;
    }
    _inboundSub = _client.inbound.listen(_onMessage);
    _closedSub = _client.closed.listen((_) => _fail('Связь с сервером потеряна'));
    _client.send(NetCodec.encode(
      ClientHello(
        protocolVersion: GameConfig.protocolVersion,
        name: _playerName,
      ),
    ));
  }

  @override
  Future<void> dispose() async {
    await _inboundSub?.cancel();
    await _closedSub?.cancel();
  }

  // ── Input port (local → server) ─────────────────────────────────────────────

  @override
  void moveTo(double worldX, double worldY) =>
      _client.send(NetCodec.encode(ClientMove(worldX, worldY)));

  @override
  void bark() => _client.send(NetCodec.encode(const ClientBark()));

  @override
  void requestRestart() {} // the pasture round loop is server-driven

  // ── Inbound ──────────────────────────────────────────────────────────────────

  void _onMessage(Uint8List bytes) {
    final NetMessage msg;
    try {
      msg = NetCodec.decode(bytes);
    } on Object {
      return;
    }
    switch (msg) {
      case HostWelcome():
        _lobby.setLocalIdentity(id: msg.assignedId, roomName: msg.roomName);
      case HostReject():
        _fail(switch (msg.reason) {
          RejectReason.versionMismatch =>
            'Версия игры устарела. Обнови страницу (Ctrl+F5).',
          RejectReason.roomFull => 'Пастбище переполнено, попробуй позже.',
        });
      case HostLobby():
        _lobby.setPlayers(msg.players);
        _lobby.setStarted(msg.started);
      case HostSnapshot():
        _samples.add(_Sample(_clock, msg.snapshot));
        if (_samples.length > 12) _samples.removeAt(0);
      default:
        break;
    }
  }

  Future<void> _fail(String message) async {
    if (_ended) return;
    _ended = true;
    await _client.disconnect();
    await _nav.toError(message);
  }

  // ── Tick port (interpolate → mirror managers) ───────────────────────────────

  @override
  void update(double dt) {
    _clock += dt;
    if (_samples.isEmpty) return;

    final renderTime = _clock - GameConfig.interpolationDelay;

    var aIdx = 0;
    for (var i = 0; i < _samples.length; i++) {
      if (_samples[i].t <= renderTime) {
        aIdx = i;
      } else {
        break;
      }
    }
    final bIdx = (aIdx + 1 < _samples.length) ? aIdx + 1 : aIdx;
    final a = _samples[aIdx];
    final b = _samples[bIdx];

    final span = b.t - a.t;
    final alpha =
        span > 1e-6 ? ((renderTime - a.t) / span).clamp(0.0, 1.0) : 0.0;
    final invDt = span > 1e-6 ? 1.0 / span : 0.0;

    _applyFlock(a.snapshot, b.snapshot, alpha, invDt);
    _applyDogs(a.snapshot, b.snapshot, alpha, invDt);
    _applyRound(b.snapshot); // round state is not interpolated — adopt newest

    if (aIdx > 0) _samples.removeRange(0, aIdx);
  }

  void _applyFlock(WorldSnapshot a, WorldSnapshot b, double alpha, double invDt) {
    final n = b.sheepTotal;
    if (_x.length != n) {
      _x = Float32List(n);
      _y = Float32List(n);
      _vx = Float32List(n);
      _vy = Float32List(n);
      _phase = Uint8List(n);
      _variant = Uint8List(n);
    }
    final interp = a.sheepTotal == n;
    for (var i = 0; i < n; i++) {
      final bx = b.sheepX[i];
      final by = b.sheepY[i];
      if (interp) {
        final ax = a.sheepX[i];
        final ay = a.sheepY[i];
        _x[i] = ax + (bx - ax) * alpha;
        _y[i] = ay + (by - ay) * alpha;
        _vx[i] = (bx - ax) * invDt;
        _vy[i] = (by - ay) * invDt;
      } else {
        _x[i] = bx;
        _y[i] = by;
        _vx[i] = 0;
        _vy[i] = 0;
      }
      _phase[i] = WorldSnapshot.phaseOf(b.sheepStatus[i]);
      _variant[i] = WorldSnapshot.variantOf(b.sheepStatus[i]);
    }
    _flock.applyNetwork(
      count: n,
      x: _x,
      y: _y,
      vx: _vx,
      vy: _vy,
      phase: _phase,
      variant: _variant,
    );
  }

  void _applyDogs(WorldSnapshot a, WorldSnapshot b, double alpha, double invDt) {
    final roster = {for (final p in _lobby.state.players) p.id: p.name};
    final dogs = <int, DogState>{};
    for (final d in b.dogs) {
      DogSnapshot? prev;
      for (final pd in a.dogs) {
        if (pd.id == d.id) {
          prev = pd;
          break;
        }
      }
      final double x, y, vx, vy;
      if (prev != null) {
        x = prev.x + (d.x - prev.x) * alpha;
        y = prev.y + (d.y - prev.y) * alpha;
        vx = (d.x - prev.x) * invDt;
        vy = (d.y - prev.y) * invDt;
      } else {
        x = d.x;
        y = d.y;
        vx = d.vx;
        vy = d.vy;
      }
      dogs[d.id] = DogState(
        id: d.id,
        name: roster[d.id] ?? 'Пастух ${d.id}',
        colorIndex: d.colorIndex,
        x: x,
        y: y,
        targetX: x,
        targetY: y,
        hasTarget: false,
        vx: vx,
        vy: vy,
        barkCooldownRemaining: d.barkCooldownRemaining,
        barkSeq: d.barkSeq,
        asleep: d.isAsleep,
      );
    }
    _dogs.setDogs(dogs);
  }

  void _applyRound(WorldSnapshot b) {
    final scores = <int, int>{
      for (final d in b.dogs)
        if (d.roundScore > 0) d.id: d.roundScore,
    };
    _round.mirror(
      phase: b.roundPhase,
      timer: b.elapsed,
      penned: b.pennedCount,
      total: b.sheepTotal,
      scores: scores,
      celebrationRemaining: b.celebrationRemaining,
      dayRecordSeconds: b.dayRecordSeconds,
    );
  }
}
