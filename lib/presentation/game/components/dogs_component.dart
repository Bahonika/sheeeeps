import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:yx_state/yx_state.dart';

import '../../../data/sources/sprite_source.dart';
import '../../../domain/state/dog_state.dart';
import '../../../domain/state/dogs_state.dart';
import '../../../shared/game_config.dart';
import '../../../shared/game_palette.dart';
import 'bark_ring_component.dart';
import 'utils/state_listener_component.dart';

/// Pure view of every dog on the field. Reads [DogsState] and stamps each dog
/// with its palette-coloured atlas, draws the player's name above it, and
/// reactively spawns a bark ring whenever any dog's bark sequence advances.
///
/// No business logic: facing/walk-frame are mirrored from velocity, and ring
/// spawning is a reaction to a monotonic counter in the state.
class DogsComponent extends Component {
  DogsComponent({required this.dogsState, required this.spriteSource})
      : super(priority: 15);

  final StateReadable<DogsState> dogsState;
  final SpriteSource spriteSource;

  final ui.Paint _paint = ui.Paint()
    ..isAntiAlias = false
    ..filterQuality = ui.FilterQuality.none;

  late final List<TextPaint> _namePaints;
  late final TextPaint _zzzPaint;

  double _clock = 0;

  @override
  Future<void> onLoad() async {
    _zzzPaint = TextPaint(
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: Color(0xFFCFE8FF),
        shadows: [
          Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );
    _namePaints = [
      for (var c = 0; c < GameConfig.dogColorCount; c++)
        TextPaint(
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(GamePalette.dogColor(c)),
            shadows: const [
              Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
        ),
    ];

    // Spawn an expanding ring in the world whenever any dog barks (its barkSeq
    // increments). Diff the previous and current rosters to find which fired.
    add(StateListenerComponent<DogsState>(
      stateReadable: dogsState,
      listener: _onDogsChanged,
    ));
  }

  void _onDogsChanged(DogsState? previous, DogsState current) {
    if (previous == null) return;
    for (final dog in current.dogs.values) {
      final was = previous.dogs[dog.id];
      if (was != null && dog.barkSeq != was.barkSeq) {
        parent?.add(BarkRingComponent(cx: dog.x, cy: dog.y));
      }
    }
  }

  @override
  void update(double dt) {
    _clock += dt; // ephemeral animation clock
  }

  @override
  void render(ui.Canvas canvas) {
    for (final dog in dogsState.state.ordered) {
      _renderDog(canvas, dog);
    }
  }

  void _renderDog(ui.Canvas canvas, DogState s) {
    final moving = s.isMoving &&
        (s.vx * s.vx + s.vy * s.vy) >=
            GameConfig.moveAnimThreshold * GameConfig.moveAnimThreshold;
    final dir = moving ? _dirOf(s.vx, s.vy) : 0;
    final frame = moving ? ((_clock * GameConfig.dogAnimFps).floor() & 1) : 0;

    final src = spriteSource.dogRect(dir, frame);
    const size = SpriteSource.tile * GameConfig.dogSpriteScale;
    const half = size / 2;
    final dst = ui.Rect.fromLTWH(s.x - half, s.y - half, size, size);
    canvas.drawImageRect(spriteSource.dogAtlas(s.colorIndex), src, dst, _paint);

    _namePaints[s.colorIndex % _namePaints.length].render(
      canvas,
      s.name,
      Vector2(s.x, s.y - half - 2),
      anchor: Anchor.bottomCenter,
    );

    // AFK: a gently bobbing "z z z" above a sleeping dog.
    if (s.asleep) {
      final bob = (_clock * 2).floor().isEven ? 0.0 : 1.5;
      _zzzPaint.render(
        canvas,
        'z z z',
        Vector2(s.x + half * 0.4, s.y - half - 11 - bob),
        anchor: Anchor.bottomCenter,
      );
    }
  }

  int _dirOf(double vx, double vy) {
    if (vx.abs() > vy.abs()) {
      return vx > 0 ? 3 : 2;
    }
    return vy > 0 ? 0 : 1;
  }
}
