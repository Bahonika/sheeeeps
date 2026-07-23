import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/name_store.dart';
import '../data/sources/sprite_source.dart';
import '../domain/interactors/menu_interactor.dart';
import '../domain/state/nav_state.dart';
import '../domain/state/player_identity_state.dart';
import '../domain/state_managers/nav_state_manager.dart';
import '../domain/state_managers/player_identity_manager.dart';

/// The always-alive application scope. It owns what outlives any single session:
/// the generated sprite atlases (built once, reused by every session), the local
/// player's name, and the navigation state. Session child-scopes hang off it.
abstract interface class AppScope {
  SpriteSource get spriteSource;
  StateReadable<NavState> get navState;
  StateReadable<PlayerIdentityState> get identityState;
  MenuInteractor get menuInteractor;

  // Exposed to child session scopes (which read identity and drive navigation).
  NavStateManager get navManager;
  PlayerIdentityManager get identityManager;
}

class AppScopeContainer extends ScopeContainer implements AppScope {
  late final _spriteSourceDep = asyncDep(() => SpriteSource());

  late final _identityDep = asyncDep(
    () => PlayerIdentityManager(
      const PlayerIdentityState(name: 'Пастух'),
      store: NameStore(),
    ),
  );

  late final _navDep = asyncDep(() => NavStateManager());

  late final _menuDep = dep(
    () => MenuInteractor(identity: _identityDep.get, nav: _navDep.get),
  );

  @override
  SpriteSource get spriteSource => _spriteSourceDep.get;

  @override
  StateReadable<NavState> get navState => _navDep.get;

  @override
  StateReadable<PlayerIdentityState> get identityState => _identityDep.get;

  @override
  MenuInteractor get menuInteractor => _menuDep.get;

  @override
  NavStateManager get navManager => _navDep.get;

  @override
  PlayerIdentityManager get identityManager => _identityDep.get;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_spriteSourceDep, _identityDep, _navDep},
      ];
}

class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
