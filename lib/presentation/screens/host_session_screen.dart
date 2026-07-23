import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app_scope.dart';
import '../../di/host_session_scope.dart';
import '../../domain/state/lobby_state.dart';
import '../game/game_view.dart';
import '../widgets/player_chips.dart';

/// Hosts the host-session scope. Shows the lobby until the host starts the
/// match, then swaps to the game — the scope (and its server) survives the
/// transition.
class HostSessionScreen extends StatefulWidget {
  const HostSessionScreen({super.key, required this.appScope});

  final AppScopeContainer appScope;

  @override
  State<HostSessionScreen> createState() => _HostSessionScreenState();
}

class _HostSessionScreenState extends State<HostSessionScreen> {
  late final HostSessionScopeHolder _holder =
      HostSessionScopeHolder(widget.appScope);

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
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E14),
      body: ScopeProvider<HostSessionScopeContainer>(
        holder: _holder,
        child: ScopeBuilder<HostSessionScopeContainer>.withPlaceholder(
          placeholder: const Center(child: CircularProgressIndicator()),
          builder: (context, scope) => StreamBuilder<LobbyState>(
            stream: scope.lobbyState.stream,
            initialData: scope.lobbyState.state,
            builder: (context, snapshot) {
              final lobby = snapshot.data!;
              if (lobby.started) {
                return GameView(
                  session: scope,
                  onExit: widget.appScope.menuInteractor.backToMenu,
                );
              }
              return _HostLobby(
                lobby: lobby,
                onStart: scope.hostNetInteractor.startGame,
                onLeave: widget.appScope.menuInteractor.backToMenu,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HostLobby extends StatelessWidget {
  const _HostLobby({
    required this.lobby,
    required this.onStart,
    required this.onLeave,
  });

  final LobbyState lobby;
  final VoidCallback onStart;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lobby.roomName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 16),
                _AddressCard(address: lobby.hostAddress),
                const SizedBox(height: 24),
                Text('Игроки (${lobby.players.length}/4)',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 12),
                PlayerChips(
                  players: lobby.players,
                  localPlayerId: lobby.localPlayerId,
                ),
                const SizedBox(height: 12),
                const Text('Ждём друзей в той же сети…',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade700,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Старт', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onLeave,
                  child: const Text('Отмена',
                      style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('Адрес для подключения вручную',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          SelectableText(
            address.isEmpty ? '…' : address,
            style: const TextStyle(
              color: Colors.amberAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
