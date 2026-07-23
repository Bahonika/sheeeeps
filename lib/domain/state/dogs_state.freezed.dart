// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dogs_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DogsState {

 Map<int, DogState> get dogs;
/// Create a copy of DogsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DogsStateCopyWith<DogsState> get copyWith => _$DogsStateCopyWithImpl<DogsState>(this as DogsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DogsState&&const DeepCollectionEquality().equals(other.dogs, dogs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dogs));

@override
String toString() {
  return 'DogsState(dogs: $dogs)';
}


}

/// @nodoc
abstract mixin class $DogsStateCopyWith<$Res>  {
  factory $DogsStateCopyWith(DogsState value, $Res Function(DogsState) _then) = _$DogsStateCopyWithImpl;
@useResult
$Res call({
 Map<int, DogState> dogs
});




}
/// @nodoc
class _$DogsStateCopyWithImpl<$Res>
    implements $DogsStateCopyWith<$Res> {
  _$DogsStateCopyWithImpl(this._self, this._then);

  final DogsState _self;
  final $Res Function(DogsState) _then;

/// Create a copy of DogsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dogs = null,}) {
  return _then(_self.copyWith(
dogs: null == dogs ? _self.dogs : dogs // ignore: cast_nullable_to_non_nullable
as Map<int, DogState>,
  ));
}

}


/// Adds pattern-matching-related methods to [DogsState].
extension DogsStatePatterns on DogsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DogsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DogsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DogsState value)  $default,){
final _that = this;
switch (_that) {
case _DogsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DogsState value)?  $default,){
final _that = this;
switch (_that) {
case _DogsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, DogState> dogs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DogsState() when $default != null:
return $default(_that.dogs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, DogState> dogs)  $default,) {final _that = this;
switch (_that) {
case _DogsState():
return $default(_that.dogs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, DogState> dogs)?  $default,) {final _that = this;
switch (_that) {
case _DogsState() when $default != null:
return $default(_that.dogs);case _:
  return null;

}
}

}

/// @nodoc


class _DogsState extends DogsState {
  const _DogsState({final  Map<int, DogState> dogs = const <int, DogState>{}}): _dogs = dogs,super._();
  

 final  Map<int, DogState> _dogs;
@override@JsonKey() Map<int, DogState> get dogs {
  if (_dogs is EqualUnmodifiableMapView) return _dogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dogs);
}


/// Create a copy of DogsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DogsStateCopyWith<_DogsState> get copyWith => __$DogsStateCopyWithImpl<_DogsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DogsState&&const DeepCollectionEquality().equals(other._dogs, _dogs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dogs));

@override
String toString() {
  return 'DogsState(dogs: $dogs)';
}


}

/// @nodoc
abstract mixin class _$DogsStateCopyWith<$Res> implements $DogsStateCopyWith<$Res> {
  factory _$DogsStateCopyWith(_DogsState value, $Res Function(_DogsState) _then) = __$DogsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<int, DogState> dogs
});




}
/// @nodoc
class __$DogsStateCopyWithImpl<$Res>
    implements _$DogsStateCopyWith<$Res> {
  __$DogsStateCopyWithImpl(this._self, this._then);

  final _DogsState _self;
  final $Res Function(_DogsState) _then;

/// Create a copy of DogsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dogs = null,}) {
  return _then(_DogsState(
dogs: null == dogs ? _self._dogs : dogs // ignore: cast_nullable_to_non_nullable
as Map<int, DogState>,
  ));
}


}

// dart format on
