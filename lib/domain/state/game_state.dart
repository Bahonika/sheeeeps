import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

/// High-level run state. A sealed union: the level is either in progress or won.
///
/// Progress fields (penned / total / elapsed) ride on the `playing` variant so
/// the HUD reads one state, and `won` carries the final tally for the overlay.
@freezed
sealed class GameState with _$GameState {
  const GameState._();

  const factory GameState.playing({
    required int penned,
    required int total,
    required double elapsed,
  }) = GamePlaying;

  const factory GameState.won({
    required int total,
    required double elapsed,
  }) = GameWon;

  bool get isWon => this is GameWon;

  // `total` and `elapsed` are common to both variants, so Freezed exposes them
  // on the base already. Only `penned` needs mapping (a won run counts as all
  // sheep penned).
  int get penned => switch (this) {
        GamePlaying(:final penned) => penned,
        GameWon(:final total) => total,
      };
}
