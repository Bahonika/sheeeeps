import '../ports/game_ports.dart';
import 'game_loop_interactor.dart';
import 'input_interactor.dart';

/// Binds the local player's view commands to the authoritative simulation
/// (solo & host). A thin adapter: it fixes the [_localPlayerId] so the view can
/// stay ignorant of ids, and routes restart to the loop. Holds no state.
class LocalSessionController implements GameInputPort {
  LocalSessionController({
    required InputInteractor input,
    required GameLoopInteractor loop,
    required int localPlayerId,
  })  : _input = input,
        _loop = loop,
        _localPlayerId = localPlayerId;

  final InputInteractor _input;
  final GameLoopInteractor _loop;
  final int _localPlayerId;

  @override
  void moveTo(double worldX, double worldY) =>
      _input.moveTo(_localPlayerId, worldX, worldY);

  @override
  void bark() => _input.bark(_localPlayerId);

  @override
  void requestRestart() => _loop.restart();
}
