import '../../core/api_result.dart';
import '../model/requisition.dart';
import '../repository/requisition_repository.dart';

class GetRequisitionUseCase {
  GetRequisitionUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<Requisition>> call(String id) => _repository.getRequisition(id);
}
