import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../shared/game_config.dart';
import '../../../shared/game_palette.dart';

/// One-shot expanding ring drawn at a bark's origin, then self-removes.
/// Ephemeral visual state (its own animation progress) — allowed inside a view.
class BarkRingComponent extends Component {
  BarkRingComponent({required this.cx, required this.cy}) : super(priority: 20);

  final double cx;
  final double cy;
  double _t = 0;

  final ui.Paint _paint = ui.Paint()
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..isAntiAlias = false;

  @override
  void update(double dt) {
    _t += dt;
    if (_t >= GameConfig.barkRingDuration) {
      removeFromParent();
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final p = (_t / GameConfig.barkRingDuration).clamp(0.0, 1.0);
    final radius = p * GameConfig.barkRadius;
    _paint.color = ui.Color(GamePalette.barkRing).withValues(alpha: 1 - p);
    canvas.drawCircle(ui.Offset(cx, cy), radius, _paint);
  }
}
