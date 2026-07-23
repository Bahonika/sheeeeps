/// Presentation-facing seams that decouple the Flame view from *how* a session
/// is driven. The same [SheepdogGame] runs a solo game, a host game and a client
/// view; only the objects behind these ports differ.
///
/// This is TZ step 1 — "game input behind an interface": the simulation accepts
/// "this player runs to a point / barks" regardless of whether the command came
/// from the local mouse or a socket.
library;

/// Commands the local player issues from the view (mouse/keyboard/touch).
///
/// Solo & host: a local adapter forwards to the simulation for the local dog.
/// Client: an adapter serialises and sends them to the host over the socket.
abstract interface class GameInputPort {
  void moveTo(double worldX, double worldY);
  void bark();

  /// Restart the level. Host/solo reseed immediately; on a client this is a
  /// no-op (only the host is authoritative).
  void requestRestart();
}

/// Per-frame drive for the world. Solo/host advances one simulation tick; a
/// client advances snapshot interpolation. Called from `SheepdogGame.update`.
abstract interface class GameTickPort {
  void update(double dt);
}
