import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';
import 'package:yx_state/yx_state.dart';

import '../../di/app_scope.dart';
import '../../di/join_browser_scope.dart';
import '../../domain/interactors/room_browser_interactor.dart';
import '../../domain/models/discovered_room.dart';
import '../../domain/state/browser_state.dart';
import '../../shared/game_config.dart';

/// The "Join" screen: auto-discovered rooms (UDP) plus a manual IP fallback for
/// networks where broadcast doesn't get through (TZ: both must work).
class JoinBrowserScreen extends StatefulWidget {
  const JoinBrowserScreen({super.key, required this.appScope});

  final AppScopeContainer appScope;

  @override
  State<JoinBrowserScreen> createState() => _JoinBrowserScreenState();
}

class _JoinBrowserScreenState extends State<JoinBrowserScreen> {
  late final JoinBrowserScopeHolder _holder =
      JoinBrowserScopeHolder(widget.appScope);

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
      body: ScopeProvider<JoinBrowserScopeContainer>(
        holder: _holder,
        child: ScopeBuilder<JoinBrowserScopeContainer>.withPlaceholder(
          placeholder: const Center(child: CircularProgressIndicator()),
          builder: (context, scope) => _JoinBody(
            interactor: scope.roomBrowserInteractor,
            browserState: scope.browserState,
          ),
        ),
      ),
    );
  }
}

class _JoinBody extends StatefulWidget {
  const _JoinBody({required this.interactor, required this.browserState});

  final RoomBrowserInteractor interactor;
  final StateReadable<BrowserState> browserState;

  @override
  State<_JoinBody> createState() => _JoinBodyState();
}

class _JoinBodyState extends State<_JoinBody> {
  final TextEditingController _ip = TextEditingController();

  @override
  void dispose() {
    _ip.dispose();
    super.dispose();
  }

  void _joinManual() {
    final raw = _ip.text.trim();
    if (raw.isEmpty) return;
    final parts = raw.split(':');
    final host = parts.first;
    final port =
        parts.length > 1 ? int.tryParse(parts[1]) ?? GameConfig.gamePort : GameConfig.gamePort;
    widget.interactor.joinManual(host, port);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.interactor.backToMenu,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text('Комнаты в сети',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<BrowserState>(
                    stream: widget.browserState.stream,
                    initialData: widget.browserState.state,
                    builder: (context, snapshot) {
                      final rooms = snapshot.data!.rooms;
                      if (rooms.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(height: 14),
                              Text('Ищем комнаты…',
                                  style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _RoomTile(
                          room: rooms[i],
                          onJoin: () => widget.interactor.join(rooms[i]),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white24, height: 32),
                const Text('Или введите адрес вручную',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ip,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '192.168.0.5:${GameConfig.gamePort}',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _joinManual(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _joinManual,
                      child: const Text('Войти'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onJoin});

  final DiscoveredRoom room;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final full = room.playerCount >= room.maxPlayers;
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: full ? null : onJoin,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.meeting_room, color: Colors.amberAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.roomName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    Text('${room.host}:${room.port}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Text('${room.playerCount}/${room.maxPlayers}',
                  style: TextStyle(
                    color: full ? Colors.redAccent : Colors.white70,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(width: 6),
              Icon(full ? Icons.block : Icons.chevron_right,
                  color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
