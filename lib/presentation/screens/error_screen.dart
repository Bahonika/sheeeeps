import 'package:flutter/material.dart';

import '../../di/app_scope.dart';

/// Terminal screen after a network session ended (host quit, version mismatch,
/// room full, connect failure). Shows the reason and returns to the menu.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.appScope,
    required this.message,
  });

  final AppScope appScope;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E14),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Colors.redAccent, size: 56),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: appScope.menuInteractor.backToMenu,
                icon: const Icon(Icons.home),
                label: const Text('В меню'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
