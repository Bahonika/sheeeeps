// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dog_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DogState {

 int get id; String get name; int get colorIndex; double get x; double get y; double get targetX; double get targetY; bool get hasTarget; double get vx; double get vy; double get barkCooldownRemaining;/// Monotonic counter incremented on every successful bark. Presentation
/// watches it to spawn a one-shot expanding-ring effect (reactive trigger),
/// keeping ring animation out of the domain.
 int get barkSeq;/// AFK: the shepherd hasn't given input for a while, so the dog is asleep
/// (drawn with a "zzz" marker). Only ever set on the pasture client mirror.
 bool get asleep;
/// Create a copy of DogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DogStateCopyWith<DogState> get copyWith => _$DogStateCopyWithImpl<DogState>(this as DogState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DogState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.targetX, targetX) || other.targetX == targetX)&&(identical(other.targetY, targetY) || other.targetY == targetY)&&(identical(other.hasTarget, hasTarget) || other.hasTarget == hasTarget)&&(identical(other.vx, vx) || other.vx == vx)&&(identical(other.vy, vy) || other.vy == vy)&&(identical(other.barkCooldownRemaining, barkCooldownRemaining) || other.barkCooldownRemaining == barkCooldownRemaining)&&(identical(other.barkSeq, barkSeq) || other.barkSeq == barkSeq)&&(identical(other.asleep, asleep) || other.asleep == asleep));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex,x,y,targetX,targetY,hasTarget,vx,vy,barkCooldownRemaining,barkSeq,asleep);

@override
String toString() {
  return 'DogState(id: $id, name: $name, colorIndex: $colorIndex, x: $x, y: $y, targetX: $targetX, targetY: $targetY, hasTarget: $hasTarget, vx: $vx, vy: $vy, barkCooldownRemaining: $barkCooldownRemaining, barkSeq: $barkSeq, asleep: $asleep)';
}


}

/// @nodoc
abstract mixin class $DogStateCopyWith<$Res>  {
  factory $DogStateCopyWith(DogState value, $Res Function(DogState) _then) = _$DogStateCopyWithImpl;
@useResult
$Res call({
 int id, String name, int colorIndex, double x, double y, double targetX, double targetY, bool hasTarget, double vx, double vy, double barkCooldownRemaining, int barkSeq, bool asleep
});




}
/// @nodoc
class _$DogStateCopyWithImpl<$Res>
    implements $DogStateCopyWith<$Res> {
  _$DogStateCopyWithImpl(this._self, this._then);

  final DogState _self;
  final $Res Function(DogState) _then;

/// Create a copy of DogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,Object? x = null,Object? y = null,Object? targetX = null,Object? targetY = null,Object? hasTarget = null,Object? vx = null,Object? vy = null,Object? barkCooldownRemaining = null,Object? barkSeq = null,Object? asleep = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,targetX: null == targetX ? _self.targetX : targetX // ignore: cast_nullable_to_non_nullable
as double,targetY: null == targetY ? _self.targetY : targetY // ignore: cast_nullable_to_non_nullable
as double,hasTarget: null == hasTarget ? _self.hasTarget : hasTarget // ignore: cast_nullable_to_non_nullable
as bool,vx: null == vx ? _self.vx : vx // ignore: cast_nullable_to_non_nullable
as double,vy: null == vy ? _self.vy : vy // ignore: cast_nullable_to_non_nullable
as double,barkCooldownRemaining: null == barkCooldownRemaining ? _self.barkCooldownRemaining : barkCooldownRemaining // ignore: cast_nullable_to_non_nullable
as double,barkSeq: null == barkSeq ? _self.barkSeq : barkSeq // ignore: cast_nullable_to_non_nullable
as int,asleep: null == asleep ? _self.asleep : asleep // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DogState].
extension DogStatePatterns on DogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DogState value)  $default,){
final _that = this;
switch (_that) {
case _DogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DogState value)?  $default,){
final _that = this;
switch (_that) {
case _DogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int colorIndex,  double x,  double y,  double targetX,  double targetY,  bool hasTarget,  double vx,  double vy,  double barkCooldownRemaining,  int barkSeq,  bool asleep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DogState() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex,_that.x,_that.y,_that.targetX,_that.targetY,_that.hasTarget,_that.vx,_that.vy,_that.barkCooldownRemaining,_that.barkSeq,_that.asleep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int colorIndex,  double x,  double y,  double targetX,  double targetY,  bool hasTarget,  double vx,  double vy,  double barkCooldownRemaining,  int barkSeq,  bool asleep)  $default,) {final _that = this;
switch (_that) {
case _DogState():
return $default(_that.id,_that.name,_that.colorIndex,_that.x,_that.y,_that.targetX,_that.targetY,_that.hasTarget,_that.vx,_that.vy,_that.barkCooldownRemaining,_that.barkSeq,_that.asleep);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int colorIndex,  double x,  double y,  double targetX,  double targetY,  bool hasTarget,  double vx,  double vy,  double barkCooldownRemaining,  int barkSeq,  bool asleep)?  $default,) {final _that = this;
switch (_that) {
case _DogState() when $default != null:
return $default(_that.id,_that.name,_that.colorIndex,_that.x,_that.y,_that.targetX,_that.targetY,_that.hasTarget,_that.vx,_that.vy,_that.barkCooldownRemaining,_that.barkSeq,_that.asleep);case _:
  return null;

}
}

}

