// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoundState {

// final time of the round just completed
 int get total; Map<int, int> get scores;// playerId → sheep credited this round
 double get dayRecordSeconds;
/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundStateCopyWith<RoundState> get copyWith => _$RoundStateCopyWithImpl<RoundState>(this as RoundState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoundState&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.dayRecordSeconds, dayRecordSeconds) || other.dayRecordSeconds == dayRecordSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(scores),dayRecordSeconds);

@override
String toString() {
  return 'RoundState(total: $total, scores: $scores, dayRecordSeconds: $dayRecordSeconds)';
}


}

/// @nodoc
abstract mixin class $RoundStateCopyWith<$Res>  {
  factory $RoundStateCopyWith(RoundState value, $Res Function(RoundState) _then) = _$RoundStateCopyWithImpl;
@useResult
$Res call({
 int total, Map<int, int> scores, double dayRecordSeconds
});




}
/// @nodoc
class _$RoundStateCopyWithImpl<$Res>
    implements $RoundStateCopyWith<$Res> {
  _$RoundStateCopyWithImpl(this._self, this._then);

  final RoundState _self;
  final $Res Function(RoundState) _then;

/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? scores = null,Object? dayRecordSeconds = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as Map<int, int>,dayRecordSeconds: null == dayRecordSeconds ? _self.dayRecordSeconds : dayRecordSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RoundState].
extension RoundStatePatterns on RoundState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RoundHerding value)?  herding,TResult Function( RoundCelebrating value)?  celebrating,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RoundHerding() when herding != null:
return herding(_that);case RoundCelebrating() when celebrating != null:
return celebrating(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RoundHerding value)  herding,required TResult Function( RoundCelebrating value)  celebrating,}){
final _that = this;
switch (_that) {
case RoundHerding():
return herding(_that);case RoundCelebrating():
return celebrating(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RoundHerding value)?  herding,TResult? Function( RoundCelebrating value)?  celebrating,}){
final _that = this;
switch (_that) {
case RoundHerding() when herding != null:
return herding(_that);case RoundCelebrating() when celebrating != null:
return celebrating(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double elapsed,  int penned,  int total,  Map<int, int> scores,  double dayRecordSeconds)?  herding,TResult Function( double roundTime,  int total,  Map<int, int> scores,  double remaining,  double dayRecordSeconds)?  celebrating,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RoundHerding() when herding != null:
return herding(_that.elapsed,_that.penned,_that.total,_that.scores,_that.dayRecordSeconds);case RoundCelebrating() when celebrating != null:
return celebrating(_that.roundTime,_that.total,_that.scores,_that.remaining,_that.dayRecordSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double elapsed,  int penned,  int total,  Map<int, int> scores,  double dayRecordSeconds)  herding,required TResult Function( double roundTime,  int total,  Map<int, int> scores,  double remaining,  double dayRecordSeconds)  celebrating,}) {final _that = this;
switch (_that) {
case RoundHerding():
return herding(_that.elapsed,_that.penned,_that.total,_that.scores,_that.dayRecordSeconds);case RoundCelebrating():
return celebrating(_that.roundTime,_that.total,_that.scores,_that.remaining,_that.dayRecordSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double elapsed,  int penned,  int total,  Map<int, int> scores,  double dayRecordSeconds)?  herding,TResult? Function( double roundTime,  int total,  Map<int, int> scores,  double remaining,  double dayRecordSeconds)?  celebrating,}) {final _that = this;
switch (_that) {
case RoundHerding() when herding != null:
return herding(_that.elapsed,_that.penned,_that.total,_that.scores,_that.dayRecordSeconds);case RoundCelebrating() when celebrating != null:
return celebrating(_that.roundTime,_that.total,_that.scores,_that.remaining,_that.dayRecordSeconds);case _:
  return null;

}
}

}

/// @nodoc


class RoundHerding extends RoundState {
  const RoundHerding({required this.elapsed, required this.penned, required this.total, required final  Map<int, int> scores, required this.dayRecordSeconds}): _scores = scores,super._();
  

