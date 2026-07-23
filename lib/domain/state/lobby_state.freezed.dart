// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LobbyState {

 String get roomName; int get localPlayerId; List<PlayerInfo> get players; String get hostAddress; bool get started; int get maxPlayers;
/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyStateCopyWith<LobbyState> get copyWith => _$LobbyStateCopyWithImpl<LobbyState>(this as LobbyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyState&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.localPlayerId, localPlayerId) || other.localPlayerId == localPlayerId)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.hostAddress, hostAddress) || other.hostAddress == hostAddress)&&(identical(other.started, started) || other.started == started)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers));
}


@override
int get hashCode => Object.hash(runtimeType,roomName,localPlayerId,const DeepCollectionEquality().hash(players),hostAddress,started,maxPlayers);

@override
String toString() {
  return 'LobbyState(roomName: $roomName, localPlayerId: $localPlayerId, players: $players, hostAddress: $hostAddress, started: $started, maxPlayers: $maxPlayers)';
}


}

/// @nodoc
abstract mixin class $LobbyStateCopyWith<$Res>  {
  factory $LobbyStateCopyWith(LobbyState value, $Res Function(LobbyState) _then) = _$LobbyStateCopyWithImpl;
@useResult
$Res call({
 String roomName, int localPlayerId, List<PlayerInfo> players, String hostAddress, bool started, int maxPlayers
});




}
/// @nodoc
class _$LobbyStateCopyWithImpl<$Res>
    implements $LobbyStateCopyWith<$Res> {
  _$LobbyStateCopyWithImpl(this._self, this._then);

  final LobbyState _self;
  final $Res Function(LobbyState) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomName = null,Object? localPlayerId = null,Object? players = null,Object? hostAddress = null,Object? started = null,Object? maxPlayers = null,}) {
  return _then(_self.copyWith(
roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,localPlayerId: null == localPlayerId ? _self.localPlayerId : localPlayerId // ignore: cast_nullable_to_non_nullable
as int,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerInfo>,hostAddress: null == hostAddress ? _self.hostAddress : hostAddress // ignore: cast_nullable_to_non_nullable
as String,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyState].
extension LobbyStatePatterns on LobbyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyState value)  $default,){
final _that = this;
switch (_that) {
case _LobbyState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyState value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roomName,  int localPlayerId,  List<PlayerInfo> players,  String hostAddress,  bool started,  int maxPlayers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
return $default(_that.roomName,_that.localPlayerId,_that.players,_that.hostAddress,_that.started,_that.maxPlayers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roomName,  int localPlayerId,  List<PlayerInfo> players,  String hostAddress,  bool started,  int maxPlayers)  $default,) {final _that = this;
switch (_that) {
case _LobbyState():
return $default(_that.roomName,_that.localPlayerId,_that.players,_that.hostAddress,_that.started,_that.maxPlayers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roomName,  int localPlayerId,  List<PlayerInfo> players,  String hostAddress,  bool started,  int maxPlayers)?  $default,) {final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
return $default(_that.roomName,_that.localPlayerId,_that.players,_that.hostAddress,_that.started,_that.maxPlayers);case _:
  return null;

}
}

}

/// @nodoc


class _LobbyState extends LobbyState {
  const _LobbyState({required this.roomName, required this.localPlayerId, required final  List<PlayerInfo> players, this.hostAddress = '', this.started = false, this.maxPlayers = 4}): _players = players,super._();
  

@override final  String roomName;
@override final  int localPlayerId;
 final  List<PlayerInfo> _players;
@override List<PlayerInfo> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override@JsonKey() final  String hostAddress;
@override@JsonKey() final  bool started;
@override@JsonKey() final  int maxPlayers;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyStateCopyWith<_LobbyState> get copyWith => __$LobbyStateCopyWithImpl<_LobbyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyState&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.localPlayerId, localPlayerId) || other.localPlayerId == localPlayerId)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.hostAddress, hostAddress) || other.hostAddress == hostAddress)&&(identical(other.started, started) || other.started == started)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers));
}


@override
int get hashCode => Object.hash(runtimeType,roomName,localPlayerId,const DeepCollectionEquality().hash(_players),hostAddress,started,maxPlayers);

@override
String toString() {
  return 'LobbyState(roomName: $roomName, localPlayerId: $localPlayerId, players: $players, hostAddress: $hostAddress, started: $started, maxPlayers: $maxPlayers)';
}


}

/// @nodoc
abstract mixin class _$LobbyStateCopyWith<$Res> implements $LobbyStateCopyWith<$Res> {
  factory _$LobbyStateCopyWith(_LobbyState value, $Res Function(_LobbyState) _then) = __$LobbyStateCopyWithImpl;
@override @useResult
$Res call({
 String roomName, int localPlayerId, List<PlayerInfo> players, String hostAddress, bool started, int maxPlayers
});




}
/// @nodoc
class __$LobbyStateCopyWithImpl<$Res>
    implements _$LobbyStateCopyWith<$Res> {
  __$LobbyStateCopyWithImpl(this._self, this._then);

  final _LobbyState _self;
  final $Res Function(_LobbyState) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomName = null,Object? localPlayerId = null,Object? players = null,Object? hostAddress = null,Object? started = null,Object? maxPlayers = null,}) {
  return _then(_LobbyState(
roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,localPlayerId: null == localPlayerId ? _self.localPlayerId : localPlayerId // ignore: cast_nullable_to_non_nullable
as int,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerInfo>,hostAddress: null == hostAddress ? _self.hostAddress : hostAddress // ignore: cast_nullable_to_non_nullable
as String,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
