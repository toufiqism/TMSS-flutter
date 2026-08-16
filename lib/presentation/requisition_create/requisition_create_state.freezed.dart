// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requisition_create_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PassengerFormState {

 DateTime? get pickupDateTime; String get pickupLocation; String get dropLocation; UsedType get usedType; String get customerName; String get numberOfPersons; RequiredFor get requiredFor; RequisitionUserType get userType; List<Employee> get selectedEmployees; String get purpose; String get remarks;
/// Create a copy of PassengerFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerFormStateCopyWith<PassengerFormState> get copyWith => _$PassengerFormStateCopyWithImpl<PassengerFormState>(this as PassengerFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerFormState&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.usedType, usedType) || other.usedType == usedType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.numberOfPersons, numberOfPersons) || other.numberOfPersons == numberOfPersons)&&(identical(other.requiredFor, requiredFor) || other.requiredFor == requiredFor)&&(identical(other.userType, userType) || other.userType == userType)&&const DeepCollectionEquality().equals(other.selectedEmployees, selectedEmployees)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,usedType,customerName,numberOfPersons,requiredFor,userType,const DeepCollectionEquality().hash(selectedEmployees),purpose,remarks);

@override
String toString() {
  return 'PassengerFormState(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, usedType: $usedType, customerName: $customerName, numberOfPersons: $numberOfPersons, requiredFor: $requiredFor, userType: $userType, selectedEmployees: $selectedEmployees, purpose: $purpose, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $PassengerFormStateCopyWith<$Res>  {
  factory $PassengerFormStateCopyWith(PassengerFormState value, $Res Function(PassengerFormState) _then) = _$PassengerFormStateCopyWithImpl;
@useResult
$Res call({
 DateTime? pickupDateTime, String pickupLocation, String dropLocation, UsedType usedType, String customerName, String numberOfPersons, RequiredFor requiredFor, RequisitionUserType userType, List<Employee> selectedEmployees, String purpose, String remarks
});




}
/// @nodoc
class _$PassengerFormStateCopyWithImpl<$Res>
    implements $PassengerFormStateCopyWith<$Res> {
  _$PassengerFormStateCopyWithImpl(this._self, this._then);

  final PassengerFormState _self;
  final $Res Function(PassengerFormState) _then;

/// Create a copy of PassengerFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickupDateTime = freezed,Object? pickupLocation = null,Object? dropLocation = null,Object? usedType = null,Object? customerName = null,Object? numberOfPersons = null,Object? requiredFor = null,Object? userType = null,Object? selectedEmployees = null,Object? purpose = null,Object? remarks = null,}) {
  return _then(_self.copyWith(
pickupDateTime: freezed == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,usedType: null == usedType ? _self.usedType : usedType // ignore: cast_nullable_to_non_nullable
as UsedType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,numberOfPersons: null == numberOfPersons ? _self.numberOfPersons : numberOfPersons // ignore: cast_nullable_to_non_nullable
as String,requiredFor: null == requiredFor ? _self.requiredFor : requiredFor // ignore: cast_nullable_to_non_nullable
as RequiredFor,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as RequisitionUserType,selectedEmployees: null == selectedEmployees ? _self.selectedEmployees : selectedEmployees // ignore: cast_nullable_to_non_nullable
as List<Employee>,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PassengerFormState].
extension PassengerFormStatePatterns on PassengerFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassengerFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassengerFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassengerFormState value)  $default,){
final _that = this;
switch (_that) {
case _PassengerFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassengerFormState value)?  $default,){
final _that = this;
switch (_that) {
case _PassengerFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  UsedType usedType,  String customerName,  String numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType userType,  List<Employee> selectedEmployees,  String purpose,  String remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassengerFormState() when $default != null:
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.selectedEmployees,_that.purpose,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  UsedType usedType,  String customerName,  String numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType userType,  List<Employee> selectedEmployees,  String purpose,  String remarks)  $default,) {final _that = this;
switch (_that) {
case _PassengerFormState():
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.selectedEmployees,_that.purpose,_that.remarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  UsedType usedType,  String customerName,  String numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType userType,  List<Employee> selectedEmployees,  String purpose,  String remarks)?  $default,) {final _that = this;
switch (_that) {
case _PassengerFormState() when $default != null:
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.selectedEmployees,_that.purpose,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc


class _PassengerFormState implements PassengerFormState {
  const _PassengerFormState({this.pickupDateTime, this.pickupLocation = '', this.dropLocation = '', this.usedType = UsedType.pickupAndDrop, this.customerName = '', this.numberOfPersons = '', this.requiredFor = RequiredFor.ownUser, this.userType = RequisitionUserType.internal, final  List<Employee> selectedEmployees = const <Employee>[], this.purpose = '', this.remarks = ''}): _selectedEmployees = selectedEmployees;
  

@override final  DateTime? pickupDateTime;
@override@JsonKey() final  String pickupLocation;
@override@JsonKey() final  String dropLocation;
@override@JsonKey() final  UsedType usedType;
@override@JsonKey() final  String customerName;
@override@JsonKey() final  String numberOfPersons;
@override@JsonKey() final  RequiredFor requiredFor;
@override@JsonKey() final  RequisitionUserType userType;
 final  List<Employee> _selectedEmployees;
@override@JsonKey() List<Employee> get selectedEmployees {
  if (_selectedEmployees is EqualUnmodifiableListView) return _selectedEmployees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedEmployees);
}

@override@JsonKey() final  String purpose;
@override@JsonKey() final  String remarks;

/// Create a copy of PassengerFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassengerFormStateCopyWith<_PassengerFormState> get copyWith => __$PassengerFormStateCopyWithImpl<_PassengerFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassengerFormState&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.usedType, usedType) || other.usedType == usedType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.numberOfPersons, numberOfPersons) || other.numberOfPersons == numberOfPersons)&&(identical(other.requiredFor, requiredFor) || other.requiredFor == requiredFor)&&(identical(other.userType, userType) || other.userType == userType)&&const DeepCollectionEquality().equals(other._selectedEmployees, _selectedEmployees)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,usedType,customerName,numberOfPersons,requiredFor,userType,const DeepCollectionEquality().hash(_selectedEmployees),purpose,remarks);

@override
String toString() {
  return 'PassengerFormState(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, usedType: $usedType, customerName: $customerName, numberOfPersons: $numberOfPersons, requiredFor: $requiredFor, userType: $userType, selectedEmployees: $selectedEmployees, purpose: $purpose, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$PassengerFormStateCopyWith<$Res> implements $PassengerFormStateCopyWith<$Res> {
  factory _$PassengerFormStateCopyWith(_PassengerFormState value, $Res Function(_PassengerFormState) _then) = __$PassengerFormStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime? pickupDateTime, String pickupLocation, String dropLocation, UsedType usedType, String customerName, String numberOfPersons, RequiredFor requiredFor, RequisitionUserType userType, List<Employee> selectedEmployees, String purpose, String remarks
});




}
/// @nodoc
class __$PassengerFormStateCopyWithImpl<$Res>
    implements _$PassengerFormStateCopyWith<$Res> {
  __$PassengerFormStateCopyWithImpl(this._self, this._then);

  final _PassengerFormState _self;
  final $Res Function(_PassengerFormState) _then;

/// Create a copy of PassengerFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickupDateTime = freezed,Object? pickupLocation = null,Object? dropLocation = null,Object? usedType = null,Object? customerName = null,Object? numberOfPersons = null,Object? requiredFor = null,Object? userType = null,Object? selectedEmployees = null,Object? purpose = null,Object? remarks = null,}) {
  return _then(_PassengerFormState(
pickupDateTime: freezed == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,usedType: null == usedType ? _self.usedType : usedType // ignore: cast_nullable_to_non_nullable
as UsedType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,numberOfPersons: null == numberOfPersons ? _self.numberOfPersons : numberOfPersons // ignore: cast_nullable_to_non_nullable
as String,requiredFor: null == requiredFor ? _self.requiredFor : requiredFor // ignore: cast_nullable_to_non_nullable
as RequiredFor,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as RequisitionUserType,selectedEmployees: null == selectedEmployees ? _self._selectedEmployees : selectedEmployees // ignore: cast_nullable_to_non_nullable
as List<Employee>,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LogisticsFormState {

 DateTime? get pickupDateTime; String get pickupLocation; String get dropLocation; VehicleType get vehicleType; String get customerName; String get userDepartment; LoadingCapacity get loadingCapacity; String get goodsWeight; String get storeName; String get goodsDetails; String get remarks;
/// Create a copy of LogisticsFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogisticsFormStateCopyWith<LogisticsFormState> get copyWith => _$LogisticsFormStateCopyWithImpl<LogisticsFormState>(this as LogisticsFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogisticsFormState&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.userDepartment, userDepartment) || other.userDepartment == userDepartment)&&(identical(other.loadingCapacity, loadingCapacity) || other.loadingCapacity == loadingCapacity)&&(identical(other.goodsWeight, goodsWeight) || other.goodsWeight == goodsWeight)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.goodsDetails, goodsDetails) || other.goodsDetails == goodsDetails)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,vehicleType,customerName,userDepartment,loadingCapacity,goodsWeight,storeName,goodsDetails,remarks);

@override
String toString() {
  return 'LogisticsFormState(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, vehicleType: $vehicleType, customerName: $customerName, userDepartment: $userDepartment, loadingCapacity: $loadingCapacity, goodsWeight: $goodsWeight, storeName: $storeName, goodsDetails: $goodsDetails, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $LogisticsFormStateCopyWith<$Res>  {
  factory $LogisticsFormStateCopyWith(LogisticsFormState value, $Res Function(LogisticsFormState) _then) = _$LogisticsFormStateCopyWithImpl;
@useResult
$Res call({
 DateTime? pickupDateTime, String pickupLocation, String dropLocation, VehicleType vehicleType, String customerName, String userDepartment, LoadingCapacity loadingCapacity, String goodsWeight, String storeName, String goodsDetails, String remarks
});




}
/// @nodoc
class _$LogisticsFormStateCopyWithImpl<$Res>
    implements $LogisticsFormStateCopyWith<$Res> {
  _$LogisticsFormStateCopyWithImpl(this._self, this._then);

  final LogisticsFormState _self;
  final $Res Function(LogisticsFormState) _then;

/// Create a copy of LogisticsFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickupDateTime = freezed,Object? pickupLocation = null,Object? dropLocation = null,Object? vehicleType = null,Object? customerName = null,Object? userDepartment = null,Object? loadingCapacity = null,Object? goodsWeight = null,Object? storeName = null,Object? goodsDetails = null,Object? remarks = null,}) {
  return _then(_self.copyWith(
pickupDateTime: freezed == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,userDepartment: null == userDepartment ? _self.userDepartment : userDepartment // ignore: cast_nullable_to_non_nullable
as String,loadingCapacity: null == loadingCapacity ? _self.loadingCapacity : loadingCapacity // ignore: cast_nullable_to_non_nullable
as LoadingCapacity,goodsWeight: null == goodsWeight ? _self.goodsWeight : goodsWeight // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,goodsDetails: null == goodsDetails ? _self.goodsDetails : goodsDetails // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogisticsFormState].
extension LogisticsFormStatePatterns on LogisticsFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogisticsFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogisticsFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogisticsFormState value)  $default,){
final _that = this;
switch (_that) {
case _LogisticsFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogisticsFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LogisticsFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails,  String remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogisticsFormState() when $default != null:
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails,  String remarks)  $default,) {final _that = this;
switch (_that) {
case _LogisticsFormState():
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails,_that.remarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? pickupDateTime,  String pickupLocation,  String dropLocation,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails,  String remarks)?  $default,) {final _that = this;
switch (_that) {
case _LogisticsFormState() when $default != null:
return $default(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc


class _LogisticsFormState implements LogisticsFormState {
  const _LogisticsFormState({this.pickupDateTime, this.pickupLocation = '', this.dropLocation = '', this.vehicleType = VehicleType.coverVan, this.customerName = '', this.userDepartment = '', this.loadingCapacity = LoadingCapacity.ton2, this.goodsWeight = '', this.storeName = '', this.goodsDetails = '', this.remarks = ''});
  

@override final  DateTime? pickupDateTime;
@override@JsonKey() final  String pickupLocation;
@override@JsonKey() final  String dropLocation;
@override@JsonKey() final  VehicleType vehicleType;
@override@JsonKey() final  String customerName;
@override@JsonKey() final  String userDepartment;
@override@JsonKey() final  LoadingCapacity loadingCapacity;
@override@JsonKey() final  String goodsWeight;
@override@JsonKey() final  String storeName;
@override@JsonKey() final  String goodsDetails;
@override@JsonKey() final  String remarks;

/// Create a copy of LogisticsFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogisticsFormStateCopyWith<_LogisticsFormState> get copyWith => __$LogisticsFormStateCopyWithImpl<_LogisticsFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogisticsFormState&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.userDepartment, userDepartment) || other.userDepartment == userDepartment)&&(identical(other.loadingCapacity, loadingCapacity) || other.loadingCapacity == loadingCapacity)&&(identical(other.goodsWeight, goodsWeight) || other.goodsWeight == goodsWeight)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.goodsDetails, goodsDetails) || other.goodsDetails == goodsDetails)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,vehicleType,customerName,userDepartment,loadingCapacity,goodsWeight,storeName,goodsDetails,remarks);

@override
String toString() {
  return 'LogisticsFormState(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, vehicleType: $vehicleType, customerName: $customerName, userDepartment: $userDepartment, loadingCapacity: $loadingCapacity, goodsWeight: $goodsWeight, storeName: $storeName, goodsDetails: $goodsDetails, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$LogisticsFormStateCopyWith<$Res> implements $LogisticsFormStateCopyWith<$Res> {
  factory _$LogisticsFormStateCopyWith(_LogisticsFormState value, $Res Function(_LogisticsFormState) _then) = __$LogisticsFormStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime? pickupDateTime, String pickupLocation, String dropLocation, VehicleType vehicleType, String customerName, String userDepartment, LoadingCapacity loadingCapacity, String goodsWeight, String storeName, String goodsDetails, String remarks
});




}
/// @nodoc
class __$LogisticsFormStateCopyWithImpl<$Res>
    implements _$LogisticsFormStateCopyWith<$Res> {
  __$LogisticsFormStateCopyWithImpl(this._self, this._then);

  final _LogisticsFormState _self;
  final $Res Function(_LogisticsFormState) _then;

/// Create a copy of LogisticsFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickupDateTime = freezed,Object? pickupLocation = null,Object? dropLocation = null,Object? vehicleType = null,Object? customerName = null,Object? userDepartment = null,Object? loadingCapacity = null,Object? goodsWeight = null,Object? storeName = null,Object? goodsDetails = null,Object? remarks = null,}) {
  return _then(_LogisticsFormState(
pickupDateTime: freezed == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,userDepartment: null == userDepartment ? _self.userDepartment : userDepartment // ignore: cast_nullable_to_non_nullable
as String,loadingCapacity: null == loadingCapacity ? _self.loadingCapacity : loadingCapacity // ignore: cast_nullable_to_non_nullable
as LoadingCapacity,goodsWeight: null == goodsWeight ? _self.goodsWeight : goodsWeight // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,goodsDetails: null == goodsDetails ? _self.goodsDetails : goodsDetails // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$RequisitionCreateUiState {

 RequisitionFormType get formType; PassengerFormState get passengerForm; LogisticsFormState get logisticsForm; String get employeeSearchQuery; List<Employee> get employeeSearchResults; bool get isSearchingEmployees;/// Surfaced under the employee picker. Without it a failed lookup is
/// indistinguishable from "this search genuinely matched nobody".
 String? get employeeSearchError; bool get isSubmitting; Map<String, String> get fieldErrors; String? get submitError;/// Set when this screen is editing an existing requisition rather than creating one.
///
/// Drives three things: the submit call becomes a PUT, the copy changes, and the
/// Passenger/Logistics toggle locks — the server rejects a `req_type` that differs
/// from the stored one, so switching type mid-edit could only ever 422.
 String? get editingRequisitionId;/// Who raised the requisition being edited, for the read-only header. All four are
/// null while creating, and individually null when the server did not report them —
/// the header renders only the parts that exist rather than blank rows.
 String? get editingRequesterName; String? get editingRequesterCode; String? get editingRequesterDepartment; String? get editingRequesterCompany;
/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionCreateUiStateCopyWith<RequisitionCreateUiState> get copyWith => _$RequisitionCreateUiStateCopyWithImpl<RequisitionCreateUiState>(this as RequisitionCreateUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionCreateUiState&&(identical(other.formType, formType) || other.formType == formType)&&(identical(other.passengerForm, passengerForm) || other.passengerForm == passengerForm)&&(identical(other.logisticsForm, logisticsForm) || other.logisticsForm == logisticsForm)&&(identical(other.employeeSearchQuery, employeeSearchQuery) || other.employeeSearchQuery == employeeSearchQuery)&&const DeepCollectionEquality().equals(other.employeeSearchResults, employeeSearchResults)&&(identical(other.isSearchingEmployees, isSearchingEmployees) || other.isSearchingEmployees == isSearchingEmployees)&&(identical(other.employeeSearchError, employeeSearchError) || other.employeeSearchError == employeeSearchError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&const DeepCollectionEquality().equals(other.fieldErrors, fieldErrors)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.editingRequisitionId, editingRequisitionId) || other.editingRequisitionId == editingRequisitionId)&&(identical(other.editingRequesterName, editingRequesterName) || other.editingRequesterName == editingRequesterName)&&(identical(other.editingRequesterCode, editingRequesterCode) || other.editingRequesterCode == editingRequesterCode)&&(identical(other.editingRequesterDepartment, editingRequesterDepartment) || other.editingRequesterDepartment == editingRequesterDepartment)&&(identical(other.editingRequesterCompany, editingRequesterCompany) || other.editingRequesterCompany == editingRequesterCompany));
}


@override
int get hashCode => Object.hash(runtimeType,formType,passengerForm,logisticsForm,employeeSearchQuery,const DeepCollectionEquality().hash(employeeSearchResults),isSearchingEmployees,employeeSearchError,isSubmitting,const DeepCollectionEquality().hash(fieldErrors),submitError,editingRequisitionId,editingRequesterName,editingRequesterCode,editingRequesterDepartment,editingRequesterCompany);

@override
String toString() {
  return 'RequisitionCreateUiState(formType: $formType, passengerForm: $passengerForm, logisticsForm: $logisticsForm, employeeSearchQuery: $employeeSearchQuery, employeeSearchResults: $employeeSearchResults, isSearchingEmployees: $isSearchingEmployees, employeeSearchError: $employeeSearchError, isSubmitting: $isSubmitting, fieldErrors: $fieldErrors, submitError: $submitError, editingRequisitionId: $editingRequisitionId, editingRequesterName: $editingRequesterName, editingRequesterCode: $editingRequesterCode, editingRequesterDepartment: $editingRequesterDepartment, editingRequesterCompany: $editingRequesterCompany)';
}


}

/// @nodoc
abstract mixin class $RequisitionCreateUiStateCopyWith<$Res>  {
  factory $RequisitionCreateUiStateCopyWith(RequisitionCreateUiState value, $Res Function(RequisitionCreateUiState) _then) = _$RequisitionCreateUiStateCopyWithImpl;
@useResult
$Res call({
 RequisitionFormType formType, PassengerFormState passengerForm, LogisticsFormState logisticsForm, String employeeSearchQuery, List<Employee> employeeSearchResults, bool isSearchingEmployees, String? employeeSearchError, bool isSubmitting, Map<String, String> fieldErrors, String? submitError, String? editingRequisitionId, String? editingRequesterName, String? editingRequesterCode, String? editingRequesterDepartment, String? editingRequesterCompany
});


$PassengerFormStateCopyWith<$Res> get passengerForm;$LogisticsFormStateCopyWith<$Res> get logisticsForm;

}
/// @nodoc
class _$RequisitionCreateUiStateCopyWithImpl<$Res>
    implements $RequisitionCreateUiStateCopyWith<$Res> {
  _$RequisitionCreateUiStateCopyWithImpl(this._self, this._then);

  final RequisitionCreateUiState _self;
  final $Res Function(RequisitionCreateUiState) _then;

/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formType = null,Object? passengerForm = null,Object? logisticsForm = null,Object? employeeSearchQuery = null,Object? employeeSearchResults = null,Object? isSearchingEmployees = null,Object? employeeSearchError = freezed,Object? isSubmitting = null,Object? fieldErrors = null,Object? submitError = freezed,Object? editingRequisitionId = freezed,Object? editingRequesterName = freezed,Object? editingRequesterCode = freezed,Object? editingRequesterDepartment = freezed,Object? editingRequesterCompany = freezed,}) {
  return _then(_self.copyWith(
formType: null == formType ? _self.formType : formType // ignore: cast_nullable_to_non_nullable
as RequisitionFormType,passengerForm: null == passengerForm ? _self.passengerForm : passengerForm // ignore: cast_nullable_to_non_nullable
as PassengerFormState,logisticsForm: null == logisticsForm ? _self.logisticsForm : logisticsForm // ignore: cast_nullable_to_non_nullable
as LogisticsFormState,employeeSearchQuery: null == employeeSearchQuery ? _self.employeeSearchQuery : employeeSearchQuery // ignore: cast_nullable_to_non_nullable
as String,employeeSearchResults: null == employeeSearchResults ? _self.employeeSearchResults : employeeSearchResults // ignore: cast_nullable_to_non_nullable
as List<Employee>,isSearchingEmployees: null == isSearchingEmployees ? _self.isSearchingEmployees : isSearchingEmployees // ignore: cast_nullable_to_non_nullable
as bool,employeeSearchError: freezed == employeeSearchError ? _self.employeeSearchError : employeeSearchError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,editingRequisitionId: freezed == editingRequisitionId ? _self.editingRequisitionId : editingRequisitionId // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterName: freezed == editingRequesterName ? _self.editingRequesterName : editingRequesterName // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterCode: freezed == editingRequesterCode ? _self.editingRequesterCode : editingRequesterCode // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterDepartment: freezed == editingRequesterDepartment ? _self.editingRequesterDepartment : editingRequesterDepartment // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterCompany: freezed == editingRequesterCompany ? _self.editingRequesterCompany : editingRequesterCompany // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PassengerFormStateCopyWith<$Res> get passengerForm {
  
  return $PassengerFormStateCopyWith<$Res>(_self.passengerForm, (value) {
    return _then(_self.copyWith(passengerForm: value));
  });
}/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogisticsFormStateCopyWith<$Res> get logisticsForm {
  
  return $LogisticsFormStateCopyWith<$Res>(_self.logisticsForm, (value) {
    return _then(_self.copyWith(logisticsForm: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequisitionCreateUiState].
extension RequisitionCreateUiStatePatterns on RequisitionCreateUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionCreateUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionCreateUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionCreateUiState value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionCreateUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionCreateUiState value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionCreateUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RequisitionFormType formType,  PassengerFormState passengerForm,  LogisticsFormState logisticsForm,  String employeeSearchQuery,  List<Employee> employeeSearchResults,  bool isSearchingEmployees,  String? employeeSearchError,  bool isSubmitting,  Map<String, String> fieldErrors,  String? submitError,  String? editingRequisitionId,  String? editingRequesterName,  String? editingRequesterCode,  String? editingRequesterDepartment,  String? editingRequesterCompany)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionCreateUiState() when $default != null:
return $default(_that.formType,_that.passengerForm,_that.logisticsForm,_that.employeeSearchQuery,_that.employeeSearchResults,_that.isSearchingEmployees,_that.employeeSearchError,_that.isSubmitting,_that.fieldErrors,_that.submitError,_that.editingRequisitionId,_that.editingRequesterName,_that.editingRequesterCode,_that.editingRequesterDepartment,_that.editingRequesterCompany);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RequisitionFormType formType,  PassengerFormState passengerForm,  LogisticsFormState logisticsForm,  String employeeSearchQuery,  List<Employee> employeeSearchResults,  bool isSearchingEmployees,  String? employeeSearchError,  bool isSubmitting,  Map<String, String> fieldErrors,  String? submitError,  String? editingRequisitionId,  String? editingRequesterName,  String? editingRequesterCode,  String? editingRequesterDepartment,  String? editingRequesterCompany)  $default,) {final _that = this;
switch (_that) {
case _RequisitionCreateUiState():
return $default(_that.formType,_that.passengerForm,_that.logisticsForm,_that.employeeSearchQuery,_that.employeeSearchResults,_that.isSearchingEmployees,_that.employeeSearchError,_that.isSubmitting,_that.fieldErrors,_that.submitError,_that.editingRequisitionId,_that.editingRequesterName,_that.editingRequesterCode,_that.editingRequesterDepartment,_that.editingRequesterCompany);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RequisitionFormType formType,  PassengerFormState passengerForm,  LogisticsFormState logisticsForm,  String employeeSearchQuery,  List<Employee> employeeSearchResults,  bool isSearchingEmployees,  String? employeeSearchError,  bool isSubmitting,  Map<String, String> fieldErrors,  String? submitError,  String? editingRequisitionId,  String? editingRequesterName,  String? editingRequesterCode,  String? editingRequesterDepartment,  String? editingRequesterCompany)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionCreateUiState() when $default != null:
return $default(_that.formType,_that.passengerForm,_that.logisticsForm,_that.employeeSearchQuery,_that.employeeSearchResults,_that.isSearchingEmployees,_that.employeeSearchError,_that.isSubmitting,_that.fieldErrors,_that.submitError,_that.editingRequisitionId,_that.editingRequesterName,_that.editingRequesterCode,_that.editingRequesterDepartment,_that.editingRequesterCompany);case _:
  return null;

}
}

}

/// @nodoc


class _RequisitionCreateUiState extends RequisitionCreateUiState {
  const _RequisitionCreateUiState({this.formType = RequisitionFormType.passenger, this.passengerForm = const PassengerFormState(), this.logisticsForm = const LogisticsFormState(), this.employeeSearchQuery = '', final  List<Employee> employeeSearchResults = const <Employee>[], this.isSearchingEmployees = false, this.employeeSearchError, this.isSubmitting = false, final  Map<String, String> fieldErrors = const <String, String>{}, this.submitError, this.editingRequisitionId, this.editingRequesterName, this.editingRequesterCode, this.editingRequesterDepartment, this.editingRequesterCompany}): _employeeSearchResults = employeeSearchResults,_fieldErrors = fieldErrors,super._();
  

@override@JsonKey() final  RequisitionFormType formType;
@override@JsonKey() final  PassengerFormState passengerForm;
@override@JsonKey() final  LogisticsFormState logisticsForm;
@override@JsonKey() final  String employeeSearchQuery;
 final  List<Employee> _employeeSearchResults;
@override@JsonKey() List<Employee> get employeeSearchResults {
  if (_employeeSearchResults is EqualUnmodifiableListView) return _employeeSearchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_employeeSearchResults);
}

@override@JsonKey() final  bool isSearchingEmployees;
/// Surfaced under the employee picker. Without it a failed lookup is
/// indistinguishable from "this search genuinely matched nobody".
@override final  String? employeeSearchError;
@override@JsonKey() final  bool isSubmitting;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

@override final  String? submitError;
/// Set when this screen is editing an existing requisition rather than creating one.
///
/// Drives three things: the submit call becomes a PUT, the copy changes, and the
/// Passenger/Logistics toggle locks — the server rejects a `req_type` that differs
/// from the stored one, so switching type mid-edit could only ever 422.
@override final  String? editingRequisitionId;
/// Who raised the requisition being edited, for the read-only header. All four are
/// null while creating, and individually null when the server did not report them —
/// the header renders only the parts that exist rather than blank rows.
@override final  String? editingRequesterName;
@override final  String? editingRequesterCode;
@override final  String? editingRequesterDepartment;
@override final  String? editingRequesterCompany;

/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionCreateUiStateCopyWith<_RequisitionCreateUiState> get copyWith => __$RequisitionCreateUiStateCopyWithImpl<_RequisitionCreateUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionCreateUiState&&(identical(other.formType, formType) || other.formType == formType)&&(identical(other.passengerForm, passengerForm) || other.passengerForm == passengerForm)&&(identical(other.logisticsForm, logisticsForm) || other.logisticsForm == logisticsForm)&&(identical(other.employeeSearchQuery, employeeSearchQuery) || other.employeeSearchQuery == employeeSearchQuery)&&const DeepCollectionEquality().equals(other._employeeSearchResults, _employeeSearchResults)&&(identical(other.isSearchingEmployees, isSearchingEmployees) || other.isSearchingEmployees == isSearchingEmployees)&&(identical(other.employeeSearchError, employeeSearchError) || other.employeeSearchError == employeeSearchError)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors)&&(identical(other.submitError, submitError) || other.submitError == submitError)&&(identical(other.editingRequisitionId, editingRequisitionId) || other.editingRequisitionId == editingRequisitionId)&&(identical(other.editingRequesterName, editingRequesterName) || other.editingRequesterName == editingRequesterName)&&(identical(other.editingRequesterCode, editingRequesterCode) || other.editingRequesterCode == editingRequesterCode)&&(identical(other.editingRequesterDepartment, editingRequesterDepartment) || other.editingRequesterDepartment == editingRequesterDepartment)&&(identical(other.editingRequesterCompany, editingRequesterCompany) || other.editingRequesterCompany == editingRequesterCompany));
}


@override
int get hashCode => Object.hash(runtimeType,formType,passengerForm,logisticsForm,employeeSearchQuery,const DeepCollectionEquality().hash(_employeeSearchResults),isSearchingEmployees,employeeSearchError,isSubmitting,const DeepCollectionEquality().hash(_fieldErrors),submitError,editingRequisitionId,editingRequesterName,editingRequesterCode,editingRequesterDepartment,editingRequesterCompany);

@override
String toString() {
  return 'RequisitionCreateUiState(formType: $formType, passengerForm: $passengerForm, logisticsForm: $logisticsForm, employeeSearchQuery: $employeeSearchQuery, employeeSearchResults: $employeeSearchResults, isSearchingEmployees: $isSearchingEmployees, employeeSearchError: $employeeSearchError, isSubmitting: $isSubmitting, fieldErrors: $fieldErrors, submitError: $submitError, editingRequisitionId: $editingRequisitionId, editingRequesterName: $editingRequesterName, editingRequesterCode: $editingRequesterCode, editingRequesterDepartment: $editingRequesterDepartment, editingRequesterCompany: $editingRequesterCompany)';
}


}

/// @nodoc
abstract mixin class _$RequisitionCreateUiStateCopyWith<$Res> implements $RequisitionCreateUiStateCopyWith<$Res> {
  factory _$RequisitionCreateUiStateCopyWith(_RequisitionCreateUiState value, $Res Function(_RequisitionCreateUiState) _then) = __$RequisitionCreateUiStateCopyWithImpl;
@override @useResult
$Res call({
 RequisitionFormType formType, PassengerFormState passengerForm, LogisticsFormState logisticsForm, String employeeSearchQuery, List<Employee> employeeSearchResults, bool isSearchingEmployees, String? employeeSearchError, bool isSubmitting, Map<String, String> fieldErrors, String? submitError, String? editingRequisitionId, String? editingRequesterName, String? editingRequesterCode, String? editingRequesterDepartment, String? editingRequesterCompany
});


@override $PassengerFormStateCopyWith<$Res> get passengerForm;@override $LogisticsFormStateCopyWith<$Res> get logisticsForm;

}
/// @nodoc
class __$RequisitionCreateUiStateCopyWithImpl<$Res>
    implements _$RequisitionCreateUiStateCopyWith<$Res> {
  __$RequisitionCreateUiStateCopyWithImpl(this._self, this._then);

  final _RequisitionCreateUiState _self;
  final $Res Function(_RequisitionCreateUiState) _then;

/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formType = null,Object? passengerForm = null,Object? logisticsForm = null,Object? employeeSearchQuery = null,Object? employeeSearchResults = null,Object? isSearchingEmployees = null,Object? employeeSearchError = freezed,Object? isSubmitting = null,Object? fieldErrors = null,Object? submitError = freezed,Object? editingRequisitionId = freezed,Object? editingRequesterName = freezed,Object? editingRequesterCode = freezed,Object? editingRequesterDepartment = freezed,Object? editingRequesterCompany = freezed,}) {
  return _then(_RequisitionCreateUiState(
formType: null == formType ? _self.formType : formType // ignore: cast_nullable_to_non_nullable
as RequisitionFormType,passengerForm: null == passengerForm ? _self.passengerForm : passengerForm // ignore: cast_nullable_to_non_nullable
as PassengerFormState,logisticsForm: null == logisticsForm ? _self.logisticsForm : logisticsForm // ignore: cast_nullable_to_non_nullable
as LogisticsFormState,employeeSearchQuery: null == employeeSearchQuery ? _self.employeeSearchQuery : employeeSearchQuery // ignore: cast_nullable_to_non_nullable
as String,employeeSearchResults: null == employeeSearchResults ? _self._employeeSearchResults : employeeSearchResults // ignore: cast_nullable_to_non_nullable
as List<Employee>,isSearchingEmployees: null == isSearchingEmployees ? _self.isSearchingEmployees : isSearchingEmployees // ignore: cast_nullable_to_non_nullable
as bool,employeeSearchError: freezed == employeeSearchError ? _self.employeeSearchError : employeeSearchError // ignore: cast_nullable_to_non_nullable
as String?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,editingRequisitionId: freezed == editingRequisitionId ? _self.editingRequisitionId : editingRequisitionId // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterName: freezed == editingRequesterName ? _self.editingRequesterName : editingRequesterName // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterCode: freezed == editingRequesterCode ? _self.editingRequesterCode : editingRequesterCode // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterDepartment: freezed == editingRequesterDepartment ? _self.editingRequesterDepartment : editingRequesterDepartment // ignore: cast_nullable_to_non_nullable
as String?,editingRequesterCompany: freezed == editingRequesterCompany ? _self.editingRequesterCompany : editingRequesterCompany // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PassengerFormStateCopyWith<$Res> get passengerForm {
  
  return $PassengerFormStateCopyWith<$Res>(_self.passengerForm, (value) {
    return _then(_self.copyWith(passengerForm: value));
  });
}/// Create a copy of RequisitionCreateUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogisticsFormStateCopyWith<$Res> get logisticsForm {
  
  return $LogisticsFormStateCopyWith<$Res>(_self.logisticsForm, (value) {
    return _then(_self.copyWith(logisticsForm: value));
  });
}
}

// dart format on
