import 'package:freezed_annotation/freezed_annotation.dart';

part 'round_state.freezed.dart';

/// The state of the persistent pasture's current round. A sealed union: the herd
/// is either being driven into the pen ([RoundHerding]) or the round has just
/// been completed and the world is celebrating before the gates reopen
/// ([RoundCelebrating]).
///
/// The round timer runs continuously (TZ: "Таймер раунда идёт всегда"); the
/// per-player [scores] tally (who penned how many this round) and the in-memory
/// [dayRecordSeconds] (best round time today, 0 = none yet) ride on every
/// variant so the HUD and scoreboard read one state.
@freezed
sealed class RoundState with _$RoundState {
  const RoundState._();

  const factory RoundState.herding({
    required double elapsed, // round timer (seconds), always counting up
    required int penned,
    required int total,
    required Map<int, int> scores, // playerId → sheep credited this round
    required double dayRecordSeconds,
  }) = RoundHerding;

  const factory RoundState.celebrating({
    required double roundTime, // final time of the round just completed
    required int total,
    required Map<int, int> scores,
    required double remaining, // celebration countdown (seconds)
    required double dayRecordSeconds,
  }) = RoundCelebrating;

  bool get isCelebrating => this is RoundCelebrating;

  int scoreOf(int playerId) => scores[playerId] ?? 0;

  /// The time shown on the HUD: the live timer while herding, the frozen round
  /// time during the celebration.
  double get displayTime => switch (this) {
        RoundHerding(:final elapsed) => elapsed,
        RoundCelebrating(:final roundTime) => roundTime,
      };

  int get penned => switch (this) {
        RoundHerding(:final penned) => penned,
        RoundCelebrating(:final total) => total,
      };
}
