import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../models/discovered_room.dart';
import '../state/browser_state.dart';

/// 1st-order owner of the discovered-rooms list. The room-browser interactor
/// feeds announcements in and prunes stale ones; the join screen reads the list.
class BrowserStateManager extends StateManager<BrowserState>
    implements AsyncLifecycle {
  BrowserStateManager() : super(const BrowserState());

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Insert or refresh a room (keyed by host+port).
  Future<void> upsert(DiscoveredRoom room) => handle((emit) async {
        final rooms = [
          for (final r in state.rooms)
            if (!(r.host == room.host && r.port == room.port)) r,
          room,
        ]..sort((a, b) => a.roomName.compareTo(b.roomName));
        emit(BrowserState(rooms: rooms));
      });

  /// Drop rooms not seen since [minClock].
  Future<void> pruneOlderThan(double minClock) => handle((emit) async {
        final kept =
            state.rooms.where((r) => r.lastSeenClock >= minClock).toList();
        if (kept.length == state.rooms.length) return;
        emit(BrowserState(rooms: kept));
      });
}
