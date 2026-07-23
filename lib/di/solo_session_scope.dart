import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/sprite_source.dart';
import '../domain/interactors/game_loop_interactor.dart';
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

/// Single-player session: one dog, local simulation, no networking. The lobby is
/// seeded with just the local player (using the menu-chosen name) so the shared
/// [GameLoopInteractor] seeding path is identical to a host game.
class SoloSessionScopeContainer extends ChildScopeContainer<AppScopeContainer>
    implements GameSessionScope {
  SoloSessionScopeContainer({required super.parent});

  static const int _localId = 0;

  late final _lobbyDep = asyncDep(
    () => LobbyStateManager(
      LobbyState(
        roomName: 'Одиночная игра',
        localPlayerId: _localId,
        players: [
          PlayerInfo(
            id: _localId,
            name: parent.identityManager.state.name,
            colorIndex: 0,
          ),
        ],
        started: true,
      ),
    ),
  );

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
      localPlayerId: _localId,
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
  int get localPlayerId => _localId;

  @override
  bool get canRestart => true;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_lobbyDep, _flockDep, _dogsDep, _gameDep},
        {_gameLoopDep},
      ];
}

class SoloSessionScopeHolder
    extends ChildScopeHolder<SoloSessionScopeContainer, AppScopeContainer> {
  SoloSessionScopeHolder(super.parent);

  @override
  SoloSessionScopeContainer createContainer(AppScopeContainer parent) =>
      SoloSessionScopeContainer(parent: parent);
}
