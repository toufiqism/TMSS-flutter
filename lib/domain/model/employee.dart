import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';

@freezed
abstract class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String name,
    required String employeeCode,
    required String designation,
    required String department,
    required String company,
  }) = _Employee;
}
