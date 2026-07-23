import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app_scope.dart';
import '../../di/pasture_client_scope.dart';
import '../../domain/state/lobby_state.dart';
import '../game/sheepdog_game.dart';
import '../overlays/celebration_overlay.dart';
import '../overlays/leave_button_overlay.dart';
import '../overlays/round_hud_overlay.dart';
import '../overlays/scoreboard_overlay.dart';
import '../overlays/touch_controls_overlay.dart';

/// The web build's in-game screen. Creates the pasture client child-scope (which
/// dials the server), shows a "connecting" state until the server assigns an id,
/// then mounts the Flame game with the round HUD, scoreboard and celebration
/// overlays. Dropping the scope on exit tears down the connection.
class PastureSessionScreen extends StatefulWidget {
  const PastureSessionScreen({super.key, required this.appScope});

  final AppScopeContainer appScope;

  @override
  State<PastureSessionScreen> createState() => _PastureSessionScreenState();
}

class _PastureSessionScreenState extends State<PastureSessionScreen> {
  late final PastureClientScopeHolder _holder =
      PastureClientScopeHolder(widget.appScope);

  @override
  void initState() {
    super.initState();
    _holder.create();
  }

  @override
  void dispose() {
    _holder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopeProvider<PastureClientScopeContainer>(
      holder: _holder,
      child: ScopeBuilder<PastureClientScopeContainer>.withPlaceholder(
        placeholder: const _Connecting(),
        builder: (context, scope) => StreamBuilder<LobbyState>(
          stream: scope.lobbyState.stream,
          initialData: scope.lobbyState.state,
          builder: (context, snapshot) {
            final connected = (snapshot.data?.localPlayerId ?? -1) >= 0;
            if (!connected) return const _Connecting();
            return _PastureGame(
              scope: scope,
              onExit: widget.appScope.menuInteractor.backToMenu,
            );
          },
        ),
      ),
    );
  }
}

class _Connecting extends StatelessWidget {
  const _Connecting();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2A1E14),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 18),
            Text('Подключение к пастбищу…',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// Holds the [SheepdogGame] so it survives widget rebuilds (created once).
class _PastureGame extends StatefulWidget {
  const _PastureGame({required this.scope, required this.onExit});

  final PastureClientScopeContainer scope;
  final VoidCallback onExit;

  @override
  State<_PastureGame> createState() => _PastureGameState();
}

class _PastureGameState extends State<_PastureGame> {
  late final SheepdogGame _game = SheepdogGame(
    spriteSource: widget.scope.spriteSource,
    flockState: widget.scope.flockState,
    dogsState: widget.scope.dogsState,
    inputPort: widget.scope.inputPort,
    tickPort: widget.scope.tickPort,
  );

  @override
  Widget build(BuildContext context) {
    final s = widget.scope;
    return GameWidget<SheepdogGame>(
      game: _game,
      overlayBuilderMap: {
        'hud': (context, game) => RoundHudOverlay(roundState: s.roundState),
        'scoreboard': (context, game) => ScoreboardOverlay(
              roundState: s.roundState,
              lobbyState: s.lobbyState,
              localPlayerId: s.localPlayerId,
            ),
        'controls': (context, game) => TouchControlsOverlay(
              dogsState: s.dogsState,
              inputPort: s.inputPort,
              localPlayerId: s.localPlayerId,
              showRestart: false,
            ),
        'celebration': (context, game) => CelebrationOverlay(
              roundState: s.roundState,
              lobbyState: s.lobbyState,
            ),
        'leave': (context, game) => LeaveButtonOverlay(onExit: widget.onExit),
      },
      initialActiveOverlays: const [
        'hud',
        'scoreboard',
        'controls',
        'celebration',
        'leave',
      ],
    );
  }
}
