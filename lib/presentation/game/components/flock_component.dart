import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:yx_state/yx_state.dart';

import '../../../data/sources/sprite_source.dart';
import '../../../domain/simulation/flock_buffers.dart';
import '../../../domain/state/flock_state.dart';
import '../../../shared/game_config.dart';

/// Pure view of the whole flock. Reads the SoA buffers straight from state and
/// stamps every sheep in a single `drawRawAtlas` call — no per-sheep object
/// allocation, no primitive drawing. Facing and walk-frame are derived from
/// velocity/phase (mirroring state into visuals, which the rules permit).
class FlockComponent extends Component {
  FlockComponent({required this.flockState, required this.spriteSource})
      : super(priority: 10);

  final StateReadable<FlockState> flockState;
  final SpriteSource spriteSource;

  final ui.Paint _paint = ui.Paint()
    ..isAntiAlias = false
    ..filterQuality = ui.FilterQuality.none;

  double _clock = 0;
  Float32List? _transforms;
  Float32List? _rects;
  int _capacity = 0;

  @override
  void update(double dt) {
    _clock += dt; // ephemeral animation clock (visual only)
  }

  @override
  void render(ui.Canvas canvas) {
    final b = flockState.state.buffers;
    final n = b.count;
    if (n == 0) return;

    if (_capacity < n) {
      _transforms = Float32List(n * 4);
      _rects = Float32List(n * 4);
      _capacity = n;
    }
    final transforms = _transforms!;
    final rects = _rects!;

    const scale = GameConfig.sheepSpriteScale;
    const anchor = SpriteSource.tile / 2 * scale; // sprite centre offset

    for (var i = 0; i < n; i++) {
      final vx = b.vx[i];
      final vy = b.vy[i];
      final spd = math.sqrt(vx * vx + vy * vy);
      final moving = spd >= GameConfig.moveAnimThreshold;
      final dir = moving ? _dirOf(vx, vy) : 0;
      final fright = b.phase[i] == SheepPhase.frightened;
      final fps = fright
          ? GameConfig.sheepAnimFpsFright
          : GameConfig.sheepAnimFpsCalm;
      final frame =
          moving ? ((_clock * fps + i * 0.7).floor() & 1) : 0;

      final src = spriteSource.sheepRect(b.variant[i], dir, frame);
      final o = i * 4;
      transforms[o] = scale; // scos (rotation 0)
      transforms[o + 1] = 0; // ssin
      transforms[o + 2] = b.x[i] - anchor; // tx
      transforms[o + 3] = b.y[i] - anchor; // ty
      rects[o] = src.left;
      rects[o + 1] = src.top;
      rects[o + 2] = src.right;
      rects[o + 3] = src.bottom;
    }

    final tView =
        _capacity == n ? transforms : Float32List.sublistView(transforms, 0, n * 4);
    final rView =
        _capacity == n ? rects : Float32List.sublistView(rects, 0, n * 4);

    canvas.drawRawAtlas(
      spriteSource.sheepAtlas,
      tView,
      rView,
      null,
      ui.BlendMode.srcOver,
      null,
      _paint,
    );
  }

  /// 4-way facing from velocity (0=down, 1=up, 2=left, 3=right).
  int _dirOf(double vx, double vy) {
    if (vx.abs() > vy.abs()) {
      return vx > 0 ? 3 : 2;
    }
    return vy > 0 ? 0 : 1;
  }
}
