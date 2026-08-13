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
import 'package:tmss/core/api_config.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/data/remote/tmss_api_client.dart';
import 'package:tmss/data/repository/remote_requisition_repository.dart';
import 'package:tmss/domain/model/requisition.dart';

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
  final api = TmssApiClient(dio);

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

  // --- create (passenger) ------------------------------------------------------
  final passenger = await repository.submitRequisition(
    NewRequisitionRequest.passenger(
      pickupDateTime: DateTime.now().add(const Duration(days: 7)),
      pickupLocation: 'Test',
      dropLocation: 'Test',
      remarks: 'Test',
      usedType: UsedType.pickupAndDrop,
      customerName: 'Test',
      numberOfPersons: 1,
      requiredFor: RequiredFor.ownUser,
      userType: RequisitionUserType.internal,
      purpose: 'Test',
    ),
  );
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

  await api.logout();
  final afterLogout = await repository.getRequisitions(const RequisitionListFilter());
  check('logout revokes the token server-side', afterLogout is ApiLogout<List<Requisition>>);

  stdout.writeln(failures == 0 ? '\nall checks passed' : '\n$failures check(s) failed');
  exit(failures == 0 ? 0 : 1);
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
        numberOfPersons: details.numberOfPersons,
        requiredFor: details.requiredFor,
        userType: details.userType,
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
