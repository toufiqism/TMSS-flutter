import '../../core/api_result.dart';
import '../model/requisition.dart';
import '../repository/requisition_repository.dart';

class GetDashboardSummaryUseCase {
  GetDashboardSummaryUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<DashboardSummary>> call() => _repository.getDashboardSummary();
}
