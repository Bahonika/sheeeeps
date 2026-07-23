import 'package:yx_state/yx_state.dart';

import '../data/sources/sprite_source.dart';
import '../domain/ports/game_ports.dart';
import '../domain/state/dogs_state.dart';
import '../domain/state/flock_state.dart';
import '../domain/state/game_state.dart';
import '../domain/state/lobby_state.dart';

/// The read-only surface every playable session (solo, host, client) exposes to
/// the Flame view and its overlays. The three scopes wire very different graphs
/// behind it — a local simulation, a host with networking, a snapshot mirror —
/// but the view depends only on this, so it is mode-agnostic.
abstract interface class GameSessionScope {
  SpriteSource get spriteSource;
  StateReadable<FlockState> get flockState;
  StateReadable<DogsState> get dogsState;
  StateReadable<GameState> get gameState;
  StateReadable<LobbyState> get lobbyState;
  GameInputPort get inputPort;
  GameTickPort get tickPort;
  int get localPlayerId;

  /// Whether this player may restart the level (host/solo) or must wait for the
  /// host (client). Drives the win overlay and touch-controls restart button.
  bool get canRestart;
}
