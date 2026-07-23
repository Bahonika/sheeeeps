import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/lan_discovery_source.dart';
import '../data/sources/lan_host_source.dart';
import '../data/sources/sprite_source.dart';
import '../domain/interactors/game_loop_interactor.dart';
import '../domain/interactors/host_net_interactor.dart';
import '../domain/interactors/input_interactor.dart';
import '../domain/interactors/local_session_controller.dart';
import '../domain/models/player_info.dart';
import '../domain/ports/game_ports.dart';
import '../domain/state/dogs_state.dart';
import '../domain/state/flock_state.dart';
import '../domain/state/game_state.dart';
import '../domain/state/lobby_state.dart';
import '../domain/state_managers/dogs_state_manager.dart';
import '../domain/state_managers/flock_state_manager.dart';
import '../domain/state_managers/game_state_manager.dart';
import '../domain/state_managers/lobby_state_manager.dart';
import 'app_scope.dart';
import 'game_session_scope.dart';

/// Host session: the same local simulation as solo, plus a WebSocket server,
/// UDP room announcements, and the [HostNetInteractor] that bridges clients into
/// the shared [InputInteractor]. The host plays through the local controller
/// exactly like solo — the network is layered on the side.
abstract interface class HostSessionScope implements GameSessionScope {
  HostNetInteractor get hostNetInteractor;
}

class HostSessionScopeContainer extends ChildScopeContainer<AppScopeContainer>
    implements HostSessionScope {
  HostSessionScopeContainer({required super.parent});

  static const int _hostId = 0;

  late final _lobbyDep = asyncDep(() {
    final name = parent.identityManager.state.name;
    return LobbyStateManager(
      LobbyState(
        roomName: 'Комната $name',
        localPlayerId: _hostId,
        players: [PlayerInfo(id: _hostId, name: name, colorIndex: 0)],
      ),
    );
  });

  late final _flockDep = asyncDep(() => FlockStateManager());
  late final _dogsDep = asyncDep(() => DogsStateManager());
  late final _gameDep = asyncDep(() => GameStateManager());

  late final _inputDep = dep(
    () => InputInteractor(dogs: _dogsDep.get, flock: _flockDep.get),
  );

  late final _gameLoopDep = asyncDep(
    () => GameLoopInteractor(
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      game: _gameDep.get,
      lobby: _lobbyDep.get,
    ),
  );

  late final _controllerDep = dep(
    () => LocalSessionController(
      input: _inputDep.get,
      loop: _gameLoopDep.get,
      localPlayerId: _hostId,
    ),
  );

  late final _hostSourceDep = asyncDep(() => LanHostSource());
  late final _announcerDep = asyncDep(() => LanDiscoverySource());

  late final _hostNetDep = asyncDep(
    () => HostNetInteractor(
      host: _hostSourceDep.get,
      announcer: _announcerDep.get,
      lobby: _lobbyDep.get,
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      game: _gameDep.get,
      input: _inputDep.get,
      loop: _gameLoopDep.get,
      nav: parent.navManager,
    ),
  );

  @override
  SpriteSource get spriteSource => parent.spriteSource;

  @override
  StateReadable<FlockState> get flockState => _flockDep.get;

  @override
  StateReadable<DogsState> get dogsState => _dogsDep.get;

  @override
  StateReadable<GameState> get gameState => _gameDep.get;

  @override
  StateReadable<LobbyState> get lobbyState => _lobbyDep.get;

  @override
  GameInputPort get inputPort => _controllerDep.get;

  @override
  GameTickPort get tickPort => _gameLoopDep.get;

  @override
  int get localPlayerId => _hostId;

  @override
  bool get canRestart => true;

  @override
  HostNetInteractor get hostNetInteractor => _hostNetDep.get;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_lobbyDep, _flockDep, _dogsDep, _gameDep},
        {_hostSourceDep, _announcerDep},
        {_gameLoopDep},
        {_hostNetDep},
      ];
}

class HostSessionScopeHolder
    extends ChildScopeHolder<HostSessionScopeContainer, AppScopeContainer> {
  HostSessionScopeHolder(super.parent);

  @override
  HostSessionScopeContainer createContainer(AppScopeContainer parent) =>
      HostSessionScopeContainer(parent: parent);
}
