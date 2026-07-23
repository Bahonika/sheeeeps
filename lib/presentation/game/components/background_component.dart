import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../../data/sources/sprite_source.dart';
import '../../../shared/game_config.dart';

/// Pure view: stamps the pre-composed grass+fence background (built once by the
/// [SpriteSource]) as a single image each frame. No per-primitive drawing.
class BackgroundComponent extends Component {
  BackgroundComponent({required this.spriteSource}) : super(priority: -100);

  final SpriteSource spriteSource;

  final ui.Paint _paint = ui.Paint()
    ..isAntiAlias = false
    ..filterQuality = ui.FilterQuality.none;

  late final ui.Rect _dst = ui.Rect.fromLTWH(
    0,
    0,
    GameConfig.worldSize,
    GameConfig.worldSize,
  );

  @override
  void render(ui.Canvas canvas) {
    final bg = spriteSource.background;
    final src = ui.Rect.fromLTWH(
      0,
      0,
      bg.width.toDouble(),
      bg.height.toDouble(),
    );
    canvas.drawImageRect(bg, src, _dst, _paint);
  }
}
