import '../../../domain/model/requisition.dart';
import 'json_reader.dart';
import 'wire_date_time.dart';

/// Maps between the API's requisition shapes and the domain model.
///
/// Verified against the live server rather than inferred from the contract, which was
/// wrong about several things. Two traps worth stating up front:
///
/// - **The read and write models use different names for the pickup time.** Requests
///   send `pick_up_date_time`; responses return it as `start_time`. Reading
///   `pick_up_date_time` back off a response finds nothing.
/// - **Timestamps mix timezones.** `start_time` is Dhaka wall-clock (it round-trips
///   verbatim), but `created_at` is UTC. Parsing both the same way puts every
///   `createdAt` six hours out.
class RequisitionMapper {
  RequisitionMapper._();

  static const reqTypePassengerVehicle = 'passenger_vehicle';
  static const reqTypeLogisticSupport = 'logistic_support';

  /// Returns null when the row has no usable id — such a row cannot be cancelled or
  /// opened, so rendering it would only offer the user broken actions.
  static Requisition? fromJson(Map<String, dynamic> json) {
    final id = json.idOrNull('id');
    if (id == null) return null;

    // `start_time` is the response field; `pick_up_date_time` is accepted as a fallback
    // in case a future endpoint echoes the request shape instead.
    final pickupDateTime =
        WireDateTime.parse(json.stringFrom(['start_time', 'pick_up_date_time']));
    final createdAt = WireDateTime.parseUtc(json.stringOrNull('created_at')) ??
        pickupDateTime ??
        DateTime.now();

    final isLogistics = json.stringOrNull('req_type') == reqTypeLogisticSupport;

    final auditLog =
        json.objectListOrEmpty('audit_logs').map(_auditEntry).nonNulls.toList();

    return Requisition(
      id: id,
      pickupDateTime: pickupDateTime ?? createdAt,
      pickupLocation: json.stringOrNull('pickup_location') ?? '',
      dropLocation: json.stringOrNull('drop_location') ?? '',
      remarks: json.stringOrNull('remarks'),
      status: RequisitionStatus.fromWire(json.stringOrNull('status')),
      details: isLogistics ? _logisticsDetails(json) : _passengerDetails(json),
      createdAt: createdAt,
      // Detail-only. Absent from list rows, which is why these are nullable rather than
      // defaulted — "the list didn't return it" and "the server has no value" must stay
      // distinguishable.
      endDateTime: WireDateTime.parse(json.stringOrNull('end_time')),
      departmentName: json.stringOrNull('department_name'),
      companyName: json.stringOrNull('company_name'),
      requesterName: _requesterName(json, auditLog),
      requesterCode: _requesterCode(json, auditLog),
      driver: _driver(json.mapOrNull('driver')),
      vehicle: _vehicle(json.mapOrNull('vehicle')),
      auditLog: auditLog,
    );
  }

  /// Who raised the requisition.
  ///
  /// `created_by_name` is a real top-level field on `GET /requisitions/{id}` — the
  /// alternative spellings after it are a cheap hedge, not evidence of another shape.
  ///
  /// The fallback is the **creating** audit entry, which carries the same
  /// `created_by_name` per-entry: a list row has no requester field at all, and the
  /// entry that opened the requisition names the same person. [_creatingEntry] is used
  /// rather than the newest entry, because a later approval or cancellation is written
  /// by somebody else and naming *them* as the requester would be worse than showing
  /// nothing.
  static String? _requesterName(
    Map<String, dynamic> json,
    List<AuditLogEntry> auditLog,
  ) =>
      json.stringFrom([
        'created_by_name',
        'requested_by_name',
        'employee_name',
        'user_name',
      ]) ??
      _creatingEntry(auditLog)?.actorName;

  static String? _requesterCode(
    Map<String, dynamic> json,
    List<AuditLogEntry> auditLog,
  ) =>
      json.stringFrom([
        'created_by_id_no',
        'created_by_code',
        'requested_by_id_no',
      ]) ??
      _creatingEntry(auditLog)?.actorCode;

