import '../../core/api_result.dart';
import '../model/employee.dart';
import '../model/requisition.dart';

abstract interface class RequisitionRepository {
  Future<ApiResult<DashboardSummary>> getDashboardSummary();
  Future<ApiResult<List<Requisition>>> getRequisitions(RequisitionListFilter filter);
  Future<ApiResult<Requisition>> submitRequisition(NewRequisitionRequest request);

  /// Full detail for one requisition, including driver, vehicle and audit log.
  /// Returns a 403-backed error when the caller is not the creator — the contract is
  /// explicit that this is *not* reported as a 404.
  Future<ApiResult<Requisition>> getRequisition(String id);

  /// Full replacement of the mutable fields. Server-gated on the requisition still
  /// being `Pending` and the caller being its creator; either failing surfaces as an
  /// error carrying 409 or 403 respectively.
  Future<ApiResult<Requisition>> updateRequisition(
    String id,
    NewRequisitionRequest request,
  );

  Future<ApiResult<void>> cancelRequisition(String id);
  Future<ApiResult<List<Employee>>> searchEmployees(String query);
}
