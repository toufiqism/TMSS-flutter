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
mixin _$AuditLogEntry {

 String get id; RequisitionStatus get status; String? get remarks; String? get actorName; String? get actorCode; DateTime? get at;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.actorCode, actorCode) || other.actorCode == actorCode)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,remarks,actorName,actorCode,at);

@override
String toString() {
  return 'AuditLogEntry(id: $id, status: $status, remarks: $remarks, actorName: $actorName, actorCode: $actorCode, at: $at)';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 String id, RequisitionStatus status, String? remarks, String? actorName, String? actorCode, DateTime? at
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? remarks = freezed,Object? actorName = freezed,Object? actorCode = freezed,Object? at = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,actorCode: freezed == actorCode ? _self.actorCode : actorCode // ignore: cast_nullable_to_non_nullable
as String?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RequisitionStatus status,  String? remarks,  String? actorName,  String? actorCode,  DateTime? at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.status,_that.remarks,_that.actorName,_that.actorCode,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RequisitionStatus status,  String? remarks,  String? actorName,  String? actorCode,  DateTime? at)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.id,_that.status,_that.remarks,_that.actorName,_that.actorCode,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RequisitionStatus status,  String? remarks,  String? actorName,  String? actorCode,  DateTime? at)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.status,_that.remarks,_that.actorName,_that.actorCode,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.id, required this.status, this.remarks, this.actorName, this.actorCode, this.at});
  

@override final  String id;
@override final  RequisitionStatus status;
@override final  String? remarks;
@override final  String? actorName;
@override final  String? actorCode;
@override final  DateTime? at;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.actorCode, actorCode) || other.actorCode == actorCode)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,remarks,actorName,actorCode,at);

