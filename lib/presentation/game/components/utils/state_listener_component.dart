import 'dart:async';

import 'package:flame/components.dart';
import 'package:yx_state/yx_state.dart';

/// Reactive primitive: subscribes to a [StateReadable] and invokes [listener]
/// on each change (optionally gated by [listenWhen]). Used to add/remove child
/// components in response to domain state — the sanctioned way for a Flame view
/// to react without embedding business logic.
class StateListenerComponent<S> extends Component {
  StateListenerComponent({
    required this.stateReadable,
    required this.listener,
    this.listenWhen,
  });

  final StateReadable<S> stateReadable;
  final void Function(S? previous, S current) listener;
  final bool Function(S? previous, S current)? listenWhen;

  StreamSubscription<S>? _sub;
  S? _previous;

  @override
  Future<void> onLoad() async {
    _previous = stateReadable.state;
    _sub = stateReadable.stream.listen((current) {
      final previous = _previous;
      if (listenWhen?.call(previous, current) ?? true) {
        listener(previous, current);
      }
      _previous = current;
    });
  }

  @override
  void onRemove() {
    _sub?.cancel();
    _sub = null;
    super.onRemove();
  }
}
