import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/data/remote/tracgo_api_client.dart';
import 'package:tracgo/data/repository/remote_requisition_repository.dart';
import 'package:tracgo/domain/model/employee.dart';
import 'package:tracgo/domain/model/requisition.dart';

class MockTracGoApiClient extends Mock implements TracGoApiClient {}

Response<dynamic> _raw(dynamic body) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/requisitions'),
      statusCode: 200,
      data: body,
    );

/// The real list envelope, captured live: rows sit at `data.data` and pagination at
/// `data.pagination` — two levels deep, which is neither shape the contract suggested.
Response<dynamic> _page(List<dynamic> rows, {int? lastPage, int perPage = 100}) => _raw({
      'success': true,
      'message': 'OK',
      'data': {
        'data': rows,
        'pagination': {
          'current_page': 1,
          'per_page': perPage,
          'total': rows.length,
          'last_page': ?lastPage,
        },
      },
    });

Map<String, dynamic> _row(
  int id, {
  String status = 'Pending',
  String pickup = 'Head Office',
  String drop = 'Gulshan',
  String purpose = 'Meeting',
  String dateTime = '2026-07-25 09:30:00',
}) =>
    {
      'id': id,
      'status': status,
      'pickup_location': pickup,
      'drop_location': drop,
      'purpose': purpose,
      // The response field is `start_time`; `pick_up_date_time` is write-only.
      'start_time': dateTime,
      'created_at': dateTime,
      'req_type': 'passenger_vehicle',
    };