@override
String toString() {
  return 'AuditLogEntry(id: $id, status: $status, remarks: $remarks, actorName: $actorName, actorCode: $actorCode, at: $at)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, RequisitionStatus status, String? remarks, String? actorName, String? actorCode, DateTime? at
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? remarks = freezed,Object? actorName = freezed,Object? actorCode = freezed,Object? at = freezed,}) {
  return _then(_AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,actorName: freezed == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String?,actorCode: freezed == actorCode ? _self.actorCode : actorCode // ignore: cast_nullable_to_non_nullable
as String?,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$AssignedDriver {

 String? get name; String? get phone; String? get identifier;
/// Create a copy of AssignedDriver
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedDriverCopyWith<AssignedDriver> get copyWith => _$AssignedDriverCopyWithImpl<AssignedDriver>(this as AssignedDriver, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedDriver&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}


@override
int get hashCode => Object.hash(runtimeType,name,phone,identifier);

@override
String toString() {
  return 'AssignedDriver(name: $name, phone: $phone, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class $AssignedDriverCopyWith<$Res>  {
  factory $AssignedDriverCopyWith(AssignedDriver value, $Res Function(AssignedDriver) _then) = _$AssignedDriverCopyWithImpl;
@useResult
$Res call({
 String? name, String? phone, String? identifier
});




}
/// @nodoc
class _$AssignedDriverCopyWithImpl<$Res>
    implements $AssignedDriverCopyWith<$Res> {
  _$AssignedDriverCopyWithImpl(this._self, this._then);

  final AssignedDriver _self;
  final $Res Function(AssignedDriver) _then;

/// Create a copy of AssignedDriver
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? phone = freezed,Object? identifier = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identifier: freezed == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedDriver].
extension AssignedDriverPatterns on AssignedDriver {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedDriver value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedDriver() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedDriver value)  $default,){
final _that = this;
switch (_that) {
case _AssignedDriver():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedDriver value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedDriver() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? phone,  String? identifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedDriver() when $default != null:
return $default(_that.name,_that.phone,_that.identifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? phone,  String? identifier)  $default,) {final _that = this;
switch (_that) {
case _AssignedDriver():
return $default(_that.name,_that.phone,_that.identifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? phone,  String? identifier)?  $default,) {final _that = this;
switch (_that) {
case _AssignedDriver() when $default != null:
return $default(_that.name,_that.phone,_that.identifier);case _:
  return null;

}
}

}

/// @nodoc


class _AssignedDriver extends AssignedDriver {
  const _AssignedDriver({this.name, this.phone, this.identifier}): super._();
  

@override final  String? name;
@override final  String? phone;
@override final  String? identifier;

/// Create a copy of AssignedDriver
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedDriverCopyWith<_AssignedDriver> get copyWith => __$AssignedDriverCopyWithImpl<_AssignedDriver>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedDriver&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}


@override
int get hashCode => Object.hash(runtimeType,name,phone,identifier);

@override
String toString() {
  return 'AssignedDriver(name: $name, phone: $phone, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class _$AssignedDriverCopyWith<$Res> implements $AssignedDriverCopyWith<$Res> {
  factory _$AssignedDriverCopyWith(_AssignedDriver value, $Res Function(_AssignedDriver) _then) = __$AssignedDriverCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? phone, String? identifier
});




}
/// @nodoc
class __$AssignedDriverCopyWithImpl<$Res>
    implements _$AssignedDriverCopyWith<$Res> {
  __$AssignedDriverCopyWithImpl(this._self, this._then);

  final _AssignedDriver _self;
  final $Res Function(_AssignedDriver) _then;

/// Create a copy of AssignedDriver
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? phone = freezed,Object? identifier = freezed,}) {
  return _then(_AssignedDriver(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,identifier: freezed == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AssignedVehicle {

 String? get registrationNumber; String? get model; String? get type;
/// Create a copy of AssignedVehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedVehicleCopyWith<AssignedVehicle> get copyWith => _$AssignedVehicleCopyWithImpl<AssignedVehicle>(this as AssignedVehicle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedVehicle&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.model, model) || other.model == model)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,registrationNumber,model,type);

@override
String toString() {
  return 'AssignedVehicle(registrationNumber: $registrationNumber, model: $model, type: $type)';
}


}

/// @nodoc
abstract mixin class $AssignedVehicleCopyWith<$Res>  {
  factory $AssignedVehicleCopyWith(AssignedVehicle value, $Res Function(AssignedVehicle) _then) = _$AssignedVehicleCopyWithImpl;
@useResult
$Res call({
 String? registrationNumber, String? model, String? type
});




}
/// @nodoc
class _$AssignedVehicleCopyWithImpl<$Res>
    implements $AssignedVehicleCopyWith<$Res> {
  _$AssignedVehicleCopyWithImpl(this._self, this._then);

  final AssignedVehicle _self;
  final $Res Function(AssignedVehicle) _then;

/// Create a copy of AssignedVehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registrationNumber = freezed,Object? model = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedVehicle].
extension AssignedVehiclePatterns on AssignedVehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedVehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedVehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedVehicle value)  $default,){
final _that = this;
switch (_that) {
case _AssignedVehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedVehicle value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedVehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? registrationNumber,  String? model,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedVehicle() when $default != null:
return $default(_that.registrationNumber,_that.model,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? registrationNumber,  String? model,  String? type)  $default,) {final _that = this;
switch (_that) {
case _AssignedVehicle():
return $default(_that.registrationNumber,_that.model,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? registrationNumber,  String? model,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _AssignedVehicle() when $default != null:
return $default(_that.registrationNumber,_that.model,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _AssignedVehicle extends AssignedVehicle {
  const _AssignedVehicle({this.registrationNumber, this.model, this.type}): super._();
  

@override final  String? registrationNumber;
@override final  String? model;
@override final  String? type;

/// Create a copy of AssignedVehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedVehicleCopyWith<_AssignedVehicle> get copyWith => __$AssignedVehicleCopyWithImpl<_AssignedVehicle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedVehicle&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.model, model) || other.model == model)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,registrationNumber,model,type);

@override
String toString() {
  return 'AssignedVehicle(registrationNumber: $registrationNumber, model: $model, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AssignedVehicleCopyWith<$Res> implements $AssignedVehicleCopyWith<$Res> {
  factory _$AssignedVehicleCopyWith(_AssignedVehicle value, $Res Function(_AssignedVehicle) _then) = __$AssignedVehicleCopyWithImpl;
@override @useResult
$Res call({
 String? registrationNumber, String? model, String? type
});




}
/// @nodoc
class __$AssignedVehicleCopyWithImpl<$Res>
    implements _$AssignedVehicleCopyWith<$Res> {
  __$AssignedVehicleCopyWithImpl(this._self, this._then);

  final _AssignedVehicle _self;
  final $Res Function(_AssignedVehicle) _then;

/// Create a copy of AssignedVehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registrationNumber = freezed,Object? model = freezed,Object? type = freezed,}) {
  return _then(_AssignedVehicle(
registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RequisitionRider {

 String get id; String get name; String get employeeCode;
/// Create a copy of RequisitionRider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionRiderCopyWith<RequisitionRider> get copyWith => _$RequisitionRiderCopyWithImpl<RequisitionRider>(this as RequisitionRider, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequisitionRider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.employeeCode, employeeCode) || other.employeeCode == employeeCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,employeeCode);

@override
String toString() {
  return 'RequisitionRider(id: $id, name: $name, employeeCode: $employeeCode)';
}


}

/// @nodoc
abstract mixin class $RequisitionRiderCopyWith<$Res>  {
  factory $RequisitionRiderCopyWith(RequisitionRider value, $Res Function(RequisitionRider) _then) = _$RequisitionRiderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String employeeCode
});




}
/// @nodoc
class _$RequisitionRiderCopyWithImpl<$Res>
    implements $RequisitionRiderCopyWith<$Res> {
  _$RequisitionRiderCopyWithImpl(this._self, this._then);

  final RequisitionRider _self;
  final $Res Function(RequisitionRider) _then;

/// Create a copy of RequisitionRider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? employeeCode = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequisitionRider].
extension RequisitionRiderPatterns on RequisitionRider {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequisitionRider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequisitionRider() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequisitionRider value)  $default,){
final _that = this;
switch (_that) {
case _RequisitionRider():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequisitionRider value)?  $default,){
final _that = this;
switch (_that) {
case _RequisitionRider() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String employeeCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequisitionRider() when $default != null:
return $default(_that.id,_that.name,_that.employeeCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String employeeCode)  $default,) {final _that = this;
switch (_that) {
case _RequisitionRider():
return $default(_that.id,_that.name,_that.employeeCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String employeeCode)?  $default,) {final _that = this;
switch (_that) {
case _RequisitionRider() when $default != null:
return $default(_that.id,_that.name,_that.employeeCode);case _:
  return null;

}
}

}

/// @nodoc


class _RequisitionRider extends RequisitionRider {
  const _RequisitionRider({required this.id, this.name = '', this.employeeCode = ''}): super._();
  

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String employeeCode;

/// Create a copy of RequisitionRider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionRiderCopyWith<_RequisitionRider> get copyWith => __$RequisitionRiderCopyWithImpl<_RequisitionRider>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequisitionRider&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.employeeCode, employeeCode) || other.employeeCode == employeeCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,employeeCode);

@override
String toString() {
  return 'RequisitionRider(id: $id, name: $name, employeeCode: $employeeCode)';
}


}

/// @nodoc
abstract mixin class _$RequisitionRiderCopyWith<$Res> implements $RequisitionRiderCopyWith<$Res> {
  factory _$RequisitionRiderCopyWith(_RequisitionRider value, $Res Function(_RequisitionRider) _then) = __$RequisitionRiderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String employeeCode
});




}
/// @nodoc
class __$RequisitionRiderCopyWithImpl<$Res>
    implements _$RequisitionRiderCopyWith<$Res> {
  __$RequisitionRiderCopyWithImpl(this._self, this._then);

  final _RequisitionRider _self;
  final $Res Function(_RequisitionRider) _then;

/// Create a copy of RequisitionRider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? employeeCode = null,}) {
  return _then(_RequisitionRider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<RequisitionRider> riders,  String purpose)?  passenger,TResult Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.riders,_that.purpose);case LogisticsDetails() when logistics != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<RequisitionRider> riders,  String purpose)  passenger,required TResult Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)  logistics,}) {final _that = this;
switch (_that) {
case PassengerDetails():
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.riders,_that.purpose);case LogisticsDetails():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UsedType usedType,  String customerName,  int numberOfPersons,  RequiredFor requiredFor,  RequisitionUserType? userType,  List<RequisitionRider> riders,  String purpose)?  passenger,TResult? Function( VehicleType vehicleType,  String customerName,  String userDepartment,  LoadingCapacity loadingCapacity,  String goodsWeight,  String storeName,  String goodsDetails)?  logistics,}) {final _that = this;
switch (_that) {
case PassengerDetails() when passenger != null:
return passenger(_that.usedType,_that.customerName,_that.numberOfPersons,_that.requiredFor,_that.userType,_that.riders,_that.purpose);case LogisticsDetails() when logistics != null:
return logistics(_that.vehicleType,_that.customerName,_that.userDepartment,_that.loadingCapacity,_that.goodsWeight,_that.storeName,_that.goodsDetails);case _:
  return null;

}
}

}

/// @nodoc


class PassengerDetails implements RequisitionDetails {
  const PassengerDetails({required this.usedType, required this.customerName, required this.numberOfPersons, required this.requiredFor, this.userType, final  List<RequisitionRider> riders = const <RequisitionRider>[], required this.purpose}): _riders = riders;
  

 final  UsedType usedType;
@override final  String customerName;
 final  int numberOfPersons;
 final  RequiredFor requiredFor;
 final  RequisitionUserType? userType;
 final  List<RequisitionRider> _riders;
@JsonKey() List<RequisitionRider> get riders {
  if (_riders is EqualUnmodifiableListView) return _riders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_riders);
}

 final  String purpose;

/// Create a copy of RequisitionDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerDetailsCopyWith<PassengerDetails> get copyWith => _$PassengerDetailsCopyWithImpl<PassengerDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerDetails&&(identical(other.usedType, usedType) || other.usedType == usedType)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.numberOfPersons, numberOfPersons) || other.numberOfPersons == numberOfPersons)&&(identical(other.requiredFor, requiredFor) || other.requiredFor == requiredFor)&&(identical(other.userType, userType) || other.userType == userType)&&const DeepCollectionEquality().equals(other._riders, _riders)&&(identical(other.purpose, purpose) || other.purpose == purpose));
}


