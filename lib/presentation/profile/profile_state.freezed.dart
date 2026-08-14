// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileUiState {

 UserAccount? get account; bool get isLoading; String? get errorMessage;/// False for terminal failures such as 403, where retrying cannot help.
 bool get canRetry;
/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUiStateCopyWith<ProfileUiState> get copyWith => _$ProfileUiStateCopyWithImpl<ProfileUiState>(this as ProfileUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUiState&&(identical(other.account, account) || other.account == account)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry));
}


@override
int get hashCode => Object.hash(runtimeType,account,isLoading,errorMessage,canRetry);

@override
String toString() {
  return 'ProfileUiState(account: $account, isLoading: $isLoading, errorMessage: $errorMessage, canRetry: $canRetry)';
}


}

/// @nodoc
abstract mixin class $ProfileUiStateCopyWith<$Res>  {
  factory $ProfileUiStateCopyWith(ProfileUiState value, $Res Function(ProfileUiState) _then) = _$ProfileUiStateCopyWithImpl;
@useResult
$Res call({
 UserAccount? account, bool isLoading, String? errorMessage, bool canRetry
});


$UserAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$ProfileUiStateCopyWithImpl<$Res>
    implements $ProfileUiStateCopyWith<$Res> {
  _$ProfileUiStateCopyWithImpl(this._self, this._then);

  final ProfileUiState _self;
  final $Res Function(ProfileUiState) _then;

/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? canRetry = null,}) {
  return _then(_self.copyWith(
account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserAccount?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $UserAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileUiState].
extension ProfileUiStatePatterns on ProfileUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUiState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUiState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserAccount? account,  bool isLoading,  String? errorMessage,  bool canRetry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUiState() when $default != null:
return $default(_that.account,_that.isLoading,_that.errorMessage,_that.canRetry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserAccount? account,  bool isLoading,  String? errorMessage,  bool canRetry)  $default,) {final _that = this;
switch (_that) {
case _ProfileUiState():
return $default(_that.account,_that.isLoading,_that.errorMessage,_that.canRetry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserAccount? account,  bool isLoading,  String? errorMessage,  bool canRetry)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUiState() when $default != null:
return $default(_that.account,_that.isLoading,_that.errorMessage,_that.canRetry);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileUiState implements ProfileUiState {
  const _ProfileUiState({this.account, this.isLoading = true, this.errorMessage, this.canRetry = true});
  

@override final  UserAccount? account;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
/// False for terminal failures such as 403, where retrying cannot help.
@override@JsonKey() final  bool canRetry;

/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUiStateCopyWith<_ProfileUiState> get copyWith => __$ProfileUiStateCopyWithImpl<_ProfileUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUiState&&(identical(other.account, account) || other.account == account)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry));
}


@override
int get hashCode => Object.hash(runtimeType,account,isLoading,errorMessage,canRetry);

@override
String toString() {
  return 'ProfileUiState(account: $account, isLoading: $isLoading, errorMessage: $errorMessage, canRetry: $canRetry)';
}


}

/// @nodoc
abstract mixin class _$ProfileUiStateCopyWith<$Res> implements $ProfileUiStateCopyWith<$Res> {
  factory _$ProfileUiStateCopyWith(_ProfileUiState value, $Res Function(_ProfileUiState) _then) = __$ProfileUiStateCopyWithImpl;
@override @useResult
$Res call({
 UserAccount? account, bool isLoading, String? errorMessage, bool canRetry
});


@override $UserAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$ProfileUiStateCopyWithImpl<$Res>
    implements _$ProfileUiStateCopyWith<$Res> {
  __$ProfileUiStateCopyWithImpl(this._self, this._then);

  final _ProfileUiState _self;
  final $Res Function(_ProfileUiState) _then;

/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? canRetry = null,}) {
  return _then(_ProfileUiState(
account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as UserAccount?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProfileUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $UserAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
