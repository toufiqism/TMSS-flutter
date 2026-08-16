// Not a unit test — a manual, opt-in probe that runs this app's real Dio stack against
// the live server. Excluded from `flutter test` runs because it needs a network and
// credentials, and because the create/cancel pair writes to production.
//
//   dart run test/live_api_check.dart --user <email> --pass <password>
//
// Everything it creates, it cancels. Field values are all "Test" so anything it leaves
// behind is obviously synthetic.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tracgo/core/api_config.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/data/remote/tracgo_api_client.dart';
import 'package:tracgo/data/remote/dto/user_mapper.dart';
import 'package:tracgo/data/repository/remote_requisition_repository.dart';
import 'package:tracgo/domain/model/employee.dart';
import 'package:tracgo/domain/model/requisition.dart';

void main(List<String> args) async {
  final user = _arg(args, '--user');
  final pass = _arg(args, '--pass');
  if (user == null || pass == null) {
    stderr.writeln('usage: dart run test/live_api_check.dart --user <email> --pass <pw>');
    exit(64);
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: <String, dynamic>{'Accept': Headers.jsonContentType},
      validateStatus: (_) => true,
    ),
  );
  final api = TracGoApiClient(dio);

  var failures = 0;
  void check(String label, bool ok, [String detail = '']) {
    stdout.writeln('${ok ? '  ok  ' : ' FAIL '} $label${detail.isEmpty ? '' : ' — $detail'}');
    if (!ok) failures++;
  }

  // --- login -------------------------------------------------------------------
  final loginRes = await api.login(userName: user, password: pass);
  final loginData = (loginRes.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  final token = loginData['token'] as String;
  dio.options.headers['Authorization'] = 'Bearer $token';
  check('login returns a token', token.isNotEmpty);
  check('login carries the display name', loginData['name'] != null,
      'so no second /user call is needed');

  final repository = RemoteRequisitionRepository(api);

  // --- list --------------------------------------------------------------------
  final list = await repository.getRequisitions(const RequisitionListFilter());
  check('list parses', list is ApiSuccess<List<Requisition>>,
      list is ApiError<List<Requisition>> ? '${list.message}' : '');

  // --- dashboard ---------------------------------------------------------------
  final summary = await repository.getDashboardSummary();
  check('dashboard summary parses', summary is ApiSuccess<DashboardSummary>);

  // --- employee directory ------------------------------------------------------
  final directory = await repository.searchEmployees('');
  check('employee directory parses', directory is ApiSuccess<List<Employee>>,
      directory is ApiError<List<Employee>> ? '${directory.message}' : '');
  var riderIds = const <String>[];
  if (directory is ApiSuccess<List<Employee>>) {
    final all = directory.response;
    check('directory is the whole staff list', all.length > 100, '${all.length} rows');
    check('directory rows carry a staff number',
        all.every((e) => e.id.isNotEmpty && e.employeeCode.isNotEmpty));

    // The picker's only search: the endpoint ignores query parameters, so this must be
    // a local filter or it is nothing.
    final byCode = await repository.searchEmployees(all.first.employeeCode);
    check(
      'search matches on staff number, not just name',
      byCode is ApiSuccess<List<Employee>> &&
          byCode.response.any((e) => e.id == all.first.id),
      'searched ${all.first.employeeCode}',
    );

    // Nothing in the directory matches this, so it exercises the empty-result path the
    // picker has to render as "no matches" rather than as a silent nothing.
    final noMatch = await repository.searchEmployees('ZZQXNOMATCH');
    check('a search with no matches returns an empty list, not an error',
        noMatch is ApiSuccess<List<Employee>> && noMatch.response.isEmpty);

    // GET /user.employee_id is the only bridge from the session to a directory row.
    // If this stops resolving, the create form silently stops pre-selecting the
    // requester — a failure with no visible symptom other than an empty picker.
    // Called through the raw client rather than the auth repository, which would drag
    // in secure storage this script has no plugin bindings for.
    final accountRes = await api.getAuthenticatedUser();
    final accountBody = accountRes.data;
    if (accountBody is Map<String, dynamic>) {
      final employeeId = UserMapper.accountFromJson(accountBody).employeeId;
      check('GET /user.employee_id resolves to a directory row',
          employeeId != null && all.any((e) => e.id == employeeId), 'employee_id=$employeeId');
    } else {
      check('GET /user returns a bare JSON object', false, '${accountRes.statusCode}');
    }

    riderIds = all.take(2).map((e) => e.id).toList();
  }

  // --- length rules ------------------------------------------------------------
  // Not decoration: these are enforced only by the server, so a silent relaxation or
  // tightening would otherwise surface as a 422 in a user's face.
  final tooShort = await repository.submitRequisition(
    _passengerRequest(riderIds, purpose: 'ab'),
  );
  check(
    'purpose under 3 characters is rejected',
    tooShort is ApiError<Requisition> && tooShort.errorCode == 422,
    tooShort is ApiError<Requisition> ? '${tooShort.fieldErrors}' : 'accepted',
  );
  final tooLong = await repository.submitRequisition(
    _passengerRequest(riderIds, purpose: 'A' * 201),
  );
  check(
    'purpose over 200 characters is rejected',
    tooLong is ApiError<Requisition> && tooLong.errorCode == 422,
    tooLong is ApiError<Requisition> ? '${tooLong.fieldErrors}' : 'accepted',
  );

  // --- create (passenger) ------------------------------------------------------
  final passenger = await repository.submitRequisition(_passengerRequest(riderIds));
  check('passenger create accepted', passenger is ApiSuccess<Requisition>,
      passenger is ApiError<Requisition> ? '${passenger.message} ${passenger.fieldErrors ?? ''}' : '');

  // --- create (logistics) ------------------------------------------------------
  final logistics = await repository.submitRequisition(
    NewRequisitionRequest.logistics(
      pickupDateTime: DateTime.now().add(const Duration(days: 7)),
      pickupLocation: 'Test',
      dropLocation: 'Test',
      remarks: 'Test',
      vehicleType: VehicleType.coverVan,
      customerName: 'Test',
      userDepartment: 'Test',
      loadingCapacity: LoadingCapacity.ton2,
      goodsWeight: 'Test',
      storeName: 'Test',
      goodsDetails: 'Test',
    ),
  );
  check('logistics create accepted', logistics is ApiSuccess<Requisition>,
      logistics is ApiError<Requisition> ? '${logistics.message} ${logistics.fieldErrors ?? ''}' : '');

  // --- round-trip fidelity + cleanup -------------------------------------------
  for (final created in [passenger, logistics]) {
    if (created is! ApiSuccess<Requisition>) continue;
    final row = created.response;
    check('created row keeps its fields (${row.type.name})',
        row.pickupLocation == 'Test' && row.status == RequisitionStatus.pending);

    final fetched = await repository.getRequisition(row.id);
    check('detail fetch parses (${row.type.name})', fetched is ApiSuccess<Requisition>);
    if (fetched is ApiSuccess<Requisition>) {
      final detail = fetched.response;
      // Detail carries fields the list does not; the audit log is the one whose shape
      // is actually confirmed, and every requisition has at least its creation entry.
      check('detail carries an audit log (${row.type.name})', detail.auditLog.isNotEmpty,
          '${detail.auditLog.length} entries');
      check('detail carries the requester department (${row.type.name})',
          detail.departmentName != null, '${detail.departmentName}');
      // The rider list comes back under `employees`, not the `employee_id` it was sent
      // as. If that key is ever renamed this is the check that catches it — and the
      // consequence of missing it is severe, because PUT replaces the whole list, so an
      // edit form seeded from an empty read wipes the riders off someone's trip.
      final details = detail.details;
      if (details is PassengerDetails) {
        check('detail reads the riders back (${row.type.name})',
            details.employeeIds.length == riderIds.length,
            'sent ${riderIds.length}, read ${details.employeeIds.length}');
      }
    }

    // --- PUT ---------------------------------------------------------------------
    final edited = await repository.updateRequisition(
      row.id,
      _editedRequest(row),
    );
    check('update accepted (${row.type.name})', edited is ApiSuccess<Requisition>,
        edited is ApiError<Requisition>
            ? '${edited.message} ${edited.fieldErrors ?? ''}'
            : '');
    if (edited is ApiSuccess<Requisition>) {
      check('update actually changed the row (${row.type.name})',
          edited.response.dropLocation == 'Test Updated',
          'drop=${edited.response.dropLocation}');
      check('update preserved the requisition type (${row.type.name})',
          edited.response.type == row.type);
    }

    final cancelled = await repository.cancelRequisition(row.id);
    check('cancel succeeds (${row.type.name})', cancelled is ApiSuccess<void>);

    final again = await repository.cancelRequisition(row.id);
    check('second cancel reports 409 (${row.type.name})',
        again is ApiError<void> && again.errorCode == 409);
  }

  // --- error mapping -----------------------------------------------------------
  final missing = await repository.getRequisition('99999999');
  check('unknown id maps to 404', missing is ApiError<Requisition> && missing.errorCode == 404);

  // --- logout ------------------------------------------------------------------
  // Last, and it has to be: it destroys the token every check above depends on. The
  // contract (`Auth > Logout`) claims a 200 and that the same token 401s afterwards —
  // both halves are asserted, because a 200 alone would not prove the revoke happened.
  final logoutRes = await api.logout();
  check('logout answers 200', logoutRes.statusCode == 200, 'got ${logoutRes.statusCode}');
  final logoutBody = logoutRes.data;
  check(
    'logout returns the standard success envelope',
    logoutBody is Map && logoutBody['success'] == true,
    'body=$logoutBody',
  );

  final afterLogout = await repository.getRequisitions(const RequisitionListFilter());
  check('logout revokes the token server-side', afterLogout is ApiLogout<List<Requisition>>,
      'a request with the revoked token must map to ApiLogout (401)');

  // The app can reach this: two sign-out taps, or a sign-out while a 401 is already in
  // flight. It must stay a clean 401 rather than a 500 the client would surface as an
  // unexplained error.
  final secondLogout = await api.logout();
  check('logging out twice is a 401, not a server error',
      secondLogout.statusCode == 401, 'got ${secondLogout.statusCode}');

  stdout.writeln(failures == 0 ? '\nall checks passed' : '\n$failures check(s) failed');
  exit(failures == 0 ? 0 : 1);
}

