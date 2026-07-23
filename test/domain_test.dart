import 'package:flutter_test/flutter_test.dart';
import 'package:sheeeeps/domain/models/player_info.dart';
import 'package:sheeeeps/domain/simulation/collision.dart';
import 'package:sheeeeps/domain/simulation/flock_buffers.dart';
import 'package:sheeeeps/domain/state_managers/dogs_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/flock_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/game_state_manager.dart';
import 'package:sheeeeps/shared/aabb.dart';
import 'package:sheeeeps/shared/game_config.dart';

PlayerInfo _player(int id, {int color = 0}) =>
    PlayerInfo(id: id, name: 'P$id', colorIndex: color);

void main() {
  group('GameConfig geometry', () {
    test('pen has an entrance gap and walls are present', () {
      final walls = GameConfig.buildWalls();
      expect(walls, isNotEmpty);
      // A point in the middle of the entrance gap must be inside no wall.
      final gx = GameConfig.penEntranceCenterX;
      final gy = GameConfig.penArea.bottom;
      expect(walls.any((w) => w.contains(gx, gy)), isFalse);
    });

    test('flock scales up with more shepherds but solo stays at the base', () {
      expect(GameConfig.sheepCountFor(1), GameConfig.sheepCount);
      expect(GameConfig.sheepCountFor(2),
          (GameConfig.sheepCount * GameConfig.sheepPerPlayerFactor * 2).round());
      expect(GameConfig.sheepCountFor(4), greaterThan(GameConfig.sheepCount));
    });
  });

  group('Collision', () {
    test('ejects a circle out of a wall (slides free)', () {
      const wall = Aabb(0, 0, 100, 10); // top strip
      final r = Collision.resolveCircle(50, 8, 5, [wall]);
      expect(r.y, greaterThan(10)); // pushed clear below the wall
    });
  });

  group('GameStateManager', () {
    test('accumulates time and wins once all sheep are penned', () async {
      final gm = GameStateManager();
      await gm.start(3);
      await gm.tick(1.0, 1, 3);
      expect(gm.state.isWon, isFalse);
      expect(gm.state.elapsed, closeTo(1.0, 1e-9));
      await gm.tick(0.5, 3, 3);
      expect(gm.state.isWon, isTrue);
      expect(gm.state.total, 3);
      await gm.dispose();
    });
  });

  group('DogsStateManager', () {
    test('spawns one dog per player and moves it toward its target', () async {
      final dm = DogsStateManager();
      await dm.reset([_player(0), _player(1, color: 1)]);
      expect(dm.state.count, 2);
      final startX = dm.state.byId(0)!.x;
      await dm.setTarget(0, startX + 400, dm.state.byId(0)!.y);
      await dm.step(0.1);
      expect(dm.state.byId(0)!.x, greaterThan(startX));
      // The untargeted dog stays put.
      await dm.dispose();
    });

    test('bark starts a cooldown and bumps only that dog', () async {
      final dm = DogsStateManager();
      await dm.reset([_player(0), _player(1, color: 1)]);
      expect(dm.state.byId(0)!.canBark, isTrue);
      await dm.bark(0);
      expect(dm.state.byId(0)!.canBark, isFalse);
      expect(dm.state.byId(0)!.barkSeq, 1);
      expect(dm.state.byId(1)!.barkSeq, 0, reason: 'other dog untouched');
      await dm.dispose();
    });

    test('add and remove a dog mid-session', () async {
      final dm = DogsStateManager();
      await dm.reset([_player(0)]);
      await dm.addDog(_player(2, color: 2));
      expect(dm.state.count, 2);
      await dm.removeDog(2);
      expect(dm.state.count, 1);
      expect(dm.state.byId(2), isNull);
      await dm.dispose();
    });
  });

  group('FlockStateManager', () {
    test('spawns the full flock outside the pen', () async {
      final fm = FlockStateManager();
      await fm.spawn(GameConfig.sheepCount);
      final b = fm.state.buffers;
      expect(b.count, GameConfig.sheepCount);
      for (var i = 0; i < b.count; i++) {
        expect(GameConfig.penArea.contains(b.x[i], b.y[i]), isFalse);
      }
      await fm.dispose();
    });

    test('bark frightens sheep at its epicentre', () async {
      final fm = FlockStateManager();
      await fm.spawn(GameConfig.sheepCount);
      final b = fm.state.buffers;
      await fm.applyBark(b.x[0], b.y[0], 0);
      expect(b.phase[0], SheepPhase.frightened);
      await fm.dispose();
    });

    test('two dogs on opposite sides push a sheep along their combined vector',
        () async {
      final fm = FlockStateManager();
      await fm.spawn(GameConfig.sheepCount);
      final b = fm.state.buffers;
      // Isolate sheep 0 in open space; park the rest far away so only the dogs
      // act on it.
      for (var i = 1; i < b.count; i++) {
        b.x[i] = 20;
        b.y[i] = 20;
      }
      b.x[0] = 500;
      b.y[0] = 500;
      b.vx[0] = 0;
      b.vy[0] = 0;
      b.phase[0] = SheepPhase.calm;

      // Dogs just below-left and below-right of the sheep, symmetric in x.
      final r = GameConfig.fleeRadius * 0.5;
      await fm.step(1 / 60, [500 - r, 500 + r], [500 + r, 500 + r], [0, 1]);

      // Symmetric horizontal threats cancel; the sheep flees straight up (-y).
      expect(b.phase[0], SheepPhase.frightened);
      expect(b.vy[0], lessThan(0), reason: 'combined threat points away (up)');
      expect(b.vx[0].abs(), lessThan(10), reason: 'x threats cancel out');
      await fm.dispose();
    });

    test('panic spreads by contact but not by radius', () async {
      final fm = FlockStateManager();
      await fm.spawn(GameConfig.sheepCount);
      final b = fm.state.buffers;

      // Infector: sheep 0, frightened, fleeing +x at full potency.
      b.x[0] = 500;
      b.y[0] = 500;
      b.vx[0] = GameConfig.frightenedSpeed;
      b.vy[0] = 0;
      b.phase[0] = SheepPhase.frightened;
      b.potency[0] = GameConfig.directFrightPotency;
      b.timer[0] = GameConfig.calmDownTime;

      // Sheep 1: calm, in contact (< separationRadius) on the +x side.
      b.x[1] = 508;
      b.y[1] = 500;
      b.vx[1] = 0;
      b.vy[1] = 0;
      b.phase[1] = SheepPhase.calm;
      b.potency[1] = 0;

      // Sheep 2: calm, far from any frightened sheep → must stay calm
      // (proves contagion is by contact, not by radius).
      b.x[2] = 180;
      b.y[2] = 180;
      b.phase[2] = SheepPhase.calm;
      b.potency[2] = 0;

      await fm.step(1 / 60, [5000], [5000], [0]); // dog far away

      expect(b.phase[1], SheepPhase.frightened, reason: 'contact should infect');
      expect(b.vx[1], greaterThan(0), reason: 'infected runs the pusher way');
      expect(b.potency[1], lessThan(GameConfig.directFrightPotency),
          reason: 'chained fright is weaker than direct');
      expect(b.phase[2], SheepPhase.calm, reason: 'no contact ⇒ no panic');
      await fm.dispose();
    });

    test('stepping never leaves a sheep stuck inside a wall', () async {
      final fm = FlockStateManager();
      await fm.spawn(GameConfig.sheepCount);
      for (var f = 0; f < 60; f++) {
        await fm.step(1 / 60, [0], [0], [0]); // dog parked in the corner
      }
      final b = fm.state.buffers;
      final walls = GameConfig.buildWalls();
      for (var i = 0; i < b.count; i++) {
        for (final w in walls) {
          // Centre must not be deep inside a wall (allow a sub-radius margin).
          final inside = b.x[i] > w.left + 0.5 &&
              b.x[i] < w.right - 0.5 &&
              b.y[i] > w.top + 0.5 &&
              b.y[i] < w.bottom - 0.5;
          expect(inside, isFalse);
        }
      }
      await fm.dispose();
    });
  });
}