@override
int get hashCode => Object.hash(runtimeType,usedType,customerName,numberOfPersons,requiredFor,userType,const DeepCollectionEquality().hash(_riders),purpose);

@override
String toString() {
  return 'RequisitionDetails.passenger(usedType: $usedType, customerName: $customerName, numberOfPersons: $numberOfPersons, requiredFor: $requiredFor, userType: $userType, riders: $riders, purpose: $purpose)';
}


}

/// @nodoc
abstract mixin class $PassengerDetailsCopyWith<$Res> implements $RequisitionDetailsCopyWith<$Res> {
  factory $PassengerDetailsCopyWith(PassengerDetails value, $Res Function(PassengerDetails) _then) = _$PassengerDetailsCopyWithImpl;
@override @useResult
$Res call({
 UsedType usedType, String customerName, int numberOfPersons, RequiredFor requiredFor, RequisitionUserType? userType, List<RequisitionRider> riders, String purpose
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
@override @pragma('vm:prefer-inline') $Res call({Object? usedType = null,Object? customerName = null,Object? numberOfPersons = null,Object? requiredFor = null,Object? userType = freezed,Object? riders = null,Object? purpose = null,}) {
  return _then(PassengerDetails(
usedType: null == usedType ? _self.usedType : usedType // ignore: cast_nullable_to_non_nullable
as UsedType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,numberOfPersons: null == numberOfPersons ? _self.numberOfPersons : numberOfPersons // ignore: cast_nullable_to_non_nullable
as int,requiredFor: null == requiredFor ? _self.requiredFor : requiredFor // ignore: cast_nullable_to_non_nullable
as RequiredFor,userType: freezed == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as RequisitionUserType?,riders: null == riders ? _self._riders : riders // ignore: cast_nullable_to_non_nullable
as List<RequisitionRider>,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
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

 String get id; DateTime get pickupDateTime; String get pickupLocation; String get dropLocation; String? get remarks; RequisitionStatus get status; RequisitionDetails get details; DateTime get createdAt; DateTime? get endDateTime; String? get departmentName; String? get companyName;/// Who raised the requisition. `created_by_name` on the detail response, falling
/// back to the creating audit entry; null on a list row, which carries neither.
 String? get requesterName;/// The requester's staff number (`created_by_id_no`), when the response carries it.
/// Independent of [requesterName] — either can arrive without the other.
 String? get requesterCode; AssignedDriver? get driver; AssignedVehicle? get vehicle; List<AuditLogEntry> get auditLog;
/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequisitionCopyWith<Requisition> get copyWith => _$RequisitionCopyWithImpl<Requisition>(this as Requisition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Requisition&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.status, status) || other.status == status)&&(identical(other.details, details) || other.details == details)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterCode, requesterCode) || other.requesterCode == requesterCode)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&const DeepCollectionEquality().equals(other.auditLog, auditLog));
}


@override
int get hashCode => Object.hash(runtimeType,id,pickupDateTime,pickupLocation,dropLocation,remarks,status,details,createdAt,endDateTime,departmentName,companyName,requesterName,requesterCode,driver,vehicle,const DeepCollectionEquality().hash(auditLog));

@override
String toString() {
  return 'Requisition(id: $id, pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, status: $status, details: $details, createdAt: $createdAt, endDateTime: $endDateTime, departmentName: $departmentName, companyName: $companyName, requesterName: $requesterName, requesterCode: $requesterCode, driver: $driver, vehicle: $vehicle, auditLog: $auditLog)';
}


}

