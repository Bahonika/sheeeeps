import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../shared/game_config.dart';
import '../state/round_state.dart';

/// 1st-order owner of the persistent pasture's round state. It advances the
/// round timer, flips to the celebration when the whole flock is penned, records
/// the day's best round time, tallies each shepherd's contribution, and runs the
/// celebration countdown. The coordinating [PastureLoopInteractor] feeds it the
/// penned count and credit events and reads back the phase to reseed the world.
///
/// On a web client this same manager is a passive mirror: [mirror] adopts the
/// host's authoritative round verbatim and the local methods are never called.
class RoundStateManager extends StateManager<RoundState>
    implements AsyncLifecycle {
  RoundStateManager()
      : super(const RoundState.herding(
          elapsed: 0,
          penned: 0,
          total: 0,
          scores: {},
          dayRecordSeconds: 0,
        ));

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Begin a fresh round with [total] sheep loose on the pasture: timer at zero,
  /// scores cleared. The day record carries over across rounds.
  Future<void> startRound(int total) => handle((emit) async {
        emit(RoundState.herding(
          elapsed: 0,
          penned: 0,
          total: total,
          scores: const {},
          dayRecordSeconds: state.dayRecordSeconds,
        ));
      });

  /// Per-frame progress while herding: advance the timer and, once every sheep is
  /// penned, flip to the celebration (recording a new day record if this round
  /// beat it). No-op once already celebrating.
  Future<void> tick(double dt, int penned) => handle((emit) async {
        final s = state;
        if (s is! RoundHerding) return;
        final elapsed = s.elapsed + dt;
        if (s.total > 0 && penned >= s.total) {
          final beatsRecord =
              s.dayRecordSeconds == 0 || elapsed < s.dayRecordSeconds;
          emit(RoundState.celebrating(
            roundTime: elapsed,
            total: s.total,
            scores: s.scores,
            remaining: GameConfig.celebrationDuration,
            dayRecordSeconds: beatsRecord ? elapsed : s.dayRecordSeconds,
          ));
        } else {
          emit(RoundState.herding(
            elapsed: elapsed,
            penned: penned,
            total: s.total,
            scores: s.scores,
            dayRecordSeconds: s.dayRecordSeconds,
          ));
        }
      });

  /// Credit [count] penned sheep to shepherd [playerId] (the dog that last
  /// frightened them). Only counts during the herding phase.
  Future<void> credit(int playerId, [int count = 1]) => handle((emit) async {
        final s = state;
        if (s is! RoundHerding) return;
        final scores = Map<int, int>.from(s.scores);
        scores[playerId] = (scores[playerId] ?? 0) + count;
        emit(s.copyWith(scores: scores));
      });

  /// Advance the celebration countdown. The loop reseeds once [RoundState] is
  /// celebrating with `remaining <= 0`.
  Future<void> tickCelebration(double dt) => handle((emit) async {
        final s = state;
        if (s is! RoundCelebrating) return;
        final remaining = s.remaining - dt;
        emit(s.copyWith(remaining: remaining < 0 ? 0 : remaining));
      });

  /// Client mirror: adopt the host's authoritative round from a snapshot.
  Future<void> mirror({
    required int phase, // 0 herding, 1 celebrating
    required double timer, // elapsed while herding, round time while celebrating
    required int penned,
    required int total,
    required Map<int, int> scores,
    required double celebrationRemaining,
    required double dayRecordSeconds,
  }) =>
      handle((emit) async {
        emit(phase == 1
            ? RoundState.celebrating(
                roundTime: timer,
                total: total,
                scores: scores,
                remaining: celebrationRemaining,
                dayRecordSeconds: dayRecordSeconds,
              )
            : RoundState.herding(
                elapsed: timer,
                penned: penned,
                total: total,
                scores: scores,
                dayRecordSeconds: dayRecordSeconds,
              ));
      });
}
