import '../../core/api_result.dart';
import '../model/requisition.dart';
import '../repository/requisition_repository.dart';

class GetRequisitionsUseCase {
  GetRequisitionsUseCase(this._repository);
  final RequisitionRepository _repository;

  Future<ApiResult<List<Requisition>>> call(RequisitionListFilter filter) {
    return _repository.getRequisitions(filter);
  }
}
