// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameState {

 int get total; double get elapsed;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&(identical(other.total, total) || other.total == total)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed));
}


@override
int get hashCode => Object.hash(runtimeType,total,elapsed);

@override
String toString() {
  return 'GameState(total: $total, elapsed: $elapsed)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
 int total, double elapsed
});




}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? elapsed = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GamePlaying value)?  playing,TResult Function( GameWon value)?  won,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GamePlaying() when playing != null:
return playing(_that);case GameWon() when won != null:
return won(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GamePlaying value)  playing,required TResult Function( GameWon value)  won,}){
final _that = this;
switch (_that) {
case GamePlaying():
return playing(_that);case GameWon():
return won(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GamePlaying value)?  playing,TResult? Function( GameWon value)?  won,}){
final _that = this;
switch (_that) {
case GamePlaying() when playing != null:
return playing(_that);case GameWon() when won != null:
return won(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int penned,  int total,  double elapsed)?  playing,TResult Function( int total,  double elapsed)?  won,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GamePlaying() when playing != null:
return playing(_that.penned,_that.total,_that.elapsed);case GameWon() when won != null:
return won(_that.total,_that.elapsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int penned,  int total,  double elapsed)  playing,required TResult Function( int total,  double elapsed)  won,}) {final _that = this;
switch (_that) {
case GamePlaying():
return playing(_that.penned,_that.total,_that.elapsed);case GameWon():
return won(_that.total,_that.elapsed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int penned,  int total,  double elapsed)?  playing,TResult? Function( int total,  double elapsed)?  won,}) {final _that = this;
switch (_that) {
case GamePlaying() when playing != null:
return playing(_that.penned,_that.total,_that.elapsed);case GameWon() when won != null:
return won(_that.total,_that.elapsed);case _:
  return null;

}
}

}

/// @nodoc


class GamePlaying extends GameState {
  const GamePlaying({required this.penned, required this.total, required this.elapsed}): super._();
  

 final  int penned;
@override final  int total;
@override final  double elapsed;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayingCopyWith<GamePlaying> get copyWith => _$GamePlayingCopyWithImpl<GamePlaying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlaying&&(identical(other.penned, penned) || other.penned == penned)&&(identical(other.total, total) || other.total == total)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed));
}


@override
int get hashCode => Object.hash(runtimeType,penned,total,elapsed);

@override
String toString() {
  return 'GameState.playing(penned: $penned, total: $total, elapsed: $elapsed)';
}


}

/// @nodoc
abstract mixin class $GamePlayingCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GamePlayingCopyWith(GamePlaying value, $Res Function(GamePlaying) _then) = _$GamePlayingCopyWithImpl;
@override @useResult
$Res call({
 int penned, int total, double elapsed
});




}
/// @nodoc
class _$GamePlayingCopyWithImpl<$Res>
    implements $GamePlayingCopyWith<$Res> {
  _$GamePlayingCopyWithImpl(this._self, this._then);

  final GamePlaying _self;
  final $Res Function(GamePlaying) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? penned = null,Object? total = null,Object? elapsed = null,}) {
  return _then(GamePlaying(
penned: null == penned ? _self.penned : penned // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class GameWon extends GameState {
  const GameWon({required this.total, required this.elapsed}): super._();
  

@override final  int total;
@override final  double elapsed;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameWonCopyWith<GameWon> get copyWith => _$GameWonCopyWithImpl<GameWon>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameWon&&(identical(other.total, total) || other.total == total)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed));
}


@override
int get hashCode => Object.hash(runtimeType,total,elapsed);

@override
String toString() {
  return 'GameState.won(total: $total, elapsed: $elapsed)';
}


}

/// @nodoc
abstract mixin class $GameWonCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory $GameWonCopyWith(GameWon value, $Res Function(GameWon) _then) = _$GameWonCopyWithImpl;
@override @useResult
$Res call({
 int total, double elapsed
});




}
/// @nodoc
class _$GameWonCopyWithImpl<$Res>
    implements $GameWonCopyWith<$Res> {
  _$GameWonCopyWithImpl(this._self, this._then);

  final GameWon _self;
  final $Res Function(GameWon) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? elapsed = null,}) {
  return _then(GameWon(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
