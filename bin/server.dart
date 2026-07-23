import 'dart:async';
import 'dart:io';

import 'package:sheeeeps/di/server_scope.dart';
import 'package:sheeeeps/domain/state/lobby_state.dart';
import 'package:sheeeeps/domain/state/round_state.dart';
import 'package:sheeeeps/shared/game_config.dart';

/// Entry point for the always-on authoritative pasture server (Stage 3).
///
/// Runs the single-player simulation headless — no rendering — and streams
/// binary snapshots to every connected web client over WebSocket. Configuration
/// is environment-only so the same binary runs locally and on any free host:
///   PORT   — TCP port to bind (default [GameConfig.serverPort]).
///
/// Logs (stdout): startup, join/leave, round completions, and periodic tick
/// timing percentiles + player count, as the TZ requires.
Future<void> main(List<String> args) async {
  final port =
      int.tryParse(Platform.environment['PORT'] ?? '') ?? GameConfig.serverPort;

  final holder = ServerScopeHolder(port: port);
  await holder.create();
  final scope = holder.scope!;

  _log('pasture server up — listening on 0.0.0.0:$port '
      '(protocol v${GameConfig.protocolVersion}, '
      '${GameConfig.pastureSheepCount} sheep, '
      'up to ${GameConfig.maxPasturePlayers} shepherds)');
  _log('health check: http://0.0.0.0:$port/health');

  _watchRoster(scope);
  _watchRounds(scope);
  final metricsTimer = _startMetricsLogger(scope);

  // Graceful shutdown so the port is released and sockets closed cleanly.
  Future<void> shutdown(String signal) async {
    _log('$signal received — shutting down');
    metricsTimer.cancel();
    await holder.drop();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  }
}

/// Log joins and leaves by diffing the roster.
void _watchRoster(ServerScope scope) {
  var known = <int, String>{};
  scope.lobby.stream.listen((LobbyState s) {
    final now = {for (final p in s.players) p.id: p.name};
    for (final e in now.entries) {
      if (!known.containsKey(e.key)) {
        _log('join  id=${e.key} "${e.value}" (${now.length}/${s.maxPlayers})');
      }
    }
    for (final e in known.entries) {
      if (!now.containsKey(e.key)) {
        _log('leave id=${e.key} "${e.value}" (${now.length}/${s.maxPlayers})');
      }
    }
    known = now;
  });
}

/// Log a line whenever a round is completed (herd fully penned).
void _watchRounds(ServerScope scope) {
  var wasCelebrating = false;
  scope.round.stream.listen((RoundState r) {
    final celebrating = r is RoundCelebrating;
    if (celebrating && !wasCelebrating) {
      final top = r.scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final lead = top.isEmpty ? '—' : 'id=${top.first.key}:${top.first.value}';
      _log('round complete — time=${r.roundTime.toStringAsFixed(1)}s '
          'record=${r.dayRecordSeconds.toStringAsFixed(1)}s top=$lead');
    }
    wasCelebrating = celebrating;
  });
}

/// Every 10 s log the tick-time percentiles and the current shepherd count.
Timer _startMetricsLogger(ServerScope scope) {
  return Timer.periodic(const Duration(seconds: 10), (_) {
    final players = scope.lobby.state.players.length;
    final m = scope.loop.sampleTickMetrics();
    if (m.isEmpty) return;
    _log('${m.line} players=$players');
  });
}

void _log(String message) {
  final t = DateTime.now().toIso8601String();
  stdout.writeln('[$t] $message');
}
