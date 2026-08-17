import 'package:freezed_annotation/freezed_annotation.dart';

part 'requisition.freezed.dart';

/// The workflow states this build knows how to *style* and *count*.
///
/// This is deliberately not what the UI displays. It exists only to answer three
/// questions — which colour, which stat tile, is it editable — and it is a closed set
/// because those three things are closed sets in the design. What the user reads is always
/// [RequisitionStatus.rawValue], the server's own string, so a state absent from this enum
/// still shows its real name rather than a placeholder.
///
/// Declaration order is lifecycle order, because `RequisitionSortField.status` sorts on
/// `index`. Do not reorder to change parse precedence — that is
/// [RequisitionStatus._matchOrder]'s job.
enum RequisitionStatusKind {
  pending('Pending', <String>[
    // Verified live.
    'pending',
    // Hedges against the web UI's wordier phrasings of the same step.
    'pendingapproval',
    'approvalpending',
    'awaitingapproval',
  ]),
  approved('Approved', <String>['approved', 'approve', 'vehicleapproved']),
  assigned('Assigned', <String>[
    // Verified live: the list endpoint sends `Vehicle Assigned`. A bare `Assigned` has
    // never been observed — it is listed second as a hedge, not as the known value.
    'vehicleassigned',
    'assigned',
    'driverassigned',
    'vehicledriverassigned',
  ]),
  rejected('Rejected', <String>[
    // Verified live.
    'rejected',
    'reject',
    'declined',
    'decline',
    'denied',
  ]),

  /// Canonical label only. The server's wire value is the bare `Cancel`.
  cancelled('Cancelled', <String>[
    // Verified live.
    'cancel',
    'canceled',
    'cancelled',
    'cancellation',
    'vehiclecancelled',
  ]),

  /// A state this build has no styling or stat tile for.
  ///
  /// Verified live: `Pending`, `Rejected`, `Vehicle Assigned` and `Cancel` are real wire
  /// values. The rest of the vocabulary is still unconfirmed — a `Completed` or
  /// `In Progress` state may well exist — so anything unmatched lands here, takes the
  /// neutral palette, and **still displays its own server string**. Actions stay gated on
  /// [pending] specifically, so an unrecognised state is never treated as cancellable.
  unrecognised('', <String>[]);

  const RequisitionStatusKind(this.canonicalLabel, this.wireAliases);

  /// The spelling used when the *client* originates a status rather than reading one —
  /// test fixtures and the [RequisitionStatus] constants. Never shown in place of a
  /// value the server sent. Empty for [unrecognised], which has no canonical spelling.
  final String canonicalLabel;

  /// Normalised wire values that map here: lower case, with separators already stripped.
  /// Empty for [unrecognised], which is the fallback rather than a matchable value.
  final List<String> wireAliases;
}

/// A requisition's status as the pairing of **what the server called it** and **what this
/// build can do with it**.
///
/// [rawValue] is the display string, always, verbatim from the response. That is the whole
/// point of this type: an earlier version displayed a curated per-status label, which meant
/// the live value `Vehicle Assigned` — two of six rows on a real list response — matched no
/// label, fell through to a hardcoded "Unknown" chip and vanished from the dashboard's
/// assigned count. A status the server invents tomorrow now renders its own name instead.
///
/// [kind] is the interpretation layered on top, and only ever drives colour, stat-tile
/// counting and whether edit/cancel is offered. An unmatched value degrades to
/// [RequisitionStatusKind.unrecognised] on those three axes without affecting what is
/// shown.
///
/// Equality covers **both** fields, so `fromWire('Vehicle Assigned') != assigned` — the
/// canonical constant carries a different [rawValue]. Compare [kind] when asking "is this
/// approved?"; there is [isPending] for the common case.
@freezed
abstract class RequisitionStatus with _$RequisitionStatus {
  const RequisitionStatus._();

  const factory RequisitionStatus({
    required String rawValue,
    required RequisitionStatusKind kind,
  }) = _RequisitionStatus;

