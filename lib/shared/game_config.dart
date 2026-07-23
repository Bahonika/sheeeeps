import 'aabb.dart';

/// Single source of tuning constants for the whole game (TZ requirement).
///
/// Everything balanceable lives here: counts, speeds, radii, cooldowns,
/// steering forces, map/pen geometry. Pure Shared layer — no Flutter/Flame.
/// Domain reads these for the simulation; Presentation reads geometry to draw.
class GameConfig {
  GameConfig._();

  // ── World ────────────────────────────────────────────────────────────────
  /// Square logical world in pixels (letterboxed to the window by the camera).
  static const double worldSize = 1000.0;
  static const double wallThickness = 18.0;

  // ── Flock ────────────────────────────────────────────────────────────────
  static const int sheepCount = 300; // single-player baseline
  static const double sheepRadius = 5.0; // collision radius (sprite ~12px)
  static const int sheepVariants = 3; // body-shade variants

  /// Multiplayer flock size scales with the number of dogs: more shepherds make
  /// herding easier, so raise the head-count to keep it a challenge. Tuning
  /// constant per the TZ (base × factor × players), clamped so a solo start
  /// still reads as [sheepCount].
  static const double sheepPerPlayerFactor = 0.7;

  /// Sheep to spawn for a session of [players] shepherds (1 ⇒ [sheepCount]).
  static int sheepCountFor(int players) {
    if (players <= 1) return sheepCount;
    return (sheepCount * sheepPerPlayerFactor * players).round();
  }

  /// Deterministic seed so a restart is reproducible for tuning.
  static const int worldSeed = 1337;

  // Calm wandering.
  static const double calmSpeed = 24.0; // px/s while strolling
  static const double wanderMinWalk = 1.0; // s
  static const double wanderMaxWalk = 3.0; // s
  static const double wanderMinPause = 1.0; // s (grazing)
  static const double wanderMaxPause = 4.0; // s

  // Fright.
  static const double fleeRadius = 82.0; // dog nearer than this ⇒ fright
  static const double frightenedSpeed = 96.0; // max flee speed (px/s)
  static const double calmDownTime = 1.6; // s of decel after leaving fleeRadius

  // Fright contagion — panic spreads by physical contact (a frightened sheep
  // shoving a calm one), NOT by radius, so dense clumps stampede as one unit.
  // Each chain hop multiplies "potency" by [contagionDecay]; once it drops
  // below [contagionMinPotency] the sheep can no longer infect, so the wave
  // dies out instead of panicking the whole map.
  static const double directFrightPotency = 1.0; // dog/bark fright seeds the chain
  static const double contagionDecay = 0.6; // potency multiplier per hop
  static const double contagionMinPotency = 0.25; // below this: no further spread
  static const double contagionTimeFactor = 0.65; // infected fright vs direct duration
  static const double contagionSpeedFactor = 0.9; // infected flee speed vs frightenedSpeed
  static const double contagionAngleSpreadDeg = 22.0; // ± jitter around pusher's heading

  // Flocking (always on).
  static const double separationRadius = 13.0; // personal space
  static const double separationForce = 34.0;
  static const double cohesionRadius = 58.0; // gentle herd pull
  static const double cohesionForce = 6.0;
  static const double wallAvoidPushback = 1.0; // slide response strength

  /// Spatial-grid cell size. ≥ cohesionRadius so a 3×3 neighbourhood covers it.
  static const double gridCell = 58.0;

  // ── Dog ──────────────────────────────────────────────────────────────────
  static const double dogRadius = 7.0;
  static const double dogSpeed = 168.0; // well above frightenedSpeed
  static const double dogArriveEpsilon = 3.0; // stop when this close to target
  static const double dogStartX = worldSize / 2;
  static const double dogStartY = worldSize * 0.8; // lower field, clear of pen

  // ── Multiplayer ────────────────────────────────────────────────────────────
  static const int maxPlayers = 4;
  static const int dogColorCount = 16; // distinct hues (see GamePalette.dogColors)

