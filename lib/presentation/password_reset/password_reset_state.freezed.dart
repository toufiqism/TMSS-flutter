// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordResetUiState {

 PasswordResetStep get step; String get userName; String get otpCode; String get password; String get confirmPassword; bool get isSubmitting;/// Failure text for the whole form. Field-specific messages go to [fieldErrors]
/// instead, so the user is not asked to work out which input a banner refers to.
 String? get errorMessage;/// The server's own success wording from `/forgot-password`, shown above step 2.
 String? get infoMessage; Map<String, String> get fieldErrors;/// Seconds until "Resend code" is available again. Client-side only, and set to
/// [resendCooldownSeconds] after every send: the server throttles this endpoint at
/// 5/min, and a resend button with no cooldown walks the user straight into a 429.
 int get resendSecondsLeft;/// Seconds until the OTP is expected to expire, counted down from
/// [otpLifetimeSeconds]. An estimate of the server's `OTP_EXPIRY_MINUTES`, not a
/// fact — the server never sends the real deadline — so it never blocks a submit.
 int get expirySecondsLeft;
/// Create a copy of PasswordResetUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetUiStateCopyWith<PasswordResetUiState> get copyWith => _$PasswordResetUiStateCopyWithImpl<PasswordResetUiState>(this as PasswordResetUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetUiState&&(identical(other.step, step) || other.step == step)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.otpCode, otpCode) || other.otpCode == otpCode)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&const DeepCollectionEquality().equals(other.fieldErrors, fieldErrors)&&(identical(other.resendSecondsLeft, resendSecondsLeft) || other.resendSecondsLeft == resendSecondsLeft)&&(identical(other.expirySecondsLeft, expirySecondsLeft) || other.expirySecondsLeft == expirySecondsLeft));
}


@override
int get hashCode => Object.hash(runtimeType,step,userName,otpCode,password,confirmPassword,isSubmitting,errorMessage,infoMessage,const DeepCollectionEquality().hash(fieldErrors),resendSecondsLeft,expirySecondsLeft);

@override
String toString() {
  return 'PasswordResetUiState(step: $step, userName: $userName, otpCode: $otpCode, password: $password, confirmPassword: $confirmPassword, isSubmitting: $isSubmitting, errorMessage: $errorMessage, infoMessage: $infoMessage, fieldErrors: $fieldErrors, resendSecondsLeft: $resendSecondsLeft, expirySecondsLeft: $expirySecondsLeft)';
}


}

