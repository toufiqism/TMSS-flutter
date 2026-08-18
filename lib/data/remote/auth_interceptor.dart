import 'package:dio/dio.dart';

/// Attaches `Authorization: Bearer <token>` to every request except the unauthenticated
/// ones (login and the two password-reset steps).
///
/// The token is read through a callback rather than captured at construction time,
/// because it changes at runtime: it does not exist before login and must stop being
/// sent after logout. Reading it per-request keeps this interceptor stateless and
/// avoids a stale token surviving a sign-out.
///
/// There is deliberately no refresh logic here, and no refresh endpoint exists to build
/// it against. Tokens *do* expire — the login response carries `expires_at`, roughly a
/// year out — but that lifetime is long enough that expiry-in-session is not a real
/// case, and `SessionLocalDataSource` already declines to hand out a token past its
/// stated expiry. A 401 therefore means revoked or invalid, and is handled the way the
/// contract prescribes — clear the session and route to login — via `safeApiCall`
/// mapping it to `ApiResult.logout`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final String? Function() _tokenProvider;

  /// The endpoints that take no bearer token.
  ///
  /// The password-reset pair belongs here for a concrete reason, not for tidiness: the
  /// flow is reached from the login screen, and a session that has *expired* rather
  /// than been signed out can still leave a token in secure storage. Sending it would
  /// attach a dead credential to a request that is specified as unauthenticated, and
  /// Laravel answers a bad bearer token with a 401 before the route ever runs — which
  /// `safeApiCall` maps to `logout`, bouncing the user out of a flow they are only in
  /// because they cannot sign in.
  static const _unauthenticatedPaths = {
    '/login',
    '/forgot-password',
    '/reset-password',
  };

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
