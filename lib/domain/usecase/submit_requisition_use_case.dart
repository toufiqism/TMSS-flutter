import '../../core/api_result.dart';
import '../model/requisition.dart';
import '../repository/requisition_repository.dart';

class SubmitRequisitionUseCase {
  SubmitRequisitionUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<Requisition>> call(NewRequisitionRequest request) {
    return _repository.submitRequisition(request);
  }
}
