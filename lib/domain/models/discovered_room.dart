import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovered_room.freezed.dart';

/// A room heard on the LAN via UDP broadcast. [lastSeenClock] is the browser's
/// local clock at the last announcement, used to prune rooms whose host has gone
/// quiet. Identity for de-duplication is host+port.
@freezed
abstract class DiscoveredRoom with _$DiscoveredRoom {
  const factory DiscoveredRoom({
    required String host,
    required int port,
    required String roomName,
    required int playerCount,
    required int maxPlayers,
    required double lastSeenClock,
  }) = _DiscoveredRoom;
}