/// @nodoc
abstract mixin class $PasswordResetUiStateCopyWith<$Res>  {
  factory $PasswordResetUiStateCopyWith(PasswordResetUiState value, $Res Function(PasswordResetUiState) _then) = _$PasswordResetUiStateCopyWithImpl;
@useResult
$Res call({
 PasswordResetStep step, String userName, String otpCode, String password, String confirmPassword, bool isSubmitting, String? errorMessage, String? infoMessage, Map<String, String> fieldErrors, int resendSecondsLeft, int expirySecondsLeft
});




}
/// @nodoc
class _$PasswordResetUiStateCopyWithImpl<$Res>
    implements $PasswordResetUiStateCopyWith<$Res> {
  _$PasswordResetUiStateCopyWithImpl(this._self, this._then);

  final PasswordResetUiState _self;
  final $Res Function(PasswordResetUiState) _then;

/// Create a copy of PasswordResetUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? userName = null,Object? otpCode = null,Object? password = null,Object? confirmPassword = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? fieldErrors = null,Object? resendSecondsLeft = null,Object? expirySecondsLeft = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as PasswordResetStep,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,otpCode: null == otpCode ? _self.otpCode : otpCode // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,resendSecondsLeft: null == resendSecondsLeft ? _self.resendSecondsLeft : resendSecondsLeft // ignore: cast_nullable_to_non_nullable
as int,expirySecondsLeft: null == expirySecondsLeft ? _self.expirySecondsLeft : expirySecondsLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetUiState].
extension PasswordResetUiStatePatterns on PasswordResetUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetUiState value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetUiState value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PasswordResetStep step,  String userName,  String otpCode,  String password,  String confirmPassword,  bool isSubmitting,  String? errorMessage,  String? infoMessage,  Map<String, String> fieldErrors,  int resendSecondsLeft,  int expirySecondsLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetUiState() when $default != null:
return $default(_that.step,_that.userName,_that.otpCode,_that.password,_that.confirmPassword,_that.isSubmitting,_that.errorMessage,_that.infoMessage,_that.fieldErrors,_that.resendSecondsLeft,_that.expirySecondsLeft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PasswordResetStep step,  String userName,  String otpCode,  String password,  String confirmPassword,  bool isSubmitting,  String? errorMessage,  String? infoMessage,  Map<String, String> fieldErrors,  int resendSecondsLeft,  int expirySecondsLeft)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetUiState():
return $default(_that.step,_that.userName,_that.otpCode,_that.password,_that.confirmPassword,_that.isSubmitting,_that.errorMessage,_that.infoMessage,_that.fieldErrors,_that.resendSecondsLeft,_that.expirySecondsLeft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PasswordResetStep step,  String userName,  String otpCode,  String password,  String confirmPassword,  bool isSubmitting,  String? errorMessage,  String? infoMessage,  Map<String, String> fieldErrors,  int resendSecondsLeft,  int expirySecondsLeft)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetUiState() when $default != null:
return $default(_that.step,_that.userName,_that.otpCode,_that.password,_that.confirmPassword,_that.isSubmitting,_that.errorMessage,_that.infoMessage,_that.fieldErrors,_that.resendSecondsLeft,_that.expirySecondsLeft);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordResetUiState extends PasswordResetUiState {
  const _PasswordResetUiState({this.step = PasswordResetStep.requestCode, this.userName = '', this.otpCode = '', this.password = '', this.confirmPassword = '', this.isSubmitting = false, this.errorMessage, this.infoMessage, final  Map<String, String> fieldErrors = const <String, String>{}, this.resendSecondsLeft = 0, this.expirySecondsLeft = 0}): _fieldErrors = fieldErrors,super._();
  

@override@JsonKey() final  PasswordResetStep step;
@override@JsonKey() final  String userName;
@override@JsonKey() final  String otpCode;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  bool isSubmitting;
/// Failure text for the whole form. Field-specific messages go to [fieldErrors]
/// instead, so the user is not asked to work out which input a banner refers to.
@override final  String? errorMessage;
/// The server's own success wording from `/forgot-password`, shown above step 2.
@override final  String? infoMessage;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

/// Seconds until "Resend code" is available again. Client-side only, and set to
/// [resendCooldownSeconds] after every send: the server throttles this endpoint at
/// 5/min, and a resend button with no cooldown walks the user straight into a 429.
@override@JsonKey() final  int resendSecondsLeft;
/// Seconds until the OTP is expected to expire, counted down from
/// [otpLifetimeSeconds]. An estimate of the server's `OTP_EXPIRY_MINUTES`, not a
/// fact — the server never sends the real deadline — so it never blocks a submit.
@override@JsonKey() final  int expirySecondsLeft;

/// Create a copy of PasswordResetUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetUiStateCopyWith<_PasswordResetUiState> get copyWith => __$PasswordResetUiStateCopyWithImpl<_PasswordResetUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetUiState&&(identical(other.step, step) || other.step == step)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.otpCode, otpCode) || other.otpCode == otpCode)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors)&&(identical(other.resendSecondsLeft, resendSecondsLeft) || other.resendSecondsLeft == resendSecondsLeft)&&(identical(other.expirySecondsLeft, expirySecondsLeft) || other.expirySecondsLeft == expirySecondsLeft));
}


@override
int get hashCode => Object.hash(runtimeType,step,userName,otpCode,password,confirmPassword,isSubmitting,errorMessage,infoMessage,const DeepCollectionEquality().hash(_fieldErrors),resendSecondsLeft,expirySecondsLeft);

@override
String toString() {
  return 'PasswordResetUiState(step: $step, userName: $userName, otpCode: $otpCode, password: $password, confirmPassword: $confirmPassword, isSubmitting: $isSubmitting, errorMessage: $errorMessage, infoMessage: $infoMessage, fieldErrors: $fieldErrors, resendSecondsLeft: $resendSecondsLeft, expirySecondsLeft: $expirySecondsLeft)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetUiStateCopyWith<$Res> implements $PasswordResetUiStateCopyWith<$Res> {
  factory _$PasswordResetUiStateCopyWith(_PasswordResetUiState value, $Res Function(_PasswordResetUiState) _then) = __$PasswordResetUiStateCopyWithImpl;
@override @useResult
$Res call({
 PasswordResetStep step, String userName, String otpCode, String password, String confirmPassword, bool isSubmitting, String? errorMessage, String? infoMessage, Map<String, String> fieldErrors, int resendSecondsLeft, int expirySecondsLeft
});




}
/// @nodoc
class __$PasswordResetUiStateCopyWithImpl<$Res>
    implements _$PasswordResetUiStateCopyWith<$Res> {
  __$PasswordResetUiStateCopyWithImpl(this._self, this._then);

  final _PasswordResetUiState _self;
  final $Res Function(_PasswordResetUiState) _then;

/// Create a copy of PasswordResetUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? userName = null,Object? otpCode = null,Object? password = null,Object? confirmPassword = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? infoMessage = freezed,Object? fieldErrors = null,Object? resendSecondsLeft = null,Object? expirySecondsLeft = null,}) {
  return _then(_PasswordResetUiState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as PasswordResetStep,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,otpCode: null == otpCode ? _self.otpCode : otpCode // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,resendSecondsLeft: null == resendSecondsLeft ? _self.resendSecondsLeft : resendSecondsLeft // ignore: cast_nullable_to_non_nullable
as int,expirySecondsLeft: null == expirySecondsLeft ? _self.expirySecondsLeft : expirySecondsLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
