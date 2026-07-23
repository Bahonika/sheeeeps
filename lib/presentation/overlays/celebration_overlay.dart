import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

import '../../domain/state/lobby_state.dart';
import '../../domain/state/round_state.dart';
import '../../shared/game_palette.dart';

/// Full-screen celebration shown between rounds: the herd is fully penned, the
/// gates are about to reopen. Renders nothing while herding, so it can stay
/// mounted permanently — it reacts purely to [RoundState].
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.roundState,
    required this.lobbyState,
  });

  final StateReadable<RoundState> roundState;
  final StateReadable<LobbyState> lobbyState;

  static String _fmt(double seconds) {
    final total = seconds.floor();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RoundState>(
      stream: roundState.stream,
      initialData: roundState.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state is! RoundCelebrating) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _Confetti(),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: StreamBuilder<LobbyState>(
                    stream: lobbyState.stream,
                    initialData: lobbyState.state,
                    builder: (context, lobbySnapshot) {
                      final lobby = lobbySnapshot.data!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🎉 Загнали всех! 🎉',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Время раунда: ${_fmt(state.roundTime)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 18),
                          ..._topContributors(state, lobby),
                          const SizedBox(height: 18),
                          Text(
                            'Новый раунд через ${state.remaining.ceil()}…',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Up to three highest scorers of the round, joined with the lobby roster for
  /// names and colours. Zero-score players are not "contributors".
  static List<Widget> _topContributors(RoundState state, LobbyState lobby) {
    final scored = lobby.players
        .where((p) => state.scoreOf(p.id) > 0)
        .toList()
      ..sort((a, b) => state.scoreOf(b.id).compareTo(state.scoreOf(a.id)));
    final top = scored.take(3).toList();
    if (top.isEmpty) return const [];

    return [
      for (var i = 0; i < top.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${i + 1}. ',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(GamePalette.dogColor(top[i].colorIndex)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '${top[i].name} — ${state.scoreOf(top[i].id)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
    ];
  }
}

/// Lightweight pixel confetti: ~80 coloured squares falling behind the panel,
/// driven by a single repeating [AnimationController] and one [CustomPainter].
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(t: _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t});

  /// Animation phase in [0, 1); the loop wraps seamlessly because every flake's
  /// vertical position is taken modulo the screen height.
  final double t;

  static const int _count = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(1337);
    final paint = Paint();
    for (var i = 0; i < _count; i++) {
      final x0 = rng.nextDouble();
      final y0 = rng.nextDouble();
      final speed = 0.5 + rng.nextDouble() * 0.8; // screens per loop
      final drift = (rng.nextDouble() - 0.5) * 0.08;
      final flakeSize = 4.0 + rng.nextDouble() * 5.0;
      final color = GamePalette.dogColors[i % GamePalette.dogColors.length];

      final y = ((y0 + t * speed) % 1.1) - 0.05;
      final x = (x0 + drift * math.sin(t * 2 * math.pi + i)) % 1.0;

      paint.color = Color(color).withValues(alpha: 0.85);
      canvas.drawRect(
        Rect.fromLTWH(
          x * size.width,
          y * size.height,
          flakeSize,
          flakeSize,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
