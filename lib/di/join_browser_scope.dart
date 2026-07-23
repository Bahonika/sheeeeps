import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../data/sources/lan_discovery_source.dart';
import '../domain/interactors/room_browser_interactor.dart';
import '../domain/state/browser_state.dart';
import '../domain/state_managers/browser_state_manager.dart';
import 'app_scope.dart';

/// The "Join" screen scope: a UDP browser listening for room announcements. It
/// lives only while the join screen is open, so the discovery socket is bound
/// exactly when needed and released on leave.
abstract interface class JoinBrowserScope {
  StateReadable<BrowserState> get browserState;
  RoomBrowserInteractor get roomBrowserInteractor;
}

class JoinBrowserScopeContainer extends ChildScopeContainer<AppScopeContainer>
    implements JoinBrowserScope {
  JoinBrowserScopeContainer({required super.parent});

  late final _discoveryDep = asyncDep(() => LanDiscoverySource());
  late final _browserDep = asyncDep(() => BrowserStateManager());

  late final _interactorDep = asyncDep(
    () => RoomBrowserInteractor(
      discovery: _discoveryDep.get,
      browser: _browserDep.get,
      nav: parent.navManager,
    ),
  );

  @override
  StateReadable<BrowserState> get browserState => _browserDep.get;

  @override
  RoomBrowserInteractor get roomBrowserInteractor => _interactorDep.get;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_discoveryDep, _browserDep},
        {_interactorDep},
      ];
}

class JoinBrowserScopeHolder
    extends ChildScopeHolder<JoinBrowserScopeContainer, AppScopeContainer> {
  JoinBrowserScopeHolder(super.parent);

  @override
  JoinBrowserScopeContainer createContainer(AppScopeContainer parent) =>
      JoinBrowserScopeContainer(parent: parent);
}
