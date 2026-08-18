import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/telemetry/crash_reporter.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/session_local_data_source.dart';
import '../remote/dto/json_reader.dart';
import '../remote/dto/user_mapper.dart';
import '../remote/dto/wire_date_time.dart';
import '../remote/safe_api_call.dart';
import '../remote/tracgo_api_client.dart';

/// Auth against `POST /login`, `POST /logout` and the unauthenticated password-reset
/// pair (`POST /forgot-password`, `POST /reset-password`).
///
/// Login is a single round-trip. The contract implied two would be needed — it recorded
/// only `data.token` as confirmed — but the live response also carries `name` and
/// `designation`, which is everything the domain [Session] needs.
///
/// `GET /user` is deliberately still not called on the login path. It returns the
/// account row (`id`, `user_name`, `employee_id`) and no display name, so it would buy
/// nothing the drawer or the router needs while adding a request and a failure mode to
/// the one flow that must not acquire either. Its `employee_id` *is* useful — it is the
/// only link between the session and a row in the employee directory — but only on the
/// create form, which fetches it through [getAccount] at the moment it needs it.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(
    this._apiClient,
    this._sessionLocalDataSource, {
    // Defaulted rather than required so tests and the live-API script keep their
    // two-argument construction; the real binding in `di/providers.dart` passes the
    // Firebase-backed reporter.
    // An initializing formal is impossible here: the field is private and a
    // named parameter cannot be, so the parameter and the field must differ.
    CrashReporter reporter = const NoOpCrashReporter(),
    // ignore: prefer_initializing_formals
  }) : _reporter = reporter;

  final TracGoApiClient _apiClient;
  final SessionLocalDataSource _sessionLocalDataSource;
  final CrashReporter _reporter;

  @override
  Stream<Session?> get session => _sessionLocalDataSource.session;

  @override
  Future<ApiResult<Session>> login(String username, String password) async {
    final result = await safeApiCall<Map<String, dynamic>?>(
      () => _apiClient.login(userName: username, password: password),
      decode: (body) => body is Map<String, dynamic> ? body.mapOrNull('data') : null,
      reporter: _reporter,
      operation: 'POST /login',
    );

    switch (result) {
      case ApiSuccess<Map<String, dynamic>?>(:final response):
        final token = response?.stringOrNull('token');
        if (response == null || token == null || token.isEmpty) {
          // A 200 with no token is a contract mismatch, not bad credentials — saying
          // "wrong password" here would send the user chasing the wrong problem.
          return const ApiResult.error(NetworkMessages.unexpectedResponse);
        }
        final session = Session(
          token: token,
          user: UserMapper.fromLoginData(response, username: username),
          // Dhaka wall-clock, not UTC — `expires_at` tracks the same clock as
          // `start_time`, unlike `created_at`. Verified against a live login: the token
          // minted at 00:32 Dhaka reported expires_at 00:32:59 a year on.
          expiresAt: WireDateTime.parse(response.stringOrNull('expires_at')),
        );
        await _sessionLocalDataSource.save(session);
        return ApiResult.success(session);
      case ApiError<Map<String, dynamic>?>(
          :final message,
          :final errorCode,
          :final fieldErrors,
        ):
        return ApiResult.error(message, errorCode, fieldErrors);
      case ApiLogout<Map<String, dynamic>?>(:final message):
        // A 401 from /login means bad credentials, not an expired session. Mapping it
        // to `logout` would bounce the user to the screen they are already on.
        return ApiResult.error(message, 401);
      case ApiMaintenance<Map<String, dynamic>?>(:final message, :final code):
        return ApiResult.maintenance(message, code);
      case ApiOffline<Map<String, dynamic>?>(:final message):
        return ApiResult.offline(message);
    }
  }

  @override
  Future<ApiResult<UserAccount>> getAccount() {
    return safeApiCall<UserAccount>(
      _apiClient.getAuthenticatedUser,
      // Bare object, not the {success, message, data} envelope every other endpoint
      // uses — so the whole body *is* the account.
      decode: (body) {
        if (body is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object from GET /user');
        }
        return UserMapper.accountFromJson(body);
      },
      reporter: _reporter,
      operation: 'GET /user',
    );
  }

  /// Revokes the token server-side, then clears it locally.
  ///
  /// `POST /logout` is documented in the updated contract (`Auth > Logout`): it nulls
  /// `acc_user_info.api_token` and `api_token_expires_at`, and the same token 401s on
  /// any request afterwards. That matters because tokens are long-lived — roughly a
  /// year — so without this call a signed-out device's token stayed valid for anyone
  /// who had captured it.
  ///
  /// The local clear runs regardless of what the server says, and the result is
  /// returned rather than swallowed so the caller can say so. Leaving the user signed
  /// in because the network hiccuped would be strictly worse than a token that outlives
  /// the session.
  @override
  Future<ApiResult<void>> logout() async {
    final result = await safeApiCall<void>(
      _apiClient.logout,
      decode: (_) {},
      reporter: _reporter,
      operation: 'POST /logout',
    );
    await _sessionLocalDataSource.clear();

    // A 401 here is not a failure to report: it means the token was already dead, which
    // is precisely the state this call exists to reach. Reported as an error it would
    // warn the user about a revoke that did not need doing — and `safeApiCall` maps 401
    // to `logout`, which the caller would otherwise have to special-case anyway.
    if (result is ApiLogout<void>) return const ApiResult.success(null);
    return result;
  }

  /// Step 1 of the reset flow. See [AuthRepository.requestPasswordReset].
  @override
  Future<ApiResult<String>> requestPasswordReset(String userName) async {
    final result = await safeApiCall<Map<String, dynamic>?>(
      () => _apiClient.forgotPassword(userName: userName),
      decode: (body) => body is Map<String, dynamic> ? body : null,
      reporter: _reporter,
      operation: 'POST /forgot-password',
    );
    return _passwordResetOutcome(result, NetworkMessages.passwordResetCodeSent);
  }

  /// Step 2 of the reset flow. See [AuthRepository.resetPassword].
  ///
  /// Nothing is written locally on success. The account has no session on this device —
  /// that is why the user is here — and the token this invalidates server-side belongs
  /// to whatever device still holds one.
  @override
  Future<ApiResult<String>> resetPassword({
    required String userName,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await safeApiCall<Map<String, dynamic>?>(
      () => _apiClient.resetPassword(
        userName: userName,
        otpCode: otpCode,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
      decode: (body) => body is Map<String, dynamic> ? body : null,
      reporter: _reporter,
      operation: 'POST /reset-password',
    );
    return _passwordResetOutcome(result, NetworkMessages.passwordResetComplete);
  }

  /// Collapses a decoded reset-flow envelope to the message the UI shows.
  ///
  /// Two things it does that a bare `mapSuccess` would not:
  ///
  /// * **Honours `success: false` on a 200.** The contract tells callers to branch on
  ///   the payload rather than on the message text, and the payload's own flag is the
  ///   most direct form of that. Every documented failure is a 422, so this should
  ///   never fire — but treating a self-declared failure as a success would tell the
  ///   user their password had been changed when it had not, which is the one outcome
  ///   here worth defending against.
  /// * **Never returns `logout`.** These endpoints are unauthenticated, so a 401 cannot
  ///   mean "your session ended"; routing on it would throw the user out of the flow
  ///   they entered *because* they have no session.
  ApiResult<String> _passwordResetOutcome(
    ApiResult<Map<String, dynamic>?> result,
    String fallbackMessage,
  ) {
    switch (result) {
      case ApiSuccess<Map<String, dynamic>?>(:final response):
        final message = response?.stringOrNull('message');
        if (response?['success'] == false) {
          return ApiResult.error(message ?? NetworkMessages.generic, 200);
        }
        return ApiResult.success(message ?? fallbackMessage);
      case ApiError<Map<String, dynamic>?>(
          :final message,
          :final errorCode,
          :final fieldErrors,
        ):
        return ApiResult.error(message, errorCode, fieldErrors);
      case ApiLogout<Map<String, dynamic>?>(:final message):
        return ApiResult.error(message, 401);
      case ApiMaintenance<Map<String, dynamic>?>(:final message, :final code):
        return ApiResult.maintenance(message, code);
      case ApiOffline<Map<String, dynamic>?>(:final message):
        return ApiResult.offline(message);
    }
  }

  /// Local-only clear for the session-expired path. No network call: see
  /// [AuthRepository.clearSession].
  @override
  Future<void> clearSession() => _sessionLocalDataSource.clear();
}
