// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requisition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequisitionDetails {

 String get customerName;
/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionDetailsCopyWith<RequisitionDetails> get copyWith => _$RequisitionDetailsCopyWithImpl<RequisitionDetails>(this as RequisitionDetails, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionDetails&&(identical(other.customerName, customerName) || other.customerName == customerName));
}


@override
int get hashCode => Object.hash(runtimeType,customerName);

@override
String toString() {
  return 'RequisitionDetails(customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $RequisitionDetailsCopyWith<$Res>  {
  factory $RequisitionDetailsCopyWith(RequisitionDetails value, $Res Function(RequisitionDetails) _then) = _$RequisitionDetailsCopyWithImpl;
@useResult
$Res call({
 String customerName
});




}
/// @nodoc
class _$RequisitionDetailsCopyWithImpl<$Res>
    implements $RequisitionDetailsCopyWith<$Res> {
  _$RequisitionDetailsCopyWithImpl(this._self, this._then);

  final RequisitionDetails _self;
  final $Res Function(RequisitionDetails) _then;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerName = null,}) {
  return _then(_self.copyWith(
customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequisitionDetails].
extension RequisitionDetailsPatterns on RequisitionDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PassengerDetails value)?  passenger,TResult Function( LogisticsDetails value)?  logistics,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that);case LogisticsDetails() when logistics != null:
return logistics(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PassengerDetails value)  passenger,required TResult Function( LogisticsDetails value)  logistics,}){
final _that = this;
switch (_that) {
case PassengerDetails():
return passenger(_that);case LogisticsDetails():
return logistics(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PassengerDetails value)?  passenger,TResult? Function( LogisticsDetails value)?  logistics,}){
final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that);case LogisticsDetails() when logistics != null:
return logistics(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)?  passenger,TResult Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsDetails() when logistics != null:
return logistics(_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)  passenger,required TResult Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)  logistics,}) {final _that = this;
switch (_that) {
case PassengerDetails():
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsDetails():
return logistics(_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)?  passenger,TResult? Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,}) {final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsDetails() when logistics != null:
return logistics(_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);case _:
  return null;

}
}

}

/// @nodoc


class PassengerDetails implements RequisitionDetails {
  const PassengerDetails({required this.usedType, required this.customerName, required this.numberOfPersons, required this.requiredFor, this.userType, final  List<String> employeeIds = const <String>[], required this.purpose}): _employeeIds = employeeIds;
  

 final  UsedType usedType;
@override final  String customerName;
 final  int numberOfPersons;
 final  RequiredFor requiredFor;
 final  RequisitionUserType? userType;
 final  List<String> _employeeIds;
@JsonKey() List<String> get employeeIds {
  if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_employeeIds);
}

 final  String purpose;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerDetailsCopyWith<PassengerDetails> get copyWith => _$PassengerDetailsCopyWithImpl<PassengerDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerDetails&&(identical(other.usedType, usedType) || other.usedType == usedType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.numberOfPersons, numberOfPersons) || other.numberOfPersons == numberOfPersons)&&(identical(other.requiredFor, requiredFor) || other.requiredFor == requiredFor)&&(identical(other.userType, userType) || other.userType == userType)&&const DeepCollectionEquality().equals(other._employeeIds, _employeeIds)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}


@override
int get hashCode => Object.hash(runtimeType,usedType,customerName,numberOfPersons,requiredFor,userType,const DeepCollectionEquality().hash(_employeeIds),purpose);

