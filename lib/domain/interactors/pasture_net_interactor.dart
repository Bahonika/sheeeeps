import 'dart:async';

import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../data/sources/lan_host_source.dart';
import '../../shared/game_config.dart';
import '../models/player_info.dart';
import '../net/net_message.dart';
import '../net/snapshot_builder.dart';
import '../state/flock_state.dart';
import '../state/lobby_state.dart';
import '../state/round_state.dart';
import '../state_managers/dogs_state_manager.dart';
import '../state_managers/lobby_state_manager.dart';
import 'input_interactor.dart';

/// The persistent pasture's networking + session coordinator (server side). It
/// owns no game state: it maps sockets to shepherds, hands out colours from the
/// 16-slot palette, spawns/removes dogs, rate-limits input, runs AFK sleep/kick
/// and the 5-second disconnect grace, and streams binary snapshots + the roster
/// to every client. There is no lobby or "Start" button — the world is always
/// live, so a joiner gets a dog immediately (drop-in/drop-out).
///
/// Robustness (TZ): every inbound frame is decoded in a try/catch and garbage is
/// dropped silently; one misbehaving connection can never throw out of a handler.
class PastureNetInteractor implements AsyncLifecycle {
  PastureNetInteractor({
    required LanHostSource socket,
    required LobbyStateManager lobby,
    required DogsStateManager dogs,
    required StateReadable<FlockState> flock,
    required StateReadable<RoundState> round,
    required InputInteractor input,
    required int port,
  })  : _socket = socket,
        _lobby = lobby,
        _dogs = dogs,
        _flock = flock,
        _round = round,
        _input = input,
        _port = port;

  final LanHostSource _socket;
  final LobbyStateManager _lobby;
  final DogsStateManager _dogs;
  final StateReadable<FlockState> _flock;
  final StateReadable<RoundState> _round;
  final InputInteractor _input;
  final int _port;

  final Map<int, int> _playerOf = {}; // connectionId → playerId
  final Map<int, int> _connOf = {}; // playerId → connectionId
  final Map<int, int> _lastInputMs = {}; // playerId → monotonic ms
  final Set<int> _sleeping = {}; // playerIds currently AFK-asleep
  final Map<int, Timer> _pendingRemoval = {}; // playerId → disconnect grace timer

  // Per-connection command rate limiter (fixed 1-second windows).
  final Map<int, int> _cmdWindowMs = {};
  final Map<int, int> _cmdCount = {};

  final Stopwatch _clock = Stopwatch();
  StreamSubscription<HostInbound>? _inboundSub;
  StreamSubscription<int>? _disconnectSub;
  StreamSubscription<LobbyState>? _lobbySub;
  Timer? _snapshotTimer;
  Timer? _afkTimer;

  int get _nowMs => _clock.elapsedMilliseconds;

  @override
  Future<void> init() async {
    _clock.start();
    await _socket.start(_port);

    _inboundSub = _socket.inbound.listen(_onInbound);
    _disconnectSub = _socket.disconnected.listen(_onDisconnect);
    _lobbySub = _lobby.stream.listen(_broadcastLobby);

    _snapshotTimer = Timer.periodic(
      Duration(milliseconds: (GameConfig.snapshotInterval * 1000).round()),
      (_) => _broadcastSnapshot(),
    );
    _afkTimer = Timer.periodic(const Duration(seconds: 1), (_) => _checkAfk());
  }

  @override
  Future<void> dispose() async {
    _snapshotTimer?.cancel();
    _afkTimer?.cancel();
    for (final t in _pendingRemoval.values) {
      t.cancel();
    }
    _pendingRemoval.clear();
    await _inboundSub?.cancel();
    await _disconnectSub?.cancel();
    await _lobbySub?.cancel();
  }

  // ── Inbound ────────────────────────────────────────────────────────────────

  void _onInbound(HostInbound frame) {
    final NetMessage msg;
    try {
      msg = NetCodec.decode(frame.bytes);
    } on Object {
      return; // malformed → drop silently
    }
    try {
      switch (msg) {
        case ClientHello():
          _onHello(frame.connectionId, msg);
        case ClientMove():
          final id = _playerOf[frame.connectionId];
          if (id != null && _allow(frame.connectionId)) {
            _touch(id);
            _input.moveTo(id, msg.x, msg.y);
          }
        case ClientBark():
          final id = _playerOf[frame.connectionId];
          if (id != null && _allow(frame.connectionId)) {
            _touch(id);
            _input.bark(id);
          }
        default:
          break; // clients never send host→client messages
      }
    } on Object {
      return; // never let one connection's handler crash the server
    }
  }