  /// Client-originated statuses, for fixtures and for code that needs to name a state it
  /// did not read off the wire. Their [rawValue] is the canonical spelling, not a server
  /// one.
  static const pending = RequisitionStatus(
    rawValue: 'Pending',
    kind: RequisitionStatusKind.pending,
  );
  static const approved = RequisitionStatus(
    rawValue: 'Approved',
    kind: RequisitionStatusKind.approved,
  );
  static const assigned = RequisitionStatus(
    rawValue: 'Assigned',
    kind: RequisitionStatusKind.assigned,
  );
  static const rejected = RequisitionStatus(
    rawValue: 'Rejected',
    kind: RequisitionStatusKind.rejected,
  );
  static const cancelled = RequisitionStatus(
    rawValue: 'Cancelled',
    kind: RequisitionStatusKind.cancelled,
  );

  /// The server sent no status at all — null, or a string that was nothing but
  /// whitespace. Distinct from an unrecognised state: there is no name to show, so the UI
  /// renders no chip and no dot rather than inventing a word for it. See [hasValue].
  static const absent = RequisitionStatus(
    rawValue: '',
    kind: RequisitionStatusKind.unrecognised,
  );

  /// Precedence for the substring pass in [fromWire], most-terminal first.
  ///
  /// A compound value like `Cancellation Pending` contains two status words, so the order
  /// decides. Terminal and restrictive states win, because [Requisition.canBeModified] is
  /// true only for pending: guessing "pending" on an ambiguous value would offer the user
  /// an edit or cancel the server then rejects, whereas guessing the terminal state only
  /// under-promises. This affects [kind] alone — [rawValue] is untouched either way.
  static const List<RequisitionStatusKind> _matchOrder = <RequisitionStatusKind>[
    RequisitionStatusKind.rejected,
    RequisitionStatusKind.cancelled,
    RequisitionStatusKind.pending,
    RequisitionStatusKind.assigned,
    RequisitionStatusKind.approved,
  ];

  static final RegExp _separators = RegExp(r'[\s_\-,./&]');

  /// Negations of a status word. `Unassigned` *contains* `assigned` and `Not Approved`
  /// contains `approved`, so the substring pass would read either as its own opposite.
  /// Neither has been observed on the wire, so their [kind] stays
  /// [RequisitionStatusKind.unrecognised] — neutral colour, no action — rather than
  /// inverting the server's meaning. The text still displays as sent.
  static final RegExp _negated = RegExp(r'(un|not|non)(approved|assigned|confirmed)');

  /// Reads a server status, keeping the original string whatever happens.
  ///
  /// Only [kind] can fail to resolve. Interpretation ignores case, spaces, underscores,
  /// hyphens, commas, dots, slashes and ampersands, because the wire vocabulary is only
  /// partly confirmed and `In Progress`, `in_progress` and `IN-PROGRESS` are all plausible
  /// spellings of the same thing.
  ///
  /// Three passes, in order:
  /// 1. exact alias match — unambiguous, so it runs before any guard and an explicitly
  ///    listed value always wins;
  /// 2. the [_negated] guard, which only ever constrains guessing;
  /// 3. substring match in [_matchOrder] precedence, for values that wrap a status word
  ///    in extra prose.
  static RequisitionStatus fromWire(String? raw) {
    // Trimmed, because the display string is user-facing and a stray leading space in the
    // response would push the chip's text off centre.
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return absent;
    return RequisitionStatus(rawValue: value, kind: _kindOf(value));
  }

  static RequisitionStatusKind _kindOf(String value) {
    final normalised = value.toLowerCase().replaceAll(_separators, '');
    if (normalised.isEmpty) return RequisitionStatusKind.unrecognised;

    for (final kind in _matchOrder) {
      if (kind.wireAliases.contains(normalised)) return kind;
    }

    if (_negated.hasMatch(normalised)) return RequisitionStatusKind.unrecognised;

    for (final kind in _matchOrder) {
      for (final alias in kind.wireAliases) {
        if (normalised.contains(alias)) return kind;
      }
    }
    return RequisitionStatusKind.unrecognised;
  }

