---
name: yx-architecture
description: Architecture rules for this Flutter + Flame game built on yx_scope (DI) and yx_state (state). Use whenever adding or reworking a feature, or creating/changing a StateManager, Interactor, Freezed state, DI scope (ScopeContainer / ScopeHolder / dep), or a Flame Component — or making any layering / architectural decision. Defines hard layer boundaries and the yx_state / yx_scope conventions the codebase must follow. Not needed for trivial, local edits.
---

# yx-architecture

This project follows a layered ("clean") architecture built around two Yandex packages:

- **yx_scope** — compile-safe DI (scopes, containers, holders, deps).
- **yx_state** — reactive state (`StateManager`, `StateReadable`).

These are **hard rules**. When a change would violate them, do not silently comply — flag the conflict and propose a compliant design. Apply them when doing architectural work or building a feature; you may relax them only for throwaway/experimental code if the user explicitly says so.

## When to read the reference files

Read the relevant file under `references/` before writing code in that area — they contain the real APIs (grounded in the installed package versions and this repo) and worked examples:

- `references/architecture.md` — layers, dependency directions, the roles (StateManager / Interactor / StateProvider / View), Data↔Domain boundaries. **Read this for any new feature or cross-layer decision.**
- `references/yx-state.md` — `StateManager` / `StateReadable` API + how state is mutated and consumed here. **Read when touching a StateManager or state.**
- `references/yx-scope.md` — DI: `ScopeContainer`, `ChildScopeContainer`, holders, `dep` / `asyncDep`, `initializeQueue`, UI wiring. **Read when wiring dependencies or adding a scope.**
- `references/flame.md` — Flame `Component` as View, lifecycle delegation, constructor DI, `StateListenerComponent`. **Read when adding/changing a game component.**
- `references/conventions.md` — Freezed state, "no Function in a dependency", "no logic in a constructor". **Read when defining state or constructors.**

## The non-negotiable rules (summary)

1. **Layer dependencies only point inward.** `DI → all`, `Presentation → Domain, Shared`, `Domain → Data, Shared`, `Data → Shared`, `Shared → nothing`. Data flows `Data → Domain → Presentation`.
2. **Call chain:** `View/Component → Interactor → StateManager → Repository → Source`. A View never reaches past an Interactor; a Component never touches a `StateManager` for writes — only via an Interactor.
3. **State lives in `StateManager` only.** It holds and mutates exactly one business state and contains 1st-order business logic. Everyone else reads through the `StateReadable` interface (`state` + `stream`).
4. **Interactors hold no business state** (only service state: subscriptions, timers, completers). They coordinate one or many StateManagers/Interactors (2nd-order logic).
5. **Domain must not import Flutter/Flame.** (Narrow, documented exceptions only, e.g. a navigation interactor.) Flame `Component`s are Presentation.
6. **No business logic or conditionals inside a Flame `Component`.** Lifecycle methods (`onLoad`/`update`/`onRemove`/input/collision) delegate straight to an Interactor.
7. **No `Function` as an injected dependency.** Inject the owning object (Interactor / StateManager / Source) and call its method. See `conventions.md`.
8. **No logic, subscriptions, or initialization in a constructor.** Constructors only assign fields (and may pass initial values to `super`). Setup goes in `init()` (yx_state `AsyncLifecycle`) or a Component's `onLoad`; teardown in `dispose()` / `onRemove`. See `conventions.md`.
9. **All domain state is Freezed.** Use `sealed` unions when a state has distinct variants (e.g. `GameState`). See `conventions.md`.
10. **DI is declarative and compile-safe.** Dependencies are assembled in `ScopeContainer`s via `dep` / `asyncDep`; creation is separated from initialization (`initializeQueue`, `init`/`dispose`). No singletons, no global access, no `HasGameReference` for dependency lookup.

## Source of truth

The conventions mirror the yx_scope / yx_state architecture ("yx_architecture"). When in doubt, follow the real package APIs (documented in the reference files) and the existing patterns in this repo (`lib/di`, `lib/domain`, `lib/presentation`).
