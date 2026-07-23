import 'dart:typed_data';

/// Sheep fright phase (kept as a byte for cache-friendly bulk storage).
class SheepPhase {
  SheepPhase._();
  static const int calm = 0;
  static const int frightened = 1;
}

/// Structure-of-Arrays backing store for the whole flock.
///
/// This is the performance core: instead of 300+ heap objects mutated per
/// frame, every sheep attribute is a parallel typed array indexed by sheep id.
/// Stepping the simulation mutates these arrays in place — zero per-frame
/// allocation, cache-friendly, and directly consumable by `Canvas.drawAtlas`.
///
/// Architecture note: this mutable store is *owned by* `FlockStateManager` and
/// exposed only wrapped inside the immutable `FlockState` (whose `version`
/// changes each emission). It is the deliberate ECS-style reconciliation of the
/// "state lives in a StateManager" rule with a 300-agent 60-FPS budget. Nothing
/// outside the manager mutates it.
class FlockBuffers {
  int count = 0;

  late Float32List x;
  late Float32List y;
  late Float32List vx;
  late Float32List vy;

  /// Countdown timer whose meaning depends on [phase]:
  /// - calm: remaining time in the current walk/pause sub-state.
  /// - frightened: remaining calm-down time once out of flee range.
  late Float32List timer;

  /// Wander heading (unit vector) used while calm and walking.
  late Float32List wanderDx;
  late Float32List wanderDy;

  /// Fright "potency" in 0..1: how strongly this sheep can infect a calm
  /// neighbour by contact. Dog/bark fright seeds it at 1.0; each contagion hop
  /// decays it, so the panic chain fades instead of spreading forever.
  late Float32List potency;

  late Uint8List phase; // SheepPhase.*
  late Uint8List walking; // calm sub-state: 1 = strolling, 0 = grazing pause
  late Uint8List variant; // body-shade variant 0..n
  late Uint8List penned; // 1 = centre inside the pen area

  /// Player id of the shepherd whose dog last directly frightened this sheep
  /// (a bark or being in flee range), or -1 if none. When the sheep enters the
  /// pen this decides who is credited for it (TZ contribution scoring). Contagion
  /// (sheep-to-sheep panic) does NOT overwrite it — only a dog's own fright does.
  late Int16List lastFrighter;

  FlockBuffers();

  /// (Re)allocate all arrays for [n] sheep. Called on world seed / restart.
  void allocate(int n) {
    count = n;
    x = Float32List(n);
    y = Float32List(n);
    vx = Float32List(n);
    vy = Float32List(n);
    timer = Float32List(n);
    wanderDx = Float32List(n);
    wanderDy = Float32List(n);
    potency = Float32List(n);
    phase = Uint8List(n);
    walking = Uint8List(n);
    variant = Uint8List(n);
    penned = Uint8List(n);
    lastFrighter = Int16List(n)..fillRange(0, n, -1);
  }
}
