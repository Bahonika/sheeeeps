import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

import '../../domain/ports/game_ports.dart';
import '../../domain/state/game_state.dart';

/// Victory overlay. Always mounted but renders nothing until the run is won, so
/// no game-side overlay toggling is needed — it reacts purely to state. Shows
/// the shared final time to everyone; only a host/solo player can restart, a
/// client is told the host controls the rematch.
class WinOverlay extends StatelessWidget {
  const WinOverlay({
    super.key,
    required this.gameState,
    required this.inputPort,
    this.canRestart = true,
  });

  final StateReadable<GameState> gameState;
  final GameInputPort inputPort;
  final bool canRestart;

  static String _fmt(double seconds) {
    final total = seconds.floor();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameState>(
      stream: gameState.stream,
      initialData: gameState.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (!state.isWon) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.6),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Победа!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Все ${state.total} овец в вольере за ${_fmt(state.elapsed)}',
                style: const TextStyle(color: Colors.white70, fontSize: 20),
              ),
              const SizedBox(height: 28),
              if (canRestart)
                FilledButton.icon(
                  onPressed: inputPort.requestRestart,
                  icon: const Icon(Icons.refresh),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Text('Играть заново', style: TextStyle(fontSize: 18)),
                  ),
                )
              else
                const Text(
                  'Ждём, пока хост начнёт заново…',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
            ],
          ),
        );
      },
    );
  }
}