@override
String toString() {
  return 'RequisitionDetails.passenger(usedType: $usedType, customerName: $customerName, numberOfPersons: $numberOfPersons, requiredFor: $requiredFor, userType: $userType, employeeIds: $employeeIds, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class $PassengerDetailsCopyWith<$Res> implements $RequisitionDetailsCopyWith<$Res> {
  factory $PassengerDetailsCopyWith(PassengerDetails value, $Res Function(PassengerDetails) _then) = _$PassengerDetailsCopyWithImpl;
@override @useResult
$Res call({
 UsedType usedType, String customerName, int numberOfPersons, RequiredFor requiredFor, RequisitionUserType? userType, List<String> employeeIds, String purpose
});




}
/// @nodoc
class _$PassengerDetailsCopyWithImpl<$Res>
    implements $PassengerDetailsCopyWith<$Res> {
  _$PassengerDetailsCopyWithImpl(this._self, this._then);

  final PassengerDetails _self;
  final $Res Function(PassengerDetails) _then;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? usedType = null,Object? customerName = null,Object? numberOfPersons = null,Object? requiredFor = null,Object? userType = freezed,Object? employeeIds = null,Object? purpose = null,}) {
  return _then(PassengerDetails(
usedType: null == usedType ? _self.usedType : usedType // ignore: cast_nullable_to_non_nullable
as UsedType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,numberOfPersons: null == numberOfPersons ? _self.numberOfPersons : numberOfPersons // ignore: cast_nullable_to_non_nullable
as int,requiredFor: null == requiredFor ? _self.requiredFor : requiredFor // ignore: cast_nullable_to_non_nullable
as RequiredFor,userType: freezed == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as RequisitionUserType?,employeeIds: null == employeeIds ? _self._employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LogisticsDetails implements RequisitionDetails {
  const LogisticsDetails({required this.vehicleType, required this.customerName, required this.userDepartment, required this.loadingCapacity, required this.goodsWeight, required this.storeName, required this.goodsDetails});
  

 final  VehicleType vehicleType;
@override final  String customerName;
 final  String userDepartment;
 final  LoadingCapacity loadingCapacity;
 final  String goodsWeight;
 final  String storeName;
 final  String goodsDetails;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogisticsDetailsCopyWith<LogisticsDetails> get copyWith => _$LogisticsDetailsCopyWithImpl<LogisticsDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogisticsDetails&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.userDepartment, userDepartment) || other.userDepartment == userDepartment)&&(identical(other.loadingCapacity, loadingCapacity) || other.loadingCapacity == loadingCapacity)&&(identical(other.goodsWeight, goodsWeight) || other.goodsWeight == goodsWeight)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.goodsDetails, goodsDetails) || other.goodsDetails == goodsDetails));
}


@override
int get hashCode => Object.hash(runtimeType,vehicleType,customerName,userDepartment,loadingCapacity,goodsWeight,storeName,goodsDetails);

@override
String toString() {
  return 'RequisitionDetails.logistics(vehicleType: $vehicleType, customerName: $customerName, userDepartment: $userDepartment, loadingCapacity: $loadingCapacity, goodsWeight: $goodsWeight, storeName: $storeName, goodsDetails: $goodsDetails)';
}


}

/// @nodoc
abstract mixin class $LogisticsDetailsCopyWith<$Res> implements $RequisitionDetailsCopyWith<$Res> {
  factory $LogisticsDetailsCopyWith(LogisticsDetails value, $Res Function(LogisticsDetails) _then) = _$LogisticsDetailsCopyWithImpl;
@override @useResult
$Res call({
 VehicleType vehicleType, String customerName, String userDepartment, LoadingCapacity loadingCapacity, String goodsWeight, String storeName, String goodsDetails
});




}
/// @nodoc
class _$LogisticsDetailsCopyWithImpl<$Res>
    implements $LogisticsDetailsCopyWith<$Res> {
  _$LogisticsDetailsCopyWithImpl(this._self, this._then);

  final LogisticsDetails _self;
  final $Res Function(LogisticsDetails) _then;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleType = null,Object? customerName = null,Object? userDepartment = null,Object? loadingCapacity = null,Object? goodsWeight = null,Object? storeName = null,Object? goodsDetails = null,}) {
  return _then(LogisticsDetails(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,userDepartment: null == userDepartment ? _self.userDepartment : userDepartment // ignore: cast_nullable_to_non_nullable
as String,loadingCapacity: null == loadingCapacity ? _self.loadingCapacity : loadingCapacity // ignore: cast_nullable_to_non_nullable
as LoadingCapacity,goodsWeight: null == goodsWeight ? _self.goodsWeight : goodsWeight // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,goodsDetails: null == goodsDetails ? _self.goodsDetails : goodsDetails // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Requisition {

 String get id; DateTime get pickupDateTime; String get pickupLocation; String get dropLocation; String? get remarks; RequisitionStatus get status; RequisitionDetails get details; DateTime get createdAt;
/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionCopyWith<Requisition> get copyWith => _$RequisitionCopyWithImpl<Requisition>(this as Requisition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Requisition&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.status, status) || other.status == status)&&(identical(other.details, details) || other.details == details)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,pickupDateTime,pickupLocation,dropLocation,remarks,status,details,createdAt);

@override
String toString() {
  return 'Requisition(id: $id, pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, status: $status, details: $details, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RequisitionCopyWith<$Res>  {
  factory $RequisitionCopyWith(Requisition value, $Res Function(Requisition) _then) = _$RequisitionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, RequisitionStatus status, RequisitionDetails details, DateTime createdAt
});


