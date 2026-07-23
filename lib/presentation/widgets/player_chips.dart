import 'package:flutter/material.dart';

import '../../domain/models/player_info.dart';
import '../../shared/game_palette.dart';

/// A wrapped row of player chips (dog colour + name), shared by the host and
/// client lobby screens.
class PlayerChips extends StatelessWidget {
  const PlayerChips({super.key, required this.players, this.localPlayerId});

  final List<PlayerInfo> players;
  final int? localPlayerId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final p in players)
          _Chip(player: p, isLocal: p.id == localPlayerId),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.player, required this.isLocal});

  final PlayerInfo player;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final color = Color(GamePalette.dogColor(player.colorIndex));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isLocal) ...[
            const SizedBox(width: 6),
            const Text('(вы)',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