/// @nodoc
abstract mixin class $RequisitionCopyWith<$Res>  {
  factory $RequisitionCopyWith(Requisition value, $Res Function(Requisition) _then) = _$RequisitionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, RequisitionStatus status, RequisitionDetails details, DateTime createdAt, DateTime? endDateTime, String? departmentName, String? companyName, String? requesterName, String? requesterCode, AssignedDriver? driver, AssignedVehicle? vehicle, List<AuditLogEntry> auditLog
});


$RequisitionDetailsCopyWith<$Res> get details;$AssignedDriverCopyWith<$Res>? get driver;$AssignedVehicleCopyWith<$Res>? get vehicle;

}
/// @nodoc
class _$RequisitionCopyWithImpl<$Res>
    implements $RequisitionCopyWith<$Res> {
  _$RequisitionCopyWithImpl(this._self, this._then);

  final Requisition _self;
  final $Res Function(Requisition) _then;

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? status = null,Object? details = null,Object? createdAt = null,Object? endDateTime = freezed,Object? departmentName = freezed,Object? companyName = freezed,Object? requesterName = freezed,Object? requesterCode = freezed,Object? driver = freezed,Object? vehicle = freezed,Object? auditLog = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as RequisitionDetails,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,requesterName: freezed == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String?,requesterCode: freezed == requesterCode ? _self.requesterCode : requesterCode // ignore: cast_nullable_to_non_nullable
as String?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as AssignedDriver?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as AssignedVehicle?,auditLog: null == auditLog ? _self.auditLog : auditLog // ignore: cast_nullable_to_non_nullable
as List<AuditLogEntry>,
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
}/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $AssignedDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedVehicleCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $AssignedVehicleCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt,  DateTime? endDateTime,  String? departmentName,  String? companyName,  String? requesterName,  String? requesterCode,  AssignedDriver? driver,  AssignedVehicle? vehicle,  List<AuditLogEntry> auditLog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Requisition() when $default != null:
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt,_that.endDateTime,_that.departmentName,_that.companyName,_that.requesterName,_that.requesterCode,_that.driver,_that.vehicle,_that.auditLog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt,  DateTime? endDateTime,  String? departmentName,  String? companyName,  String? requesterName,  String? requesterCode,  AssignedDriver? driver,  AssignedVehicle? vehicle,  List<AuditLogEntry> auditLog)  $default,) {final _that = this;
switch (_that) {
case _Requisition():
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt,_that.endDateTime,_that.departmentName,_that.companyName,_that.requesterName,_that.requesterCode,_that.driver,_that.vehicle,_that.auditLog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime pickupDateTime,  String pickupLocation,  String dropLocation,  String? remarks,  RequisitionStatus status,  RequisitionDetails details,  DateTime createdAt,  DateTime? endDateTime,  String? departmentName,  String? companyName,  String? requesterName,  String? requesterCode,  AssignedDriver? driver,  AssignedVehicle? vehicle,  List<AuditLogEntry> auditLog)?  $default,) {final _that = this;
switch (_that) {
case _Requisition() when $default != null:
return $default(_that.id,_that.pickupDateTime,_that.pickupLocation,_that.dropLocation,_that.remarks,_that.status,_that.details,_that.createdAt,_that.endDateTime,_that.departmentName,_that.companyName,_that.requesterName,_that.requesterCode,_that.driver,_that.vehicle,_that.auditLog);case _:
  return null;

}
}

}

