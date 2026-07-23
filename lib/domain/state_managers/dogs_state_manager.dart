import 'dart:math' as math;

import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../shared/aabb.dart';
import '../../shared/game_config.dart';
import '../models/player_info.dart';
import '../simulation/collision.dart';
import '../state/dog_state.dart';
import '../state/dogs_state.dart';

/// 1st-order owner of every shepherd dog (1–4). Each frame it moves every dog
/// toward its commanded target in a straight line, slides it along walls and
/// ticks its bark cooldown — the same motion the single dog had, now per id.
///
/// It never reads another StateManager: dog motion depends only on each dog's
/// own target. On a client this manager is a passive mirror — [setDogs] writes
/// interpolated network state and [step] is not called.
class DogsStateManager extends StateManager<DogsState>
    implements AsyncLifecycle {
  DogsStateManager() : super(const DogsState());

  final List<Aabb> _walls = GameConfig.buildWalls();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Replace the whole roster with a fresh dog per [players], each parked at its
  /// assigned spawn point. Called when a level starts.
  Future<void> reset(List<PlayerInfo> players) => handle((emit) async {
        final spawns = GameConfig.dogSpawns;
        final dogs = <int, DogState>{};
        for (var i = 0; i < players.length; i++) {
          final p = players[i];
          final spawn = spawns[i % spawns.length];
          dogs[p.id] = DogState.spawn(
            id: p.id,
            name: p.name,
            colorIndex: p.colorIndex,
            x: spawn.$1,
            y: spawn.$2,
          );
        }
        emit(DogsState(dogs: dogs));
      });

  /// Add a single dog mid-session (a player joined). Without [x]/[y] it parks at
  /// the LAN spawn slot for its colour; the pasture server passes an explicit
  /// edge spawn (there can be up to 16 dogs, more than [GameConfig.dogSpawns]).
  Future<void> addDog(PlayerInfo player, {double? x, double? y}) =>
      handle((emit) async {
        if (state.dogs.containsKey(player.id)) return;
        final double sx, sy;
        if (x != null && y != null) {
          sx = x;
          sy = y;
        } else {
          final spawns = GameConfig.dogSpawns;
          final spawn = spawns[player.colorIndex % spawns.length];
          sx = spawn.$1;
          sy = spawn.$2;
        }
        final dogs = Map<int, DogState>.from(state.dogs);
        dogs[player.id] = DogState.spawn(
          id: player.id,
          name: player.name,
          colorIndex: player.colorIndex,
          x: sx,
          y: sy,
        );
        emit(DogsState(dogs: dogs));
      });

  /// Remove a dog (its player left).
  Future<void> removeDog(int id) => handle((emit) async {
        if (!state.dogs.containsKey(id)) return;
        final dogs = Map<int, DogState>.from(state.dogs)..remove(id);
        emit(DogsState(dogs: dogs));
      });

  /// Send dog [id] running toward ([x], [y]). A new target overrides the old.
  Future<void> setTarget(int id, double x, double y) => handle((emit) async {
        final dog = state.dogs[id];
        if (dog == null) return;
        final dogs = Map<int, DogState>.from(state.dogs);
        dogs[id] = dog.copyWith(targetX: x, targetY: y, hasTarget: true);
        emit(DogsState(dogs: dogs));
      });

  /// Trigger dog [id]'s bark: start its cooldown and bump its sequence counter
  /// (the visual ring is spawned reactively from [DogState.barkSeq]). The caller
  /// gates on [DogState.canBark].
  Future<void> bark(int id) => handle((emit) async {
        final dog = state.dogs[id];
        if (dog == null) return;
        final dogs = Map<int, DogState>.from(state.dogs);
        dogs[id] = dog.copyWith(
          barkCooldownRemaining: GameConfig.barkCooldown,
          barkSeq: dog.barkSeq + 1,
        );
        emit(DogsState(dogs: dogs));
      });

  /// Advance every dog by [dt] (host/solo simulation only).
  Future<void> step(double dt) => handle((emit) async {
        if (state.dogs.isEmpty) return;
        final dogs = <int, DogState>{};
        for (final dog in state.dogs.values) {
          dogs[dog.id] = _stepOne(dog, dt);
        }
        emit(DogsState(dogs: dogs));
      });

  /// Overwrite the roster with network-authoritative state (client mirror).
  /// Identity + kinematics arrive already resolved in [dogs]; no simulation runs.
  Future<void> setDogs(Map<int, DogState> dogs) =>
      handle((emit) async => emit(DogsState(dogs: dogs)));

  DogState _stepOne(DogState s, double dt) {
    var x = s.x;
    var y = s.y;
    var vx = 0.0;
    var vy = 0.0;
    var hasTarget = s.hasTarget;

    if (hasTarget) {
      final dx = s.targetX - x;
      final dy = s.targetY - y;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist <= GameConfig.dogArriveEpsilon) {
        hasTarget = false;
      } else {
        final step = GameConfig.dogSpeed * dt;
        final travel = step >= dist ? dist : step;
        vx = dx / dist * GameConfig.dogSpeed;
        vy = dy / dist * GameConfig.dogSpeed;
        x += dx / dist * travel;
        y += dy / dist * travel;
      }
    }

    final resolved = Collision.resolveCircle(x, y, GameConfig.dogRadius, _walls);
    final cooldown = (s.barkCooldownRemaining - dt)
        .clamp(0.0, GameConfig.barkCooldown);

    return s.copyWith(
      x: resolved.x,
      y: resolved.y,
      vx: vx,
      vy: vy,
      hasTarget: hasTarget,
      barkCooldownRemaining: cooldown,
    );
  }
}
