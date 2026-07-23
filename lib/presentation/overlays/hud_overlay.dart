import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

import '../../domain/state/game_state.dart';

/// Top HUD: penned counter, running timer and the restart hint. Pure view bound
/// to [GameState] via its stream.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.gameState});

  final StateReadable<GameState> gameState;

  static String _fmt(double seconds) {
    final total = seconds.floor();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<GameState>(
          stream: gameState.stream,
          initialData: gameState.state,
          builder: (context, snapshot) {
            final s = snapshot.data!;
            return Row(
              children: [
                _Pill(
                  icon: Icons.pets,
                  label: 'В вольере: ${s.penned} / ${s.total}',
                ),
                const SizedBox(width: 10),
                _Pill(icon: Icons.timer_outlined, label: _fmt(s.elapsed)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