  Future<void> _onHello(int connectionId, ClientHello hello) async {
    if (hello.protocolVersion != GameConfig.protocolVersion) {
      _socket.sendTo(connectionId,
          NetCodec.encode(const HostReject(RejectReason.versionMismatch)));
      await _socket.kick(connectionId);
      return;
    }
    if (_lobby.state.isFull) {
      _socket.sendTo(connectionId,
          NetCodec.encode(const HostReject(RejectReason.roomFull)));
      await _socket.kick(connectionId);
      return;
    }

    final id = _lobby.state.nextPlayerId;
    final colorIndex = _lobby.state.nextColorIndex;
    final name = _sanitizeName(hello.name, id);
    final player = PlayerInfo(id: id, name: name, colorIndex: colorIndex);

    _playerOf[connectionId] = id;
    _connOf[id] = connectionId;
    _touch(id);

    await _lobby.addPlayer(player);
    final spawn = GameConfig.edgeSpawn(colorIndex);
    await _dogs.addDog(player, x: spawn.$1, y: spawn.$2);

    _socket.sendTo(
      connectionId,
      NetCodec.encode(HostWelcome(
        protocolVersion: GameConfig.protocolVersion,
        assignedId: id,
        colorIndex: colorIndex,
        roomName: _lobby.state.roomName,
      )),
    );
  }

  /// TZ: trim to 12 characters, reject empty/whitespace (fall back to a name).
  String _sanitizeName(String raw, int id) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Пастух $id';
    final runes = trimmed.runes.toList();
    if (runes.length <= 12) return trimmed;
    return String.fromCharCodes(runes.take(12));
  }

  void _touch(int id) {
    _lastInputMs[id] = _nowMs;
    _sleeping.remove(id); // any input wakes a sleeping dog
  }

  /// Fixed-window rate limit: at most [GameConfig.maxCommandsPerSecond] per
  /// connection per second; excess is ignored.
  bool _allow(int connectionId) {
    final now = _nowMs;
    final start = _cmdWindowMs[connectionId] ?? 0;
    if (now - start >= 1000) {
      _cmdWindowMs[connectionId] = now;
      _cmdCount[connectionId] = 1;
      return true;
    }
    final count = (_cmdCount[connectionId] ?? 0) + 1;
    _cmdCount[connectionId] = count;
    return count <= GameConfig.maxCommandsPerSecond;
  }

  // ── Disconnect (5s grace) + AFK ──────────────────────────────────────────────

  void _onDisconnect(int connectionId) {
    final id = _playerOf.remove(connectionId);
    _cmdWindowMs.remove(connectionId);
    _cmdCount.remove(connectionId);
    if (id == null) return;
    if (_connOf[id] == connectionId) _connOf.remove(id);
    // The dog lingers (standing still) for a grace window before removal, so a
    // fast reconnect isn't punished.
    _pendingRemoval[id]?.cancel();
    _pendingRemoval[id] = Timer(
      Duration(milliseconds: (GameConfig.disconnectGraceSeconds * 1000).round()),
      () => _removePlayer(id),
    );
  }

  Future<void> _removePlayer(int id) async {
    _pendingRemoval.remove(id)?.cancel();
    _lastInputMs.remove(id);
    _sleeping.remove(id);
    _connOf.remove(id);
    await _lobby.removePlayer(id);
    await _dogs.removeDog(id);
  }

  void _checkAfk() {
    final now = _nowMs;
    // Snapshot ids to avoid mutating while iterating.
    for (final id in _lastInputMs.keys.toList()) {
      final idleMs = now - (_lastInputMs[id] ?? now);
      if (idleMs >= GameConfig.afkKickSeconds * 1000) {
        final conn = _connOf[id];
        if (conn != null) _socket.kick(conn);
        _removePlayer(id);
      } else if (idleMs >= GameConfig.afkSleepSeconds * 1000) {
        _sleeping.add(id);
      }
    }
  }

  // ── Outbound ─────────────────────────────────────────────────────────────────

  void _broadcastLobby(LobbyState s) {
    _socket.broadcast(
      NetCodec.encode(HostLobby(players: s.players, started: true)),
    );
  }

  void _broadcastSnapshot() {
    if (_socket.connectionCount == 0) return; // no listeners → no traffic
    final snap = buildPastureSnapshot(
      _dogs.state,
      _flock.state,
      _round.state,
      _sleeping,
    );
    _socket.broadcast(NetCodec.encode(HostSnapshot(snap)));
  }
}