  /// The entry that opened the requisition: the earliest by timestamp, or — when no
  /// entry carries one — the first in the response, which arrives oldest-first.
  ///
  /// Returns null for an empty log rather than throwing, so a list row (no audit log at
  /// all) simply yields no requester.
  static AuditLogEntry? _creatingEntry(List<AuditLogEntry> auditLog) {
    if (auditLog.isEmpty) return null;
    AuditLogEntry earliest = auditLog.first;
    for (final entry in auditLog) {
      final at = entry.at;
      final earliestAt = earliest.at;
      if (at == null) continue;
      if (earliestAt == null || at.isBefore(earliestAt)) earliest = entry;
    }
    return earliest;
  }

  /// Field names here are guesses over an unverified shape (see [AssignedDriver]), so
  /// each reads a list of plausible keys and yields null rather than failing.
  static AssignedDriver? _driver(Map<String, dynamic>? json) {
    if (json == null) return null;
    final driver = AssignedDriver(
      name: json.stringFrom(['name', 'driver_name', 'full_name']),
      phone: json.stringFrom(['phone', 'mobile', 'contact_no', 'phone_no']),
      identifier: json.stringFrom(['id_no', 'employee_id', 'driver_id', 'code']),
    );
    return driver.hasAnything ? driver : null;
  }

  static AssignedVehicle? _vehicle(Map<String, dynamic>? json) {
    if (json == null) return null;
    final vehicle = AssignedVehicle(
      registrationNumber: json.stringFrom([
        'registration_no',
        'registration_number',
        'reg_no',
        'vehicle_no',
        'number',
      ]),
      model: json.stringFrom(['model', 'vehicle_model', 'name']),
      type: json.stringFrom(['type', 'vehicle_type', 'category']),
    );
    return vehicle.hasAnything ? vehicle : null;
  }

  /// Entries without an id are dropped: they cannot be keyed in a list and carry no
  /// more information than the row already shows.
  static AuditLogEntry? _auditEntry(Map<String, dynamic> json) {
    final id = json.idOrNull('id');
    if (id == null) return null;
    return AuditLogEntry(
      id: id,
      status: RequisitionStatus.fromWire(json.stringOrNull('requisition_status')),
      remarks: json.stringOrNull('remarks'),
      actorName: json.stringFrom(['created_by_name', 'actor_name', 'user_name']),
      actorCode: json.stringFrom(['created_by_id_no', 'created_by_code']),
      // Same UTC treatment as the requisition's own created_at.
      at: WireDateTime.parseUtc(json.stringOrNull('created_at')),
    );
  }

  static RequisitionDetails _passengerDetails(Map<String, dynamic> json) {
    return RequisitionDetails.passenger(
      usedType: UsedType.fromWire(json.stringOrNull('used_type')),
      customerName: json.stringOrNull('customer_name') ?? '',
      numberOfPersons: json.intOrNull('no_of_person') ?? 1,
      requiredFor: RequiredFor.fromWire(json.stringOrNull('requisition_for')),
      userType: RequisitionUserType.fromWire(json.stringOrNull('requisition_for_user')),
      riders: _riders(json),
      purpose: json.stringOrNull('purpose') ?? '',
    );
  }

