// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardUiState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardUiState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardUiState()';
}


}

/// @nodoc
class $DashboardUiStateCopyWith<$Res>  {
$DashboardUiStateCopyWith(DashboardUiState _, $Res Function(DashboardUiState) __);
}


/// Adds pattern-matching-related methods to [DashboardUiState].
extension DashboardUiStatePatterns on DashboardUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardLoading value)?  loading,TResult Function( DashboardSuccess value)?  success,TResult Function( DashboardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardSuccess() when success != null:
return success(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardLoading value)  loading,required TResult Function( DashboardSuccess value)  success,required TResult Function( DashboardError value)  error,}){
final _that = this;
switch (_that) {
case DashboardLoading():
return loading(_that);case DashboardSuccess():
return success(_that);case DashboardError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardLoading value)?  loading,TResult? Function( DashboardSuccess value)?  success,TResult? Function( DashboardError value)?  error,}){
final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading(_that);case DashboardSuccess() when success != null:
return success(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( DashboardSummary summary,  bool isRefreshing)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardSuccess() when success != null:
return success(_that.summary,_that.isRefreshing);case DashboardError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( DashboardSummary summary,  bool isRefreshing)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DashboardLoading():
return loading();case DashboardSuccess():
return success(_that.summary,_that.isRefreshing);case DashboardError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( DashboardSummary summary,  bool isRefreshing)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DashboardLoading() when loading != null:
return loading();case DashboardSuccess() when success != null:
return success(_that.summary,_that.isRefreshing);case DashboardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DashboardLoading implements DashboardUiState {
  const DashboardLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardUiState.loading()';
}


}




/// @nodoc


class DashboardSuccess implements DashboardUiState {
  const DashboardSuccess(this.summary, {this.isRefreshing = false});
  

 final  DashboardSummary summary;
@JsonKey() final  bool isRefreshing;

/// Create a copy of DashboardUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSuccessCopyWith<DashboardSuccess> get copyWith => _$DashboardSuccessCopyWithImpl<DashboardSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSuccess&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing));
}


@override
int get hashCode => Object.hash(runtimeType,summary,isRefreshing);

@override
String toString() {
  return 'DashboardUiState.success(summary: $summary, isRefreshing: $isRefreshing)';
}


}

/// @nodoc
abstract mixin class $DashboardSuccessCopyWith<$Res> implements $DashboardUiStateCopyWith<$Res> {
  factory $DashboardSuccessCopyWith(DashboardSuccess value, $Res Function(DashboardSuccess) _then) = _$DashboardSuccessCopyWithImpl;
@useResult
$Res call({
 DashboardSummary summary, bool isRefreshing
});


$DashboardSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$DashboardSuccessCopyWithImpl<$Res>
    implements $DashboardSuccessCopyWith<$Res> {
  _$DashboardSuccessCopyWithImpl(this._self, this._then);

  final DashboardSuccess _self;
  final $Res Function(DashboardSuccess) _then;

/// Create a copy of DashboardUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? isRefreshing = null,}) {
  return _then(DashboardSuccess(
null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as DashboardSummary,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DashboardUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<$Res> get summary {
  
  return $DashboardSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

/// @nodoc


class DashboardError implements DashboardUiState {
  const DashboardError(this.message);
  

 final  String message;

/// Create a copy of DashboardUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardErrorCopyWith<DashboardError> get copyWith => _$DashboardErrorCopyWithImpl<DashboardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DashboardUiState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardErrorCopyWith<$Res> implements $DashboardUiStateCopyWith<$Res> {
  factory $DashboardErrorCopyWith(DashboardError value, $Res Function(DashboardError) _then) = _$DashboardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DashboardErrorCopyWithImpl<$Res>
    implements $DashboardErrorCopyWith<$Res> {
  _$DashboardErrorCopyWithImpl(this._self, this._then);

  final DashboardError _self;
  final $Res Function(DashboardError) _then;

/// Create a copy of DashboardUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DashboardError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
