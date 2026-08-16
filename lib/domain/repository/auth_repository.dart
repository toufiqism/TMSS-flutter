import '../../core/api_result.dart';
import '../model/user.dart';

abstract interface class AuthRepository {
  Stream<Session?> get session;
  Future<ApiResult<Session>> login(String username, String password);

  /// User-initiated sign-out: revokes the token server-side (`POST /logout`), then
  /// clears the local session.
  ///
  /// The returned result describes **only the server call**. The local session is
  /// cleared either way, so a failure here means "you are signed out on this device,
  /// but the token may still be live" — worth telling the user, not worth blocking them
  /// on.
  Future<ApiResult<void>> logout();

  /// Clears the local session **without** calling the server.
  ///
  /// For the 401 path: the token has already been rejected, so posting it back to
  /// `/logout` only buys a second 401. Not a replacement for [logout] — a user who
  /// taps Log Out wants the token revoked, not just forgotten.
  Future<void> clearSession();

  /// The account row behind the current token, from `GET /user`. Read-only — the API
  /// exposes no way to update it.
  Future<ApiResult<UserAccount>> getAccount();
}
