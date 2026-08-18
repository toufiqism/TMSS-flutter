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

  /// `POST /forgot-password` — asks the server to email a 6-digit OTP to the address
  /// behind [userName].
  ///
  /// Unauthenticated, and **deliberately indiscriminate**: the contract specifies the
  /// same generic 200 whether or not the account exists, so that the endpoint cannot be
  /// used to enumerate registered addresses. The success payload is therefore only ever
  /// a reassurance message — it is not evidence that a mail was sent, and the UI must
  /// not claim otherwise.
  ///
  /// Returns the server's own `message` on success so the wording shown to the user is
  /// the server's, not a guess made here.
  Future<ApiResult<String>> requestPasswordReset(String userName);

  /// `POST /reset-password` — verifies the OTP from [requestPasswordReset] and writes
  /// the new password.
  ///
  /// A wrong or expired OTP arrives as a 422, i.e. an [ApiError] with `errorCode: 422`,
  /// alongside the field-keyed `errors` map when the failure is ordinary validation.
  ///
  /// On success the server invalidates any `api_token` already issued for the account.
  /// Nothing needs clearing locally — this flow only runs while signed out — but a
  /// session held on *another* device is now dead, which is the point.
  Future<ApiResult<String>> resetPassword({
    required String userName,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  });
}
