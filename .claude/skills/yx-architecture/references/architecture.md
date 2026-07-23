# Architecture (layers & roles)

## Glossary

- **Business state** — state of a business context (a feature, an entity, the run). Lives in a `StateManager`.
- **Service state** — technical fields of a class (`StreamSubscription`, `Completer`, timers, `isDisposed`). Not business logic. Allowed in Interactors.
- **Ephemeral state** — UI/animation-local state (e.g. a particle's progress). Allowed inside a Component.
- **1st-order business logic** — changes exactly one business state. Lives in a `StateManager`.
- **2nd-order business logic** — orchestrates several 1st-order logics. Lives in an `Interactor`.
- **StateReadable** — read-only interface: `T get state; Stream<T> get stream;` (from yx_state).

## Layers

`Shared`, `Data`, `Domain`, `Presentation`, `DI`.

**Dependency directions** (A → B means "A may depend on B"):

- `DI → all layers`
- `Presentation → Domain, Shared`
- `Domain → Data, Shared`
- `Data → Shared`
- `Shared → nothing`

**Data flow:** `Data → Domain → Presentation`.

**Call chain:** `View/Component → Interactor → StateManager → Repository → Source (Api / Storage / Service)`.

In this repo the directories are: `lib/data/`, `lib/domain/` (`state/`, `state_managers/`, `interactors/`, `models/`), `lib/presentation/` (`game/components/`, `overlays/`, `controllers/`), `lib/di/`, `lib/shared/`.

## Data layer

Read/write access to data. State is optional here (only as cache).

- **Source** — raw access to data:
  - **Api** — remote storage.
  - **Storage** — local (DB, files, `SharedPreferences`).
  - **Service** — an external module/library wrapper (e.g. `AudioService` over `flutter_soloud`, asset sources).
- **Repository** — maps and combines data between Sources and the Domain. Repositories do not depend on each other; cross-cutting coordination happens in the Domain via StateManagers.

This game is largely state-driven and has thin Data needs: today the Data layer is asset/audio Sources (`lib/data/sources/`). Repositories appear when real persistence/remote data is added.

### Data ↔ Domain boundary (pick the lightest that fits)

- **Easy** — Domain imports Data and works with `Source` directly. (Acceptable when a Source is exclusive to one StateManager.)
- **Medium** — Domain works through a `Repository`; Data may know Domain entities.
- **Hard** — Domain declares the `Repository` interface; Data implements it. (Use when Data must not leak into Domain.)

## Domain layer

Business logic and state. Only **StateManager** and **Interactor** (plus plain models and pure helpers). **No Flutter/Flame imports** (narrow documented exceptions only).

### StateManager (1st-order)

- Implements `StateReadable` (via yx_state). Holds and mutates **only its own** business state.
- Talks to Data via a Repository (or directly to a Source if that Source is exclusive to it).
- **Does not depend on other StateManagers or Interactors.**
- **Does not duplicate** another state's data — map instead of copying.
- If state transitions need validation/guarding, wrap the manager in an Interactor.

See `yx-state.md` for the API and examples.

### Interactor (2nd-order)

- Holds **no business state** — only service state (subscriptions, timers).
- May depend on many StateManagers (for writes) and `StateReadable`s (for reads) and other Interactors.
- Methods either cause side-effects or return values (prefer pure where possible).
- **Reactive** style: subscribe to a `StateReadable` and react to changes (in `init()`, cancel in `dispose()`).
- **Imperative** style: allowed when a strict sequence is required.
- A real example here is `GameLifecycleInteractor` (`lib/domain/interactors/game_lifecycle_interactor.dart`): it `implements AsyncLifecycle`, subscribes to tower/wave state in `init()`, drives the pre-game countdown in `update(dt)`, and ends the game — orchestrating several states without owning any.

### StateProvider (concept — not currently used here)

A read-only `StateReadable` that aggregates several StateManagers into one composite domain model. **Not implemented in this repo today.** If you need a combined read model, prefer either:
- exposing the underlying `StateReadable`s and combining in the consumer, or
- hand-rolling a class that `implements StateReadable<Composite>` and derives its `state`/`stream` (e.g. with `rxdart`) from the source managers.

Do not invent a `StateProvider` base class — there is none in yx_state.

## Presentation layer

Turns state into UI and forwards events.

- **View / Widget / Flame Component** — depends only on `Interactor` and `StateReadable`. Converts state to UI; forwards events to an Interactor. Parameter-based computation may live inside the widget. Flame specifics in `flame.md`.
- **Screen** — composition of Views (in this repo, `main.dart` composes the `GameWidget` + overlays).
- Presentation may also hold small UI controllers for ephemeral visual state (e.g. `PrayerFeedbackController`, a `Listenable` for shake) — these are not business state.

## Boundaries / mapping

Map at the seams: `Data → Domain` (DTO → Entity) and `Domain → View`. Mapping may be omitted for a simple feature, a single team, or when a BFF exists; a shared single model then lives in `Shared`. State→data mapping convention:

```dart
extension MyStateToMyData on MyState {
  MyData get asMyData => /* convert */;
}
// Use: stateManager.stream.map((s) => s.asMyData)
// NOT: a bespoke stateManager.myDataStream getter
```

## Shared layer

No dependencies. Common value types and pure utilities only (e.g. `lib/shared/game_config.dart`, `lib/shared/game_theme.dart`).
