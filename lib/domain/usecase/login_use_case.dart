import '../../core/api_result.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<ApiResult<Session>> call(String username, String password) {
    return _repository.login(username, password);
  }
}
