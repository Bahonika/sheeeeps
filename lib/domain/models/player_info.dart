import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_info.freezed.dart';

/// Identity of one shepherd in a session: a stable [id] (assigned by the host,
/// or 0 for the local solo player), a display [name] shown over the dog and in
/// the lobby, and a [colorIndex] into the fixed dog palette.
///
/// Plain immutable domain model shared by the lobby roster and the dog state —
/// it carries no behaviour, only the few fields the presentation needs to draw a
/// named, coloured dog.
@freezed
abstract class PlayerInfo with _$PlayerInfo {
  const factory PlayerInfo({
    required int id,
    required String name,
    required int colorIndex,
  }) = _PlayerInfo;
}
