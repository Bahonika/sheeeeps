import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../di/app_scope.dart';
import '../domain/state/nav_state.dart';
import 'screens/client_session_screen.dart';
import 'screens/error_screen.dart';
import 'screens/host_session_screen.dart';
import 'screens/join_browser_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/solo_game_screen.dart';

/// App root. Owns the always-alive [AppScope] and renders one screen per
/// [NavState] — session screens create/drop their own child scopes on entry and
/// exit, so navigation drives DI lifecycle (scopes create UI, not the reverse).
class SheepdogApp extends StatelessWidget {
  const SheepdogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheeeeps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
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
          placeholder: const Center(child: CircularProgressIndicator()),
          builder: (context, appScope) => _Router(appScope: appScope),
        ),
      ),
    );
  }
}

class _Router extends StatelessWidget {
  const _Router({required this.appScope});

  final AppScopeContainer appScope;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NavState>(
      stream: appScope.navState.stream,
      initialData: appScope.navState.state,
      builder: (context, snapshot) {
        return switch (snapshot.data!) {
          NavMenu() => MainMenuScreen(appScope: appScope),
          NavSolo() => SoloGameScreen(appScope: appScope),
          // The pasture is web-only; the desktop build never navigates here.
          NavPasture() => MainMenuScreen(appScope: appScope),
          NavHostSession() => HostSessionScreen(appScope: appScope),
          NavJoinBrowser() => JoinBrowserScreen(appScope: appScope),
          NavClientSession(:final host, :final port) => ClientSessionScreen(
              key: ValueKey('client-$host-$port'),
              appScope: appScope,
              host: host,
              port: port,
            ),
          NavError(:final message) =>
            ErrorScreen(appScope: appScope, message: message),
        };
      },
    );
  }
}