  /// Spawn points for up to [maxPlayers] dogs, spread across the lower field so
  /// nobody overlaps at kickoff. Solo uses index 0 ([dogStartX], [dogStartY]).
  static List<(double, double)> get dogSpawns => const [
        (worldSize / 2, worldSize * 0.8),
        (worldSize * 0.30, worldSize * 0.85),
        (worldSize * 0.70, worldSize * 0.85),
        (worldSize * 0.50, worldSize * 0.90),
      ];

  // ── Network (LAN co-op) ─────────────────────────────────────────────────────
  /// Bumped whenever the wire protocol or snapshot layout changes. A client
  /// refuses to join a host whose version differs (clear error, no silent desync).
  /// v2 (Stage 3) added round phase, per-dog score/flags and the day record to
  /// the snapshot.
  static const int protocolVersion = 2;

  /// Host WebSocket (game traffic) and UDP (room discovery) ports.
  static const int gamePort = 7777;
  static const int discoveryPort = 7778;

  /// Snapshots per second the host streams to clients (TZ: 15–20 Hz).
  static const double snapshotHz = 20.0;
  static double get snapshotInterval => 1.0 / snapshotHz;

  /// UDP room announcements per second while a host sits in its lobby/game.
  static const double announceHz = 1.0;
  static double get announceInterval => 1.0 / announceHz;

  /// Client render delay: it plays [interpolationDelay] behind the newest
  /// snapshot so it always has two samples to interpolate between (≈ one and a
  /// half snapshot intervals of buffer against jitter).
  static double get interpolationDelay => snapshotInterval * 1.5;

  /// Drop a discovered room from the browser list if no UDP announce arrives
  /// within this window (host closed or moved out of range).
  static const double roomStaleTimeout = 3.0;

  // ── Pasture (Stage 3 — persistent online world) ────────────────────────────
  /// Herd size of the always-on public pasture (TZ: base 400–500, fixed — it does
  /// NOT scale with players like the LAN co-op flock).
  static const int pastureSheepCount = 450;

  /// One public room, up to 16 shepherds at once; 16 distinct dog colours.
  static const int maxPasturePlayers = 16;

  /// Celebration pause after the whole flock is penned before the gates open and
  /// a fresh round seeds (TZ: 10–15 s).
  static const double celebrationDuration = 12.0;

  /// AFK handling. A dog with no input for [afkSleepSeconds] falls asleep (zzz);
  /// after [afkKickSeconds] total it is disconnected, freeing its slot.
  static const double afkSleepSeconds = 180; // 3 min
  static const double afkKickSeconds = 600; // 10 min

  /// A dropped socket's dog lingers this long (standing still) before removal, so
  /// a quick reconnect isn't punished (TZ: "исчезает через 5 секунд").
  static const double disconnectGraceSeconds = 5.0;

  /// Server input rate-limit: commands beyond this per second per client are
  /// dropped (TZ устойчивость).
  static const int maxCommandsPerSecond = 20;

  /// Server simulation tick rate while ≥1 shepherd is present. With zero players
  /// the driver drops to [idleTickHz] (nobody to fear — accuracy is pointless,
  /// saves CPU) and instantly restores full rate when someone joins.
  static const int serverTickHz = 60;
  static const double idleTickHz = 2.0;
  static int get serverTickMillis => (1000 / serverTickHz).round();
  static int get idleTickMillis => (1000 / idleTickHz).round();

  /// The wss/ws URL the web client dials. Baked at build time with
  /// `--dart-define=PASTURE_URL=wss://your-host`. Defaults to a local dev server.
  static const String pastureServerUrl =
      String.fromEnvironment('PASTURE_URL', defaultValue: 'ws://localhost:8080');

  /// Default TCP port the headless server binds (overridable via the PORT env var
  /// in bin/server.dart). 8080 is the conventional free-tier container port.
  static const int serverPort = 8080;

