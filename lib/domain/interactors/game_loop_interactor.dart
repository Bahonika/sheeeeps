import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../shared/game_config.dart';
import '../ports/game_ports.dart';
import '../state/lobby_state.dart';
import '../state_managers/dogs_state_manager.dart';
import '../state_managers/flock_state_manager.dart';
import '../state_managers/game_state_manager.dart';

/// 2nd-order coordinator that drives one simulation frame and owns the level
/// lifecycle (seed on start, reseed on restart). This is the authoritative loop
/// — it runs in solo and on the host; a client never instantiates it.
///
/// Holds no business state — only the managers it orchestrates and two reusable
/// scratch lists for dog positions. Each frame it reads last-frame positions and
/// issues the per-state steps; because `handle` emits on a later microtask,
/// cross-state reads use the previous frame's values (a one-frame lag that is
/// imperceptible at 60 FPS).
class GameLoopInteractor implements AsyncLifecycle, GameTickPort {
  GameLoopInteractor({
    required DogsStateManager dogs,
    required FlockStateManager flock,
    required GameStateManager game,
    required StateReadable<LobbyState> lobby,
  })  : _dogs = dogs,
        _flock = flock,
        _game = game,
        _lobby = lobby;

  final DogsStateManager _dogs;
  final FlockStateManager _flock;
  final GameStateManager _game;
  final StateReadable<LobbyState> _lobby;

  // Reused each frame so passing dog positions to the flock allocates nothing.
  final List<double> _dogXs = <double>[];
  final List<double> _dogYs = <double>[];
  final List<int> _dogIds = <int>[];

  @override
  Future<void> init() async {
    await _seed();
  }

  @override
  Future<void> dispose() async {}

  /// Advance the world one frame. Called by the root game component's `update`.
  @override
  void update(double dt) {
    final dogs = _dogs.state;
    final flock = _flock.state;

    _dogs.step(dt);

    _dogXs.clear();
    _dogYs.clear();
    _dogIds.clear();
    for (final d in dogs.dogs.values) {
      _dogXs.add(d.x);
      _dogYs.add(d.y);
      _dogIds.add(d.id);
    }
    _flock.step(dt, _dogXs, _dogYs, _dogIds);

    _game.tick(dt, flock.pennedCount, flock.total);
  }

  /// Restart the level from scratch (host/solo).
  Future<void> restart() => _seed();

  Future<void> _seed() async {
    final players = _lobby.state.players;
    final count = GameConfig.sheepCountFor(players.length);
    await _game.start(count);
    await _dogs.reset(players);
    await _flock.spawn(count);
  }
}
