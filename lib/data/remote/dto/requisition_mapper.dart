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
      driver: _driver(json.mapOrNull('driver')),
      vehicle: _vehicle(json.mapOrNull('vehicle')),
      auditLog: json
          .objectListOrEmpty('audit_logs')
          .map(_auditEntry)
          .nonNulls
          .toList(),
    );
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
      purpose: json.stringOrNull('purpose') ?? '',
    );
  }

  static RequisitionDetails _logisticsDetails(Map<String, dynamic> json) {
    return RequisitionDetails.logistics(
      // The server has no vehicle_type field, so nothing can be read back into it.
      // The domain model still requires one; the form's own default stands in.
      vehicleType: VehicleType.coverVan,
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
          if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        },
      LogisticsRequest(
        :final pickupDateTime,
        :final pickupLocation,
        :final dropLocation,
        :final remarks,
        :final customerName,
        :final userDepartment,
        :final loadingCapacity,
        :final goodsWeight,
        :final storeName,
        :final goodsDetails,
      ) =>
        <String, dynamic>{
          'req_type': reqTypeLogisticSupport,
          // Required by the server for logistics too, though the form does not ask:
          // a logistics run is always raised by the requester for their own department.
          'requisition_for': RequiredFor.ownUser.label,
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
