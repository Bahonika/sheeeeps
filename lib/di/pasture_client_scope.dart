import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/pasture_client_source.dart';
import '../data/sources/sprite_source.dart';
import '../domain/interactors/pasture_client_net_interactor.dart';
import '../domain/ports/game_ports.dart';
import '../domain/state/dogs_state.dart';
import '../domain/state/flock_state.dart';
import '../domain/state/lobby_state.dart';
import '../domain/state/round_state.dart';
import '../domain/state_managers/dogs_state_manager.dart';
import '../domain/state_managers/flock_state_manager.dart';
import '../domain/state_managers/lobby_state_manager.dart';
import '../domain/state_managers/round_state_manager.dart';
import '../shared/game_config.dart';
import 'app_scope.dart';

/// The web client's session scope for the persistent pasture. It wires passive
/// mirror managers (flock/dogs/lobby/round — never stepped locally) fed by the
/// [PastureClientNetInteractor], which is both the view's input and tick port.
/// The interactor dials the single fixed server URL ([GameConfig.pastureServerUrl],
/// baked at build time). Sprites come from the always-alive [AppScope].
abstract interface class PastureClientScope {
  SpriteSource get spriteSource;
  StateReadable<FlockState> get flockState;
  StateReadable<DogsState> get dogsState;
  StateReadable<LobbyState> get lobbyState;
  StateReadable<RoundState> get roundState;
  GameInputPort get inputPort;
  GameTickPort get tickPort;
  int get localPlayerId;
}

class PastureClientScopeContainer extends ChildScopeContainer<AppScopeContainer>
    implements PastureClientScope {
  PastureClientScopeContainer({required super.parent});

  late final _lobbyDep = asyncDep(
    () => LobbyStateManager(const LobbyState(
      roomName: 'Пастбище',
      localPlayerId: -1, // assigned by the server on welcome
      players: [],
      started: true,
      maxPlayers: GameConfig.maxPasturePlayers,
    )),
  );

  late final _flockDep = asyncDep(() => FlockStateManager());
  late final _dogsDep = asyncDep(() => DogsStateManager());
  late final _roundDep = asyncDep(() => RoundStateManager());

  late final _sourceDep = asyncDep(() => PastureClientSource());

  late final _netDep = asyncDep(
    () => PastureClientNetInteractor(
      client: _sourceDep.get,
      lobby: _lobbyDep.get,
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      round: _roundDep.get,
      nav: parent.navManager,
      playerName: parent.identityManager.state.name,
      url: GameConfig.pastureServerUrl,
    ),
  );

  @override
  SpriteSource get spriteSource => parent.spriteSource;

  @override
  StateReadable<FlockState> get flockState => _flockDep.get;

  @override
  StateReadable<DogsState> get dogsState => _dogsDep.get;

  @override
  StateReadable<LobbyState> get lobbyState => _lobbyDep.get;

  @override
  StateReadable<RoundState> get roundState => _roundDep.get;

  @override
  GameInputPort get inputPort => _netDep.get;

  @override
  GameTickPort get tickPort => _netDep.get;

  @override
  int get localPlayerId => _lobbyDep.get.state.localPlayerId;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_lobbyDep, _flockDep, _dogsDep, _roundDep},
        {_sourceDep},
        {_netDep},
      ];
}

class PastureClientScopeHolder
    extends ChildScopeHolder<PastureClientScopeContainer, AppScopeContainer> {
  PastureClientScopeHolder(super.parent);

  @override
  PastureClientScopeContainer createContainer(AppScopeContainer parent) =>
      PastureClientScopeContainer(parent: parent);
}
