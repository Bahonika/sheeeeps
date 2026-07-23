import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/player_info.dart';

part 'lobby_state.freezed.dart';

/// Roster of a session's shepherds plus the room metadata shown in the lobby.
///
/// Used uniformly across modes: solo seeds it with a single local player, a host
/// grows/shrinks it as clients join and leave, and a client mirrors the host's
/// roster so it can draw the same player list. [localPlayerId] identifies which
/// entry is "me" (whose input the local controls drive).
@freezed
sealed class LobbyState with _$LobbyState {
  const LobbyState._();

  const factory LobbyState({
    required String roomName,
    required int localPlayerId,
    required List<PlayerInfo> players,
    @Default('') String hostAddress,
    @Default(false) bool started,
    @Default(4) int maxPlayers,
  }) = _LobbyState;

  PlayerInfo? get localPlayer =>
      players.where((p) => p.id == localPlayerId).firstOrNull;

  bool get isFull => players.length >= maxPlayers;

  /// Lowest colour index not yet taken (0..[maxPlayers]-1) — the slot a joiner
  /// gets. Falls back to a wrapped index if somehow all are taken.
  int get nextColorIndex {
    final taken = players.map((p) => p.colorIndex).toSet();
    for (var i = 0; i < maxPlayers; i++) {
      if (!taken.contains(i)) return i;
    }
    return players.length % maxPlayers;
  }

  /// Lowest positive player id not yet taken (host is always id 0).
  int get nextPlayerId {
    final taken = players.map((p) => p.id).toSet();
    var id = 1;
    while (taken.contains(id)) {
      id++;
    }
    return id;
  }
}
