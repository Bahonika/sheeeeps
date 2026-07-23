import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../../data/sources/name_store.dart';
import '../state/player_identity_state.dart';

/// 1st-order owner of the local player's name. Lives in the app scope so every
/// session reads the same identity. On the web the name is persisted to and
/// restored from `localStorage` via the injected [NameStore] (a no-op on
/// desktop), satisfying the TZ's "сохранять в localStorage".
class PlayerIdentityManager extends StateManager<PlayerIdentityState>
    implements AsyncLifecycle {
  PlayerIdentityManager(super.initial, {NameStore? store}) : _store = store;

  final NameStore? _store;

  @override
  Future<void> init() async {
    final saved = _store?.load();
    if (saved != null && saved.trim().isNotEmpty) {
      await handle((emit) async => emit(PlayerIdentityState(name: saved.trim())));
    }
  }

  @override
  Future<void> dispose() async {
    await close();
  }

  Future<void> setName(String name) => handle((emit) async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) return;
        emit(PlayerIdentityState(name: trimmed));
        _store?.save(trimmed);
      });
}
