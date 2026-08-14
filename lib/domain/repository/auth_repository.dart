import '../../core/api_result.dart';
import '../model/user.dart';

abstract interface class AuthRepository {
  Stream<Session?> get session;
  Future<ApiResult<Session>> login(String username, String password);
  Future<void> logout();

  /// The account row behind the current token, from `GET /user`. Read-only — the API
  /// exposes no way to update it.
  Future<ApiResult<UserAccount>> getAccount();
}
