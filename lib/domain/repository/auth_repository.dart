import '../../core/api_result.dart';
import '../model/user.dart';

abstract interface class AuthRepository {
  Stream<Session?> get session;
  Future<ApiResult<Session>> login(String username, String password);
  Future<void> logout();
}
