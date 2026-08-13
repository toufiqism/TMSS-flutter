import 'package:freezed_annotation/freezed_annotation.dart';

part 'requisition.freezed.dart';

enum RequisitionStatus {
  pending('Pending'),
  approved('Approved'),
  assigned('Assigned'),
  rejected('Rejected'),

  /// Display label only. The server's wire value is the bare `Cancel` — see [fromWire].
  cancelled('Cancelled'),

  /// A status this build does not recognise.
  ///
  /// Verified live: `Pending` and `Cancel` are real wire values. The rest of the
  /// vocabulary is still unconfirmed, so a row with an unrecognised status must still
  /// render and lands here instead of throwing. Actions stay gated on [pending]
  /// specifically, so an unknown status is never treated as cancellable.
  unknown('Unknown');

  const RequisitionStatus(this.label);
  final String label;

  /// Parses a server status. Matching ignores case, spaces, underscores and hyphens,
  /// because the wire vocabulary is only partly confirmed and `In Progress`,
  /// `in_progress` and `IN-PROGRESS` are all plausible spellings of the same thing.
  static RequisitionStatus fromWire(String? raw) {
    if (raw == null) return unknown;
    final normalised = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (normalised.isEmpty) return unknown;
    // Checked before the label scan: the server sends the verb `Cancel`, not the
    // adjective `Cancelled` this enum displays, so the labels do not match directly.
    if (normalised == 'cancel' || normalised == 'canceled' || normalised == 'cancelled') {
      return cancelled;
    }
    for (final status in values) {
      if (status == unknown) continue;
      if (status.label.toLowerCase() == normalised) return status;
    }
    return unknown;
  }
}

enum RequisitionType { passenger, logistics }

/// Journey shape. [label] doubles as the wire value — these are exact-match strings
/// (note the literal ampersand and spacing in `Pickup & Drop`), so they are never
/// reconstructed from parts.
///
/// All three are accepted by the server. The contract listed only `Drop` and
/// `Pickup & Drop`; a live probe confirmed bare `Pickup` is valid too.
enum UsedType {
  pickup('Pickup'),
  drop('Drop'),
  pickupAndDrop('Pickup & Drop');

  const UsedType(this.label);
  final String label;

  static UsedType fromWire(String? raw) {
    if (raw == null) return pickupAndDrop;
    final normalised = raw.toLowerCase().replaceAll(RegExp(r'[\s&_-]'), '');
    for (final type in values) {
      if (type.label.toLowerCase().replaceAll(RegExp(r'[\s&_-]'), '') == normalised) {
        return type;
      }
    }
    return pickupAndDrop;
  }
}

enum RequiredFor {
  ownUser('Own User'),

  /// Confirmed valid by a live probe, despite the contract listing only `Own User`.
  /// Note the server requires no employee field alongside it — there is still nowhere
  /// on the wire to send *who* the requisition is for, which is why the employee
  /// picker stays gated behind [ApiCapabilities.employeeDirectory].
  someoneElse('Someone Else');

  const RequiredFor(this.label);
  final String label;

  static RequiredFor fromWire(String? raw) =>
      raw != null && raw.toLowerCase().contains('someone') ? someoneElse : ownUser;
}

enum RequisitionUserType {
  internal('Internal User'),

  /// Confirmed valid by a live probe; the contract had it as "plausible but unverified".
  external('External User');

  const RequisitionUserType(this.label);
  final String label;

  static RequisitionUserType fromWire(String? raw) =>
      raw != null && raw.toLowerCase().contains('external') ? external : internal;
}

/// Kept for the logistics form, but **not sent**: the server neither requires nor
/// validates a `vehicle_type` field, and a probe with a nonsense value was accepted
/// without comment. Retained so the UI still matches the Android app; revisit if the
/// backend ever starts reading it.
enum VehicleType {
  coverVan('Cover Van'),
  openTruck('Open Truck');

  const VehicleType(this.label);
  final String label;
}

/// Server-validated `in:` list. Probed exhaustively against the live API: these four
/// are the complete set.
///
/// `1-5 Ton` used to be the first value here and the form's default — it is rejected by
/// the server, so every logistics submission built on the default would have failed
/// validation.
enum LoadingCapacity {
  ton2('2 Ton'),
  ton3('3 Ton'),
  ton5('5 Ton'),
  ton7('7 Ton');

  const LoadingCapacity(this.label);
  final String label;

  static LoadingCapacity fromWire(String? raw) {
    if (raw == null) return ton2;
    final normalised = raw.toLowerCase().replaceAll(' ', '');
    for (final capacity in values) {
      if (capacity.label.toLowerCase().replaceAll(' ', '') == normalised) return capacity;
    }
    return ton2;
  }
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
