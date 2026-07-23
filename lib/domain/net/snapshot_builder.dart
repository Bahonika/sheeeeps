import 'dart:typed_data';

import '../state/dogs_state.dart';
import '../state/flock_state.dart';
import '../state/game_state.dart';
import '../state/round_state.dart';
import 'world_snapshot.dart';

/// Host-side mapping: fold the three authoritative states into one [WorldSnapshot]
/// ready for [NetCodec.encode]. Reads the flock SoA buffers directly (Domain), so
/// there is no intermediate per-sheep object.
WorldSnapshot buildWorldSnapshot(
  DogsState dogs,
  FlockState flock,
  GameState game,
) {
  final b = flock.buffers;
  final n = b.count;
  final sx = Float32List(n);
  final sy = Float32List(n);
  final st = Uint8List(n);
  for (var i = 0; i < n; i++) {
    sx[i] = b.x[i];
    sy[i] = b.y[i];
    st[i] = WorldSnapshot.packStatus(b.variant[i], b.phase[i]);
  }

  final dogSnaps = [
    for (final d in dogs.ordered)
      DogSnapshot(
        id: d.id,
        colorIndex: d.colorIndex,
        x: d.x,
        y: d.y,
        vx: d.vx,
        vy: d.vy,
        barkCooldownRemaining: d.barkCooldownRemaining,
        barkSeq: d.barkSeq,
      ),
  ];

  return WorldSnapshot(
    elapsed: game.elapsed,
    pennedCount: game.penned,
    sheepTotal: n,
    won: game.isWon,
    dogs: dogSnaps,
    sheepX: sx,
    sheepY: sy,
    sheepStatus: st,
  );
}

/// Server-side (Stage 3 pasture) mapping: fold the dogs, flock and round into one
/// [WorldSnapshot], attaching each shepherd's round score and asleep flag. Reads
/// the flock SoA buffers directly (Domain), no per-sheep object. [sleeping] is the
/// set of player ids the session interactor has marked AFK-asleep.
WorldSnapshot buildPastureSnapshot(
  DogsState dogs,
  FlockState flock,
  RoundState round,
  Set<int> sleeping,
) {
  final b = flock.buffers;
  final n = b.count;
  final sx = Float32List(n);
  final sy = Float32List(n);
  final st = Uint8List(n);
  for (var i = 0; i < n; i++) {
    sx[i] = b.x[i];
    sy[i] = b.y[i];
    st[i] = WorldSnapshot.packStatus(b.variant[i], b.phase[i]);
  }

  final celebrating = round.isCelebrating;
  final dogSnaps = [
    for (final d in dogs.ordered)
      DogSnapshot(
        id: d.id,
        colorIndex: d.colorIndex,
        x: d.x,
        y: d.y,
        vx: d.vx,
        vy: d.vy,
        barkCooldownRemaining: d.barkCooldownRemaining,
        barkSeq: d.barkSeq,
        flags: sleeping.contains(d.id) ? DogSnapshot.flagAsleep : 0,
        roundScore: round.scoreOf(d.id),
      ),
  ];

  return WorldSnapshot(
    elapsed: round.displayTime,
    pennedCount: round.penned,
    sheepTotal: n,
    won: celebrating,
    dogs: dogSnaps,
    sheepX: sx,
    sheepY: sy,
    sheepStatus: st,
    roundPhase: celebrating ? 1 : 0,
    celebrationRemaining:
        round is RoundCelebrating ? round.remaining : 0,
    dayRecordSeconds: round.dayRecordSeconds,
  );
}
