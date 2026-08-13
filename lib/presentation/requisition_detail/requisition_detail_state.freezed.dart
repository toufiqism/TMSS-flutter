// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requisition_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequisitionDetailUiState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDetailUiState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RequisitionDetailUiState()';
}


}

/// @nodoc
class $RequisitionDetailUiStateCopyWith<$Res>  {
$RequisitionDetailUiStateCopyWith(RequisitionDetailUiState _, $Res Function(RequisitionDetailUiState) __);
}


/// Adds pattern-matching-related methods to [RequisitionDetailUiState].
extension RequisitionDetailUiStatePatterns on RequisitionDetailUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RequisitionDetailLoading value)?  loading,TResult Function( RequisitionDetailSuccess value)?  success,TResult Function( RequisitionDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RequisitionDetailLoading() when loading != null:
return loading(_that);case RequisitionDetailSuccess() when success != null:
return success(_that);case RequisitionDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RequisitionDetailLoading value)  loading,required TResult Function( RequisitionDetailSuccess value)  success,required TResult Function( RequisitionDetailError value)  error,}){
final _that = this;
switch (_that) {
case RequisitionDetailLoading():
return loading(_that);case RequisitionDetailSuccess():
return success(_that);case RequisitionDetailError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RequisitionDetailLoading value)?  loading,TResult? Function( RequisitionDetailSuccess value)?  success,TResult? Function( RequisitionDetailError value)?  error,}){
final _that = this;
switch (_that) {
case RequisitionDetailLoading() when loading != null:
return loading(_that);case RequisitionDetailSuccess() when success != null:
return success(_that);case RequisitionDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Requisition requisition,  bool isRefreshing,  bool isCancelling)?  success,TResult Function( String message,  bool canRetry)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RequisitionDetailLoading() when loading != null:
return loading();case RequisitionDetailSuccess() when success != null:
return success(_that.requisition,_that.isRefreshing,_that.isCancelling);case RequisitionDetailError() when error != null:
return error(_that.message,_that.canRetry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Requisition requisition,  bool isRefreshing,  bool isCancelling)  success,required TResult Function( String message,  bool canRetry)  error,}) {final _that = this;
switch (_that) {
case RequisitionDetailLoading():
return loading();case RequisitionDetailSuccess():
return success(_that.requisition,_that.isRefreshing,_that.isCancelling);case RequisitionDetailError():
return error(_that.message,_that.canRetry);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Requisition requisition,  bool isRefreshing,  bool isCancelling)?  success,TResult? Function( String message,  bool canRetry)?  error,}) {final _that = this;
switch (_that) {
case RequisitionDetailLoading() when loading != null:
return loading();case RequisitionDetailSuccess() when success != null:
return success(_that.requisition,_that.isRefreshing,_that.isCancelling);case RequisitionDetailError() when error != null:
return error(_that.message,_that.canRetry);case _:
  return null;

}
}

}

/// @nodoc


class RequisitionDetailLoading implements RequisitionDetailUiState {
  const RequisitionDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RequisitionDetailUiState.loading()';
}


}




/// @nodoc


class RequisitionDetailSuccess implements RequisitionDetailUiState {
  const RequisitionDetailSuccess(this.requisition, {this.isRefreshing = false, this.isCancelling = false});
  

 final  Requisition requisition;
/// A refetch running underneath content that is already on screen — pull-to-refresh,
/// or the resync after a save or a 409.
@JsonKey() final  bool isRefreshing;
/// A cancel in flight. Keeps the action disabled without blanking the screen.
@JsonKey() final  bool isCancelling;

/// Create a copy of RequisitionDetailUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionDetailSuccessCopyWith<RequisitionDetailSuccess> get copyWith => _$RequisitionDetailSuccessCopyWithImpl<RequisitionDetailSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDetailSuccess&&(identical(other.requisition, requisition) || other.requisition == requisition)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isCancelling, isCancelling) || other.isCancelling == isCancelling));
}


@override
int get hashCode => Object.hash(runtimeType,requisition,isRefreshing,isCancelling);

@override
String toString() {
  return 'RequisitionDetailUiState.success(requisition: $requisition, isRefreshing: $isRefreshing, isCancelling: $isCancelling)';
}


}

/// @nodoc
abstract mixin class $RequisitionDetailSuccessCopyWith<$Res> implements $RequisitionDetailUiStateCopyWith<$Res> {
  factory $RequisitionDetailSuccessCopyWith(RequisitionDetailSuccess value, $Res Function(RequisitionDetailSuccess) _then) = _$RequisitionDetailSuccessCopyWithImpl;
@useResult
$Res call({
 Requisition requisition, bool isRefreshing, bool isCancelling
});


$RequisitionCopyWith<$Res> get requisition;

}
/// @nodoc
class _$RequisitionDetailSuccessCopyWithImpl<$Res>
    implements $RequisitionDetailSuccessCopyWith<$Res> {
  _$RequisitionDetailSuccessCopyWithImpl(this._self, this._then);

  final RequisitionDetailSuccess _self;
  final $Res Function(RequisitionDetailSuccess) _then;

/// Create a copy of RequisitionDetailUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? requisition = null,Object? isRefreshing = null,Object? isCancelling = null,}) {
  return _then(RequisitionDetailSuccess(
null == requisition ? _self.requisition : requisition // ignore: cast_nullable_to_non_nullable
as Requisition,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isCancelling: null == isCancelling ? _self.isCancelling : isCancelling // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RequisitionDetailUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequisitionCopyWith<$Res> get requisition {
  
  return $RequisitionCopyWith<$Res>(_self.requisition, (value) {
    return _then(_self.copyWith(requisition: value));
  });
}
}

/// @nodoc


class RequisitionDetailError implements RequisitionDetailUiState {
  const RequisitionDetailError(this.message, {this.canRetry = true});
  

 final  String message;
@JsonKey() final  bool canRetry;

/// Create a copy of RequisitionDetailUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionDetailErrorCopyWith<RequisitionDetailError> get copyWith => _$RequisitionDetailErrorCopyWithImpl<RequisitionDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDetailError&&(identical(other.message, message) || other.message == message)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry));
}


@override
int get hashCode => Object.hash(runtimeType,message,canRetry);

@override
String toString() {
  return 'RequisitionDetailUiState.error(message: $message, canRetry: $canRetry)';
}


}

/// @nodoc
abstract mixin class $RequisitionDetailErrorCopyWith<$Res> implements $RequisitionDetailUiStateCopyWith<$Res> {
  factory $RequisitionDetailErrorCopyWith(RequisitionDetailError value, $Res Function(RequisitionDetailError) _then) = _$RequisitionDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message, bool canRetry
});




}
/// @nodoc
class _$RequisitionDetailErrorCopyWithImpl<$Res>
    implements $RequisitionDetailErrorCopyWith<$Res> {
  _$RequisitionDetailErrorCopyWithImpl(this._self, this._then);

  final RequisitionDetailError _self;
  final $Res Function(RequisitionDetailError) _then;

/// Create a copy of RequisitionDetailUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? canRetry = null,}) {
  return _then(RequisitionDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
