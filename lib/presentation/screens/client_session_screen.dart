import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app_scope.dart';
import '../../di/client_session_scope.dart';
import '../../domain/state/lobby_state.dart';
import '../game/game_view.dart';
import '../widgets/player_chips.dart';

/// Hosts a client-session scope for one host/port. Shows a waiting lobby until
/// the host starts, then the mirrored game. A dropped connection or a reject is
/// handled by [ClientNetInteractor] routing navigation to the error screen,
/// which tears this scope down.
class ClientSessionScreen extends StatefulWidget {
  const ClientSessionScreen({
    super.key,
    required this.appScope,
    required this.host,
    required this.port,
  });

  final AppScopeContainer appScope;
  final String host;
  final int port;

  @override
  State<ClientSessionScreen> createState() => _ClientSessionScreenState();
}

class _ClientSessionScreenState extends State<ClientSessionScreen> {
  late final ClientSessionScopeHolder _holder = ClientSessionScopeHolder(
    widget.appScope,
    host: widget.host,
    port: widget.port,
  );

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
      body: ScopeProvider<ClientSessionScopeContainer>(
        holder: _holder,
        child: ScopeBuilder<ClientSessionScopeContainer>.withPlaceholder(
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
              return _ClientLobby(
                lobby: lobby,
                host: widget.host,
                onLeave: widget.appScope.menuInteractor.backToMenu,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClientLobby extends StatelessWidget {
  const _ClientLobby({
    required this.lobby,
    required this.host,
    required this.onLeave,
  });

  final LobbyState lobby;
  final String host;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final connected = lobby.localPlayerId >= 0;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(connected ? lobby.roomName : 'Подключение к $host…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 24),
                if (!connected)
                  const CircularProgressIndicator()
                else ...[
                  Text('Игроки (${lobby.players.length}/4)',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 12),
                  PlayerChips(
                    players: lobby.players,
                    localPlayerId: lobby.localPlayerId,
                  ),
                  const SizedBox(height: 20),
                  const Text('Ждём, пока хост начнёт игру…',
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                ],
                const SizedBox(height: 28),
                TextButton(
                  onPressed: onLeave,
                  child: const Text('Выйти',
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
