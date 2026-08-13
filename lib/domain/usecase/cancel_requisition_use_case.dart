import '../../core/api_result.dart';
import '../repository/requisition_repository.dart';

class CancelRequisitionUseCase {
  CancelRequisitionUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<void>> call(String id) => _repository.cancelRequisition(id);
}
