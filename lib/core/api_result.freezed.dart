// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiResult<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResult<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiResult<$T>()';
}


}

/// @nodoc
class $ApiResultCopyWith<T,$Res>  {
$ApiResultCopyWith(ApiResult<T> _, $Res Function(ApiResult<T>) __);
}


/// Adds pattern-matching-related methods to [ApiResult].
extension ApiResultPatterns<T> on ApiResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApiSuccess<T> value)?  success,TResult Function( ApiError<T> value)?  error,TResult Function( ApiLogout<T> value)?  logout,TResult Function( ApiMaintenance<T> value)?  maintenance,TResult Function( ApiOffline<T> value)?  offline,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApiSuccess() when success != null:
return success(_that);case ApiError() when error != null:
return error(_that);case ApiLogout() when logout != null:
return logout(_that);case ApiMaintenance() when maintenance != null:
return maintenance(_that);case ApiOffline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApiSuccess<T> value)  success,required TResult Function( ApiError<T> value)  error,required TResult Function( ApiLogout<T> value)  logout,required TResult Function( ApiMaintenance<T> value)  maintenance,required TResult Function( ApiOffline<T> value)  offline,}){
final _that = this;
switch (_that) {
case ApiSuccess():
return success(_that);case ApiError():
return error(_that);case ApiLogout():
return logout(_that);case ApiMaintenance():
return maintenance(_that);case ApiOffline():
return offline(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApiSuccess<T> value)?  success,TResult? Function( ApiError<T> value)?  error,TResult? Function( ApiLogout<T> value)?  logout,TResult? Function( ApiMaintenance<T> value)?  maintenance,TResult? Function( ApiOffline<T> value)?  offline,}){
final _that = this;
switch (_that) {
case ApiSuccess() when success != null:
return success(_that);case ApiError() when error != null:
return error(_that);case ApiLogout() when logout != null:
return logout(_that);case ApiMaintenance() when maintenance != null:
return maintenance(_that);case ApiOffline() when offline != null:
return offline(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T response)?  success,TResult Function( String? message,  int? errorCode,  Map<String, String>? fieldErrors)?  error,TResult Function( String message,  int code)?  logout,TResult Function( String message,  int code)?  maintenance,TResult Function( String message)?  offline,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApiSuccess() when success != null:
return success(_that.response);case ApiError() when error != null:
return error(_that.message,_that.errorCode,_that.fieldErrors);case ApiLogout() when logout != null:
return logout(_that.message,_that.code);case ApiMaintenance() when maintenance != null:
return maintenance(_that.message,_that.code);case ApiOffline() when offline != null:
return offline(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T response)  success,required TResult Function( String? message,  int? errorCode,  Map<String, String>? fieldErrors)  error,required TResult Function( String message,  int code)  logout,required TResult Function( String message,  int code)  maintenance,required TResult Function( String message)  offline,}) {final _that = this;
switch (_that) {
case ApiSuccess():
return success(_that.response);case ApiError():
return error(_that.message,_that.errorCode,_that.fieldErrors);case ApiLogout():
return logout(_that.message,_that.code);case ApiMaintenance():
return maintenance(_that.message,_that.code);case ApiOffline():
return offline(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T response)?  success,TResult? Function( String? message,  int? errorCode,  Map<String, String>? fieldErrors)?  error,TResult? Function( String message,  int code)?  logout,TResult? Function( String message,  int code)?  maintenance,TResult? Function( String message)?  offline,}) {final _that = this;
switch (_that) {
case ApiSuccess() when success != null:
return success(_that.response);case ApiError() when error != null:
return error(_that.message,_that.errorCode,_that.fieldErrors);case ApiLogout() when logout != null:
return logout(_that.message,_that.code);case ApiMaintenance() when maintenance != null:
return maintenance(_that.message,_that.code);case ApiOffline() when offline != null:
return offline(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ApiSuccess<T> implements ApiResult<T> {
  const ApiSuccess(this.response);
  

 final  T response;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiSuccessCopyWith<T, ApiSuccess<T>> get copyWith => _$ApiSuccessCopyWithImpl<T, ApiSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiSuccess<T>&&const DeepCollectionEquality().equals(other.response, response));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(response));

@override
String toString() {
  return 'ApiResult<$T>.success(response: $response)';
}


}

/// @nodoc
abstract mixin class $ApiSuccessCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiSuccessCopyWith(ApiSuccess<T> value, $Res Function(ApiSuccess<T>) _then) = _$ApiSuccessCopyWithImpl;
@useResult
$Res call({
 T response
});




}
/// @nodoc
class _$ApiSuccessCopyWithImpl<T,$Res>
    implements $ApiSuccessCopyWith<T, $Res> {
  _$ApiSuccessCopyWithImpl(this._self, this._then);

  final ApiSuccess<T> _self;
  final $Res Function(ApiSuccess<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = freezed,}) {
  return _then(ApiSuccess<T>(
freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class ApiError<T> implements ApiResult<T> {
  const ApiError(this.message, [this.errorCode, final  Map<String, String>? fieldErrors]): _fieldErrors = fieldErrors;
  

 final  String? message;
 final  int? errorCode;
 final  Map<String, String>? _fieldErrors;
 Map<String, String>? get fieldErrors {
  final value = _fieldErrors;
  if (value == null) return null;
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<T, ApiError<T>> get copyWith => _$ApiErrorCopyWithImpl<T, ApiError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiError<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,message,errorCode,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'ApiResult<$T>.error(message: $message, errorCode: $errorCode, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ApiErrorCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiErrorCopyWith(ApiError<T> value, $Res Function(ApiError<T>) _then) = _$ApiErrorCopyWithImpl;
@useResult
$Res call({
 String? message, int? errorCode, Map<String, String>? fieldErrors
});




}
/// @nodoc
class _$ApiErrorCopyWithImpl<T,$Res>
    implements $ApiErrorCopyWith<T, $Res> {
  _$ApiErrorCopyWithImpl(this._self, this._then);

  final ApiError<T> _self;
  final $Res Function(ApiError<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? errorCode = freezed,Object? fieldErrors = freezed,}) {
  return _then(ApiError<T>(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int?,freezed == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

/// @nodoc


class ApiLogout<T> implements ApiResult<T> {
  const ApiLogout(this.message, this.code);
  

 final  String message;
 final  int code;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiLogoutCopyWith<T, ApiLogout<T>> get copyWith => _$ApiLogoutCopyWithImpl<T, ApiLogout<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiLogout<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'ApiResult<$T>.logout(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $ApiLogoutCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiLogoutCopyWith(ApiLogout<T> value, $Res Function(ApiLogout<T>) _then) = _$ApiLogoutCopyWithImpl;
@useResult
$Res call({
 String message, int code
});




}
/// @nodoc
class _$ApiLogoutCopyWithImpl<T,$Res>
    implements $ApiLogoutCopyWith<T, $Res> {
  _$ApiLogoutCopyWithImpl(this._self, this._then);

  final ApiLogout<T> _self;
  final $Res Function(ApiLogout<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = null,}) {
  return _then(ApiLogout<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ApiMaintenance<T> implements ApiResult<T> {
  const ApiMaintenance(this.message, this.code);
  

 final  String message;
 final  int code;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiMaintenanceCopyWith<T, ApiMaintenance<T>> get copyWith => _$ApiMaintenanceCopyWithImpl<T, ApiMaintenance<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiMaintenance<T>&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'ApiResult<$T>.maintenance(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $ApiMaintenanceCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiMaintenanceCopyWith(ApiMaintenance<T> value, $Res Function(ApiMaintenance<T>) _then) = _$ApiMaintenanceCopyWithImpl;
@useResult
$Res call({
 String message, int code
});




}
/// @nodoc
class _$ApiMaintenanceCopyWithImpl<T,$Res>
    implements $ApiMaintenanceCopyWith<T, $Res> {
  _$ApiMaintenanceCopyWithImpl(this._self, this._then);

  final ApiMaintenance<T> _self;
  final $Res Function(ApiMaintenance<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = null,}) {
  return _then(ApiMaintenance<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ApiOffline<T> implements ApiResult<T> {
  const ApiOffline([this.message = 'No internet connection available']);
  

@JsonKey() final  String message;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiOfflineCopyWith<T, ApiOffline<T>> get copyWith => _$ApiOfflineCopyWithImpl<T, ApiOffline<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiOffline<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ApiResult<$T>.offline(message: $message)';
}


}

/// @nodoc
abstract mixin class $ApiOfflineCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiOfflineCopyWith(ApiOffline<T> value, $Res Function(ApiOffline<T>) _then) = _$ApiOfflineCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ApiOfflineCopyWithImpl<T,$Res>
    implements $ApiOfflineCopyWith<T, $Res> {
  _$ApiOfflineCopyWithImpl(this._self, this._then);

  final ApiOffline<T> _self;
  final $Res Function(ApiOffline<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ApiOffline<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