  /// Reads back the rider list.
  ///
  /// **Confirmed against the live server.** The key is `employees`, and it carries
  /// objects, not ids:
  ///
  /// ```json
  /// "employees": [{"id": 3035, "id_no": "2-765", "full_name": "Md. Tofiq Akbar"}]
  /// ```
  ///
  /// Three properties of it are worth stating, because each one has a way of biting:
  ///
  /// - It appears on the **detail, create and update** responses, and **not on list
  ///   rows** — so a requisition mapped from the list always reads back zero riders.
  ///   That is the response's shape, not the requisition's state.
  /// - The name is asymmetric with the request, which sends `employee_id`. Reading and
  ///   writing use different keys.
  /// - It is `[]`, never null, on a logistics requisition. Riders are a passenger-only
  ///   concept.
  ///
  /// The alternative spellings below are kept as a cheap hedge against a rename, since
  /// a wrong guess here costs nothing and a missed rename costs the rider list.
  ///
  /// Empty is the safe default *for reading*, but it is not safe to act on blindly:
  /// `employee_id` **replaces** the whole rider list on update, so an edit form seeded
  /// from an empty read would silently wipe the riders. The create/edit notifier
  /// therefore distinguishes "no riders returned" from "requisition has no riders" and
  /// warns rather than submitting an unintended replacement.
  /// The object form also carries `full_name` and `id_no`, which are kept: they are
  /// what the detail screen shows and what seeds the edit form's chips, and without
  /// them the edit form can only display "details unavailable" until the whole 537-row
  /// directory downloads. A bare-id entry yields a rider with no name — still
  /// submittable, and the UI labels it as unresolved rather than blank.
  static List<RequisitionRider> _riders(Map<String, dynamic> json) {
    for (final key in const [
      // Verified first, guesses after.
      'employees',
      'employee_id',
      'employee_ids',
      'riders',
      'requisition_employees',
    ]) {
      final raw = json[key];
      if (raw is! List || raw.isEmpty) continue;

      final riders = <RequisitionRider>[];
      for (final entry in raw) {
        if (entry is num) {
          riders.add(RequisitionRider(id: entry.toInt().toString()));
        } else if (entry is String && entry.trim().isNotEmpty) {
          riders.add(RequisitionRider(id: entry.trim()));
        } else if (entry is Map<String, dynamic>) {
          // A list of employee objects: take the surrogate `id`, never `id_no` — only
          // `id` is accepted back in `employee_id[]`. An entry with no `id` is dropped
          // rather than kept for its name: it could not be re-submitted, so keeping it
          // would show a rider that any subsequent edit would silently remove.
          final id = entry.idOrNull('id') ?? entry.idOrNull('employee_id');
          if (id == null) continue;
          riders.add(RequisitionRider(
            id: id,
            name: entry.stringFrom(['full_name', 'name', 'employee_name']) ?? '',
            employeeCode: entry.stringFrom(['id_no', 'employee_code', 'code']) ?? '',
          ));
        }
      }
      if (riders.isNotEmpty) return riders;
    }
    return const <RequisitionRider>[];
  }

  static RequisitionDetails _logisticsDetails(Map<String, dynamic> json) {
    return RequisitionDetails.logistics(
      // `requisition_for` carries the vehicle type for logistics. This used to be
      // hardcoded to coverVan because no field was known to hold it, which meant an
      // Open Truck requisition always read back — and re-submitted on edit — as a
      // Cover Van.
      vehicleType: VehicleType.fromWire(json.stringOrNull('requisition_for')),
      customerName: json.stringOrNull('customer_name') ?? '',
      userDepartment: json.stringOrNull('user_department') ?? '',
      loadingCapacity: LoadingCapacity.fromWire(json.stringOrNull('loading_capacity')),
      goodsWeight: json.stringOrNull('goods_weight') ?? '',
      storeName: json.stringOrNull('store_name') ?? '',
      goodsDetails: json.stringOrNull('goods_details') ?? '',
    );
  }

