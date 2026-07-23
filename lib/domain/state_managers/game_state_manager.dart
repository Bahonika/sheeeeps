import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../state/game_state.dart';

/// 1st-order owner of the run state. Accumulates the timer and flips to `won`
/// once the whole flock is inside the pen. The penned/total figures are fed in
/// by the coordinating interactor (derived from the flock state).
class GameStateManager extends StateManager<GameState>
    implements AsyncLifecycle {
  GameStateManager()
      : super(const GameState.playing(penned: 0, total: 0, elapsed: 0));

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Begin a fresh level with [total] sheep, none penned, timer at zero.
  Future<void> start(int total) => handle((emit) async {
        emit(GameState.playing(penned: 0, total: total, elapsed: 0));
      });

  /// Client mirror: adopt the host's authoritative scoreboard verbatim (no local
  /// timing). Used when applying a snapshot on a client.
  Future<void> mirror({
    required int penned,
    required int total,
    required double elapsed,
    required bool won,
  }) =>
      handle((emit) async {
        emit(won
            ? GameState.won(total: total, elapsed: elapsed)
            : GameState.playing(penned: penned, total: total, elapsed: elapsed));
      });

  /// Per-frame progress update. Advances the timer and declares victory when
  /// all sheep are penned. Ignored once already won.
  Future<void> tick(double dt, int penned, int total) => handle((emit) async {
        final s = state;
        if (s is! GamePlaying) return;
        final elapsed = s.elapsed + dt;
        if (total > 0 && penned >= total) {
          emit(GameState.won(total: total, elapsed: elapsed));
        } else {
          emit(GameState.playing(penned: penned, total: total, elapsed: elapsed));
        }
      });
}