/// @nodoc


class _DogState extends DogState {
  const _DogState({required this.id, required this.name, required this.colorIndex, required this.x, required this.y, required this.targetX, required this.targetY, required this.hasTarget, required this.vx, required this.vy, required this.barkCooldownRemaining, required this.barkSeq, this.asleep = false}): super._();
  

@override final  int id;
@override final  String name;
@override final  int colorIndex;
@override final  double x;
@override final  double y;
@override final  double targetX;
@override final  double targetY;
@override final  bool hasTarget;
@override final  double vx;
@override final  double vy;
@override final  double barkCooldownRemaining;
/// Monotonic counter incremented on every successful bark. Presentation
/// watches it to spawn a one-shot expanding-ring effect (reactive trigger),
/// keeping ring animation out of the domain.
@override final  int barkSeq;
/// AFK: the shepherd hasn't given input for a while, so the dog is asleep
/// (drawn with a "zzz" marker). Only ever set on the pasture client mirror.
@override@JsonKey() final  bool asleep;

/// Create a copy of DogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DogStateCopyWith<_DogState> get copyWith => __$DogStateCopyWithImpl<_DogState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DogState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorIndex, colorIndex) || other.colorIndex == colorIndex)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.targetX, targetX) || other.targetX == targetX)&&(identical(other.targetY, targetY) || other.targetY == targetY)&&(identical(other.hasTarget, hasTarget) || other.hasTarget == hasTarget)&&(identical(other.vx, vx) || other.vx == vx)&&(identical(other.vy, vy) || other.vy == vy)&&(identical(other.barkCooldownRemaining, barkCooldownRemaining) || other.barkCooldownRemaining == barkCooldownRemaining)&&(identical(other.barkSeq, barkSeq) || other.barkSeq == barkSeq)&&(identical(other.asleep, asleep) || other.asleep == asleep));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,colorIndex,x,y,targetX,targetY,hasTarget,vx,vy,barkCooldownRemaining,barkSeq,asleep);

@override
String toString() {
  return 'DogState(id: $id, name: $name, colorIndex: $colorIndex, x: $x, y: $y, targetX: $targetX, targetY: $targetY, hasTarget: $hasTarget, vx: $vx, vy: $vy, barkCooldownRemaining: $barkCooldownRemaining, barkSeq: $barkSeq, asleep: $asleep)';
}


}

/// @nodoc
abstract mixin class _$DogStateCopyWith<$Res> implements $DogStateCopyWith<$Res> {
  factory _$DogStateCopyWith(_DogState value, $Res Function(_DogState) _then) = __$DogStateCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int colorIndex, double x, double y, double targetX, double targetY, bool hasTarget, double vx, double vy, double barkCooldownRemaining, int barkSeq, bool asleep
});




}
/// @nodoc
class __$DogStateCopyWithImpl<$Res>
    implements _$DogStateCopyWith<$Res> {
  __$DogStateCopyWithImpl(this._self, this._then);

  final _DogState _self;
  final $Res Function(_DogState) _then;

/// Create a copy of DogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? colorIndex = null,Object? x = null,Object? y = null,Object? targetX = null,Object? targetY = null,Object? hasTarget = null,Object? vx = null,Object? vy = null,Object? barkCooldownRemaining = null,Object? barkSeq = null,Object? asleep = null,}) {
  return _then(_DogState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorIndex: null == colorIndex ? _self.colorIndex : colorIndex // ignore: cast_nullable_to_non_nullable
as int,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,targetX: null == targetX ? _self.targetX : targetX // ignore: cast_nullable_to_non_nullable
as double,targetY: null == targetY ? _self.targetY : targetY // ignore: cast_nullable_to_non_nullable
as double,hasTarget: null == hasTarget ? _self.hasTarget : hasTarget // ignore: cast_nullable_to_non_nullable
as bool,vx: null == vx ? _self.vx : vx // ignore: cast_nullable_to_non_nullable
as double,vy: null == vy ? _self.vy : vy // ignore: cast_nullable_to_non_nullable
as double,barkCooldownRemaining: null == barkCooldownRemaining ? _self.barkCooldownRemaining : barkCooldownRemaining // ignore: cast_nullable_to_non_nullable
as double,barkSeq: null == barkSeq ? _self.barkSeq : barkSeq // ignore: cast_nullable_to_non_nullable
as int,asleep: null == asleep ? _self.asleep : asleep // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