  /// Builds the shared create/update body.
  ///
  /// Only the fields the server actually validates are sent. Required sets differ by
  /// type and were read off the server's own 422 responses:
  ///
  /// - passenger: `customer_name`, `drop_location`, `no_of_person`, `pick_up_date_time`,
  ///   `pickup_location`, `purpose`, `requisition_for`, `requisition_for_user`,
  ///   `used_type`
  /// - logistics: `customer_name`, `drop_location`, `goods_details`, `goods_weight`,
  ///   `loading_capacity`, `pick_up_date_time`, `pickup_location`, `requisition_for`,
  ///   `store_name`, `user_department`
  ///
  /// `remarks` is optional for both.
  static Map<String, dynamic> toWriteJson(NewRequisitionRequest request) {
    return switch (request) {
      PassengerRequest(
        :final pickupDateTime,
        :final pickupLocation,
        :final dropLocation,
        :final remarks,
        :final usedType,
        :final customerName,
        :final numberOfPersons,
        :final requiredFor,
        :final userType,
        :final employeeIds,
        :final purpose,
      ) =>
        <String, dynamic>{
          'req_type': reqTypePassengerVehicle,
          'requisition_for': requiredFor.label,
          'requisition_for_user': (userType ?? RequisitionUserType.internal).label,
          'used_type': usedType.label,
          'purpose': purpose,
          'customer_name': customerName,
          'pickup_location': pickupLocation,
          'drop_location': dropLocation,
          'pick_up_date_time': WireDateTime.format(pickupDateTime),
          'no_of_person': numberOfPersons,
          // Integers, not the strings the domain carries: the server's `distinct` and
          // count rules compare numerically, and a list of quoted ids fails them.
          //
          // Ids that are not numeric are dropped rather than coerced — they cannot be
          // real `employee_id` values, and sending a 0 or a null in their place would
          // turn a client bug into a wrong rider on someone's trip.
          'employee_id': employeeIds
              .map(int.tryParse)
              .nonNulls
              .toList(growable: false),
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        },
      LogisticsRequest(
        :final pickupDateTime,
        :final pickupLocation,
        :final dropLocation,
        :final remarks,
        :final vehicleType,
        :final customerName,
        :final userDepartment,
        :final loadingCapacity,
        :final goodsWeight,
        :final storeName,
        :final goodsDetails,
      ) =>
        <String, dynamic>{
          'req_type': reqTypeLogisticSupport,
          // For logistics, `requisition_for` **is** the vehicle type — the web UI labels
          // this same field "Vehicle Type" and accepts only `Cover Van` | `Open Truck`.
          // It previously sent `Own User`, borrowed from the passenger meaning of the
          // field; the updated contract rejects that with a 422.
          'requisition_for': vehicleType.label,
          'customer_name': customerName,
          'user_department': userDepartment,
          'pickup_location': pickupLocation,
          'drop_location': dropLocation,
          'pick_up_date_time': WireDateTime.format(pickupDateTime),
          'loading_capacity': loadingCapacity.label,
          'goods_weight': goodsWeight,
          'store_name': storeName,
          'goods_details': goodsDetails,
          // vehicle_type is deliberately absent: the server does not validate or store
          // it. Sending it would be noise.
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        },
    };
  }
}

/// Pagination, as the server actually sends it: nested at `data.pagination`, with
/// `current_page`, `per_page`, `total` and `last_page`.
///
/// This is neither of the two Laravel conventions the contract suggested — not a
/// `meta` wrapper, not a flat `LengthAwarePaginator`. Those keys are still read as
/// fallbacks so a backend refactor toward either convention degrades quietly instead
/// of silently truncating every list.
class PageInfo {
  const PageInfo({this.currentPage, this.lastPage, this.total});

  final int? currentPage;
  final int? lastPage;
  final int? total;

  static PageInfo fromEnvelope(Map<String, dynamic> envelope) {
    final source = envelope.mapOrNull('pagination') ?? envelope.mapOrNull('meta') ?? envelope;
    return PageInfo(
      currentPage: source.intOrNull('current_page'),
      lastPage: source.intOrNull('last_page'),
      total: source.intOrNull('total'),
    );
  }

  /// Whether another page is worth requesting.
  ///
  /// Prefers the server's own `last_page`. Note it reports `0` — not `1` — for an empty
  /// result, so a plain `page < last_page` is enough and no empty-case special-casing
  /// is needed. Without pagination at all it falls back to "a full page probably means
  /// there is more", which over-fetches by one empty request rather than truncating.
  bool hasMoreAfter(int page, int receivedCount, int requestedPageSize) {
    final last = lastPage;
    if (last != null) return page < last;
    return receivedCount >= requestedPageSize;
  }
}