void main() {
  late MockTracGoApiClient api;
  late RemoteRequisitionRepository repository;

  setUp(() {
    api = MockTracGoApiClient();
    repository = RemoteRequisitionRepository(api);
  });

  void stubList(List<Response<dynamic>> pages) {
    var call = 0;
    when(() => api.listRequisitions(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async {
      final index = call < pages.length ? call : pages.length - 1;
      call++;
      return pages[index];
    });
  }

  group('getRequisitions', () {
    test('search matches across pages, not just the one the server returned first', () async {
      // The contract exposes no search parameter, so the repository fetches the window
      // and filters locally. Filtering only page 1 would hide this match entirely.
      stubList([
        _page([_row(1, purpose: 'Airport run'), _row(2, purpose: 'Client meeting')],
            lastPage: 2),
        _page([_row(3, purpose: 'Warehouse delivery')], lastPage: 2),
      ]);

      final result = await repository.getRequisitions(
        const RequisitionListFilter(searchQuery: 'warehouse'),
      );

      final items = (result as ApiSuccess<List<Requisition>>).response;
      expect(items.single.id, '3');
    });

    test('search also matches pickup and drop locations', () async {
      stubList([
        _page([_row(1, pickup: 'Tongi Depot'), _row(2, drop: 'Savar Plant')], lastPage: 1),
      ]);

      final byPickup = await repository.getRequisitions(
        const RequisitionListFilter(searchQuery: 'tongi'),
      );
      final byDrop = await repository.getRequisitions(
        const RequisitionListFilter(searchQuery: 'savar'),
      );

      expect((byPickup as ApiSuccess<List<Requisition>>).response.single.id, '1');
      expect((byDrop as ApiSuccess<List<Requisition>>).response.single.id, '2');
    });

    test('sorts locally, descending by default', () async {
      stubList([
        _page([
          _row(1, dateTime: '2026-07-20 09:00:00'),
          _row(2, dateTime: '2026-07-25 09:00:00'),
          _row(3, dateTime: '2026-07-22 09:00:00'),
        ], lastPage: 1),
      ]);

      final result = await repository.getRequisitions(const RequisitionListFilter());

      final ids = (result as ApiSuccess<List<Requisition>>).response.map((r) => r.id);
      expect(ids, ['2', '3', '1']);
    });

    test('pages the filtered set locally', () async {
      stubList([
        _page([for (var i = 1; i <= 5; i++) _row(i, dateTime: '2026-07-0$i 09:00:00')],
            lastPage: 1),
      ]);

      final page2 = await repository.getRequisitions(
        const RequisitionListFilter(page: 2, pageSize: 2, sortDescending: false),
      );

      final ids = (page2 as ApiSuccess<List<Requisition>>).response.map((r) => r.id);
      expect(ids, ['3', '4']);
    });

    test('a page beyond the end is empty rather than a range error', () async {
      stubList([_page([_row(1)], lastPage: 1)]);

      final result = await repository.getRequisitions(
        const RequisitionListFilter(page: 9, pageSize: 10),
      );

      expect((result as ApiSuccess<List<Requisition>>).response, isEmpty);
    });

    test('rows without an id are skipped instead of failing the whole page', () async {
      stubList([
        _page([_row(1), {'status': 'Pending'}, 'not even an object'], lastPage: 1),
      ]);

      final result = await repository.getRequisitions(const RequisitionListFilter());

      expect((result as ApiSuccess<List<Requisition>>).response, hasLength(1));
    });

    test('a failure mid-walk propagates instead of returning a partial list', () async {
      // Returning page 1 as if it were everything would silently truncate the user's
      // list and, worse, make a 401 look like a successful empty result.
      stubList([
        _page([for (var i = 1; i <= 100; i++) _row(i)], lastPage: 5),
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/requisitions'),
          statusCode: 401,
          data: {'success': false, 'message': 'Unauthenticated.', 'errors': null},
        ),
      ]);

      final result = await repository.getRequisitions(const RequisitionListFilter());

      expect(result, isA<ApiLogout<List<Requisition>>>());
    });
  });

  group('getDashboardSummary', () {
    test('derives counts client-side, since no summary endpoint exists', () async {
      stubList([
        _page([
          _row(1, status: 'Pending'),
          _row(2, status: 'Approved'),
          _row(3, status: 'Approved'),
          _row(4, status: 'Assigned'),
          _row(5, status: 'Rejected'),
          _row(6, status: 'Something New'),
        ], lastPage: 1),
      ]);

      final result = await repository.getDashboardSummary();

      final summary = (result as ApiSuccess<DashboardSummary>).response;
      expect(summary.allCount, 6);
      expect(summary.approvedCount, 2);
      expect(summary.assignedCount, 1);
      expect(summary.pendingCount, 1);
      expect(summary.rejectedCount, 1);
      expect(summary.recentRequisitions, hasLength(5),
          reason: 'the dashboard shows at most five recent rows');
    });

    test('sends an explicit date window, since the server defaults to only one month', () async {
      stubList([_page(<dynamic>[], lastPage: 0)]);

      await repository.getDashboardSummary();

      final captured = verify(() => api.listRequisitions(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            fromDate: captureAny(named: 'fromDate'),
            toDate: captureAny(named: 'toDate'),
          )).captured;

      expect(captured[0], isNotNull);
      expect(captured[1], isNotNull);
    });

    test('propagates a failure rather than reporting zero of everything', () async {
      stubList([
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/requisitions'),
          statusCode: 503,
        ),
      ]);

      final result = await repository.getDashboardSummary();

      expect(result, isA<ApiMaintenance<DashboardSummary>>());
    });
  });

  group('unsupported operations', () {
    test('employee search fails rather than reporting "nobody matched"', () async {
      final result = await repository.searchEmployees('rafiq');

      expect(result, isA<ApiError<List<Employee>>>());
    });

    test('a logistics submit now reaches the wire with req_type logistic_support', () async {
      when(() => api.createRequisition(any())).thenAnswer(
        (_) async => _raw({
          'success': true,
          'data': {..._row(99), 'req_type': 'logistic_support'},
        }),
      );

      final result = await repository.submitRequisition(
        NewRequisitionRequest.logistics(
          pickupDateTime: DateTime.utc(2026, 7, 25),
          pickupLocation: 'A',
          dropLocation: 'B',
          vehicleType: VehicleType.coverVan,
          customerName: 'X',
          userDepartment: 'Ops',
          loadingCapacity: LoadingCapacity.ton2,
          goodsWeight: '1.8',
          storeName: 'S',
          goodsDetails: 'D',
        ),
      );

      expect(result, isA<ApiSuccess<Requisition>>());
      final body = verify(() => api.createRequisition(captureAny())).captured.single
          as Map<String, dynamic>;
      expect(body['req_type'], 'logistic_support');
      expect(body['loading_capacity'], '2 Ton');
      expect(body['user_department'], 'Ops');
    });
  });

  group('cancelRequisition', () {
    test('succeeds without needing to understand the echoed body', () async {
      when(() => api.cancelRequisition('1'))
          .thenAnswer((_) async => _raw({'success': true, 'data': <String, dynamic>{}}));

      expect(await repository.cancelRequisition('1'), isA<ApiSuccess<void>>());
    });

    test('a 409 keeps its code so the caller knows to resync', () async {
      when(() => api.cancelRequisition('1')).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/requisitions/1/cancel'),
          statusCode: 409,
          data: {'success': false, 'message': 'Only pending requisitions can be cancelled', 'errors': null},
        ),
      );

      final result = await repository.cancelRequisition('1');

      expect((result as ApiError<void>).errorCode, 409);
    });
  });
}
