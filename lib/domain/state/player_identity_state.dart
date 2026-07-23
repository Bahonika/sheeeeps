import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_identity_state.freezed.dart';

/// The local player's chosen display name, entered once on the main menu and
/// reused for solo, hosting and joining (TZ: name set once).
@freezed
sealed class PlayerIdentityState with _$PlayerIdentityState {
  const factory PlayerIdentityState({required String name}) =
      _PlayerIdentityState;
}
