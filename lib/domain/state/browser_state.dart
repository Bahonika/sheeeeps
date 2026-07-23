import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/discovered_room.dart';

part 'browser_state.freezed.dart';

/// The set of rooms the join screen currently knows about, freshest data per
/// host+port. Ordered for a stable list; pruning of stale entries happens in the
/// owning manager.
@freezed
sealed class BrowserState with _$BrowserState {
  const BrowserState._();

  const factory BrowserState({
    @Default(<DiscoveredRoom>[]) List<DiscoveredRoom> rooms,
  }) = _BrowserState;

  bool get isEmpty => rooms.isEmpty;
}
