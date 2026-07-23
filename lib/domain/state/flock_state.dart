import 'package:freezed_annotation/freezed_annotation.dart';

import '../simulation/flock_buffers.dart';

part 'flock_state.freezed.dart';

/// Immutable handle over the flock simulation.
///
/// The heavy per-sheep data lives in [buffers] (a stable, manager-owned SoA
/// store mutated in place). [version] is bumped on every step so `yx_state`
/// treats each frame as a new state and emits; equality short-circuits on the
/// identical [buffers] reference, so no 300-element list comparison runs.
@freezed
sealed class FlockState with _$FlockState {
  const FlockState._();

  const factory FlockState({
    required FlockBuffers buffers,
    required int version,
    required int pennedCount,
  }) = _FlockState;

  int get total => buffers.count;
}
