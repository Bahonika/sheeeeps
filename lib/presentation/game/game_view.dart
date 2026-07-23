import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../di/game_session_scope.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/leave_button_overlay.dart';
import '../overlays/touch_controls_overlay.dart';
import '../overlays/win_overlay.dart';
import 'sheepdog_game.dart';

/// Mounts the Flame game and its overlays for any [GameSessionScope] — solo,
/// host or client are identical here because they all expose the same read-only
/// states and ports. Kept stateful so the game instance survives rebuilds.
class GameView extends StatefulWidget {
  const GameView({super.key, required this.session, required this.onExit});

  final GameSessionScope session;
  final VoidCallback onExit;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final SheepdogGame _game = SheepdogGame(
    spriteSource: widget.session.spriteSource,
    flockState: widget.session.flockState,
    dogsState: widget.session.dogsState,
    inputPort: widget.session.inputPort,
    tickPort: widget.session.tickPort,
  );

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return GameWidget<SheepdogGame>(
      game: _game,
      overlayBuilderMap: {
        'hud': (context, game) => HudOverlay(gameState: s.gameState),
        'controls': (context, game) => TouchControlsOverlay(
              dogsState: s.dogsState,
              inputPort: s.inputPort,
              localPlayerId: s.localPlayerId,
              showRestart: s.canRestart,
            ),
        'win': (context, game) => WinOverlay(
              gameState: s.gameState,
              inputPort: s.inputPort,
              canRestart: s.canRestart,
            ),
        'leave': (context, game) => LeaveButtonOverlay(onExit: widget.onExit),
      },
      initialActiveOverlays: const ['hud', 'controls', 'win', 'leave'],
    );
  }
}
