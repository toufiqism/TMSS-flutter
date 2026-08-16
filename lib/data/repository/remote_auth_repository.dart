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

/// Auth against `POST /login` and `POST /logout`.
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

  /// Local-only clear for the session-expired path. No network call: see
  /// [AuthRepository.clearSession].
  @override
  Future<void> clearSession() => _sessionLocalDataSource.clear();
}
