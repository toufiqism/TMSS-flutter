// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginUiState {

 String get username; String get password; bool get isLoading; String? get errorMessage;/// A non-failure note shown in the same slot as [errorMessage] — set only by
/// [LoginNotifier.onPasswordResetComplete], so the user who just changed their
/// password is told to sign in with the new one rather than landing on a form that
/// looks like nothing happened.
 String? get infoMessage;
/// Create a copy of LoginUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginUiStateCopyWith<LoginUiState> get copyWith => _$LoginUiStateCopyWithImpl<LoginUiState>(this as LoginUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginUiState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage));
}


@override
int get hashCode => Object.hash(runtimeType,username,password,isLoading,errorMessage,infoMessage);

@override
String toString() {
  return 'LoginUiState(username: $username, password: $password, isLoading: $isLoading, errorMessage: $errorMessage, infoMessage: $infoMessage)';
}


}

/// @nodoc
abstract mixin class $LoginUiStateCopyWith<$Res>  {
  factory $LoginUiStateCopyWith(LoginUiState value, $Res Function(LoginUiState) _then) = _$LoginUiStateCopyWithImpl;
@useResult
$Res call({
 String username, String password, bool isLoading, String? errorMessage, String? infoMessage
});




}
/// @nodoc
class _$LoginUiStateCopyWithImpl<$Res>
    implements $LoginUiStateCopyWith<$Res> {
  _$LoginUiStateCopyWithImpl(this._self, this._then);

  final LoginUiState _self;
  final $Res Function(LoginUiState) _then;

/// Create a copy of LoginUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? isLoading = null,Object? errorMessage = freezed,Object? infoMessage = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginUiState].
extension LoginUiStatePatterns on LoginUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginUiState value)  $default,){
final _that = this;
switch (_that) {
case _LoginUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginUiState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  bool isLoading,  String? errorMessage,  String? infoMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginUiState() when $default != null:
return $default(_that.username,_that.password,_that.isLoading,_that.errorMessage,_that.infoMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  bool isLoading,  String? errorMessage,  String? infoMessage)  $default,) {final _that = this;
switch (_that) {
case _LoginUiState():
return $default(_that.username,_that.password,_that.isLoading,_that.errorMessage,_that.infoMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  bool isLoading,  String? errorMessage,  String? infoMessage)?  $default,) {final _that = this;
switch (_that) {
case _LoginUiState() when $default != null:
return $default(_that.username,_that.password,_that.isLoading,_that.errorMessage,_that.infoMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LoginUiState implements LoginUiState {
  const _LoginUiState({this.username = '', this.password = '', this.isLoading = false, this.errorMessage, this.infoMessage});
  

@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
/// A non-failure note shown in the same slot as [errorMessage] — set only by
/// [LoginNotifier.onPasswordResetComplete], so the user who just changed their
/// password is told to sign in with the new one rather than landing on a form that
/// looks like nothing happened.
@override final  String? infoMessage;

/// Create a copy of LoginUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginUiStateCopyWith<_LoginUiState> get copyWith => __$LoginUiStateCopyWithImpl<_LoginUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginUiState&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage));
}


@override
int get hashCode => Object.hash(runtimeType,username,password,isLoading,errorMessage,infoMessage);

@override
String toString() {
  return 'LoginUiState(username: $username, password: $password, isLoading: $isLoading, errorMessage: $errorMessage, infoMessage: $infoMessage)';
}


}

/// @nodoc
abstract mixin class _$LoginUiStateCopyWith<$Res> implements $LoginUiStateCopyWith<$Res> {
  factory _$LoginUiStateCopyWith(_LoginUiState value, $Res Function(_LoginUiState) _then) = __$LoginUiStateCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, bool isLoading, String? errorMessage, String? infoMessage
});




}
/// @nodoc
class __$LoginUiStateCopyWithImpl<$Res>
    implements _$LoginUiStateCopyWith<$Res> {
  __$LoginUiStateCopyWithImpl(this._self, this._then);

  final _LoginUiState _self;
  final $Res Function(_LoginUiState) _then;

/// Create a copy of LoginUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? isLoading = null,Object? errorMessage = freezed,Object? infoMessage = freezed,}) {
  return _then(_LoginUiState(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
