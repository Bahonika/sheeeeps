import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/lan_client_source.dart';
import '../data/sources/sprite_source.dart';
import '../domain/interactors/client_net_interactor.dart';
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

/// Client session: the same managers as solo/host, but as passive mirrors — they
/// are never stepped. The [ClientNetInteractor] connects to the host, applies
/// interpolated snapshots into them, and doubles as both the tick port
/// (interpolation) and input port (commands sent to the host).
class ClientSessionScopeContainer extends ChildScopeContainer<AppScopeContainer>
    implements GameSessionScope {
  ClientSessionScopeContainer({
    required super.parent,
    required this.host,
    required this.port,
  });

  final String host;
  final int port;

  late final _lobbyDep = asyncDep(
    () => LobbyStateManager(
      const LobbyState(
        roomName: 'Подключение…',
        localPlayerId: -1,
        players: [],
      ),
    ),
  );

  late final _flockDep = asyncDep(() => FlockStateManager());
  late final _dogsDep = asyncDep(() => DogsStateManager());
  late final _gameDep = asyncDep(() => GameStateManager());

  late final _clientSourceDep = asyncDep(() => LanClientSource());

  late final _clientNetDep = asyncDep(
    () => ClientNetInteractor(
      client: _clientSourceDep.get,
      lobby: _lobbyDep.get,
      dogs: _dogsDep.get,
      flock: _flockDep.get,
      game: _gameDep.get,
      nav: parent.navManager,
      playerName: parent.identityManager.state.name,
      host: host,
      port: port,
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
  GameInputPort get inputPort => _clientNetDep.get;

  @override
  GameTickPort get tickPort => _clientNetDep.get;

  /// The host assigns our id after the handshake; the lobby mirror holds it.
  @override
  int get localPlayerId => _lobbyDep.get.state.localPlayerId;

  @override
  bool get canRestart => false;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_lobbyDep, _flockDep, _dogsDep, _gameDep},
        {_clientSourceDep},
        {_clientNetDep},
      ];
}

class ClientSessionScopeHolder
    extends ChildScopeHolder<ClientSessionScopeContainer, AppScopeContainer> {
  ClientSessionScopeHolder(super.parent, {required this.host, required this.port});

  final String host;
  final int port;

  @override
  ClientSessionScopeContainer createContainer(AppScopeContainer parent) =>
      ClientSessionScopeContainer(parent: parent, host: host, port: port);
}