$RequisitionDetailsCopyWith<$Res> get details;

}
/// @nodoc
class _$RequisitionCopyWithImpl<$Res>
    implements $RequisitionCopyWith<$Res> {
  _$RequisitionCopyWithImpl(this._self, this._then);

  final Requisition _self;
  final $Res Function(Requisition) _then;

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? status = null,Object? details = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as RequisitionDetails,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequisitionDetailsCopyWith<$Res> get details {
  
  return $RequisitionDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [Requisition].
extension RequisitionPatterns on Requisition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Requisition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Requisition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Requisition value)  $default,){
final _that = this;
switch (_that) {
case _Requisition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Requisition value)?  $default,){
final _that = this;
switch (_that) {
case _Requisition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Requisition() when $default != null:
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Requisition():
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Requisition() when $default != null:
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Requisition extends Requisition {
  const _Requisition({required this.id, required this.pickupDateTime, required this.pickupLocation, required this.dropLocation, this.remarks, required this.status, required this.details, required this.createdAt}): super._();
  

@override final  String id;
@override final  DateTime pickupDateTime;
@override final  String pickupLocation;
@override final  String dropLocation;
@override final  String? remarks;
@override final  RequisitionStatus status;
@override final  RequisitionDetails details;
@override final  DateTime createdAt;

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionCopyWith<_Requisition> get copyWith => __$RequisitionCopyWithImpl<_Requisition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Requisition&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.status, status) || other.status == status)&&(identical(other.details, details) || other.details == details)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,pickupDateTime,pickupLocation,dropLocation,remarks,status,details,createdAt);

@override
String toString() {
  return 'Requisition(id: $id, pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, status: $status, details: $details, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RequisitionCopyWith<$Res> implements $RequisitionCopyWith<$Res> {
  factory _$RequisitionCopyWith(_Requisition value, $Res Function(_Requisition) _then) = __$RequisitionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, RequisitionStatus status, RequisitionDetails details, DateTime createdAt
});


