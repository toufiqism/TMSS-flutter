import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/session_local_data_source.dart';
import '../remote/dto/json_reader.dart';
import '../remote/dto/user_mapper.dart';
import '../remote/safe_api_call.dart';
import '../remote/tmss_api_client.dart';

/// Auth against `POST /login` and `POST /logout`.
///
/// Login is a single round-trip. The contract implied two would be needed — it recorded
/// only `data.token` as confirmed — but the live response also carries `name` and
/// `designation`, which is everything the domain [Session] needs. `GET /user` is not
/// called here: it returns the account row (id, `user_name`, `employee_id`) and no
/// display name, so it would add a request and a failure mode for a user id nothing
/// sends anywhere.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._apiClient, this._sessionLocalDataSource);

  final TmssApiClient _apiClient;
  final SessionLocalDataSource _sessionLocalDataSource;

  @override
  Stream<Session?> get session => _sessionLocalDataSource.session;

  @override
  Future<ApiResult<Session>> login(String username, String password) async {
    final result = await safeApiCall<Map<String, dynamic>?>(
      () => _apiClient.login(userName: username, password: password),
      decode: (body) => body is Map<String, dynamic> ? body.mapOrNull('data') : null,
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

  /// Revokes the token server-side, then clears it locally.
  ///
  /// `POST /logout` is undocumented — it appears nowhere in the contract, which lists
  /// "is there a refresh or logout endpoint?" as an open question — but it exists and
  /// works. That matters: tokens are long-lived (a year), so without this call a
  /// signed-out device's token stayed valid for anyone who had captured it.
  ///
  /// The local clear runs regardless of what the server says. A failed revoke is worth
  /// nothing to the user standing there trying to sign out, and leaving them logged in
  /// because the network hiccuped would be strictly worse than a token that outlives
  /// the session.
  @override
  Future<void> logout() async {
    await safeApiCall<void>(_apiClient.logout, decode: (_) {});
    await _sessionLocalDataSource.clear();
  }
}
