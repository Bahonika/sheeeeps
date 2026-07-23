import 'dart:async';
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../shared/game_config.dart';
import '../state/flock_state.dart';
import '../state/lobby_state.dart';
import '../state/round_state.dart';
import '../state_managers/dogs_state_manager.dart';
import '../state_managers/flock_state_manager.dart';
import '../state_managers/round_state_manager.dart';

/// Percentiles of recent tick compute-times, in microseconds. Logged by the
/// server so the TZ's "время тика при 16 игроках" requirement can be checked.
class TickMetrics {
  const TickMetrics({
    required this.count,
    required this.p50us,
    required this.p95us,
    required this.p99us,
    required this.maxUs,
  });
  final int count;
  final int p50us, p95us, p99us, maxUs;

  bool get isEmpty => count == 0;
  String get line => 'tick p50=${_ms(p50us)}ms p95=${_ms(p95us)}ms '
      'p99=${_ms(p99us)}ms max=${_ms(maxUs)}ms n=$count';
  static String _ms(int us) => (us / 1000).toStringAsFixed(2);
}

/// The authoritative simulation driver for the persistent pasture — the headless
/// server's game loop, replacing Flame's per-frame `update`. It owns no business
/// state; it drives a wall-clock tick that steps the dogs and flock, credits each
/// penned sheep to the shepherd that last frightened it, advances the round, and
/// reseeds the world when a celebration ends.
///
/// Economy (TZ): with zero shepherds present it drops to [GameConfig.idleTickHz]
/// (nobody to fear — accuracy is pointless) and instantly returns to full rate
/// when someone joins. Reads last-frame state then issues the steps, so cross-
/// state reads use the previous frame (the same one-frame lag as the solo loop).
class PastureLoopInteractor implements AsyncLifecycle {
  PastureLoopInteractor({
    required DogsStateManager dogs,
    required FlockStateManager flock,
    required RoundStateManager round,
    required StateReadable<LobbyState> lobby,
  })  : _dogs = dogs,
        _flock = flock,
        _round = round,
        _lobby = lobby;

  final DogsStateManager _dogs;
  final FlockStateManager _flock;
  final RoundStateManager _round;
  final StateReadable<LobbyState> _lobby;

  final List<double> _dogXs = <double>[];
  final List<double> _dogYs = <double>[];
  final List<int> _dogIds = <int>[];

  /// Per-sheep "already credited this round" flags, parallel to the flock.
  Uint8List _scored = Uint8List(0);

  final Stopwatch _frameClock = Stopwatch();
  final List<int> _tickMicros = <int>[];
  Timer? _timer;
  bool _disposed = false;

  @override
  Future<void> init() async {
    await _seed();
    _frameClock.start();
    _scheduleNext();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
  }

  Future<void> _seed() async {
    await _flock.spawn(GameConfig.pastureSheepCount);
    await _round.startRound(GameConfig.pastureSheepCount);
    _scored = Uint8List(GameConfig.pastureSheepCount);
  }

  void _scheduleNext() {
    if (_disposed) return;
    final idle = _lobby.state.players.isEmpty;
    final ms = idle ? GameConfig.idleTickMillis : GameConfig.serverTickMillis;
    _timer = Timer(Duration(milliseconds: ms), _onTick);
  }

  Future<void> _onTick() async {
    if (_disposed) return;
    final dt = (_frameClock.elapsedMicroseconds / 1e6).clamp(0.0, 0.1);
    _frameClock
      ..reset()
      ..start();

    final sw = Stopwatch()..start();
    try {
      await _tickOnce(dt);
    } finally {
      sw.stop();
      _recordTick(sw.elapsedMicroseconds);
      _scheduleNext();
    }
  }

  Future<void> _tickOnce(double dt) async {
    // Reseed once a finished celebration has run out (gates open, herd scatters).
    final round = _round.state;
    if (round is RoundCelebrating && round.remaining <= 0) {
      await _seed();
      return;
    }

    // Read last-frame state, then step (one-frame lag, as in the solo loop).
    final dogsState = _dogs.state;
    final flock = _flock.state;

    if (round is RoundHerding) {
      _creditNewlyPenned(flock);
    }

    _dogs.step(dt);

    _dogXs.clear();
    _dogYs.clear();
    _dogIds.clear();
    for (final d in dogsState.dogs.values) {
      _dogXs.add(d.x);
      _dogYs.add(d.y);
      _dogIds.add(d.id);
    }
    _flock.step(dt, _dogXs, _dogYs, _dogIds);

    if (round is RoundCelebrating) {
      _round.tickCelebration(dt);
    } else {
      _round.tick(dt, flock.pennedCount);
    }
  }

  /// Award each sheep that has just entered the pen to the shepherd whose dog
  /// last frightened it. Reads the flock SoA buffers directly (Domain). Each
  /// sheep is counted at most once per round via [_scored].
  void _creditNewlyPenned(FlockState flock) {
    final b = flock.buffers;
    final n = b.count < _scored.length ? b.count : _scored.length;
    for (var i = 0; i < n; i++) {
      if (_scored[i] != 0) continue;
      if (b.penned[i] != 1) continue;
      _scored[i] = 1;
      final frighter = b.lastFrighter[i];
      if (frighter >= 0) _round.credit(frighter);
    }
  }

  void _recordTick(int micros) {
    _tickMicros.add(micros);
    // Bound memory: keep only the most recent window of samples.
    if (_tickMicros.length > 4096) {
      _tickMicros.removeRange(0, _tickMicros.length - 4096);
    }
  }

  /// Snapshot the recent tick-time percentiles and clear the window. Called by
  /// the server's periodic logger (keeps IO out of the Domain).
  TickMetrics sampleTickMetrics() {
    if (_tickMicros.isEmpty) {
      return const TickMetrics(count: 0, p50us: 0, p95us: 0, p99us: 0, maxUs: 0);
    }
    final sorted = List<int>.from(_tickMicros)..sort();
    int pct(double p) => sorted[((sorted.length - 1) * p).round()];
    final m = TickMetrics(
      count: sorted.length,
      p50us: pct(0.50),
      p95us: pct(0.95),
      p99us: pct(0.99),
      maxUs: sorted.last,
    );
    _tickMicros.clear();
    return m;
  }
}