@override $RequisitionDetailsCopyWith<$Res> get details;

}
/// @nodoc
class __$RequisitionCopyWithImpl<$Res>
    implements _$RequisitionCopyWith<$Res> {
  __$RequisitionCopyWithImpl(this._self, this._then);

  final _Requisition _self;
  final $Res Function(_Requisition) _then;

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? status = null,Object? details = null,Object? createdAt = null,}) {
  return _then(_Requisition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as RequisitionDetails,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequisitionDetailsCopyWith<$Res> get details {
  
  return $RequisitionDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

/// @nodoc
mixin _$NewRequisitionRequest {

 DateTime get pickupDateTime; String get pickupLocation; String get dropLocation; String? get remarks; String get customerName;
/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewRequisitionRequestCopyWith<NewRequisitionRequest> get copyWith => _$NewRequisitionRequestCopyWithImpl<NewRequisitionRequest>(this as NewRequisitionRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewRequisitionRequest&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,remarks,customerName);

@override
String toString() {
  return 'NewRequisitionRequest(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class $NewRequisitionRequestCopyWith<$Res>  {
  factory $NewRequisitionRequestCopyWith(NewRequisitionRequest value, $Res Function(NewRequisitionRequest) _then) = _$NewRequisitionRequestCopyWithImpl;
@useResult
$Res call({
 DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, String customerName
});




}
/// @nodoc
class _$NewRequisitionRequestCopyWithImpl<$Res>
    implements $NewRequisitionRequestCopyWith<$Res> {
  _$NewRequisitionRequestCopyWithImpl(this._self, this._then);

  final NewRequisitionRequest _self;
  final $Res Function(NewRequisitionRequest) _then;

/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? customerName = null,}) {
  return _then(_self.copyWith(
pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NewRequisitionRequest].
extension NewRequisitionRequestPatterns on NewRequisitionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PassengerRequest value)?  passenger,TResult Function( LogisticsRequest value)?  logistics,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PassengerRequest() when passenger != null:
return passenger(_that);case LogisticsRequest() when logistics != null:
return logistics(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PassengerRequest value)  passenger,required TResult Function( LogisticsRequest value)  logistics,}){
final _that = this;
switch (_that) {
case PassengerRequest():
return passenger(_that);case LogisticsRequest():
return logistics(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PassengerRequest value)?  passenger,TResult? Function( LogisticsRequest value)?  logistics,}){
final _that = this;
switch (_that) {
case PassengerRequest() when passenger != null:
return passenger(_that);case LogisticsRequest() when logistics != null:
return logistics(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)?  passenger,TResult Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PassengerRequest() when passenger != null:
return passenger(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsRequest() when logistics != null:
return logistics(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)  passenger,required TResult Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)  logistics,}) {final _that = this;
switch (_that) {
case PassengerRequest():
return passenger(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsRequest():
return logistics(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<String> employeeIds,  String purpose)?  passenger,TResult? Function( DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,}) {final _that = this;
switch (_that) {
case PassengerRequest() when passenger != null:
return passenger(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.employeeIds,_that.purpose);case LogisticsRequest() when logistics != null:
return logistics(_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);case _:
  return null;

}
}

}

/// @nodoc


class PassengerRequest implements NewRequisitionRequest {
  const PassengerRequest({required this.pickupDateTime, required this.pickupLocation, required this.dropLocation, this.remarks, required this.usedType, required this.customerName, required this.numberOfPersons, required this.requiredFor, this.userType, final  List<String> employeeIds = const <String>[], required this.purpose}): _employeeIds = employeeIds;
  

@override final  DateTime pickupDateTime;
@override final  String pickupLocation;
@override final  String dropLocation;
@override final  String? remarks;
 final  UsedType usedType;
@override final  String customerName;
 final  int numberOfPersons;
 final  RequiredFor requiredFor;
 final  RequisitionUserType? userType;
 final  List<String> _employeeIds;
@JsonKey() List<String> get employeeIds {
  if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_employeeIds);
}

 final  String purpose;

/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerRequestCopyWith<PassengerRequest> get copyWith => _$PassengerRequestCopyWithImpl<PassengerRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerRequest&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.usedType, usedType) || other.usedType == usedType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.numberOfPersons, numberOfPersons) || other.numberOfPersons == numberOfPersons)&&(identical(other.requiredFor, requiredFor) || other.requiredFor == requiredFor)&&(identical(other.userType, userType) || other.userType == userType)&&const DeepCollectionEquality().equals(other._employeeIds, _employeeIds)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,remarks,usedType,customerName,numberOfPersons,requiredFor,userType,const DeepCollectionEquality().hash(_employeeIds),purpose);

