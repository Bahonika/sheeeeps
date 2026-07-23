import 'package:freezed_annotation/freezed_annotation.dart';

part 'nav_state.freezed.dart';

/// Where the app currently is. The root widget mounts one screen per variant and
/// creates/drops the matching session child-scope. Host and client sessions
/// cover both their lobby and their in-game phase — the lobby's `started` flag
/// decides which is shown, so the scope survives the lobby→game transition.
@freezed
sealed class NavState with _$NavState {
  const factory NavState.menu() = NavMenu;
  const factory NavState.solo() = NavSolo;

  /// Stage 3: connected to the persistent public pasture (the web build's only
  /// in-game screen). The pasture client scope is created/dropped around it.
  const factory NavState.pasture() = NavPasture;
  const factory NavState.hostSession() = NavHostSession;
  const factory NavState.joinBrowser() = NavJoinBrowser;
  const factory NavState.clientSession({
    required String host,
    required int port,
  }) = NavClientSession;

  /// Terminal screen after a failed/ended network session (host quit, version
  /// mismatch, room full). Carries the message to show before returning to menu.
  const factory NavState.error({required String message}) = NavError;
}
