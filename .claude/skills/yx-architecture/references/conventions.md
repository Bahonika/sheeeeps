# Conventions (hard rules)

## Freezed for all domain state

Every domain state is a Freezed class (`freezed: ^3.0.0`). Add `part 'x.freezed.dart';` and run the generator.

**Simple state** — a single factory:

```dart
@freezed
sealed class AimState with _$AimState {
  const factory AimState({required double x, required double y}) = _AimState;
}
```

**Variant state** — a `sealed` union when the state has distinct cases. Add `const X._();` to attach getters/methods:

```dart
@freezed
sealed class GameState with _$GameState {
  const GameState._();
  const factory GameState.preGame() = _PreGame;
  const factory GameState.running() = _Running;
  const factory GameState.lottery(LotteryData data) = _Lottery;
  const factory GameState.gameOver(GameOverData data) = _GameOver;

  bool get isRunning => this is _Running;
  bool get isPaused => switch (this) { _Lottery() => true, _ => false };
}
```

Rules:
- Produce the next state with `copyWith` or a union factory inside a `StateManager`'s `handle/emit`. Never mutate in place.
- Put pure derived getters (`isRunning`, `isPaused`) on the state via `const X._();` — keep them pure, no side effects.
- Use `sealed` so consumers can exhaustively `switch`. Reach for a union only when variants genuinely differ; otherwise a single-factory state is simpler.
- After editing a Freezed file, regenerate: `dart run build_runner build --delete-conflicting-outputs`.

## No `Function` in a dependency

A class must not declare a `Function`-typed **injected dependency** (constructor field / member you depend on).

**Why:** yx_scope builds a declarative, compile-safe dependency graph. A raw closure/callback as a dependency hides the real collaborator, defeats traceability and the scope linter, and escapes the lifecycle (`init`/`dispose`). It also makes tests assert on opaque callbacks instead of real seams.

**How to apply:** inject the owning object — an `Interactor`, `StateManager`, or `Source` — and call its method.

```dart
// NOT OK
class FooInteractor { FooInteractor({required void Function() onDone}); }

// OK
class FooInteractor {
  final BarInteractor _bar;
  FooInteractor({required BarInteractor bar}) : _bar = bar;
  void finish() => _bar.onFooDone();
}
```

Not a violation: passing `someDep.get` as a constructor *argument while assembling another `dep(() => ...)`* in a `ScopeContainer` — that is yx_scope's own wiring mechanism, not an injected `Function` field.

## No logic in a constructor

A constructor only assigns fields (and may pass initial values to `super`). No business logic, no async work, no subscriptions, no `init`.

**Why:** yx_scope separates **creation** from **initialization** — deps are constructed when the container is built, then initialized exactly once via `AsyncLifecycle` (`init`/`dispose`) in `initializeQueue` order. Work in a constructor can run before the scope is ready and makes ordering and disposal unreliable.

**How to apply:**
- `StateManager` / coordinating `Interactor`: do setup (subscriptions, async) in `init()`, teardown in `dispose()`. Constructor body is just `: _a = a, _b = b;` (or `super(initial)`).
- Flame `Component`: do setup in `onLoad`, teardown in `onRemove`. Constructor may seed `super` (e.g. an initial `position` read from `state`) but must not subscribe or mutate.

```dart
class GameLifecycleInteractor implements AsyncLifecycle {
  final StateReadable<TowerState> _towerState;
  StreamSubscription<TowerState>? _sub;
  GameLifecycleInteractor({required StateReadable<TowerState> towerState}) : _towerState = towerState; // assign only

  @override
  Future<void> init() async { _sub ??= _towerState.stream.listen(_onTower); } // subscribe here
  @override
  Future<void> dispose() async { await _sub?.cancel(); _sub = null; }
}
```
