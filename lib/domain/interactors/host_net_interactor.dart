import 'dart:async';

import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../data/sources/lan_discovery_source.dart';
import '../../data/sources/lan_host_source.dart';
import '../../shared/game_config.dart';
import '../models/player_info.dart';
import '../net/net_message.dart';
import '../net/snapshot_builder.dart';
import '../state/flock_state.dart';
import '../state/game_state.dart';
import '../state/lobby_state.dart';
import '../state_managers/dogs_state_manager.dart';
import '../state_managers/lobby_state_manager.dart';
import '../state_managers/nav_state_manager.dart';
import 'game_loop_interactor.dart';
import 'input_interactor.dart';

/// 2nd-order coordinator that runs the host's networking on top of the local
/// authoritative simulation. It owns no game state — it maps sockets to players,
/// feeds decoded client input into the shared [InputInteractor], streams
/// snapshots and UDP room announcements, and keeps the lobby roster in sync.
///
/// The host itself plays through the same local controller as solo; this class
/// only bridges the network side (TZ: "хост играет без сети как обычно").
class HostNetInteractor implements AsyncLifecycle {
  HostNetInteractor({
    required LanHostSource host,
    required LanDiscoverySource announcer,
    required LobbyStateManager lobby,
    required DogsStateManager dogs,
    required StateReadable<FlockState> flock,
    required StateReadable<GameState> game,
    required InputInteractor input,
    required GameLoopInteractor loop,
    required NavStateManager nav,
    int gamePort = GameConfig.gamePort,
  })  : _gamePort = gamePort,
        _host = host,
        _announcer = announcer,
        _lobby = lobby,
        _dogs = dogs,
        _flock = flock,
        _game = game,
        _input = input,
        _loop = loop,
        _nav = nav;

  final LanHostSource _host;
  final LanDiscoverySource _announcer;
  final LobbyStateManager _lobby;
  final DogsStateManager _dogs;
  final StateReadable<FlockState> _flock;
  final StateReadable<GameState> _game;
  final InputInteractor _input;
  final GameLoopInteractor _loop;
  final NavStateManager _nav;
  final int _gamePort;

  /// connection id → player id.
  final Map<int, int> _players = {};

  StreamSubscription<HostInbound>? _inboundSub;
  StreamSubscription<int>? _disconnectSub;
  StreamSubscription<LobbyState>? _lobbySub;
  Timer? _snapshotTimer;
  Timer? _announceTimer;

  @override
  Future<void> init() async {
    try {
      await _host.start(_gamePort);
      await _announcer.openBroadcaster(GameConfig.discoveryPort);
    } on Object {
      await _nav.toError('Не удалось открыть порт ${GameConfig.gamePort}. '
          'Возможно, уже запущена другая комната.');
      return;
    }

    final ip = await LanHostSource.resolveLocalIp();
    await _lobby.setHostAddress("$ip:$_gamePort");

    _inboundSub = _host.inbound.listen(_onInbound);
    _disconnectSub = _host.disconnected.listen(_onDisconnect);
    // Any roster change (join/leave/start) is pushed to every client.
    _lobbySub = _lobby.stream.listen((s) => _broadcastLobby(s));

    _snapshotTimer = Timer.periodic(
      Duration(milliseconds: (GameConfig.snapshotInterval * 1000).round()),
      (_) => _broadcastSnapshot(),
    );
    _announceTimer = Timer.periodic(
      Duration(milliseconds: (GameConfig.announceInterval * 1000).round()),
      (_) => _announce(),
    );
  }

  @override
  Future<void> dispose() async {
    _snapshotTimer?.cancel();
    _announceTimer?.cancel();
    await _inboundSub?.cancel();
    await _disconnectSub?.cancel();
    await _lobbySub?.cancel();
  }

  /// Host pressed "Start": seed the world with the full roster, then flip the
  /// lobby to started (which the roster broadcast carries to every client).
  Future<void> startGame() async {
    await _loop.restart();
    await _lobby.setStarted(true);
  }

  // ── Inbound ────────────────────────────────────────────────────────────────

  void _onInbound(HostInbound frame) {
    final NetMessage msg;
    try {
      msg = NetCodec.decode(frame.bytes);
    } on FormatException {
      return;
    }
    switch (msg) {
      case ClientHello():
        _onHello(frame.connectionId, msg);
      case ClientMove():
        final id = _players[frame.connectionId];
        if (id != null) _input.moveTo(id, msg.x, msg.y);
      case ClientBark():
        final id = _players[frame.connectionId];
        if (id != null) _input.bark(id);
      default:
        break; // clients never send host messages
    }
  }

  Future<void> _onHello(int connectionId, ClientHello hello) async {
    if (hello.protocolVersion != GameConfig.protocolVersion) {
      _host.sendTo(
        connectionId,
        NetCodec.encode(const HostReject(RejectReason.versionMismatch)),
      );
      await _host.kick(connectionId);
      return;
    }
    if (_lobby.state.isFull) {
      _host.sendTo(
        connectionId,
        NetCodec.encode(const HostReject(RejectReason.roomFull)),
      );
      await _host.kick(connectionId);
      return;
    }

    final id = _lobby.state.nextPlayerId;
    final colorIndex = _lobby.state.nextColorIndex;
    final name = hello.name.trim().isEmpty ? 'Игрок $id' : hello.name.trim();
    _players[connectionId] = id;

    await _lobby.addPlayer(
      PlayerInfo(id: id, name: name, colorIndex: colorIndex),
    );
    _host.sendTo(
      connectionId,
      NetCodec.encode(HostWelcome(
        protocolVersion: GameConfig.protocolVersion,
        assignedId: id,
        colorIndex: colorIndex,
        roomName: _lobby.state.roomName,
      )),
    );

    // Joined a match already in progress: hand out a dog immediately (TZ).
    if (_lobby.state.started) {
      await _dogs.addDog(
        PlayerInfo(id: id, name: name, colorIndex: colorIndex),
      );
    }
  }

  Future<void> _onDisconnect(int connectionId) async {
    final id = _players.remove(connectionId);
    if (id == null) return;
    await _lobby.removePlayer(id);
    await _dogs.removeDog(id);
  }

  // ── Outbound ─────────────────────────────────────────────────────────────

  void _broadcastLobby(LobbyState s) {
    _host.broadcast(NetCodec.encode(
      HostLobby(players: s.players, started: s.started),
    ));
  }

  void _broadcastSnapshot() {
    if (!_lobby.state.started) return;
    if (_host.connectionCount == 0) return;
    final snap = buildWorldSnapshot(_dogs.state, _flock.state, _game.state);
    _host.broadcast(NetCodec.encode(HostSnapshot(snap)));
  }

  void _announce() {
    _announcer.sendBroadcast(NetCodec.encode(RoomAnnounce(
      protocolVersion: GameConfig.protocolVersion,
      port: _gamePort,
      roomName: _lobby.state.roomName,
      playerCount: _lobby.state.players.length,
      maxPlayers: GameConfig.maxPlayers,
    )));
  }
}
