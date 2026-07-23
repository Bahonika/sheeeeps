import 'package:flutter/material.dart';

import '../../di/app_scope.dart';
import '../../domain/state/player_identity_state.dart';

/// The main menu: name entry (once, reused everywhere) plus the three entry
/// points — solo, create room, join.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.appScope});

  final AppScope appScope;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.appScope.identityState.state.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _go(void Function() action) {
    widget.appScope.menuInteractor.setName(_name.text);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.appScope.menuInteractor;
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E14),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐑 Sheeeeps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                const Text('Загоняй овец. Вместе веселее.',
                    style: TextStyle(color: Colors.white60, fontSize: 15)),
                const SizedBox(height: 36),
                StreamBuilder<PlayerIdentityState>(
                  stream: widget.appScope.identityState.stream,
                  initialData: widget.appScope.identityState.state,
                  builder: (context, _) => TextField(
                    controller: _name,
                    textAlign: TextAlign.center,
                    maxLength: 16,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Ваше имя',
                      labelStyle: const TextStyle(color: Colors.white54),
                      counterStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.person,
                  label: 'Одиночная игра',
                  onTap: () => _go(menu.playSolo),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.add_home,
                  label: 'Создать комнату',
                  onTap: () => _go(menu.createRoom),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.wifi_find,
                  label: 'Присоединиться',
                  onTap: () => _go(menu.openJoin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.amber.shade800,
        ),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
