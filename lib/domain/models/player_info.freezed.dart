// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerInfo {

 int get id; String get name; int get colorIndex;
/// Create a copy of PlayerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerInfoCopyWith<PlayerInfo> get copyWith => _$PlayerInfoCopyWithImpl<PlayerInfo>(this as PlayerInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex);

@override
String toString() {
  return 'PlayerInfo(id: $id, name: $name, colorIndex: $colorIndex)';
}


}

/// @nodoc
abstract mixin class $PlayerInfoCopyWith<$Res>  {
  factory $PlayerInfoCopyWith(PlayerInfo value, $Res Function(PlayerInfo) _then) = _$PlayerInfoCopyWithImpl;
@useResult
$Res call({
 int id, String name, int colorIndex
});




}
/// @nodoc
class _$PlayerInfoCopyWithImpl<$Res>
    implements $PlayerInfoCopyWith<$Res> {
  _$PlayerInfoCopyWithImpl(this._self, this._then);

  final PlayerInfo _self;
  final $Res Function(PlayerInfo) _then;

/// Create a copy of PlayerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerInfo].
extension PlayerInfoPatterns on PlayerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlayerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int colorIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerInfo() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int colorIndex)  $default,) {final _that = this;
switch (_that) {
case _PlayerInfo():
return $default(_that.id,_that.name,_that.colorIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int colorIndex)?  $default,) {final _that = this;
switch (_that) {
case _PlayerInfo() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerInfo implements PlayerInfo {
  const _PlayerInfo({required this.id, required this.name, required this.colorIndex});
  

@override final  int id;
@override final  String name;
@override final  int colorIndex;

/// Create a copy of PlayerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerInfoCopyWith<_PlayerInfo> get copyWith => __$PlayerInfoCopyWithImpl<_PlayerInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex);

@override
String toString() {
  return 'PlayerInfo(id: $id, name: $name, colorIndex: $colorIndex)';
}


}

/// @nodoc
abstract mixin class _$PlayerInfoCopyWith<$Res> implements $PlayerInfoCopyWith<$Res> {
  factory _$PlayerInfoCopyWith(_PlayerInfo value, $Res Function(_PlayerInfo) _then) = __$PlayerInfoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int colorIndex
});




}
/// @nodoc
class __$PlayerInfoCopyWithImpl<$Res>
    implements _$PlayerInfoCopyWith<$Res> {
  __$PlayerInfoCopyWithImpl(this._self, this._then);

  final _PlayerInfo _self;
  final $Res Function(_PlayerInfo) _then;

/// Create a copy of PlayerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,}) {
  return _then(_PlayerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
