import 'package:dio/dio.dart';

/// Attaches `Authorization: Bearer <token>` to every request except the login call.
///
/// The token is read through a callback rather than captured at construction time,
/// because it changes at runtime: it does not exist before login and must stop being
/// sent after logout. Reading it per-request keeps this interceptor stateless and
/// avoids a stale token surviving a sign-out.
///
/// There is deliberately no refresh logic here, and that is now a settled design
/// rather than a gap: the backend issues Laravel Sanctum tokens that do not expire, so
/// there is nothing to refresh. A 401 therefore means the token was revoked or is
/// invalid, not that it aged out, and is handled the way the contract prescribes —
/// clear the session and route to login — via `safeApiCall` mapping it to
/// `ApiResult.logout`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final String? Function() _tokenProvider;

  static const _unauthenticatedPaths = {'/login'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_unauthenticatedPaths.contains(options.path)) {
      final token = _tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
