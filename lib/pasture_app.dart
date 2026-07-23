import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import 'di/app_scope.dart';
import 'domain/state/nav_state.dart';
import 'presentation/screens/error_screen.dart';
import 'presentation/screens/pasture_entry_screen.dart';
import 'presentation/screens/pasture_session_screen.dart';

/// Root of the WEB build — the public online pasture. Deliberately independent of
/// `app.dart`: it never imports the LAN host/join/client screens (which pull in
/// `dart:io`, uncompilable for web). It routes only three states: the name-entry
/// menu, the connected pasture session, and the terminal error screen.
class PastureApp extends StatelessWidget {
  const PastureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheeeeps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const _PastureRoot(),
    );
  }
}

class _PastureRoot extends StatefulWidget {
  const _PastureRoot();

  @override
  State<_PastureRoot> createState() => _PastureRootState();
}

class _PastureRootState extends State<_PastureRoot> {
  final AppScopeHolder _holder = AppScopeHolder();

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
      body: ScopeProvider<AppScopeContainer>(
        holder: _holder,
        child: ScopeBuilder<AppScopeContainer>.withPlaceholder(
          placeholder: const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
          builder: (context, appScope) => _PastureRouter(appScope: appScope),
        ),
      ),
    );
  }
}

class _PastureRouter extends StatelessWidget {
  const _PastureRouter({required this.appScope});

  final AppScopeContainer appScope;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NavState>(
      stream: appScope.navState.stream,
      initialData: appScope.navState.state,
      builder: (context, snapshot) {
        return switch (snapshot.data!) {
          NavPasture() => PastureSessionScreen(appScope: appScope),
          NavError(:final message) =>
            ErrorScreen(appScope: appScope, message: message),
          // Menu (and any unreachable desktop-only state) → the entry screen.
          _ => PastureEntryScreen(appScope: appScope),
        };
      },
    );
  }
}
