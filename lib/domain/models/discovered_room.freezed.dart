// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovered_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoveredRoom {

 String get host; int get port; String get roomName; int get playerCount; int get maxPlayers; double get lastSeenClock;
/// Create a copy of DiscoveredRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveredRoomCopyWith<DiscoveredRoom> get copyWith => _$DiscoveredRoomCopyWithImpl<DiscoveredRoom>(this as DiscoveredRoom, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveredRoom&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.playerCount, playerCount) || other.playerCount == playerCount)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.lastSeenClock, lastSeenClock) || other.lastSeenClock == lastSeenClock));
}


@override
int get hashCode => Object.hash(runtimeType,host,port,roomName,playerCount,maxPlayers,lastSeenClock);

@override
String toString() {
  return 'DiscoveredRoom(host: $host, port: $port, roomName: $roomName, playerCount: $playerCount, maxPlayers: $maxPlayers, lastSeenClock: $lastSeenClock)';
}


}

/// @nodoc
abstract mixin class $DiscoveredRoomCopyWith<$Res>  {
  factory $DiscoveredRoomCopyWith(DiscoveredRoom value, $Res Function(DiscoveredRoom) _then) = _$DiscoveredRoomCopyWithImpl;
@useResult
$Res call({
 String host, int port, String roomName, int playerCount, int maxPlayers, double lastSeenClock
});




}
/// @nodoc
class _$DiscoveredRoomCopyWithImpl<$Res>
    implements $DiscoveredRoomCopyWith<$Res> {
  _$DiscoveredRoomCopyWithImpl(this._self, this._then);

  final DiscoveredRoom _self;
  final $Res Function(DiscoveredRoom) _then;

/// Create a copy of DiscoveredRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? port = null,Object? roomName = null,Object? playerCount = null,Object? maxPlayers = null,Object? lastSeenClock = null,}) {
  return _then(_self.copyWith(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,playerCount: null == playerCount ? _self.playerCount : playerCount // ignore: cast_nullable_to_non_nullable
as int,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,lastSeenClock: null == lastSeenClock ? _self.lastSeenClock : lastSeenClock // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveredRoom].
extension DiscoveredRoomPatterns on DiscoveredRoom {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoveredRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoveredRoom() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoveredRoom value)  $default,){
final _that = this;
switch (_that) {
case _DiscoveredRoom():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoveredRoom value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoveredRoom() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  int port,  String roomName,  int playerCount,  int maxPlayers,  double lastSeenClock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoveredRoom() when $default != null:
return $default(_that.host,_that.port,_that.roomName,_that.playerCount,_that.maxPlayers,_that.lastSeenClock);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  int port,  String roomName,  int playerCount,  int maxPlayers,  double lastSeenClock)  $default,) {final _that = this;
switch (_that) {
case _DiscoveredRoom():
return $default(_that.host,_that.port,_that.roomName,_that.playerCount,_that.maxPlayers,_that.lastSeenClock);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  int port,  String roomName,  int playerCount,  int maxPlayers,  double lastSeenClock)?  $default,) {final _that = this;
switch (_that) {
case _DiscoveredRoom() when $default != null:
return $default(_that.host,_that.port,_that.roomName,_that.playerCount,_that.maxPlayers,_that.lastSeenClock);case _:
  return null;

}
}

}

/// @nodoc


class _DiscoveredRoom implements DiscoveredRoom {
  const _DiscoveredRoom({required this.host, required this.port, required this.roomName, required this.playerCount, required this.maxPlayers, required this.lastSeenClock});
  

@override final  String host;
@override final  int port;
@override final  String roomName;
@override final  int playerCount;
@override final  int maxPlayers;
@override final  double lastSeenClock;

/// Create a copy of DiscoveredRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoveredRoomCopyWith<_DiscoveredRoom> get copyWith => __$DiscoveredRoomCopyWithImpl<_DiscoveredRoom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoveredRoom&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.playerCount, playerCount) || other.playerCount == playerCount)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.lastSeenClock, lastSeenClock) || other.lastSeenClock == lastSeenClock));
}


@override
int get hashCode => Object.hash(runtimeType,host,port,roomName,playerCount,maxPlayers,lastSeenClock);

@override
String toString() {
  return 'DiscoveredRoom(host: $host, port: $port, roomName: $roomName, playerCount: $playerCount, maxPlayers: $maxPlayers, lastSeenClock: $lastSeenClock)';
}


}

/// @nodoc
abstract mixin class _$DiscoveredRoomCopyWith<$Res> implements $DiscoveredRoomCopyWith<$Res> {
  factory _$DiscoveredRoomCopyWith(_DiscoveredRoom value, $Res Function(_DiscoveredRoom) _then) = __$DiscoveredRoomCopyWithImpl;
@override @useResult
$Res call({
 String host, int port, String roomName, int playerCount, int maxPlayers, double lastSeenClock
});




}
/// @nodoc
class __$DiscoveredRoomCopyWithImpl<$Res>
    implements _$DiscoveredRoomCopyWith<$Res> {
  __$DiscoveredRoomCopyWithImpl(this._self, this._then);

  final _DiscoveredRoom _self;
  final $Res Function(_DiscoveredRoom) _then;

/// Create a copy of DiscoveredRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = null,Object? roomName = null,Object? playerCount = null,Object? maxPlayers = null,Object? lastSeenClock = null,}) {
  return _then(_DiscoveredRoom(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,playerCount: null == playerCount ? _self.playerCount : playerCount // ignore: cast_nullable_to_non_nullable
as int,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,lastSeenClock: null == lastSeenClock ? _self.lastSeenClock : lastSeenClock // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
