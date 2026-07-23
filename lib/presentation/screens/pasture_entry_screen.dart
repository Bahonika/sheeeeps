import 'package:flutter/material.dart';

import '../../di/app_scope.dart';
import '../../domain/state/player_identity_state.dart';

/// The web build's landing screen: enter a name (remembered in localStorage) and
/// press "Играть" to drop into the public pasture. No registration, no lobby.
class PastureEntryScreen extends StatefulWidget {
  const PastureEntryScreen({super.key, required this.appScope});

  final AppScope appScope;

  @override
  State<PastureEntryScreen> createState() => _PastureEntryScreenState();
}

class _PastureEntryScreenState extends State<PastureEntryScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.appScope.identityState.state.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _play() {
    widget.appScope.menuInteractor.setName(_name.text);
    widget.appScope.menuInteractor.playPasture();
  }

  @override
  Widget build(BuildContext context) {
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
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                const Text('Общее пастбище. Загоняй овец вместе с другими.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 15)),
                const SizedBox(height: 36),
                StreamBuilder<PlayerIdentityState>(
                  stream: widget.appScope.identityState.stream,
                  initialData: widget.appScope.identityState.state,
                  builder: (context, _) => TextField(
                    controller: _name,
                    textAlign: TextAlign.center,
                    maxLength: 12,
                    onSubmitted: (_) => _play(),
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _play,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.amber.shade800,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 26),
                    label: const Text('Играть', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Клик — вести собаку. Пробел или ПКМ — гавкнуть.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
