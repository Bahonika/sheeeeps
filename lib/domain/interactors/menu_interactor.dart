import '../state_managers/nav_state_manager.dart';
import '../state_managers/player_identity_manager.dart';

/// 2nd-order coordinator for the main menu: sets the local player's name and
/// navigates into a session. Holds no state.
class MenuInteractor {
  MenuInteractor({
    required PlayerIdentityManager identity,
    required NavStateManager nav,
  })  : _identity = identity,
        _nav = nav;

  final PlayerIdentityManager _identity;
  final NavStateManager _nav;

  void setName(String name) => _identity.setName(name);

  void playSolo() => _nav.toSolo();
  void playPasture() => _nav.toPasture();
  void createRoom() => _nav.toHostSession();
  void openJoin() => _nav.toJoinBrowser();
  void backToMenu() => _nav.toMenu();
}