/// @nodoc


class _Requisition extends Requisition {
  const _Requisition({required this.id, required this.pickupDateTime, required this.pickupLocation, required this.dropLocation, this.remarks, required this.status, required this.details, required this.createdAt, this.endDateTime, this.departmentName, this.companyName, this.requesterName, this.requesterCode, this.driver, this.vehicle, final  List<AuditLogEntry> auditLog = const <AuditLogEntry>[]}): _auditLog = auditLog,super._();
  

@override final  String id;
@override final  DateTime pickupDateTime;
@override final  String pickupLocation;
@override final  String dropLocation;
@override final  String? remarks;
@override final  RequisitionStatus status;
@override final  RequisitionDetails details;
@override final  DateTime createdAt;
@override final  DateTime? endDateTime;
@override final  String? departmentName;
@override final  String? companyName;
/// Who raised the requisition. `created_by_name` on the detail response, falling
/// back to the creating audit entry; null on a list row, which carries neither.
@override final  String? requesterName;
/// The requester's staff number (`created_by_id_no`), when the response carries it.
/// Independent of [requesterName] — either can arrive without the other.
@override final  String? requesterCode;
@override final  AssignedDriver? driver;
@override final  AssignedVehicle? vehicle;
 final  List<AuditLogEntry> _auditLog;
@override@JsonKey() List<AuditLogEntry> get auditLog {
  if (_auditLog is EqualUnmodifiableListView) return _auditLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_auditLog);
}


