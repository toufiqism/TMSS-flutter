import 'package:freezed_annotation/freezed_annotation.dart';

part 'requisition.freezed.dart';

enum RequisitionStatus {
  pending('Pending'),
  approved('Approved'),
  assigned('Assigned'),
  rejected('Rejected');

  const RequisitionStatus(this.label);
  final String label;
}

enum RequisitionType { passenger, logistics }

enum UsedType {
  pickup('Pickup'),
  drop('Drop'),
  pickupAndDrop('Pickup & Drop');

  const UsedType(this.label);
  final String label;
}

enum RequiredFor {
  ownUser('Own User'),
  someoneElse('Someone Else');

  const RequiredFor(this.label);
  final String label;
}

enum RequisitionUserType {
  internal('Internal User'),
  external('External User');

  const RequisitionUserType(this.label);
  final String label;
}

enum VehicleType {
  coverVan('Cover Van'),
  openTruck('Open Truck');

  const VehicleType(this.label);
  final String label;
}

enum LoadingCapacity {
  ton1To5('1-5 Ton'),
  ton2('2 Ton'),
  ton3('3 Ton'),
  ton5('5 Ton'),
  ton7('7 Ton');

  const LoadingCapacity(this.label);
  final String label;
}

@freezed
sealed class RequisitionDetails with _$RequisitionDetails {
  const factory RequisitionDetails.passenger({
    required UsedType usedType,
    required String customerName,
    required int numberOfPersons,
    required RequiredFor requiredFor,
    RequisitionUserType? userType,
    @Default(<String>[]) List<String> employeeIds,
    required String purpose,
  }) = PassengerDetails;

  const factory RequisitionDetails.logistics({
    required VehicleType vehicleType,
    required String customerName,
    required String userDepartment,
    required LoadingCapacity loadingCapacity,
    required String goodsWeight,
    required String storeName,
    required String goodsDetails,
  }) = LogisticsDetails;
}

@freezed
abstract class Requisition with _$Requisition {
  const Requisition._();

  const factory Requisition({
    required String id,
    required DateTime pickupDateTime,
    required String pickupLocation,
    required String dropLocation,
    String? remarks,
    required RequisitionStatus status,
    required RequisitionDetails details,
    required DateTime createdAt,
  }) = _Requisition;

  RequisitionType get type => switch (details) {
        PassengerDetails() => RequisitionType.passenger,
        LogisticsDetails() => RequisitionType.logistics,
      };

  String get purposeText => switch (details) {
        PassengerDetails(:final purpose) => purpose,
        LogisticsDetails(:final goodsDetails) => goodsDetails,
      };
}

@freezed
sealed class NewRequisitionRequest with _$NewRequisitionRequest {
  const factory NewRequisitionRequest.passenger({
    required DateTime pickupDateTime,
    required String pickupLocation,
    required String dropLocation,
    String? remarks,
    required UsedType usedType,
    required String customerName,
    required int numberOfPersons,
    required RequiredFor requiredFor,
    RequisitionUserType? userType,
    @Default(<String>[]) List<String> employeeIds,
    required String purpose,
  }) = PassengerRequest;

  const factory NewRequisitionRequest.logistics({
    required DateTime pickupDateTime,
    required String pickupLocation,
    required String dropLocation,
    String? remarks,
    required VehicleType vehicleType,
    required String customerName,
    required String userDepartment,
    required LoadingCapacity loadingCapacity,
    required String goodsWeight,
    required String storeName,
    required String goodsDetails,
  }) = LogisticsRequest;
}

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int allCount,
    required int approvedCount,
    required int assignedCount,
    required int pendingCount,
    required int rejectedCount,
    required List<Requisition> recentRequisitions,
  }) = _DashboardSummary;
}

enum RequisitionSortField { date, pickup, destination, purpose, status }

@freezed
abstract class RequisitionListFilter with _$RequisitionListFilter {
  const factory RequisitionListFilter({
    DateTime? startDate,
    DateTime? endDate,
    @Default('') String searchQuery,
    @Default(1) int page,
    @Default(10) int pageSize,
    @Default(RequisitionSortField.date) RequisitionSortField sortBy,
    @Default(true) bool sortDescending,
  }) = _RequisitionListFilter;
}