@override
String toString() {
  return 'NewRequisitionRequest.passenger(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, usedType: $usedType, customerName: $customerName, numberOfPersons: $numberOfPersons, requiredFor: $requiredFor, userType: $userType, employeeIds: $employeeIds, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class $PassengerRequestCopyWith<$Res> implements $NewRequisitionRequestCopyWith<$Res> {
  factory $PassengerRequestCopyWith(PassengerRequest value, $Res Function(PassengerRequest) _then) = _$PassengerRequestCopyWithImpl;
@override @useResult
$Res call({
 DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, UsedType usedType, String customerName, int numberOfPersons, RequiredFor requiredFor, RequisitionUserType? userType, List<String> employeeIds, String purpose
});




}
/// @nodoc
class _$PassengerRequestCopyWithImpl<$Res>
    implements $PassengerRequestCopyWith<$Res> {
  _$PassengerRequestCopyWithImpl(this._self, this._then);

  final PassengerRequest _self;
  final $Res Function(PassengerRequest) _then;

/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? usedType = null,Object? customerName = null,Object? numberOfPersons = null,Object? requiredFor = null,Object? userType = freezed,Object? employeeIds = null,Object? purpose = null,}) {
  return _then(PassengerRequest(
pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,usedType: null == usedType ? _self.usedType : usedType // ignore: cast_nullable_to_non_nullable
as UsedType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,numberOfPersons: null == numberOfPersons ? _self.numberOfPersons : numberOfPersons // ignore: cast_nullable_to_non_nullable
as int,requiredFor: null == requiredFor ? _self.requiredFor : requiredFor // ignore: cast_nullable_to_non_nullable
as RequiredFor,userType: freezed == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as RequisitionUserType?,employeeIds: null == employeeIds ? _self._employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LogisticsRequest implements NewRequisitionRequest {
  const LogisticsRequest({required this.pickupDateTime, required this.pickupLocation, required this.dropLocation, this.remarks, required this.vehicleType, required this.customerName, required this.userDepartment, required this.loadingCapacity, required this.goodsWeight, required this.storeName, required this.goodsDetails});
  

@override final  DateTime pickupDateTime;
@override final  String pickupLocation;
@override final  String dropLocation;
@override final  String? remarks;
 final  VehicleType vehicleType;
@override final  String customerName;
 final  String userDepartment;
 final  LoadingCapacity loadingCapacity;
 final  String goodsWeight;
 final  String storeName;
 final  String goodsDetails;

/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogisticsRequestCopyWith<LogisticsRequest> get copyWith => _$LogisticsRequestCopyWithImpl<LogisticsRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogisticsRequest&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.userDepartment, userDepartment) || other.userDepartment == userDepartment)&&(identical(other.loadingCapacity, loadingCapacity) || other.loadingCapacity == loadingCapacity)&&(identical(other.goodsWeight, goodsWeight) || other.goodsWeight == goodsWeight)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.goodsDetails, goodsDetails) || other.goodsDetails == goodsDetails));
}


@override
int get hashCode => Object.hash(runtimeType,pickupDateTime,pickupLocation,dropLocation,remarks,vehicleType,customerName,userDepartment,loadingCapacity,goodsWeight,storeName,goodsDetails);

@override
String toString() {
  return 'NewRequisitionRequest.logistics(pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, vehicleType: $vehicleType, customerName: $customerName, userDepartment: $userDepartment, loadingCapacity: $loadingCapacity, goodsWeight: $goodsWeight, storeName: $storeName, goodsDetails: $goodsDetails)';
}


}

/// @nodoc
abstract mixin class $LogisticsRequestCopyWith<$Res> implements $NewRequisitionRequestCopyWith<$Res> {
  factory $LogisticsRequestCopyWith(LogisticsRequest value, $Res Function(LogisticsRequest) _then) = _$LogisticsRequestCopyWithImpl;
@override @useResult
$Res call({
 DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, VehicleType vehicleType, String customerName, String userDepartment, LoadingCapacity loadingCapacity, String goodsWeight, String storeName, String goodsDetails
});




}
/// @nodoc
class _$LogisticsRequestCopyWithImpl<$Res>
    implements $LogisticsRequestCopyWith<$Res> {
  _$LogisticsRequestCopyWithImpl(this._self, this._then);

  final LogisticsRequest _self;
  final $Res Function(LogisticsRequest) _then;

/// Create a copy of NewRequisitionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? vehicleType = null,Object? customerName = null,Object? userDepartment = null,Object? loadingCapacity = null,Object? goodsWeight = null,Object? storeName = null,Object? goodsDetails = null,}) {
  return _then(LogisticsRequest(
pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,userDepartment: null == userDepartment ? _self.userDepartment : userDepartment // ignore: cast_nullable_to_non_nullable
as String,loadingCapacity: null == loadingCapacity ? _self.loadingCapacity : loadingCapacity // ignore: cast_nullable_to_non_nullable
as LoadingCapacity,goodsWeight: null == goodsWeight ? _self.goodsWeight : goodsWeight // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,goodsDetails: null == goodsDetails ? _self.goodsDetails : goodsDetails // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DashboardSummary {

 int get allCount; int get approvedCount; int get assignedCount; int get pendingCount; int get rejectedCount; List<Requisition> get recentRequisitions;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.allCount, allCount) || other.allCount == allCount)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.assignedCount, assignedCount) || other.assignedCount == assignedCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&const DeepCollectionEquality().equals(other.recentRequisitions, recentRequisitions));
}


@override
int get hashCode => Object.hash(runtimeType,allCount,approvedCount,assignedCount,pendingCount,rejectedCount,const DeepCollectionEquality().hash(recentRequisitions));