/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequisitionCopyWith<_Requisition> get copyWith => __$RequisitionCopyWithImpl<_Requisition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Requisition&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupDateTime, pickupDateTime) || other.pickupDateTime == pickupDateTime)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.status, status) || other.status == status)&&(identical(other.details, details) || other.details == details)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.endDateTime, endDateTime) || other.endDateTime == endDateTime)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterCode, requesterCode) || other.requesterCode == requesterCode)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&const DeepCollectionEquality().equals(other._auditLog, _auditLog));
}


@override
int get hashCode => Object.hash(runtimeType,id,pickupDateTime,pickupLocation,dropLocation,remarks,status,details,createdAt,endDateTime,departmentName,companyName,requesterName,requesterCode,driver,vehicle,const DeepCollectionEquality().hash(_auditLog));

@override
String toString() {
  return 'Requisition(id: $id, pickupDateTime: $pickupDateTime, pickupLocation: $pickupLocation, dropLocation: $dropLocation, remarks: $remarks, status: $status, details: $details, createdAt: $createdAt, endDateTime: $endDateTime, departmentName: $departmentName, companyName: $companyName, requesterName: $requesterName, requesterCode: $requesterCode, driver: $driver, vehicle: $vehicle, auditLog: $auditLog)';
}


}

/// @nodoc
abstract mixin class _$RequisitionCopyWith<$Res> implements $RequisitionCopyWith<$Res> {
  factory _$RequisitionCopyWith(_Requisition value, $Res Function(_Requisition) _then) = __$RequisitionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime pickupDateTime, String pickupLocation, String dropLocation, String? remarks, RequisitionStatus status, RequisitionDetails details, DateTime createdAt, DateTime? endDateTime, String? departmentName, String? companyName, String? requesterName, String? requesterCode, AssignedDriver? driver, AssignedVehicle? vehicle, List<AuditLogEntry> auditLog
});


@override $RequisitionDetailsCopyWith<$Res> get details;@override $AssignedDriverCopyWith<$Res>? get driver;@override $AssignedVehicleCopyWith<$Res>? get vehicle;

}
/// @nodoc
class __$RequisitionCopyWithImpl<$Res>
    implements _$RequisitionCopyWith<$Res> {
  __$RequisitionCopyWithImpl(this._self, this._then);

  final _Requisition _self;
  final $Res Function(_Requisition) _then;

/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pickupDateTime = null,Object? pickupLocation = null,Object? dropLocation = null,Object? remarks = freezed,Object? status = null,Object? details = null,Object? createdAt = null,Object? endDateTime = freezed,Object? departmentName = freezed,Object? companyName = freezed,Object? requesterName = freezed,Object? requesterCode = freezed,Object? driver = freezed,Object? vehicle = freezed,Object? auditLog = null,}) {
  return _then(_Requisition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupDateTime: null == pickupDateTime ? _self.pickupDateTime : pickupDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,dropLocation: null == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequisitionStatus,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as RequisitionDetails,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,endDateTime: freezed == endDateTime ? _self.endDateTime : endDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,requesterName: freezed == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String?,requesterCode: freezed == requesterCode ? _self.requesterCode : requesterCode // ignore: cast_nullable_to_non_nullable
as String?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as AssignedDriver?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as AssignedVehicle?,auditLog: null == auditLog ? _self._auditLog : auditLog // ignore: cast_nullable_to_non_nullable
as List<AuditLogEntry>,
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
}/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedDriverCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $AssignedDriverCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of Requisition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedVehicleCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $AssignedVehicleCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
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