  /// Whether there is a name to display. False only for [absent] — an unrecognised status
  /// still has a perfectly good string to show.
  bool get hasValue => rawValue.isNotEmpty;

  /// True when the server called this pending, by any spelling. The one interpretation
  /// worth a getter, because it gates every mutating action.
  bool get isPending => kind == RequisitionStatusKind.pending;
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
  ///
  /// Riders are named on the wire via `employee_id[]` for both values now, so the
  /// picker is no longer gated — the note that once stood here, saying there was
  /// nowhere to send *who* the requisition is for, is obsolete.
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

  /// Reads a logistics requisition's `requisition_for`, which is where the server keeps
  /// the vehicle type. Falls back to [coverVan] for an unrecognised or absent value, so
  /// a row still renders rather than failing to parse over one field.
  static VehicleType fromWire(String? raw) {
    if (raw == null) return coverVan;
    final normalised = raw.toLowerCase().replaceAll(' ', '');
    for (final type in values) {
      if (type.label.toLowerCase().replaceAll(' ', '') == normalised) return type;
    }
    return coverVan;
  }
}

/// Server-validated `in:` list. Probed exhaustively against the live API: these four
/// are the complete set.
///
/// `1-5 Ton` used to be the first value here and the form's default — it is rejected by
/// the server, so every logistics submission built on the default would have failed
/// validation.
enum LoadingCapacity {
  /// Written `1∙5 Ton` — a BULLET OPERATOR (U+2219), **not** a full stop.
  ///
  /// That is the literal value the API accepts, taken verbatim from the updated
  /// contract's documented option list; anything else earns a 422.
  ///
  /// The character is stored literally, so an editor, terminal or diff tool that
  /// normalises it to `.` or `·` would break submission at runtime — and a test
  /// comparing against this same constant would still pass, because both sides would
  /// have changed together. `loading_capacity 1.5 Ton keeps its U+2219` in
  /// `requisition_model_test.dart` therefore asserts the raw code unit instead.
  ///
  /// Named `ton1Point5` rather than `ton1_5` only because `constant_identifier_names`
  /// rejects the underscore.
  ton1Point5('1∙5 Ton'),
  ton2('2 Ton'),
  ton3('3 Ton'),
  ton5('5 Ton'),
  ton7('7 Ton');

  const LoadingCapacity(this.label);
  final String label;

  /// Reads leniently in both directions: the separator is normalised on the wire value
  /// *and* on the label, so a server that ever returns the sane `1.5 Ton` — or the
  /// middle dot `1·5 Ton` — still maps to [ton1_5] instead of silently falling back to
  /// [ton2] and showing the user a capacity they never chose.
  static LoadingCapacity fromWire(String? raw) {
    if (raw == null) return ton2;
    final normalised = _normalise(raw);
    for (final capacity in values) {
      if (_normalise(capacity.label) == normalised) return capacity;
    }
    return ton2;
  }

  static String _normalise(String value) => value
      .toLowerCase()
      .replaceAll(' ', '')
      // U+2219 BULLET OPERATOR and U+00B7 MIDDLE DOT, escaped for the same reason the
      // label above is.
      .replaceAll('∙', '.')
      .replaceAll('·', '.');
}

/// One entry in a requisition's history. Shape confirmed against a live response:
/// `{id, requisition_status, remarks, created_by_name, created_by_id_no, created_at}`.
@freezed
abstract class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String id,
    required RequisitionStatus status,
    String? remarks,
    String? actorName,
    String? actorCode,
    DateTime? at,
  }) = _AuditLogEntry;
}

/// Driver assigned by dispatch, present only once a requisition leaves `Pending`.
///
/// The server's field names for this object are **unverified** — it was null on every
/// requisition observed so far, and the API contract records the field set as unknown.
/// Every field is therefore nullable and parsed by trying plausible keys; the UI renders
/// only what it actually found rather than asserting a shape nobody has confirmed.
@freezed
abstract class AssignedDriver with _$AssignedDriver {
  const AssignedDriver._();

