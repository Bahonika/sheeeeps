# Flame (Presentation layer)

Flame `Component`s are **Presentation**. A `Component` is the View: `render` is its `build`. It may depend only on `StateReadable` and `Interactor` — never on a `StateManager` for writes, never on the DI container.

## Two kinds of component

**1. Pure view** — bound to a `StateReadable`, no interactor, no logic. Reads state to position/draw itself. Example `AimComponent` (`lib/presentation/game/components/aim_component.dart`):

```dart
class AimComponent extends PositionComponent {
  final StateReadable<AimState> aimState;
  AimComponent({required this.aimState})
      : super(position: Vector2(aimState.state.x, aimState.state.y), /* seed super only */);

  @override
  void update(double dt) {
    super.update(dt);
    position.setFrom(Vector2(aimState.state.x, aimState.state.y)); // mirror state → no decision
  }
  // render() draws; no branching on business state
}
```

Reading `state` in `update` to mirror it into a visual property is fine. **Making a business decision from `state` in `update` is not** — that belongs in an Interactor.

**2. Delegating component** — owns input/lifecycle and forwards to an Interactor. Lifecycle methods are entry points that call the Interactor and nothing else:

```dart
class PlayerComponent extends PositionComponent {
  final StateReadable<PlayerState> playerState;
  final PlayerInteractor playerInteractor;
  PlayerComponent({required this.playerState, required this.playerInteractor});

  @override
  Future<void> onLoad() async {
    await playerInteractor.onLoad();
    // bind visuals to state (see StateListenerComponent below)
  }

  @override
  void update(double dt) => playerInteractor.update(dt); // pure delegation

  @override
  void onRemove() {
    playerInteractor.onRemove();
    super.onRemove();
  }
}
```

Input and collisions delegate the same way: `onTap`, `onCollision`, etc. call an Interactor method. **No type checks, no conditionals, no business logic inside a component.**

## Reacting to state: `StateListenerComponent`

The repo's reactive primitive is `StateListenerComponent<S>` (`lib/presentation/game/components/.../utils/state_listener_component.dart`) — it subscribes to a `StateReadable.stream` and calls `listener(previous, current)`, with optional `listenWhen`. Use it to add/remove child components in response to state. Real example, spawning enemy components from `EnemyState` (`enemies_manager_component.dart`):

```dart
add(StateListenerComponent<EnemyState>(
  stateReadable: enemyState,
  listener: (previous, current) {
    final added = current.enemies.keys.toSet().difference(previous.enemies.keys.toSet());
    final removed = previous.enemies.keys.toSet().difference(current.enemies.keys.toSet());
    for (final id in removed) { _components.remove(id); }
    for (final id in added) { add(EnemyComponent(/* deps from constructor */)); }
  },
));
```

> Note: some yx examples mention a `StateBuilderComponent` for binding a single state to visual props. **It does not exist in this repo** — use `StateListenerComponent` (or read `state` directly in `update` for a pure view). If a builder helper is wanted, add it deliberately; don't reference a class that isn't there.

## Dependency injection into components

- A `Component` receives its dependencies **through its constructor**, as plain fields — resolved from the Scope at the place where the component is created (in the widget tree for the root `FlameGame`, or by a parent component for children).
- The root `FlameGame` (`SpellGame`) is constructed in the widget tree from the resolved game scope (`lib/main.dart`), passing `StateReadable`s and `Interactor`s in.
- Constructors only assign / seed `super`. Subscriptions and async setup go in `onLoad`; teardown in `onRemove` (cancel subscriptions, then `super.onRemove()`).

## Prohibited

- `HasGameReference` (or storing deps on `FlameGame`) to fetch dependencies.
- Creating `Component`s inside the DI container.
- A `Component` depending on a `StateManager` (writes) directly.
- Using `Shared`, globals, or singletons to pass dependencies.
- Any business logic or conditional in a `Component` lifecycle method.
- Reading `state` in `update` to make a business decision (mirroring it into a visual property is allowed).
