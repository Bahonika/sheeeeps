// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nav_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState()';
}


}

/// @nodoc
class $NavStateCopyWith<$Res>  {
$NavStateCopyWith(NavState _, $Res Function(NavState) __);
}


/// Adds pattern-matching-related methods to [NavState].
extension NavStatePatterns on NavState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NavMenu value)?  menu,TResult Function( NavSolo value)?  solo,TResult Function( NavPasture value)?  pasture,TResult Function( NavHostSession value)?  hostSession,TResult Function( NavJoinBrowser value)?  joinBrowser,TResult Function( NavClientSession value)?  clientSession,TResult Function( NavError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NavMenu() when menu != null:
return menu(_that);case NavSolo() when solo != null:
return solo(_that);case NavPasture() when pasture != null:
return pasture(_that);case NavHostSession() when hostSession != null:
return hostSession(_that);case NavJoinBrowser() when joinBrowser != null:
return joinBrowser(_that);case NavClientSession() when clientSession != null:
return clientSession(_that);case NavError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NavMenu value)  menu,required TResult Function( NavSolo value)  solo,required TResult Function( NavPasture value)  pasture,required TResult Function( NavHostSession value)  hostSession,required TResult Function( NavJoinBrowser value)  joinBrowser,required TResult Function( NavClientSession value)  clientSession,required TResult Function( NavError value)  error,}){
final _that = this;
switch (_that) {
case NavMenu():
return menu(_that);case NavSolo():
return solo(_that);case NavPasture():
return pasture(_that);case NavHostSession():
return hostSession(_that);case NavJoinBrowser():
return joinBrowser(_that);case NavClientSession():
return clientSession(_that);case NavError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NavMenu value)?  menu,TResult? Function( NavSolo value)?  solo,TResult? Function( NavPasture value)?  pasture,TResult? Function( NavHostSession value)?  hostSession,TResult? Function( NavJoinBrowser value)?  joinBrowser,TResult? Function( NavClientSession value)?  clientSession,TResult? Function( NavError value)?  error,}){
final _that = this;
switch (_that) {
case NavMenu() when menu != null:
return menu(_that);case NavSolo() when solo != null:
return solo(_that);case NavPasture() when pasture != null:
return pasture(_that);case NavHostSession() when hostSession != null:
return hostSession(_that);case NavJoinBrowser() when joinBrowser != null:
return joinBrowser(_that);case NavClientSession() when clientSession != null:
return clientSession(_that);case NavError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  menu,TResult Function()?  solo,TResult Function()?  pasture,TResult Function()?  hostSession,TResult Function()?  joinBrowser,TResult Function( String host,  int port)?  clientSession,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NavMenu() when menu != null:
return menu();case NavSolo() when solo != null:
return solo();case NavPasture() when pasture != null:
return pasture();case NavHostSession() when hostSession != null:
return hostSession();case NavJoinBrowser() when joinBrowser != null:
return joinBrowser();case NavClientSession() when clientSession != null:
return clientSession(_that.host,_that.port);case NavError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  menu,required TResult Function()  solo,required TResult Function()  pasture,required TResult Function()  hostSession,required TResult Function()  joinBrowser,required TResult Function( String host,  int port)  clientSession,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case NavMenu():
return menu();case NavSolo():
return solo();case NavPasture():
return pasture();case NavHostSession():
return hostSession();case NavJoinBrowser():
return joinBrowser();case NavClientSession():
return clientSession(_that.host,_that.port);case NavError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  menu,TResult? Function()?  solo,TResult? Function()?  pasture,TResult? Function()?  hostSession,TResult? Function()?  joinBrowser,TResult? Function( String host,  int port)?  clientSession,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case NavMenu() when menu != null:
return menu();case NavSolo() when solo != null:
return solo();case NavPasture() when pasture != null:
return pasture();case NavHostSession() when hostSession != null:
return hostSession();case NavJoinBrowser() when joinBrowser != null:
return joinBrowser();case NavClientSession() when clientSession != null:
return clientSession(_that.host,_that.port);case NavError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NavMenu implements NavState {
  const NavMenu();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavMenu);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState.menu()';
}


}




/// @nodoc


class NavSolo implements NavState {
  const NavSolo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavSolo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState.solo()';
}


}




/// @nodoc


class NavPasture implements NavState {
  const NavPasture();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavPasture);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState.pasture()';
}


}




/// @nodoc


class NavHostSession implements NavState {
  const NavHostSession();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavHostSession);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState.hostSession()';
}


}




/// @nodoc


class NavJoinBrowser implements NavState {
  const NavJoinBrowser();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavJoinBrowser);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavState.joinBrowser()';
}


}




/// @nodoc


class NavClientSession implements NavState {
  const NavClientSession({required this.host, required this.port});
  

 final  String host;
 final  int port;

/// Create a copy of NavState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavClientSessionCopyWith<NavClientSession> get copyWith => _$NavClientSessionCopyWithImpl<NavClientSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavClientSession&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,host,port);

@override
String toString() {
  return 'NavState.clientSession(host: $host, port: $port)';
}


}

/// @nodoc
abstract mixin class $NavClientSessionCopyWith<$Res> implements $NavStateCopyWith<$Res> {
  factory $NavClientSessionCopyWith(NavClientSession value, $Res Function(NavClientSession) _then) = _$NavClientSessionCopyWithImpl;
@useResult
$Res call({
 String host, int port
});




}
/// @nodoc
class _$NavClientSessionCopyWithImpl<$Res>
    implements $NavClientSessionCopyWith<$Res> {
  _$NavClientSessionCopyWithImpl(this._self, this._then);

  final NavClientSession _self;
  final $Res Function(NavClientSession) _then;

/// Create a copy of NavState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = null,}) {
  return _then(NavClientSession(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class NavError implements NavState {
  const NavError({required this.message});
  

 final  String message;

/// Create a copy of NavState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavErrorCopyWith<NavError> get copyWith => _$NavErrorCopyWithImpl<NavError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NavState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $NavErrorCopyWith<$Res> implements $NavStateCopyWith<$Res> {
  factory $NavErrorCopyWith(NavError value, $Res Function(NavError) _then) = _$NavErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NavErrorCopyWithImpl<$Res>
    implements $NavErrorCopyWith<$Res> {
  _$NavErrorCopyWithImpl(this._self, this._then);

  final NavError _self;
  final $Res Function(NavError) _then;

/// Create a copy of NavState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NavError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