 final  double elapsed;
// round timer (seconds), always counting up
 final  int penned;
@override final  int total;
 final  Map<int, int> _scores;
@override Map<int, int> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}

// playerId → sheep credited this round
@override final  double dayRecordSeconds;

/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundHerdingCopyWith<RoundHerding> get copyWith => _$RoundHerdingCopyWithImpl<RoundHerding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoundHerding&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&(identical(other.penned, penned) || other.penned == penned)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.dayRecordSeconds, dayRecordSeconds) || other.dayRecordSeconds == dayRecordSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,elapsed,penned,total,const DeepCollectionEquality().hash(_scores),dayRecordSeconds);

@override
String toString() {
  return 'RoundState.herding(elapsed: $elapsed, penned: $penned, total: $total, scores: $scores, dayRecordSeconds: $dayRecordSeconds)';
}


}

/// @nodoc
abstract mixin class $RoundHerdingCopyWith<$Res> implements $RoundStateCopyWith<$Res> {
  factory $RoundHerdingCopyWith(RoundHerding value, $Res Function(RoundHerding) _then) = _$RoundHerdingCopyWithImpl;
@override @useResult
$Res call({
 double elapsed, int penned, int total, Map<int, int> scores, double dayRecordSeconds
});




}
/// @nodoc
class _$RoundHerdingCopyWithImpl<$Res>
    implements $RoundHerdingCopyWith<$Res> {
  _$RoundHerdingCopyWithImpl(this._self, this._then);

  final RoundHerding _self;
  final $Res Function(RoundHerding) _then;

/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elapsed = null,Object? penned = null,Object? total = null,Object? scores = null,Object? dayRecordSeconds = null,}) {
  return _then(RoundHerding(
elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as double,penned: null == penned ? _self.penned : penned // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<int, int>,dayRecordSeconds: null == dayRecordSeconds ? _self.dayRecordSeconds : dayRecordSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class RoundCelebrating extends RoundState {
  const RoundCelebrating({required this.roundTime, required this.total, required final  Map<int, int> scores, required this.remaining, required this.dayRecordSeconds}): _scores = scores,super._();
  

 final  double roundTime;
// final time of the round just completed
@override final  int total;
 final  Map<int, int> _scores;
@override Map<int, int> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}

 final  double remaining;
// celebration countdown (seconds)
@override final  double dayRecordSeconds;

/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundCelebratingCopyWith<RoundCelebrating> get copyWith => _$RoundCelebratingCopyWithImpl<RoundCelebrating>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoundCelebrating&&(identical(other.roundTime, roundTime) || other.roundTime == roundTime)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.dayRecordSeconds, dayRecordSeconds) || other.dayRecordSeconds == dayRecordSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,roundTime,total,const DeepCollectionEquality().hash(_scores),remaining,dayRecordSeconds);

@override
String toString() {
  return 'RoundState.celebrating(roundTime: $roundTime, total: $total, scores: $scores, remaining: $remaining, dayRecordSeconds: $dayRecordSeconds)';
}


}

/// @nodoc
abstract mixin class $RoundCelebratingCopyWith<$Res> implements $RoundStateCopyWith<$Res> {
  factory $RoundCelebratingCopyWith(RoundCelebrating value, $Res Function(RoundCelebrating) _then) = _$RoundCelebratingCopyWithImpl;
@override @useResult
$Res call({
 double roundTime, int total, Map<int, int> scores, double remaining, double dayRecordSeconds
});




}
/// @nodoc
class _$RoundCelebratingCopyWithImpl<$Res>
    implements $RoundCelebratingCopyWith<$Res> {
  _$RoundCelebratingCopyWithImpl(this._self, this._then);

  final RoundCelebrating _self;
  final $Res Function(RoundCelebrating) _then;

/// Create a copy of RoundState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roundTime = null,Object? total = null,Object? scores = null,Object? remaining = null,Object? dayRecordSeconds = null,}) {
  return _then(RoundCelebrating(
roundTime: null == roundTime ? _self.roundTime : roundTime // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<int, int>,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,dayRecordSeconds: null == dayRecordSeconds ? _self.dayRecordSeconds : dayRecordSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