  /// Spawn point for the [index]-th pasture shepherd — spread around the lower and
  /// side edges of the field (TZ: "у края карты"), away from the pen at the top so
  /// nobody lands inside it. Wraps after [maxPasturePlayers].
  static (double, double) edgeSpawn(int index) {
    final m = wallThickness + 30;
    final lo = m;
    final hi = worldSize - m;
    final i = index % maxPasturePlayers;
    if (i < 8) {
      // Bottom edge, left→right.
      final t = (i + 0.5) / 8;
      return (lo + (hi - lo) * t, hi);
    } else if (i < 12) {
      // Lower-left side, bottom→middle.
      final t = (i - 8 + 0.5) / 4;
      return (lo, hi - (hi - lo) * 0.45 * t);
    } else {
      // Lower-right side, bottom→middle.
      final t = (i - 12 + 0.5) / 4;
      return (hi, hi - (hi - lo) * 0.45 * t);
    }
  }

  // ── Bark ─────────────────────────────────────────────────────────────────
  static const double barkRadius = fleeRadius * 2.5; // ~205
  static const double barkCooldown = 1.75; // s
  static const double barkSpeedBoost = 1.35; // multiplier on frightenedSpeed
  static const double barkAngleSpreadDeg = 55.0; // ±spread on flee direction
  static const double barkRingDuration = 0.55; // s visual ring expansion

  // ── Rendering (world units; art tiles are 16px) ──────────────────────────
  static const double sheepSpriteScale = 1.0; // 16px tile → ~16 world px
  static const double dogSpriteScale = 1.45; // dog reads clearly larger
  static const double sheepAnimFpsCalm = 6.0;
  static const double sheepAnimFpsFright = 13.0;
  static const double dogAnimFps = 9.0;
  static const double moveAnimThreshold = 3.0; // speed below ⇒ standing frame

  // ── Win ──────────────────────────────────────────────────────────────────
  // A sheep is "penned" when its centre is inside [penArea].

  // ── Geometry helpers ─────────────────────────────────────────────────────

  /// Interior of the field (inside the border walls) — the roamable area.
  static Aabb get field => Aabb(
        wallThickness,
        wallThickness,
        worldSize - wallThickness,
        worldSize - wallThickness,
      );

  // Pen: near the top, offset right of centre. Entrance faces down (into field).
  static const double _penLeft = 470.0;
  static const double _penRight = 760.0;
  static const double _penTop = 95.0;
  static const double _penBottom = 275.0;
  static const double _penEntranceWidth = 62.0; // ~5 sheep bodies

  /// Region a sheep must be inside to count as penned (inner clear area).
  static Aabb get penArea => Aabb(
        _penLeft + wallThickness,
        _penTop + wallThickness,
        _penRight - wallThickness,
        _penBottom, // open bottom edge — the interior reaches the entrance line
      );

  /// Centre X of the pen entrance gap (for HUD / debug markers if needed).
  static double get penEntranceCenterX => (_penLeft + _penRight) / 2;

  /// All impassable wall rectangles: field border + pen (with a bottom gap).
  static List<Aabb> buildWalls() {
    const t = wallThickness;
    const w = worldSize;
    final walls = <Aabb>[
      // Field border.
      const Aabb(0, 0, w, t), // top
      const Aabb(0, w - t, w, w), // bottom
      const Aabb(0, 0, t, w), // left
      const Aabb(w - t, 0, w, w), // right

      // Pen: top, left, right.
      const Aabb(_penLeft, _penTop, _penRight, _penTop + t),
      const Aabb(_penLeft, _penTop, _penLeft + t, _penBottom),
      const Aabb(_penRight - t, _penTop, _penRight, _penBottom),
    ];

    // Pen bottom wall split into two segments around the centred entrance gap.
    final gapLeft = penEntranceCenterX - _penEntranceWidth / 2;
    final gapRight = penEntranceCenterX + _penEntranceWidth / 2;
    walls.add(Aabb(_penLeft, _penBottom - t, gapLeft, _penBottom));
    walls.add(Aabb(gapRight, _penBottom - t, _penRight, _penBottom));

    return walls;
  }
}
