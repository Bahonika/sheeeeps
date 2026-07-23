import '../state_managers/dogs_state_manager.dart';
import '../state_managers/flock_state_manager.dart';

/// 2nd-order coordinator for player input, addressed by player id. This is the
/// single seam through which *any* command reaches the simulation — a local
/// mouse click and a decoded socket message both land here, keeping host and
/// solo on identical code (TZ step 1).
///
/// Holds no business state. Bark gating reads the addressed dog's current
/// cooldown and, when allowed, fires both that dog's bark and the flock's
/// shock-wave at that dog's position.
class InputInteractor {
  InputInteractor({
    required DogsStateManager dogs,
    required FlockStateManager flock,
  })  : _dogs = dogs,
        _flock = flock;

  final DogsStateManager _dogs;
  final FlockStateManager _flock;

  /// Command dog [playerId] to run to a world-space point.
  void moveTo(int playerId, double worldX, double worldY) =>
      _dogs.setTarget(playerId, worldX, worldY);

  /// Attempt a bark for dog [playerId]. No-op while on cooldown or if unknown.
  void bark(int playerId) {
    final dog = _dogs.state.byId(playerId);
    if (dog == null || !dog.canBark) return;
    _dogs.bark(playerId);
    _flock.applyBark(dog.x, dog.y, playerId);
  }
}
