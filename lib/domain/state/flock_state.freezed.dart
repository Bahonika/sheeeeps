// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flock_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlockState {

 FlockBuffers get buffers; int get version; int get pennedCount;
/// Create a copy of FlockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlockStateCopyWith<FlockState> get copyWith => _$FlockStateCopyWithImpl<FlockState>(this as FlockState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlockState&&(identical(other.buffers, buffers) || other.buffers == buffers)&&(identical(other.version, version) || other.version == version)&&(identical(other.pennedCount, pennedCount) || other.pennedCount == pennedCount));
}


@override
int get hashCode => Object.hash(runtimeType,buffers,version,pennedCount);

@override
String toString() {
  return 'FlockState(buffers: $buffers, version: $version, pennedCount: $pennedCount)';
}


}

/// @nodoc
abstract mixin class $FlockStateCopyWith<$Res>  {
  factory $FlockStateCopyWith(FlockState value, $Res Function(FlockState) _then) = _$FlockStateCopyWithImpl;
@useResult
$Res call({
 FlockBuffers buffers, int version, int pennedCount
});




}
/// @nodoc
class _$FlockStateCopyWithImpl<$Res>
    implements $FlockStateCopyWith<$Res> {
  _$FlockStateCopyWithImpl(this._self, this._then);

  final FlockState _self;
  final $Res Function(FlockState) _then;

/// Create a copy of FlockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? buffers = null,Object? version = null,Object? pennedCount = null,}) {
  return _then(_self.copyWith(
buffers: null == buffers ? _self.buffers : buffers // ignore: cast_nullable_to_non_nullable
as FlockBuffers,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,pennedCount: null == pennedCount ? _self.pennedCount : pennedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FlockState].
extension FlockStatePatterns on FlockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlockState value)  $default,){
final _that = this;
switch (_that) {
case _FlockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlockState value)?  $default,){
final _that = this;
switch (_that) {
case _FlockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FlockBuffers buffers,  int version,  int pennedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlockState() when $default != null:
return $default(_that.buffers,_that.version,_that.pennedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FlockBuffers buffers,  int version,  int pennedCount)  $default,) {final _that = this;
switch (_that) {
case _FlockState():
return $default(_that.buffers,_that.version,_that.pennedCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FlockBuffers buffers,  int version,  int pennedCount)?  $default,) {final _that = this;
switch (_that) {
case _FlockState() when $default != null:
return $default(_that.buffers,_that.version,_that.pennedCount);case _:
  return null;

}
}

}

/// @nodoc


class _FlockState extends FlockState {
  const _FlockState({required this.buffers, required this.version, required this.pennedCount}): super._();
  

@override final  FlockBuffers buffers;
@override final  int version;
@override final  int pennedCount;

/// Create a copy of FlockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlockStateCopyWith<_FlockState> get copyWith => __$FlockStateCopyWithImpl<_FlockState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlockState&&(identical(other.buffers, buffers) || other.buffers == buffers)&&(identical(other.version, version) || other.version == version)&&(identical(other.pennedCount, pennedCount) || other.pennedCount == pennedCount));
}


@override
int get hashCode => Object.hash(runtimeType,buffers,version,pennedCount);

@override
String toString() {
  return 'FlockState(buffers: $buffers, version: $version, pennedCount: $pennedCount)';
}


}

/// @nodoc
abstract mixin class _$FlockStateCopyWith<$Res> implements $FlockStateCopyWith<$Res> {
  factory _$FlockStateCopyWith(_FlockState value, $Res Function(_FlockState) _then) = __$FlockStateCopyWithImpl;
@override @useResult
$Res call({
 FlockBuffers buffers, int version, int pennedCount
});




}
/// @nodoc
class __$FlockStateCopyWithImpl<$Res>
    implements _$FlockStateCopyWith<$Res> {
  __$FlockStateCopyWithImpl(this._self, this._then);

  final _FlockState _self;
  final $Res Function(_FlockState) _then;

/// Create a copy of FlockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? buffers = null,Object? version = null,Object? pennedCount = null,}) {
  return _then(_FlockState(
buffers: null == buffers ? _self.buffers : buffers // ignore: cast_nullable_to_non_nullable
as FlockBuffers,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,pennedCount: null == pennedCount ? _self.pennedCount : pennedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
