import '../../core/api_result.dart';
import '../model/employee.dart';
import '../model/requisition.dart';

abstract interface class RequisitionRepository {
  Future<ApiResult<DashboardSummary>> getDashboardSummary();
  Future<ApiResult<List<Requisition>>> getRequisitions(RequisitionListFilter filter);
  Future<ApiResult<Requisition>> submitRequisition(NewRequisitionRequest request);
  Future<ApiResult<void>> cancelRequisition(String id);
  Future<ApiResult<List<Employee>>> searchEmployees(String query);
}
