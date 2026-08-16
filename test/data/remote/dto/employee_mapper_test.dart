import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/data/remote/dto/employee_mapper.dart';

/// Synthetic rows in the real response's shape. The live directory is 537 real staff
/// records and never belongs in source — see CLAUDE.md.
Map<String, dynamic> row({
  Object? id = 1073,
  String idNo = '298',
  String fullName = 'Synthetic Person One',
}) =>
    <String, dynamic>{
      'id': id,
      'id_no': idNo,
      'full_name': fullName,
      'designation_name': 'Assistant Engineer',
      'department_name': 'Operation',
      'company_name': 'Synthetic Engineering Ltd.',
    };

Map<String, dynamic> envelope(List<Map<String, dynamic>> data) =>
    <String, dynamic>{'success': true, 'message': 'OK', 'data': data};

void main() {
  test('maps the documented row shape onto the domain model', () {
    final employees = EmployeeMapper.listFromResponse(envelope([row()]));

    expect(employees, hasLength(1));
    final employee = employees.single;
    expect(employee.id, '1073');
    expect(employee.employeeCode, '298');
    expect(employee.name, 'Synthetic Person One');
    expect(employee.designation, 'Assistant Engineer');
    expect(employee.department, 'Operation');
    expect(employee.company, 'Synthetic Engineering Ltd.');
  });

  test('id and id_no are kept distinct — only id is submittable', () {
    // The write path puts `id` in employee_id[]; id_no is a staff number that is not
    // always numeric ("4-112") and would be rejected.
    final employee =
        EmployeeMapper.listFromResponse(envelope([row(id: 651, idNo: '4-112')])).single;

    expect(employee.id, '651');
    expect(employee.employeeCode, '4-112');
    expect(int.tryParse(employee.id), isNotNull);
  });

  test('a row with no usable id is dropped, not rendered as unselectable', () {
    final employees = EmployeeMapper.listFromResponse(
      envelope([row(), <String, dynamic>{'full_name': 'No Id Here'}]),
    );

    expect(employees, hasLength(1));
    expect(employees.single.id, '1073');
  });

  test('one malformed row does not cost the user the whole picker', () {
    final employees = EmployeeMapper.listFromResponse(
      envelope([row(id: 1), <String, dynamic>{'id': null}, row(id: 2)]),
    );

    expect(employees.map((e) => e.id), ['1', '2']);
  });

  test('missing optional names become empty strings rather than nulls', () {
    final employee = EmployeeMapper.listFromResponse(
      envelope([
        <String, dynamic>{'id': 5, 'full_name': 'Only A Name'},
      ]),
    ).single;

    expect(employee.name, 'Only A Name');
    expect(employee.designation, isEmpty);
    expect(employee.department, isEmpty);
    expect(employee.company, isEmpty);
  });

  test('an empty directory decodes to an empty list, not an error', () {
    expect(EmployeeMapper.listFromResponse(envelope([])), isEmpty);
  });

  test('a non-object body is a contract mismatch and throws', () {
    // safeApiCall turns this into ApiError(unexpectedResponse) and a Crashlytics
    // non-fatal, which is the correct treatment for a 2xx the client cannot read.
    expect(
      () => EmployeeMapper.listFromResponse('not json'),
      throwsA(isA<FormatException>()),
    );
  });
}
