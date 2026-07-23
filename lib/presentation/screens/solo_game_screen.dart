import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app_scope.dart';
import '../../di/solo_session_scope.dart';
import '../game/game_view.dart';

/// Hosts the single-player session scope for its lifetime: created on entry,
/// dropped on leave.
class SoloGameScreen extends StatefulWidget {
  const SoloGameScreen({super.key, required this.appScope});

  final AppScopeContainer appScope;

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  late final SoloSessionScopeHolder _holder =
      SoloSessionScopeHolder(widget.appScope);

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
      backgroundColor: Colors.black,
      body: ScopeProvider<SoloSessionScopeContainer>(
        holder: _holder,
        child: ScopeBuilder<SoloSessionScopeContainer>.withPlaceholder(
          placeholder: const Center(child: CircularProgressIndicator()),
          builder: (context, scope) => GameView(
            session: scope,
            onExit: widget.appScope.menuInteractor.backToMenu,
          ),
        ),
      ),
    );
  }
}
