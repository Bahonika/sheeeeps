import 'dart:math' as math;

import '../../shared/aabb.dart';
import 'flock_buffers.dart';

/// Circle-vs-AABB collision resolution shared by sheep and dog.
///
/// Pure Domain math (`dart:math` is a pure core library, allowed here): pushes
/// an overlapping circle out along its axis of least penetration, which yields
/// natural wall-sliding — movement along one axis is preserved while the blocked
/// axis is clamped. Guarantees no agent ends up inside a wall, even when
/// squeezed against a corner by a crowd.
class Collision {
  Collision._();

  /// Resolve one wall against a circle centre. Returns the corrected centre.
  static ({double x, double y}) _pushOut(double x, double y, double r, Aabb w) {
    // Closest point on the box to the circle centre.
    final cx = x < w.left ? w.left : (x > w.right ? w.right : x);
    final cy = y < w.top ? w.top : (y > w.bottom ? w.bottom : y);
    final dx = x - cx;
    final dy = y - cy;
    final d2 = dx * dx + dy * dy;

    if (d2 > r * r) return (x: x, y: y); // no overlap

    if (d2 > 1e-6) {
      // Centre outside the box: push out along the contact normal.
      final d = math.sqrt(d2);
      final push = r - d;
      return (x: x + dx / d * push, y: y + dy / d * push);
    }

    // Centre inside the box: eject along the least-penetration axis.
    final toLeft = x - w.left;
    final toRight = w.right - x;
    final toTop = y - w.top;
    final toBottom = w.bottom - y;
    final ejectX = toLeft < toRight ? -(toLeft + r) : (toRight + r);
    final ejectY = toTop < toBottom ? -(toTop + r) : (toBottom + r);
    if (ejectX.abs() < ejectY.abs()) return (x: x + ejectX, y: y);
    return (x: x, y: y + ejectY);
  }

  /// Resolve a circle against all [walls]. Two passes settle most corner cases.
  static ({double x, double y}) resolveCircle(
    double x,
    double y,
    double r,
    List<Aabb> walls,
  ) {
    for (var pass = 0; pass < 2; pass++) {
      for (var k = 0; k < walls.length; k++) {
        final res = _pushOut(x, y, r, walls[k]);
        x = res.x;
        y = res.y;
      }
    }
    return (x: x, y: y);
  }

  /// In-place variant for a sheep in the SoA buffers (avoids record allocation
  /// in the hot per-sheep loop).
  static void resolveSheep(FlockBuffers b, int i, double r, List<Aabb> walls) {
    var x = b.x[i];
    var y = b.y[i];
    for (var pass = 0; pass < 2; pass++) {
      for (var k = 0; k < walls.length; k++) {
        final res = _pushOut(x, y, r, walls[k]);
        x = res.x;
        y = res.y;
      }
    }
    b.x[i] = x;
    b.y[i] = y;
  }
}
