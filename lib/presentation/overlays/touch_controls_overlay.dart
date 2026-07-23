import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

import '../../domain/ports/game_ports.dart';
import '../../domain/state/dogs_state.dart';
import '../../shared/game_config.dart';

/// On-screen controls so the game is fully playable by touch (Android), where
/// there is no right-click or keyboard. The buttons also work with a mouse, so
/// desktop keeps both these and its keyboard/right-click shortcuts.
///
/// Rendered as a [Stack] of [Positioned] buttons: empty areas hit-test through
/// to the game below, so tap/drag-to-move still reaches the field. The bark
/// button's cooldown ring mirrors the *local* dog only.
class TouchControlsOverlay extends StatelessWidget {
  const TouchControlsOverlay({
    super.key,
    required this.dogsState,
    required this.inputPort,
    required this.localPlayerId,
    this.showRestart = true,
  });

  final StateReadable<DogsState> dogsState;
  final GameInputPort inputPort;
  final int localPlayerId;
  final bool showRestart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          if (showRestart)
            Positioned(
              left: 16,
              bottom: 16,
              child: _RoundButton(
                icon: Icons.refresh,
                label: 'Заново',
                onTap: inputPort.requestRestart,
              ),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: StreamBuilder<DogsState>(
              stream: dogsState.stream,
              initialData: dogsState.state,
              builder: (context, snapshot) {
                final dog = snapshot.data!.byId(localPlayerId);
                final ready = dog?.canBark ?? false;
                final progress = dog == null
                    ? 0.0
                    : (1 - dog.barkCooldownRemaining / GameConfig.barkCooldown)
                        .clamp(0.0, 1.0);
                return _BarkButton(
                  ready: ready,
                  progress: progress,
                  onTap: inputPort.bark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarkButton extends StatelessWidget {
  const _BarkButton({
    required this.ready,
    required this.progress,
    required this.onTap,
  });

  final bool ready;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    return GestureDetector(
      onTap: ready ? onTap : null,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cooldown ring: fills back to full while recharging.
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ready ? Colors.amberAccent : Colors.white54,
                ),
              ),
            ),
            Container(
              width: size - 16,
              height: size - 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (ready ? Colors.amber.shade700 : Colors.grey.shade800)
                    .withValues(alpha: 0.92),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 6),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, color: Colors.white, size: 26),
                  Text(
                    'ГАВ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
