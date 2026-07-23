import 'package:freezed_annotation/freezed_annotation.dart';

part 'dog_state.freezed.dart';

/// State of a single shepherd dog. Up to four exist at once (one per player), so
/// each is a plain scalar record with per-frame `copyWith` — cheap at this count,
/// unlike the flock which needs SoA buffers.
///
/// Identity ([id], [name], [colorIndex]) rides alongside the kinematics so the
/// presentation can draw a named, palette-coloured dog straight from the state,
/// and so a network snapshot carries everything a client needs per dog.
@freezed
sealed class DogState with _$DogState {
  const DogState._();

  const factory DogState({
    required int id,
    required String name,
    required int colorIndex,
    required double x,
    required double y,
    required double targetX,
    required double targetY,
    required bool hasTarget,
    required double vx,
    required double vy,
    required double barkCooldownRemaining,

    /// Monotonic counter incremented on every successful bark. Presentation
    /// watches it to spawn a one-shot expanding-ring effect (reactive trigger),
    /// keeping ring animation out of the domain.
    required int barkSeq,

    /// AFK: the shepherd hasn't given input for a while, so the dog is asleep
    /// (drawn with a "zzz" marker). Only ever set on the pasture client mirror.
    @Default(false) bool asleep,
  }) = _DogState;

  bool get canBark => barkCooldownRemaining <= 0;
  bool get isMoving => vx != 0 || vy != 0;

  /// A fresh dog for [player] parked at ([x], [y]) with a ready bark.
  static DogState spawn({
    required int id,
    required String name,
    required int colorIndex,
    required double x,
    required double y,
  }) =>
      DogState(
        id: id,
        name: name,
        colorIndex: colorIndex,
        x: x,
        y: y,
        targetX: x,
        targetY: y,
        hasTarget: false,
        vx: 0,
        vy: 0,
        barkCooldownRemaining: 0,
        barkSeq: 0,
      );
}
