import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/data/remote/tracgo_api_client.dart';
import 'package:tracgo/data/repository/remote_requisition_repository.dart';
import 'package:tracgo/domain/model/employee.dart';

class MockTracGoApiClient extends Mock implements TracGoApiClient {}

/// Synthetic directory in the live response's shape — never the real 537 records.
Response<dynamic> _employees(List<Map<String, dynamic>> rows, {int status = 200}) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/requisitions/employees'),
      statusCode: status,
      data: {'success': true, 'message': 'OK', 'data': rows},
    );

Map<String, dynamic> _row(int id, String name, {String dept = 'Operation'}) => {
      'id': id,
      'id_no': 'E-$id',
      'full_name': name,
      'designation_name': 'Engineer',
      'department_name': dept,
      'company_name': 'Synthetic Co.',
    };

final _directory = [
  _row(1036, 'Abul Kalam'),
  _row(1404, 'Barin Chowdhury', dept: 'Logistics'),
  _row(2872, 'Chandan Das'),
];

void main() {
  late MockTracGoApiClient api;
  late RemoteRequisitionRepository repository;

  setUp(() {
    api = MockTracGoApiClient();
    repository = RemoteRequisitionRepository(api);
  });

  List<Employee> unwrap(ApiResult<List<Employee>> result) =>
      (result as ApiSuccess<List<Employee>>).response;

  test('an empty query returns the whole directory', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    final result = await repository.searchEmployees('');

    expect(unwrap(result).map((e) => e.id), ['1036', '1404', '2872']);
  });

  test('the directory is fetched once and then served from cache', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    await repository.searchEmployees('');
    await repository.searchEmployees('ab');
    await repository.searchEmployees('cha');

    // The endpoint is unpaginated and ~146KB; searching per keystroke over the network
    // is precisely what this cache exists to prevent.
    verify(api.listEmployees).called(1);
  });

  test('concurrent first searches share one fetch instead of racing', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    await Future.wait([
      repository.searchEmployees('a'),
      repository.searchEmployees('b'),
      repository.searchEmployees('c'),
    ]);

    verify(api.listEmployees).called(1);
  });

  test('filters on name, code, designation and department', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    expect(unwrap(await repository.searchEmployees('barin')).single.id, '1404');
    expect(unwrap(await repository.searchEmployees('E-2872')).single.id, '2872');
    expect(unwrap(await repository.searchEmployees('logistics')).single.id, '1404');
    expect(unwrap(await repository.searchEmployees('engineer')), hasLength(3));
  });

  test('search is case-insensitive and ignores surrounding whitespace', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    expect(unwrap(await repository.searchEmployees('  ABUL ')).single.id, '1036');
  });

  test('no match is an empty list, not an error', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));

    expect(unwrap(await repository.searchEmployees('nobody')), isEmpty);
  });

  test('invalidating the cache forces the next search to refetch', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(_directory));
    await repository.searchEmployees('');

    repository.invalidateEmployeeCache();
    await repository.searchEmployees('');

    // This is the stale-directory recovery path: a 422 naming an inactive employee is
    // evidence the cached list is out of date.
    verify(api.listEmployees).called(2);
  });

  test('a failed fetch is not cached, so a later search retries', () async {
    var call = 0;
    when(api.listEmployees).thenAnswer((_) async {
      call++;
      return call == 1 ? _employees(const [], status: 500) : _employees(_directory);
    });

    final failure = await repository.searchEmployees('');
    expect(failure, isA<ApiError<List<Employee>>>());

    final retry = await repository.searchEmployees('');
    expect(unwrap(retry), hasLength(3));
    verify(api.listEmployees).called(2);
  });

  test('a 401 surfaces as logout rather than an empty directory', () async {
    when(api.listEmployees).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/requisitions/employees'),
        statusCode: 401,
        data: {'message': 'Unauthenticated.'},
      ),
    );

    expect(
      await repository.searchEmployees(''),
      isA<ApiLogout<List<Employee>>>(),
    );
  });

  test('an empty directory is reported as empty, not as a failure', () async {
    when(api.listEmployees).thenAnswer((_) async => _employees(const []));

    expect(unwrap(await repository.searchEmployees('')), isEmpty);
  });
}
