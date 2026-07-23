# yx_scope (dependency injection)

Packages: `yx_scope: ^1.2.0`, `yx_scope_flutter: ^1.2.0`. Compile-safe DI — no codegen, no service locator, no globals.

## Core idea

> The DI container is primary; UI is attached to it, not the other way around. **UI does not create scopes; scopes create UI.**

Key entities:

- **Dep** — a holder for one instance. Declared with `dep(() => ...)` (sync) or `asyncDep(() => ...)` (has `AsyncLifecycle`). Access the instance via `.get`.
- **ScopeContainer** — an isolated set of deps sharing a lifecycle.
- **ScopeHolder** — owns a container's lifecycle: `create()` builds it, `drop()` disposes it. Holds `null` until created (compile-safe existence check).

## Root scope (real pattern in `lib/di/`)

A scope exposes a public interface (suffix `Scope`); the container implements it and declares the deps:

```dart
abstract interface class RootScope {
  GameStateManager get gameState;
  AudioService get audioService;
  // ...getters for everything the scope exposes
}

class RootScopeContainer extends ScopeContainer implements RootScope {
  late final _gameStateDep = asyncDep(() => GameStateManager());
  late final _audioServiceDep = asyncDep(() => AudioService());
  late final _musicInteractorDep = asyncDep(
    () => MusicInteractor(audioService: _audioServiceDep.get, gameState: _gameStateDep.get),
  );

  @override
  GameStateManager get gameState => _gameStateDep.get;
  // ...other getters

  // Ordered async init: sets run sequentially; deps within a set run in parallel.
  @override
  List<Set<AsyncDep>> get initializeQueue => [
    {_audioServiceDep},
    {_gameStateDep, _spellAssetsDep, _slimeAssetsDep},
    {_soundInteractorDep, _musicInteractorDep},
  ];
}

class RootScopeHolder extends ScopeHolder<RootScopeContainer> {
  @override
  RootScopeContainer createContainer() => RootScopeContainer();
}
```

## Child scope (real pattern: `GameScopeContainer`)

A child scope reaches its parent's deps through `parent`:

```dart
class GameScopeContainer extends ChildScopeContainer<RootScopeContainer> implements GameScope {
  final double initialX;
  final double initialY;
  GameScopeContainer({required super.parent, required this.initialX, required this.initialY});

  late final _aimStateDep = asyncDep(() => AimStateManager(AimState(x: initialX, y: initialY)));

  late final _aimInteractorDep = dep(() => AimInteractor(
    aimState: _aimStateDep.get,
    inputState: _inputStateDep.get,
    artifactsState: _artifactsStateDep.get,
  ));

  // parent deps are used directly:
  late final _pauseInteractorDep = dep(() => PauseInteractor(gameState: parent.gameState));

  @override
  List<Set<AsyncDep>> get initializeQueue => [ /* event managers */, /* state managers */, /* lifecycle/coordinating interactors */ ];
}

class GameScopeHolder extends ChildScopeHolder<GameScopeContainer, RootScopeContainer> {
  final double initialX, initialY;
  GameScopeHolder(super.parent, {required this.initialX, required this.initialY});
  @override
  GameScopeContainer createContainer(RootScopeContainer parent) =>
      GameScopeContainer(parent: parent, initialX: initialX, initialY: initialY);
}
```

> The base classes used here are `ScopeContainer` / `ScopeHolder` and `ChildScopeContainer` / `ChildScopeHolder`. (Older docs mention `BaseScopeHolder` / `BaseChildScopeHolder` — use the names that exist in the installed package and the repo, shown above.)

## Conventions

- **`dep` vs `asyncDep`:** use `asyncDep` when the instance implements `AsyncLifecycle` (most StateManagers, and Interactors that subscribe). Otherwise `dep`. Every `asyncDep` should appear in `initializeQueue` in the right order.
- **`initializeQueue` ordering:** put producers before consumers. Event sinks first, then the StateManagers, then coordinating Interactors that subscribe to them (e.g. `GameLifecycleInteractor` last). Mirror what `GameScopeContainer` does.
- **Wiring is the only place dependencies are assembled.** Constructors elsewhere just receive what they need — they never look anything up.
- **No `Function` deps** even though `dep(() => ...)` uses closures internally: passing `xDep.get` as a constructor *argument when building another dep* is the DI mechanism and is fine; a domain/presentation class must not declare a `Function`-typed injected field. See `conventions.md`.

## Attaching to the widget tree (`yx_scope_flutter`)

Hold a `ScopeHolder` in a `StatefulWidget`, `create()` in `initState`, `drop()` in `dispose`. Expose to descendants with `ScopeProvider` + `ScopeBuilder`:

```dart
ScopeProvider<RootScopeContainer>(
  holder: _rootScopeHolder,
  child: ScopeBuilder<RootScopeContainer>.withPlaceholder(
    placeholder: const Center(child: CircularProgressIndicator()),
    builder: (context, rootScope) => /* use rootScope.* deps */,
  ),
);
```

The Flame `FlameGame` (`SpellGame`) is built **here**, receiving its dependencies from the resolved scope (`gameScope.aimState`, `gameScope.aimInteractor`, ...). See `flame.md` and `lib/main.dart`.