@override
String toString() {
  return 'DashboardSummary(allCount: $allCount, approvedCount: $approvedCount, assignedCount: $assignedCount, pendingCount: $pendingCount, rejectedCount: $rejectedCount, recentRequisitions: $recentRequisitions)';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int allCount, int approvedCount, int assignedCount, int pendingCount, int rejectedCount, List<Requisition> recentRequisitions
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allCount = null,Object? approvedCount = null,Object? assignedCount = null,Object? pendingCount = null,Object? rejectedCount = null,Object? recentRequisitions = null,}) {
  return _then(_self.copyWith(
allCount: null == allCount ? _self.allCount : allCount // ignore: cast_nullable_to_non_nullable
as int,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,assignedCount: null == assignedCount ? _self.assignedCount : assignedCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,recentRequisitions: null == recentRequisitions ? _self.recentRequisitions : recentRequisitions // ignore: cast_nullable_to_non_nullable
as List<Requisition>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int allCount,  int approvedCount,  int assignedCount,  int pendingCount,  int rejectedCount,  List<Requisition> recentRequisitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.allCount,_that.approvedCount,_that.assignedCount,_that.pendingCount,_that.rejectedCount,_that.recentRequisitions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int allCount,  int approvedCount,  int assignedCount,  int pendingCount,  int rejectedCount,  List<Requisition> recentRequisitions)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.allCount,_that.approvedCount,_that.assignedCount,_that.pendingCount,_that.rejectedCount,_that.recentRequisitions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int allCount,  int approvedCount,  int assignedCount,  int pendingCount,  int rejectedCount,  List<Requisition> recentRequisitions)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.allCount,_that.approvedCount,_that.assignedCount,_that.pendingCount,_that.rejectedCount,_that.recentRequisitions);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary implements DashboardSummary {
  const _DashboardSummary({required this.allCount, required this.approvedCount, required this.assignedCount, required this.pendingCount, required this.rejectedCount, required final  List<Requisition> recentRequisitions}): _recentRequisitions = recentRequisitions;
  

@override final  int allCount;
@override final  int approvedCount;
@override final  int assignedCount;
@override final  int pendingCount;
@override final  int rejectedCount;
 final  List<Requisition> _recentRequisitions;
@override List<Requisition> get recentRequisitions {
  if (_recentRequisitions is EqualUnmodifiableListView) return _recentRequisitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentRequisitions);
}


/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.allCount, allCount) || other.allCount == allCount)&&(identical(other.approvedCount, approvedCount) || other.approvedCount == approvedCount)&&(identical(other.assignedCount, assignedCount) || other.assignedCount == assignedCount)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&const DeepCollectionEquality().equals(other._recentRequisitions, _recentRequisitions));
}


@override
int get hashCode => Object.hash(runtimeType,allCount,approvedCount,assignedCount,pendingCount,rejectedCount,const DeepCollectionEquality().hash(_recentRequisitions));

@override
String toString() {
  return 'DashboardSummary(allCount: $allCount, approvedCount: $approvedCount, assignedCount: $assignedCount, pendingCount: $pendingCount, rejectedCount: $rejectedCount, recentRequisitions: $recentRequisitions)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int allCount, int approvedCount, int assignedCount, int pendingCount, int rejectedCount, List<Requisition> recentRequisitions
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allCount = null,Object? approvedCount = null,Object? assignedCount = null,Object? pendingCount = null,Object? rejectedCount = null,Object? recentRequisitions = null,}) {
  return _then(_DashboardSummary(
allCount: null == allCount ? _self.allCount : allCount // ignore: cast_nullable_to_non_nullable
as int,approvedCount: null == approvedCount ? _self.approvedCount : approvedCount // ignore: cast_nullable_to_non_nullable
as int,assignedCount: null == assignedCount ? _self.assignedCount : assignedCount // ignore: cast_nullable_to_non_nullable
as int,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,recentRequisitions: null == recentRequisitions ? _self._recentRequisitions : recentRequisitions // ignore: cast_nullable_to_non_nullable
as List<Requisition>,
  ));
}


}

