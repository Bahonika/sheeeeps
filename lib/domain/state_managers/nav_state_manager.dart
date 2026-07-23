import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../state/nav_state.dart';

/// 1st-order owner of the current screen. Menu/session interactors and the net
/// interactors (on host-quit / reject) drive it; the root widget renders it.
class NavStateManager extends StateManager<NavState>
    implements AsyncLifecycle {
  NavStateManager() : super(const NavState.menu());

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  Future<void> toMenu() => _set(const NavState.menu());
  Future<void> toSolo() => _set(const NavState.solo());
  Future<void> toPasture() => _set(const NavState.pasture());
  Future<void> toHostSession() => _set(const NavState.hostSession());
  Future<void> toJoinBrowser() => _set(const NavState.joinBrowser());

  Future<void> toClientSession(String host, int port) =>
      _set(NavState.clientSession(host: host, port: port));

  Future<void> toError(String message) =>
      _set(NavState.error(message: message));

  Future<void> _set(NavState next) => handle((emit) async => emit(next));
}
