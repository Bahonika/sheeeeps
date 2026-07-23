import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yx_state/yx_state.dart';

import '../../data/sources/sprite_source.dart';
import '../../domain/ports/game_ports.dart';
import '../../domain/state/dogs_state.dart';
import '../../domain/state/flock_state.dart';
import '../../shared/game_config.dart';
import 'components/background_component.dart';
import 'components/dogs_component.dart';
import 'components/flock_component.dart';

/// Root Flame view. Owns a fixed-resolution letterboxed world and forwards all
/// raw input straight through the [GameInputPort] — no business logic, and no
/// knowledge of whether it is a solo, host or client session. Its `update`
/// delegates one tick to the [GameTickPort] (simulation on host/solo, snapshot
/// interpolation on a client).
class SheepdogGame extends FlameGame
    with TapCallbacks, DragCallbacks, SecondaryTapCallbacks, KeyboardEvents {
  SheepdogGame._({
    required World world,
    required CameraComponent camera,
    required this.spriteSource,
    required this.flockState,
    required this.dogsState,
    required this.inputPort,
    required this.tickPort,
  }) : super(world: world, camera: camera);

  factory SheepdogGame({
    required SpriteSource spriteSource,
    required StateReadable<FlockState> flockState,
    required StateReadable<DogsState> dogsState,
    required GameInputPort inputPort,
    required GameTickPort tickPort,
  }) {
    final world = World();
    final camera = CameraComponent.withFixedResolution(
      width: GameConfig.worldSize,
      height: GameConfig.worldSize,
      world: world,
    );
    return SheepdogGame._(
      world: world,
      camera: camera,
      spriteSource: spriteSource,
      flockState: flockState,
      dogsState: dogsState,
      inputPort: inputPort,
      tickPort: tickPort,
    );
  }

  final SpriteSource spriteSource;
  final StateReadable<FlockState> flockState;
  final StateReadable<DogsState> dogsState;
  final GameInputPort inputPort;
  final GameTickPort tickPort;

  @override
  Color backgroundColor() => const Color(0xFF2A1E14);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    world.addAll([
      BackgroundComponent(spriteSource: spriteSource),
      FlockComponent(flockState: flockState, spriteSource: spriteSource),
      DogsComponent(dogsState: dogsState, spriteSource: spriteSource),
    ]);
  }

  @override
  void update(double dt) {
    tickPort.update(dt);
    super.update(dt);
  }

  // ── Input → port (pure delegation) ─────────────────────────────────────────

  void _moveToCanvas(Vector2 canvasPosition) {
    final world = camera.globalToLocal(canvasPosition);
    inputPort.moveTo(world.x, world.y);
  }

  @override
  void onTapDown(TapDownEvent event) => _moveToCanvas(event.canvasPosition);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _moveToCanvas(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      _moveToCanvas(event.canvasEndPosition);

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) => inputPort.bark();

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        inputPort.bark();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        inputPort.requestRestart();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