/// @nodoc
mixin _$RequisitionListFilter {

 DateTime? get startDate; DateTime? get endDate; String get searchQuery; int get page; int get pageSize; RequisitionSortField get sortBy; bool get sortDescending;
/// Create a copy of RequisitionListFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionListFilterCopyWith<RequisitionListFilter> get copyWith => _$RequisitionListFilterCopyWithImpl<RequisitionListFilter>(this as RequisitionListFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionListFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDescending, sortDescending) || other.sortDescending == sortDescending));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,searchQuery,page,pageSize,sortBy,sortDescending);

@override
String toString() {
  return 'RequisitionListFilter(startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery, page: $page, pageSize: $pageSize, sortBy: $sortBy, sortDescending: $sortDescending)';
}


}

/// @nodoc
abstract mixin class $RequisitionListFilterCopyWith<$Res>  {
  factory $RequisitionListFilterCopyWith(RequisitionListFilter value, $Res Function(RequisitionListFilter) _then) = _$RequisitionListFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, String searchQuery, int page, int pageSize, RequisitionSortField sortBy, bool sortDescending
});




}
/// @nodoc
class _$RequisitionListFilterCopyWithImpl<$Res>
    implements $RequisitionListFilterCopyWith<$Res> {
  _$RequisitionListFilterCopyWithImpl(this._self, this._then);

  final RequisitionListFilter _self;
  final $Res Function(RequisitionListFilter) _then;

/// Create a copy of RequisitionListFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? searchQuery = null,Object? page = null,Object? pageSize = null,Object? sortBy = null,Object? sortDescending = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as RequisitionSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RequisitionListFilter].
extension RequisitionListFilterPatterns on RequisitionListFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionListFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionListFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionListFilter value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionListFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionListFilter value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionListFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  String searchQuery,  int page,  int pageSize,  RequisitionSortField sortBy,  bool sortDescending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionListFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.searchQuery,_that.page,_that.pageSize,_that.sortBy,_that.sortDescending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  String searchQuery,  int page,  int pageSize,  RequisitionSortField sortBy,  bool sortDescending)  $default,) {final _that = this;
switch (_that) {
case _RequisitionListFilter():
return $default(_that.startDate,_that.endDate,_that.searchQuery,_that.page,_that.pageSize,_that.sortBy,_that.sortDescending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  String searchQuery,  int page,  int pageSize,  RequisitionSortField sortBy,  bool sortDescending)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionListFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.searchQuery,_that.page,_that.pageSize,_that.sortBy,_that.sortDescending);case _:
  return null;

}
}

}

/// @nodoc


class _RequisitionListFilter implements RequisitionListFilter {
  const _RequisitionListFilter({this.startDate, this.endDate, this.searchQuery = '', this.page = 1, this.pageSize = 10, this.sortBy = RequisitionSortField.date, this.sortDescending = true});
  

@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  RequisitionSortField sortBy;
@override@JsonKey() final  bool sortDescending;

/// Create a copy of RequisitionListFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionListFilterCopyWith<_RequisitionListFilter> get copyWith => __$RequisitionListFilterCopyWithImpl<_RequisitionListFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionListFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDescending, sortDescending) || other.sortDescending == sortDescending));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,searchQuery,page,pageSize,sortBy,sortDescending);

@override
String toString() {
  return 'RequisitionListFilter(startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery, page: $page, pageSize: $pageSize, sortBy: $sortBy, sortDescending: $sortDescending)';
}


}

/// @nodoc
abstract mixin class _$RequisitionListFilterCopyWith<$Res> implements $RequisitionListFilterCopyWith<$Res> {
  factory _$RequisitionListFilterCopyWith(_RequisitionListFilter value, $Res Function(_RequisitionListFilter) _then) = __$RequisitionListFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, String searchQuery, int page, int pageSize, RequisitionSortField sortBy, bool sortDescending
});




}
/// @nodoc
class __$RequisitionListFilterCopyWithImpl<$Res>
    implements _$RequisitionListFilterCopyWith<$Res> {
  __$RequisitionListFilterCopyWithImpl(this._self, this._then);

  final _RequisitionListFilter _self;
  final $Res Function(_RequisitionListFilter) _then;

/// Create a copy of RequisitionListFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? searchQuery = null,Object? page = null,Object? pageSize = null,Object? sortBy = null,Object? sortDescending = null,}) {
  return _then(_RequisitionListFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as RequisitionSortField,sortDescending: null == sortDescending ? _self.sortDescending : sortDescending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
