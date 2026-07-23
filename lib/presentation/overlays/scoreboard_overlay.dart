import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

import '../../domain/models/player_info.dart';
import '../../domain/state/lobby_state.dart';
import '../../domain/state/round_state.dart';
import '../../shared/game_palette.dart';

/// Collapsible per-round scoreboard pinned to the right edge: who penned how
/// many sheep this round, sorted by score. Pure view over [RoundState] and
/// [LobbyState].
class ScoreboardOverlay extends StatefulWidget {
  const ScoreboardOverlay({
    super.key,
    required this.roundState,
    required this.lobbyState,
    this.localPlayerId,
  });

  final StateReadable<RoundState> roundState;
  final StateReadable<LobbyState> lobbyState;
  final int? localPlayerId;

  @override
  State<ScoreboardOverlay> createState() => _ScoreboardOverlayState();
}

class _ScoreboardOverlayState extends State<ScoreboardOverlay> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 70, right: 12),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder<LobbyState>(
              stream: widget.lobbyState.stream,
              initialData: widget.lobbyState.state,
              builder: (context, lobbySnapshot) {
                final lobby = lobbySnapshot.data!;
                return StreamBuilder<RoundState>(
                  stream: widget.roundState.stream,
                  initialData: widget.roundState.state,
                  builder: (context, roundSnapshot) {
                    final round = roundSnapshot.data!;
                    final players = [...lobby.players]..sort(
                        (a, b) =>
                            round.scoreOf(b.id).compareTo(round.scoreOf(a.id)),
                      );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Загнали 🐑',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _expanded = !_expanded),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              iconSize: 20,
                              color: Colors.white70,
                              icon: Icon(
                                _expanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ),
                          ],
                        ),
                        if (_expanded)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final p in players)
                                    _ScoreRow(
                                      player: p,
                                      score: round.scoreOf(p.id),
                                      isLocal: p.id == widget.localPlayerId,
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.player,
    required this.score,
    required this.isLocal,
  });

  final PlayerInfo player;
  final int score;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final color = Color(GamePalette.dogColor(player.colorIndex));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              isLocal ? '${player.name} (вы)' : player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLocal ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isLocal ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
