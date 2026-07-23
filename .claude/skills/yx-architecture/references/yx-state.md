# yx_state (state management)

Package: `yx_state: ^1.0.0`. Two types matter:

- `StateManager<State>` — owns and mutates one state.
- `StateReadable<State>` — read-only interface everyone else depends on:
  ```dart
  abstract class StateReadable<State> {
    Stream<State> get stream; // broadcast; emits on change
    State get state;          // current value
  }
  ```

`StateManager` already implements `StateReadable`, plus: `close()`, `addError(error, st)`, and the protected `handle(...)` used to mutate state.

## How a StateManager is written here

Every StateManager in this repo follows this shape (see `lib/domain/state_managers/`):

```dart
class AimStateManager extends StateManager<AimState> implements AsyncLifecycle {
  AimStateManager(super.initial); // constructor only passes initial state to super

  @override
  Future<void> init() async {}     // one-time setup (subscriptions, etc.) — empty if none

  @override
  Future<void> dispose() async {
    await close();                 // release the stream
  }

  // A mutation: read `state`, emit the next value. Mutate ONLY via handle/emit.
  Future<void> move(double dx, double dy) => handle((emit) async {
    final newX = (state.x + dx).clamp(0.0, GameConfig.gameWidth);
    final newY = (state.y + dy).clamp(0.0, GameConfig.gameHeight);
    emit(state.copyWith(x: newX, y: newY));
  });
}
```

Rules in practice:

- **Mutate state only inside `handle((emit) async { ... emit(next); })`.** Never expose a setter that assigns state directly.
- The state object is **Freezed** — produce the next value with `copyWith` or a union factory, never mutate in place (see `conventions.md`).
- `implements AsyncLifecycle` so the DI scope can `init()`/`dispose()` it exactly once. `dispose()` calls `close()`.
- **Constructor does no work** beyond `super(initial)` — no subscriptions, no async. Put those in `init()`.
- A StateManager **must not depend on another StateManager or an Interactor.** If it needs another state, that coordination belongs in an Interactor. (Exception that already exists: event-style managers may be handed sibling event managers as collaborators when they are pure write-sinks — keep this rare and deliberate.)

## How state is consumed

**Interactors** take `StateReadable<T>` for reads and the concrete `StateManager` for writes:

```dart
class AimInteractor {
  final AimStateManager _aimState;              // write
  final StateReadable<ArtifactsState> _artifacts; // read-only
  AimInteractor({required AimStateManager aimState, required StateReadable<ArtifactsState> artifactsState})
      : _aimState = aimState, _artifacts = artifactsState; // assign only

  void update(double dt) {
    // ...compute using _artifacts.state...
    _aimState.move(dx, dy); // write through the manager's method
  }
}
```

**Flame Components / overlays** take `StateReadable<T>` only (never a `StateManager` for writes — go through an Interactor). See `flame.md`.

**Tests** fake state by implementing `StateReadable<T>` directly (see `test/domain/...`). That is the intended seam — keep state behind `StateReadable` so it stays mockable.

## Observability

Global hooks exist if needed: `StateManagerObserver` (override `onChange`, etc.) and `StateManagerOverrides` (`observer`, `defaultShouldEmit`). Wire once at startup. Don't sprinkle logging inside managers.
