import 'dart:math' as math;
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../shared/aabb.dart';
import '../../shared/game_config.dart';
import '../simulation/collision.dart';
import '../simulation/flock_buffers.dart';
import '../simulation/spatial_grid.dart';
import '../state/flock_state.dart';

/// 1st-order owner of the flock. Holds the SoA buffers and advances every
/// sheep's steering, separation, fright and wall-sliding each tick.
///
/// It never reads another StateManager: the dog position and bark are passed in
/// as plain values by the coordinating interactor, keeping this manager's logic
/// confined to the single state it owns.
class FlockStateManager extends StateManager<FlockState>
    implements AsyncLifecycle {
  FlockStateManager()
      : _buffers = FlockBuffers(),
        _grid = SpatialGrid(
          worldSize: GameConfig.worldSize,
          cellSize: GameConfig.gridCell,
        ),
        _walls = GameConfig.buildWalls(),
        super(FlockState(
          buffers: FlockBuffers(),
          version: 0,
          pennedCount: 0,
        ));

  final FlockBuffers _buffers;
  final SpatialGrid _grid;
  final List<Aabb> _walls;
  int _version = 0;
  math.Random _random = math.Random(GameConfig.worldSeed);

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Seed (or reseed) the flock: scatter [count] sheep across the open field,
  /// away from the pen. Deterministic for reproducible tuning. [count] varies
  /// with the number of shepherds (see [GameConfig.sheepCountFor]).
  Future<void> spawn(int count) => handle((emit) async {
        _random = math.Random(GameConfig.worldSeed);
        final n = count;
        _buffers.allocate(n);
        final field = GameConfig.field;
        final pen = GameConfig.penArea;
        for (var i = 0; i < n; i++) {
          double px, py;
          // Reject positions inside the pen so sheep start out on the field.
          do {
            px = field.left + _random.nextDouble() * field.width;
            py = field.top + _random.nextDouble() * field.height;
          } while (pen.contains(px, py));
          _buffers.x[i] = px;
          _buffers.y[i] = py;
          _buffers.vx[i] = 0;
          _buffers.vy[i] = 0;
          _buffers.phase[i] = SheepPhase.calm;
          _buffers.walking[i] = _random.nextBool() ? 1 : 0;
          _buffers.timer[i] = _randWander(_buffers.walking[i] == 1);
          _buffers.variant[i] = _random.nextInt(GameConfig.sheepVariants);
          final a = _random.nextDouble() * math.pi * 2;
          _buffers.wanderDx[i] = math.cos(a);
          _buffers.wanderDy[i] = math.sin(a);
          _buffers.potency[i] = 0;
          _buffers.penned[i] = 0;
        }
        emit(FlockState(buffers: _buffers, version: ++_version, pennedCount: 0));
      });

  /// Explosive bark: every sheep within [GameConfig.barkRadius] is thrown into
  /// fright, fleeing away from ([cx], [cy]) with a large random angular spread
  /// so the herd bursts apart chaotically. [barkerId] is the barking shepherd's
  /// player id — recorded as each affected sheep's last frighter for scoring.
  Future<void> applyBark(double cx, double cy, int barkerId) =>
      handle((emit) async {
        final r2 = GameConfig.barkRadius * GameConfig.barkRadius;
        final spread = GameConfig.barkAngleSpreadDeg * math.pi / 180;
        final speed = GameConfig.frightenedSpeed * GameConfig.barkSpeedBoost;
        for (var i = 0; i < _buffers.count; i++) {
          final dx = _buffers.x[i] - cx;
          final dy = _buffers.y[i] - cy;
          final d2 = dx * dx + dy * dy;
          if (d2 > r2) continue;
          final d = math.sqrt(d2);
          double dirX, dirY;
          if (d > 1e-4) {
            dirX = dx / d;
            dirY = dy / d;
          } else {
            final a = _random.nextDouble() * math.pi * 2;
            dirX = math.cos(a);
            dirY = math.sin(a);
          }
          final jitter = (_random.nextDouble() * 2 - 1) * spread;
          final ca = math.cos(jitter);
          final sa = math.sin(jitter);
          final rx = dirX * ca - dirY * sa;
          final ry = dirX * sa + dirY * ca;
          _buffers.phase[i] = SheepPhase.frightened;
          _buffers.timer[i] = GameConfig.calmDownTime;
          _buffers.vx[i] = rx * speed;
          _buffers.vy[i] = ry * speed;
          _buffers.potency[i] = GameConfig.directFrightPotency; // seeds contact chain
          _buffers.lastFrighter[i] = barkerId; // credit the barking shepherd
        }
        emit(FlockState(
          buffers: _buffers,
          version: ++_version,
          pennedCount: state.pennedCount,
        ));
      });

  /// Client mirror: overwrite the flock with network-authoritative, already
  /// interpolated per-sheep data. No simulation runs — the host is the source of
  /// truth. Velocities are the interpolation deltas so facing/walk animation
  /// still reads correctly. Reallocates if the head-count changed (match start).
  Future<void> applyNetwork({
    required int count,
    required Float32List x,
    required Float32List y,
    required Float32List vx,
    required Float32List vy,
    required Uint8List phase,
    required Uint8List variant,
  }) =>
      handle((emit) async {
        final b = _buffers;
        if (b.count != count) b.allocate(count);
        for (var i = 0; i < count; i++) {
          b.x[i] = x[i];
          b.y[i] = y[i];
          b.vx[i] = vx[i];
          b.vy[i] = vy[i];
          b.phase[i] = phase[i];
          b.variant[i] = variant[i];
        }
        emit(FlockState(buffers: b, version: ++_version, pennedCount: 0));
      });

  /// Advance the whole flock by [dt]. Every dog is a threat: a sheep flees the
  /// weighted sum of the dogs within [GameConfig.fleeRadius], each weighted by
  /// how close it is, so several shepherds converging push harder and from the
  /// combined direction. [dogXs]/[dogYs] are parallel, one entry per live dog
  /// (may be empty on a dogless frame). With a single dog this reduces exactly
  /// to the old flee-from-one behaviour. [dogIds] is parallel to [dogXs]/[dogYs]
  /// (the owning player id of each dog) so a directly-frightened sheep records
  /// the nearest dog's shepherd as its last frighter for contribution scoring.
  Future<void> step(
    double dt,
    List<double> dogXs,
    List<double> dogYs,
    List<int> dogIds,
  ) =>
      handle((emit) async {
        final b = _buffers;
        final n = b.count;
        if (n == 0) return;

        final dogCount = dogXs.length;
        _grid.rebuild(b.x, b.y, n);

        final fleeR = GameConfig.fleeRadius;
        final fleeR2 = fleeR * fleeR;
        final sepR = GameConfig.separationRadius;
        final sepR2 = sepR * sepR;
        final cohR = GameConfig.cohesionRadius;
        final cohR2 = cohR * cohR;

        var penned = 0;

        for (var i = 0; i < n; i++) {
          final x = b.x[i];
          final y = b.y[i];

          // ── Neighbour scan (3×3 grid block): separation + cohesion + the
          //    most potent frightened sheep actually touching us (contagion). ─
          var sepX = 0.0, sepY = 0.0;
          var cohX = 0.0, cohY = 0.0, cohCount = 0;
          var infPot = 0.0, infVx = 0.0, infVy = 0.0; // best infector on contact
          final col = _grid.colOf(x);
          final row = _grid.rowOf(y);
          for (var gy = row - 1; gy <= row + 1; gy++) {
            if (gy < 0 || gy >= _grid.rows) continue;
            for (var gx = col - 1; gx <= col + 1; gx++) {
              if (gx < 0 || gx >= _grid.cols) continue;
              final s = _grid.startOf(gx, gy);
              final e = _grid.endOf(gx, gy);
              for (var k = s; k < e; k++) {
                final j = _grid.sorted[k];
                if (j == i) continue;
                final dx = x - b.x[j];
                final dy = y - b.y[j];
                final d2 = dx * dx + dy * dy;
                if (d2 < sepR2 && d2 > 1e-6) {
                  final d = math.sqrt(d2);
                  final push = (sepR - d) / sepR; // 0..1, stronger when closer
                  sepX += dx / d * push;
                  sepY += dy / d * push;
                  // Contact = separation fired: a frightened neighbour can
                  // infect us. Keep the most potent one to carry its heading.
                  if (b.phase[j] == SheepPhase.frightened &&
                      b.potency[j] > infPot) {
                    infPot = b.potency[j];
                    infVx = b.vx[j];
                    infVy = b.vy[j];
                  }
                }
                if (d2 < cohR2) {
                  cohX += b.x[j];
                  cohY += b.y[j];
                  cohCount++;
                }
              }
            }
          }

          // ── Dog fright (weighted sum over every nearby dog) ────────────────
          // Accumulate a threat vector pointing away from each dog in range,
          // each contribution weighted by proximity; the closest dog also sets
          // the flee speed. One dog ⇒ identical to the old single-threat flee.
          var threatX = 0.0, threatY = 0.0, maxProximity = 0.0;
          var closestDog = -1;
          for (var d = 0; d < dogCount; d++) {
            final ddx = x - dogXs[d];
            final ddy = y - dogYs[d];
            final dd2 = ddx * ddx + ddy * ddy;
            if (dd2 >= fleeR2) continue;
            final dist = math.sqrt(dd2);
            final proximity = 1 - dist / fleeR; // 0..1
            double nx, ny;
            if (dist > 1e-4) {
              nx = ddx / dist;
              ny = ddy / dist;
            } else {
              final a = _random.nextDouble() * math.pi * 2;
              nx = math.cos(a);
              ny = math.sin(a);
            }
            threatX += nx * proximity;
            threatY += ny * proximity;
            if (proximity > maxProximity) {
              maxProximity = proximity;
              closestDog = d;
            }
          }
          final threatMag2 = threatX * threatX + threatY * threatY;

          double vx = b.vx[i];
          double vy = b.vy[i];

          if (threatMag2 > 1e-8) {
            // Within fear range of ≥1 dog: flee the combined direction, speed
            // scaled by the nearest dog's proximity.
            final tl = math.sqrt(threatMag2);
            final speed =
                GameConfig.frightenedSpeed * (0.45 + 0.55 * maxProximity);
            vx = threatX / tl * speed;
            vy = threatY / tl * speed;
            b.phase[i] = SheepPhase.frightened;
            b.timer[i] = GameConfig.calmDownTime;
            b.potency[i] = GameConfig.directFrightPotency; // dog fright wins, reseeds
            if (closestDog >= 0) b.lastFrighter[i] = dogIds[closestDog];
          } else if (b.phase[i] == SheepPhase.frightened) {
            // Out of range: coast in the current heading and decelerate.
            b.timer[i] -= dt;
            final decay = (b.timer[i] / GameConfig.calmDownTime).clamp(0.0, 1.0);
            vx *= 0.90 + 0.10 * decay;
            vy *= 0.90 + 0.10 * decay;
            if (b.timer[i] <= 0) {
              b.phase[i] = SheepPhase.calm;
              b.walking[i] = 1;
              b.timer[i] = _randWander(true);
              b.potency[i] = 0; // calmed down: no longer infectious
            }
          } else if ((infPot * GameConfig.contagionDecay) >=
                  GameConfig.contagionMinPotency &&
              (infVx * infVx + infVy * infVy) > 1e-4) {
            // ── Caught panic by contact ───────────────────────────────────
            // A frightened neighbour shoved us: run roughly the way it runs
            // (its heading ± a small random spread), not away from the dog.
            // Potency decays each hop so the chain fades out.
            final il = math.sqrt(infVx * infVx + infVy * infVy);
            final dirX = infVx / il;
            final dirY = infVy / il;
            final spread = GameConfig.contagionAngleSpreadDeg * math.pi / 180;
            final jitter = (_random.nextDouble() * 2 - 1) * spread;
            final ca = math.cos(jitter);
            final sa = math.sin(jitter);
            final speed =
                GameConfig.frightenedSpeed * GameConfig.contagionSpeedFactor;
            vx = (dirX * ca - dirY * sa) * speed;
            vy = (dirX * sa + dirY * ca) * speed;
            b.phase[i] = SheepPhase.frightened;
            b.timer[i] = GameConfig.calmDownTime * GameConfig.contagionTimeFactor;
            b.potency[i] = infPot * GameConfig.contagionDecay;
          } else {
            // ── Calm wandering ────────────────────────────────────────────
            b.timer[i] -= dt;
            if (b.timer[i] <= 0) {
              if (b.walking[i] == 1) {
                b.walking[i] = 0; // begin grazing pause
                b.timer[i] = _randWander(false);
              } else {
                b.walking[i] = 1; // pick a new heading and stroll
                b.timer[i] = _randWander(true);
                final a = _random.nextDouble() * math.pi * 2;
                b.wanderDx[i] = math.cos(a);
                b.wanderDy[i] = math.sin(a);
              }
            }
            if (b.walking[i] == 1) {
              vx = b.wanderDx[i] * GameConfig.calmSpeed;
              vy = b.wanderDy[i] * GameConfig.calmSpeed;
            } else {
              vx = 0;
              vy = 0;
            }
            // Gentle cohesion toward local herd centre.
            if (cohCount > 0) {
              final tx = cohX / cohCount - x;
              final ty = cohY / cohCount - y;
              final tl = math.sqrt(tx * tx + ty * ty);
              if (tl > 1e-3) {
                vx += tx / tl * GameConfig.cohesionForce;
                vy += ty / tl * GameConfig.cohesionForce;
              }
            }
          }

          // ── Separation always applies (physical personal space) ──────────
          vx += sepX * GameConfig.separationForce;
          vy += sepY * GameConfig.separationForce;

          // Integrate and resolve against walls (slide, never penetrate).
          b.x[i] = x + vx * dt;
          b.y[i] = y + vy * dt;
          Collision.resolveSheep(b, i, GameConfig.sheepRadius, _walls);
          b.vx[i] = vx;
          b.vy[i] = vy;

          if (GameConfig.penArea.contains(b.x[i], b.y[i])) {
            b.penned[i] = 1;
            penned++;
          } else {
            b.penned[i] = 0;
          }
        }

        emit(FlockState(
          buffers: b,
          version: ++_version,
          pennedCount: penned,
        ));
      });

  double _randWander(bool walking) {
    if (walking) {
      return GameConfig.wanderMinWalk +
          _random.nextDouble() *
              (GameConfig.wanderMaxWalk - GameConfig.wanderMinWalk);
    }
    return GameConfig.wanderMinPause +
        _random.nextDouble() *
            (GameConfig.wanderMaxPause - GameConfig.wanderMinPause);
  }
}
