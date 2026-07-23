/// Axis-aligned bounding box. Pure value type (Shared layer — no Flutter/Flame).
///
/// Used for walls, the pen area and any rectangular region. Collision math that
/// consumes these lives in the Domain layer (`domain/simulation/collision.dart`).
class Aabb {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Aabb(this.left, this.top, this.right, this.bottom);

  const Aabb.fromLTWH(double x, double y, double w, double h)
      : left = x,
        top = y,
        right = x + w,
        bottom = y + h;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;
}
