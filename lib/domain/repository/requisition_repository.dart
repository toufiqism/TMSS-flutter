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
  /// Matches [query] against the active-employee directory. An empty query returns the
  /// full list.
  ///
  /// Implementations are expected to serve this from a cache: the endpoint behind it is
  /// unpaginated and has no search parameter, so a per-keystroke round trip would
  /// re-download the entire directory.
  Future<ApiResult<List<Employee>>> searchEmployees(String query);

  /// Discards any cached employee directory so the next [searchEmployees] refetches.
  ///
  /// Exists because the server can reject a submission for naming an employee who has
  /// since gone inactive — a 422 that is itself the evidence the cache is stale.
  /// Synchronous and returning nothing: it only drops state, and there is no failure
  /// mode for a caller to handle.
  void invalidateEmployeeCache();
}
