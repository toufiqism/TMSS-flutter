// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requisition_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequisitionListUiState {

 String get searchQuery; DateTime? get startDate; DateTime? get endDate; RequisitionSortField get sortBy; bool get sortDescending; List<Requisition> get items; bool get isInitialLoading; bool get isLoadingMore; bool get isRefreshing; bool get hasMore; String? get errorMessage;
/// Create a copy of RequisitionListUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionListUiStateCopyWith<RequisitionListUiState> get copyWith => _$RequisitionListUiStateCopyWithImpl<RequisitionListUiState>(this as RequisitionListUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionListUiState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDescending, sortDescending) || other.sortDescending == sortDescending)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isInitialLoading, isInitialLoading) || other.isInitialLoading == isInitialLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,startDate,endDate,sortBy,sortDescending,const DeepCollectionEquality().hash(items),isInitialLoading,isLoadingMore,isRefreshing,hasMore,errorMessage);

@override
String toString() {
  return 'RequisitionListUiState(searchQuery: $searchQuery, startDate: $startDate, endDate: $endDate, sortBy: $sortBy, sortDescending: $sortDescending, items: $items, isInitialLoading: $isInitialLoading, isLoadingMore: $isLoadingMore, isRefreshing: $isRefreshing, hasMore: $hasMore, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $RequisitionListUiStateCopyWith<$Res>  {
  factory $RequisitionListUiStateCopyWith(RequisitionListUiState value, $Res Function(RequisitionListUiState) _then) = _$RequisitionListUiStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, DateTime? startDate, DateTime? endDate, RequisitionSortField sortBy, bool sortDescending, List<Requisition> items, bool isInitialLoading, bool isLoadingMore, bool isRefreshing, bool hasMore, String? errorMessage
});




}
/// @nodoc
class _$RequisitionListUiStateCopyWithImpl<$Res>
    implements $RequisitionListUiStateCopyWith<$Res> {
  _$RequisitionListUiStateCopyWithImpl(this._self, this._then);

  final RequisitionListUiState _self;
  final $Res Function(RequisitionListUiState) _then;

/// Create a copy of RequisitionListUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? startDate = freezed,Object? endDate = freezed,Object? sortBy = null,Object? sortDescending = null,Object? items = null,Object? isInitialLoading = null,Object? isLoadingMore = null,Object? isRefreshing = null,Object? hasMore = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as RequisitionSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Requisition>,isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequisitionListUiState].
extension RequisitionListUiStatePatterns on RequisitionListUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionListUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionListUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionListUiState value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionListUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionListUiState value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionListUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  DateTime? startDate,  DateTime? endDate,  RequisitionSortField sortBy,  bool sortDescending,  List<Requisition> items,  bool isInitialLoading,  bool isLoadingMore,  bool isRefreshing,  bool hasMore,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionListUiState() when $default != null:
return $default(_that.searchQuery,_that.startDate,_that.endDate,_that.sortBy,_that.sortDescending,_that.items,_that.isInitialLoading,_that.isLoadingMore,_that.isRefreshing,_that.hasMore,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  DateTime? startDate,  DateTime? endDate,  RequisitionSortField sortBy,  bool sortDescending,  List<Requisition> items,  bool isInitialLoading,  bool isLoadingMore,  bool isRefreshing,  bool hasMore,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RequisitionListUiState():
return $default(_that.searchQuery,_that.startDate,_that.endDate,_that.sortBy,_that.sortDescending,_that.items,_that.isInitialLoading,_that.isLoadingMore,_that.isRefreshing,_that.hasMore,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  DateTime? startDate,  DateTime? endDate,  RequisitionSortField sortBy,  bool sortDescending,  List<Requisition> items,  bool isInitialLoading,  bool isLoadingMore,  bool isRefreshing,  bool hasMore,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionListUiState() when $default != null:
return $default(_that.searchQuery,_that.startDate,_that.endDate,_that.sortBy,_that.sortDescending,_that.items,_that.isInitialLoading,_that.isLoadingMore,_that.isRefreshing,_that.hasMore,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RequisitionListUiState extends RequisitionListUiState {
  const _RequisitionListUiState({this.searchQuery = '', this.startDate, this.endDate, this.sortBy = RequisitionSortField.date, this.sortDescending = true, final  List<Requisition> items = const <Requisition>[], this.isInitialLoading = true, this.isLoadingMore = false, this.isRefreshing = false, this.hasMore = true, this.errorMessage}): _items = items,super._();
  

@override@JsonKey() final  String searchQuery;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  RequisitionSortField sortBy;
@override@JsonKey() final  bool sortDescending;
 final  List<Requisition> _items;
@override@JsonKey() List<Requisition> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isInitialLoading;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool hasMore;
@override final  String? errorMessage;

/// Create a copy of RequisitionListUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionListUiStateCopyWith<_RequisitionListUiState> get copyWith => __$RequisitionListUiStateCopyWithImpl<_RequisitionListUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionListUiState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDescending, sortDescending) || other.sortDescending == sortDescending)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isInitialLoading, isInitialLoading) || other.isInitialLoading == isInitialLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,startDate,endDate,sortBy,sortDescending,const DeepCollectionEquality().hash(_items),isInitialLoading,isLoadingMore,isRefreshing,hasMore,errorMessage);

@override
String toString() {
  return 'RequisitionListUiState(searchQuery: $searchQuery, startDate: $startDate, endDate: $endDate, sortBy: $sortBy, sortDescending: $sortDescending, items: $items, isInitialLoading: $isInitialLoading, isLoadingMore: $isLoadingMore, isRefreshing: $isRefreshing, hasMore: $hasMore, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RequisitionListUiStateCopyWith<$Res> implements $RequisitionListUiStateCopyWith<$Res> {
  factory _$RequisitionListUiStateCopyWith(_RequisitionListUiState value, $Res Function(_RequisitionListUiState) _then) = __$RequisitionListUiStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, DateTime? startDate, DateTime? endDate, RequisitionSortField sortBy, bool sortDescending, List<Requisition> items, bool isInitialLoading, bool isLoadingMore, bool isRefreshing, bool hasMore, String? errorMessage
});




}
/// @nodoc
class __$RequisitionListUiStateCopyWithImpl<$Res>
    implements _$RequisitionListUiStateCopyWith<$Res> {
  __$RequisitionListUiStateCopyWithImpl(this._self, this._then);

  final _RequisitionListUiState _self;
  final $Res Function(_RequisitionListUiState) _then;

/// Create a copy of RequisitionListUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? startDate = freezed,Object? endDate = freezed,Object? sortBy = null,Object? sortDescending = null,Object? items = null,Object? isInitialLoading = null,Object? isLoadingMore = null,Object? isRefreshing = null,Object? hasMore = null,Object? errorMessage = freezed,}) {
  return _then(_RequisitionListUiState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as RequisitionSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Requisition>,isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
