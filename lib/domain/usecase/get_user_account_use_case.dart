import '../../core/api_result.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class GetUserAccountUseCase {
  GetUserAccountUseCase(this._repository);
  final AuthRepository _repository;

  Future<ApiResult<UserAccount>> call() => _repository.getAccount();
}
