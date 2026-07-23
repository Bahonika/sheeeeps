// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'browser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BrowserState {

 List<DiscoveredRoom> get rooms;
/// Create a copy of BrowserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrowserStateCopyWith<BrowserState> get copyWith => _$BrowserStateCopyWithImpl<BrowserState>(this as BrowserState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrowserState&&const DeepCollectionEquality().equals(other.rooms, rooms));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rooms));

@override
String toString() {
  return 'BrowserState(rooms: $rooms)';
}


}

/// @nodoc
abstract mixin class $BrowserStateCopyWith<$Res>  {
  factory $BrowserStateCopyWith(BrowserState value, $Res Function(BrowserState) _then) = _$BrowserStateCopyWithImpl;
@useResult
$Res call({
 List<DiscoveredRoom> rooms
});




}
/// @nodoc
class _$BrowserStateCopyWithImpl<$Res>
    implements $BrowserStateCopyWith<$Res> {
  _$BrowserStateCopyWithImpl(this._self, this._then);

  final BrowserState _self;
  final $Res Function(BrowserState) _then;

/// Create a copy of BrowserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rooms = null,}) {
  return _then(_self.copyWith(
rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<DiscoveredRoom>,
  ));
}

}


/// Adds pattern-matching-related methods to [BrowserState].
extension BrowserStatePatterns on BrowserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrowserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrowserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrowserState value)  $default,){
final _that = this;
switch (_that) {
case _BrowserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrowserState value)?  $default,){
final _that = this;
switch (_that) {
case _BrowserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DiscoveredRoom> rooms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrowserState() when $default != null:
return $default(_that.rooms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DiscoveredRoom> rooms)  $default,) {final _that = this;
switch (_that) {
case _BrowserState():
return $default(_that.rooms);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DiscoveredRoom> rooms)?  $default,) {final _that = this;
switch (_that) {
case _BrowserState() when $default != null:
return $default(_that.rooms);case _:
  return null;

}
}

}

/// @nodoc


class _BrowserState extends BrowserState {
  const _BrowserState({final  List<DiscoveredRoom> rooms = const <DiscoveredRoom>[]}): _rooms = rooms,super._();
  

 final  List<DiscoveredRoom> _rooms;
@override@JsonKey() List<DiscoveredRoom> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}


/// Create a copy of BrowserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrowserStateCopyWith<_BrowserState> get copyWith => __$BrowserStateCopyWithImpl<_BrowserState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrowserState&&const DeepCollectionEquality().equals(other._rooms, _rooms));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rooms));

@override
String toString() {
  return 'BrowserState(rooms: $rooms)';
}


}

/// @nodoc
abstract mixin class _$BrowserStateCopyWith<$Res> implements $BrowserStateCopyWith<$Res> {
  factory _$BrowserStateCopyWith(_BrowserState value, $Res Function(_BrowserState) _then) = __$BrowserStateCopyWithImpl;
@override @useResult
$Res call({
 List<DiscoveredRoom> rooms
});




}
/// @nodoc
class __$BrowserStateCopyWithImpl<$Res>
    implements _$BrowserStateCopyWith<$Res> {
  __$BrowserStateCopyWithImpl(this._self, this._then);

  final _BrowserState _self;
  final $Res Function(_BrowserState) _then;

/// Create a copy of BrowserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rooms = null,}) {
  return _then(_BrowserState(
rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<DiscoveredRoom>,
  ));
}


}

// dart format on
