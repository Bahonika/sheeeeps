import 'package:freezed_annotation/freezed_annotation.dart';

import 'dog_state.dart';

part 'dogs_state.freezed.dart';

/// The set of dogs currently on the field, keyed by player id.
///
/// Only 1–4 entries ever exist, so a plain immutable `Map<int, DogState>` with
/// Freezed deep equality is cheap to rebuild each frame — no SoA needed here
/// (contrast the flock). Mutations replace the map with a new one inside the
/// owning [DogsStateManager].
@freezed
sealed class DogsState with _$DogsState {
  const DogsState._();

  const factory DogsState({@Default(<int, DogState>{}) Map<int, DogState> dogs}) =
      _DogsState;

  /// Stable-ordered list (by id) for rendering and iteration.
  List<DogState> get ordered =>
      dogs.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  DogState? byId(int id) => dogs[id];

  int get count => dogs.length;
}
