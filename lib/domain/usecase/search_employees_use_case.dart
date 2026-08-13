import '../../core/api_result.dart';
import '../model/employee.dart';
import '../repository/requisition_repository.dart';

class SearchEmployeesUseCase {
  SearchEmployeesUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<List<Employee>>> call(String query) => _repository.searchEmployees(query);
}
