import '../../../domain/model/employee.dart';
import 'json_reader.dart';

/// Maps `GET /requisitions/employees` rows to the domain [Employee].
///
/// The response is the usual `{success, message, data: [...]}` envelope over rows of:
///
/// ```json
/// {
///   "id": 1073,
///   "id_no": "298",
///   "full_name": "...",
///   "designation_name": "...",
///   "department_name": "...",
///   "company_name": "..."
/// }
/// ```
///
/// **`id` and `id_no` are different things and the distinction matters.** `id` is the
/// surrogate key the write path must send in `employee_id[]` (the contract's worked
/// example uses 1036 / 1404 / 2872, which are `id` values). `id_no` is the
/// human-facing staff number — `"298"`, `"4-112"` — which is not even always numeric
/// and must never be sent as an employee id.
class EmployeeMapper {
  EmployeeMapper._();

  /// Returns null for a row with no usable `id`.
  ///
  /// Such a row cannot be selected — there would be nothing to put in `employee_id[]`
  /// — so showing it would offer the user a choice that fails validation on submit.
  static Employee? fromJson(Map<String, dynamic> json) {
    final id = json.idOrNull('id');
    if (id == null) return null;

    return Employee(
      id: id,
      name: json.stringFrom(['full_name', 'name', 'employee_name']) ?? '',
      employeeCode: json.stringFrom(['id_no', 'employee_code', 'code']) ?? '',
      designation: json.stringFrom(['designation_name', 'designation']) ?? '',
      department: json.stringFrom(['department_name', 'department']) ?? '',
      company: json.stringFrom(['company_name', 'company']) ?? '',
    );
  }

  /// Decodes the whole list response, dropping unusable rows rather than failing.
  ///
  /// One malformed row out of 537 must not cost the user the entire picker, and there
  /// is nothing they could do about it if it did.
  static List<Employee> listFromResponse(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected a JSON object from GET /requisitions/employees',
      );
    }
    return body.objectListOrEmpty('data').map(fromJson).nonNulls.toList();
  }
}
