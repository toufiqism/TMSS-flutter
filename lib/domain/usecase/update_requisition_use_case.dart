import '../../core/api_result.dart';
import '../model/requisition.dart';
import '../repository/requisition_repository.dart';

class UpdateRequisitionUseCase {
  UpdateRequisitionUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<Requisition>> call(String id, NewRequisitionRequest request) =>
      _repository.updateRequisition(id, request);
}