/// The baseline passenger body, with the riders the directory actually returned.
///
/// `employee_id` is required on every passenger requisition now, and must hold exactly
/// `no_of_person` distinct active ids — so both come from one list and cannot disagree.
/// Every string is at least 3 characters because the server's `min:3` rule would
/// otherwise mask whatever this call was meant to test.
NewRequisitionRequest _passengerRequest(
  List<String> riderIds, {
  String purpose = 'Test',
}) {
  return NewRequisitionRequest.passenger(
    pickupDateTime: DateTime.now().add(const Duration(days: 7)),
    pickupLocation: 'Test',
    dropLocation: 'Test',
    remarks: 'Test',
    usedType: UsedType.pickupAndDrop,
    customerName: 'Test',
    numberOfPersons: riderIds.length,
    requiredFor: RequiredFor.ownUser,
    userType: RequisitionUserType.internal,
    employeeIds: riderIds,
    purpose: purpose,
  );
}

/// Rebuilds a write request from an existing requisition with one field changed, so a
/// successful PUT is distinguishable from a no-op.
NewRequisitionRequest _editedRequest(Requisition row) {
  final details = row.details;
  return switch (details) {
    PassengerDetails() => NewRequisitionRequest.passenger(
        pickupDateTime: row.pickupDateTime,
        pickupLocation: row.pickupLocation,
        dropLocation: 'Test Updated',
        remarks: row.remarks,
        usedType: details.usedType,
        customerName: details.customerName,
        // Both from the same list, and both mandatory: PUT replaces the rider list
        // outright, so omitting `employee_id` here would not "leave them alone" — it
        // would be a 422 for a zero-rider trip.
        numberOfPersons: details.employeeIds.length,
        requiredFor: details.requiredFor,
        userType: details.userType,
        employeeIds: details.employeeIds,
        purpose: details.purpose,
      ),
    LogisticsDetails() => NewRequisitionRequest.logistics(
        pickupDateTime: row.pickupDateTime,
        pickupLocation: row.pickupLocation,
        dropLocation: 'Test Updated',
        remarks: row.remarks,
        vehicleType: details.vehicleType,
        customerName: details.customerName,
        userDepartment: details.userDepartment,
        loadingCapacity: details.loadingCapacity,
        goodsWeight: details.goodsWeight,
        storeName: details.storeName,
        goodsDetails: details.goodsDetails,
      ),
  };
}

String? _arg(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}