  const factory AssignedDriver({String? name, String? phone, String? identifier}) =
      _AssignedDriver;

  bool get hasAnything => name != null || phone != null || identifier != null;
}

/// Vehicle assigned by dispatch. Same caveat as [AssignedDriver] — field names unverified.
@freezed
abstract class AssignedVehicle with _$AssignedVehicle {
  const AssignedVehicle._();

  const factory AssignedVehicle({
    String? registrationNumber,
    String? model,
    String? type,
  }) = _AssignedVehicle;

  bool get hasAnything => registrationNumber != null || model != null || type != null;
}

/// One rider on a passenger requisition, exactly as the server reports them.
///
/// Deliberately not an [Employee]: the requisition's `employees[]` carries only
/// `{id, id_no, full_name}`, so designation, department and company are unknown here.
/// Modelling this as an `Employee` would mean inventing three empty strings and letting
/// the UI render them as though the server had said they were blank.
///
/// [name] and [employeeCode] are empty when the wire entry was a bare id (the older
/// `employee_id: [3035]` shape) rather than an object — the id is still submittable,
/// which is the part that must never be lost.
@freezed
abstract class RequisitionRider with _$RequisitionRider {
  const RequisitionRider._();

  const factory RequisitionRider({
    required String id,
    @Default('') String name,
    @Default('') String employeeCode,
  }) = _RequisitionRider;

  /// Whether the server gave a name to show. False for an id-only rider, which the UI
  /// labels as unresolved rather than rendering a blank row.
  bool get hasName => name.trim().isNotEmpty;
}

@freezed
sealed class RequisitionDetails with _$RequisitionDetails {
  const factory RequisitionDetails.passenger({
    required UsedType usedType,
    required String customerName,
    required int numberOfPersons,
    required RequiredFor requiredFor,
    RequisitionUserType? userType,
    @Default(<RequisitionRider>[]) List<RequisitionRider> riders,
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

/// The rider ids in submission order.
///
/// An extension rather than a member because the getter belongs to one branch of the
/// union, and Freezed generates the branches. Ids are what `employee_id[]` takes; the
/// names alongside them are read-only decoration.
extension PassengerRiderIds on PassengerDetails {
  List<String> get employeeIds =>
      riders.map((rider) => rider.id).toList(growable: false);
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
    // Everything below is returned by GET /requisitions/{id} but not by the list, so it
    // is absent on rows built from a list response rather than meaningfully empty.
    DateTime? endDateTime,
    String? departmentName,
    String? companyName,

    /// Who raised the requisition. `created_by_name` on the detail response, falling
    /// back to the creating audit entry; null on a list row, which carries neither.
    String? requesterName,

    /// The requester's staff number (`created_by_id_no`), when the response carries it.
    /// Independent of [requesterName] — either can arrive without the other.
    String? requesterCode,
    AssignedDriver? driver,
    AssignedVehicle? vehicle,
    @Default(<AuditLogEntry>[]) List<AuditLogEntry> auditLog,
  }) = _Requisition;

  /// Whether the server will accept an edit or a cancel.
  ///
  /// Mirrors the rule the API enforces — `status == Pending` **and** caller is the
  /// creator. The client can only check the first half; ownership is implicit because
  /// the list is already scoped to the authenticated user, and a 403 covers the rest.
  /// Compares [RequisitionStatus.kind], not the status itself: equality on
  /// [RequisitionStatus] includes the raw server string, so a live `Pending` row is not
  /// equal to the canonical constant and a value comparison here would gate every action
  /// off by accident.
  bool get canBeModified => status.isPending;

  /// True once dispatch has attached either a driver or a vehicle.
  bool get hasAssignment =>
      (driver?.hasAnything ?? false) || (vehicle?.hasAnything ?? false);

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
