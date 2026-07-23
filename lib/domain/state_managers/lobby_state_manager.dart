import 'package:yx_scope/yx_scope.dart';
import 'package:yx_state/yx_state.dart';

import '../models/player_info.dart';
import '../state/lobby_state.dart';

/// 1st-order owner of the session roster. Coordinating interactors (host accept
/// loop, client snapshot apply) call these mutators; the lobby UI and dog seeder
/// read the state.
class LobbyStateManager extends StateManager<LobbyState>
    implements AsyncLifecycle {
  LobbyStateManager(super.initial);

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await close();
  }

  /// Add a joiner (no-op if the id already exists or the room is full).
  Future<void> addPlayer(PlayerInfo player) => handle((emit) async {
        final s = state;
        if (s.isFull || s.players.any((p) => p.id == player.id)) return;
        emit(s.copyWith(players: [...s.players, player]));
      });

  /// Remove a player by id (they left / disconnected).
  Future<void> removePlayer(int id) => handle((emit) async {
        final s = state;
        emit(s.copyWith(
          players: s.players.where((p) => p.id != id).toList(),
        ));
      });

  /// Replace the whole roster (client mirroring the host's authoritative list).
  Future<void> setPlayers(List<PlayerInfo> players) => handle((emit) async {
        emit(state.copyWith(players: players));
      });

  Future<void> setHostAddress(String address) => handle((emit) async {
        emit(state.copyWith(hostAddress: address));
      });

  /// Client mirror: adopt the id the host assigned us and the room's name.
  Future<void> setLocalIdentity({required int id, required String roomName}) =>
      handle((emit) async {
        emit(state.copyWith(localPlayerId: id, roomName: roomName));
      });

  Future<void> setStarted(bool started) => handle((emit) async {
        emit(state.copyWith(started: started));
      });
}
