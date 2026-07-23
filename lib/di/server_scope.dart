import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/lan_host_source.dart';
import '../domain/interactors/input_interactor.dart';
import '../domain/interactors/pasture_loop_interactor.dart';
import '../domain/interactors/pasture_net_interactor.dart';
import '../domain/state/lobby_state.dart';
import '../domain/state/round_state.dart';
import '../domain/state_managers/dogs_state_manager.dart';
import '../domain/state_managers/flock_state_manager.dart';
import '../domain/state_managers/lobby_state_manager.dart';
import '../domain/state_managers/round_state_manager.dart';
import '../shared/game_config.dart';

/// The headless pasture server's root scope. It assembles the exact same
/// simulation StateManagers the single-player game uses (flock, dogs) plus the
/// persistent-world round manager, wraps them in the authoritative
/// [PastureLoopInteractor] (the tick loop) and [PastureNetInteractor] (sessions
/// + networking). No sprites, no navigation, no Flutter — this container is
/// created from a plain Dart entrypoint (`bin/server.dart`).
abstract interface class ServerScope {
  LanHostSource get socket;
  PastureLoopInteractor get loop;
  StateReadable<RoundState> get round;
  StateReadable<LobbyState> get lobby;
}

class ServerScopeContainer extends ScopeContainer implements ServerScope {
  ServerScopeContainer({required this.port});

  final int port;

  late final _flockDep = asyncDep(() => FlockStateManager());
  late final _dogsDep = asyncDep(() => DogsStateManager());
  late final _roundDep = asyncDep(() => RoundStateManager());

  late final _lobbyDep = asyncDep(
    () => LobbyStateManager(const LobbyState(
      roomName: 'Пастбище',
      localPlayerId: -1, // the server itself is not a shepherd
      players: [],
      started: true, // the world is always live — no lobby
      maxPlayers: GameConfig.maxPasturePlayers,
    )),
  );

  late final _inputDep = dep(
    () => InputInteractor(dogs: _dogsDep.get, flock: _flockDep.get),
  );

  late final _socketDep = asyncDep(() => LanHostSource());

  late final _loopDep = asyncDep(
    () => PastureLoopInteractor(
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      round: _roundDep.get,
      lobby: _lobbyDep.get,
    ),
  );

  late final _netDep = asyncDep(
    () => PastureNetInteractor(
      socket: _socketDep.get,
      lobby: _lobbyDep.get,
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      round: _roundDep.get,
      input: _inputDep.get,
      port: port,
    ),
  );

  @override
  LanHostSource get socket => _socketDep.get;

  @override
  PastureLoopInteractor get loop => _loopDep.get;

  @override
  StateReadable<RoundState> get round => _roundDep.get;

  @override
  StateReadable<LobbyState> get lobby => _lobbyDep.get;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_flockDep, _dogsDep, _roundDep, _lobbyDep},
        {_socketDep},
        // Loop seeds the world and starts ticking; net binds the port and starts
        // streaming. Both depend on the managers above.
        {_loopDep, _netDep},
      ];
}

class ServerScopeHolder extends ScopeHolder<ServerScopeContainer> {
  ServerScopeHolder({required this.port});

  final int port;

  @override
  ServerScopeContainer createContainer() => ServerScopeContainer(port: port);
}
