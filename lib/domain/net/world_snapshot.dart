import 'dart:typed_data';

/// One dog's networked state inside a [WorldSnapshot]. Identity beyond [id]/
/// [colorIndex] (the name) is taken from the lobby roster the client already
/// holds, so it is not repeated every snapshot.
class DogSnapshot {
  const DogSnapshot({
    required this.id,
    required this.colorIndex,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.barkCooldownRemaining,
    required this.barkSeq,
    this.flags = 0,
    this.roundScore = 0,
  });

  final int id;
  final int colorIndex;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double barkCooldownRemaining; // wired as one byte (fraction of cooldown)
  final int barkSeq; // wraps in a byte; clients only compare for inequality
  final int flags; // bit 0 = asleep (AFK), one byte on the wire
  final int roundScore; // sheep this shepherd penned this round (u16)

  static const int flagAsleep = 0x1;
  bool get isAsleep => (flags & flagAsleep) != 0;
}

/// A full host→client world frame: every dog and every sheep, plus the shared
/// scoreboard. Positions are the authoritative host values; the client
/// interpolates between consecutive snapshots for smooth motion at 15–20 Hz.
///
/// Sheep are stored Structure-of-Arrays exactly like the simulation buffers, so
/// decode writes straight into a client-side [FlockBuffers] with no per-sheep
/// allocation. [sheepStatus] packs `variant | phase<<2` per sheep.
class WorldSnapshot {
  WorldSnapshot({
    required this.elapsed,
    required this.pennedCount,
    required this.sheepTotal,
    required this.won,
    required this.dogs,
    required this.sheepX,
    required this.sheepY,
    required this.sheepStatus,
    this.roundPhase = 0,
    this.celebrationRemaining = 0,
    this.dayRecordSeconds = 0,
  });

  final double elapsed; // round timer while herding; frozen round time while celebrating
  final int pennedCount;
  final int sheepTotal;
  final bool won;
  final List<DogSnapshot> dogs;
  final Float32List sheepX;
  final Float32List sheepY;
  final Uint8List sheepStatus; // variant (bits 0-1) | phase (bit 2)

  // ── Stage 3 (pasture) round fields. LAN host leaves these at defaults. ──────
  final int roundPhase; // 0 herding, 1 celebrating
  final double celebrationRemaining; // seconds left in the celebration
  final double dayRecordSeconds; // best round time today (0 = none)

  static int packStatus(int variant, int phase) => (variant & 0x3) | (phase << 2);
  static int variantOf(int status) => status & 0x3;
  static int phaseOf(int status) => (status >> 2) & 0x1;
}
