import 'package:dio/dio.dart';

/// Thin transport over the endpoints in `api-contract/tms-requisition-api.json`.
///
/// This layer knows about URLs, query parameters and headers, and nothing else — it
/// does not interpret status codes (that is `safeApiCall`) and does not map payloads
/// (that is `dto/`). Every method returns the raw [Response] so the repository can
/// decide how to read it.
///
/// The Dio instance is configured with `validateStatus: (_) => true`, so a 404 comes
/// back as a response rather than an exception. That keeps status interpretation in
/// exactly one place instead of split across a return path and a catch block.
class TracGoApiClient {
  TracGoApiClient(this._dio);

  final Dio _dio;

  /// `POST /login` — the only unauthenticated endpoint.
  Future<Response<dynamic>> login({
    required String userName,
    required String password,
  }) {
    return _dio.post<dynamic>(
      '/login',
      data: <String, dynamic>{'user_name': userName, 'password': password},
    );
  }

  /// `POST /logout` — revokes the current bearer token server-side.
  ///
  /// Undocumented: it is absent from the contract, which lists the existence of a
  /// logout endpoint as an open question. Confirmed working against the live server —
  /// it returns 200 and the token 401s immediately afterwards.
  Future<Response<dynamic>> logout() => _dio.post<dynamic>('/logout');

  /// `GET /user` — the account row behind the current token.
  ///
  /// Returns a **bare object**, with no `{success, message, data}` envelope, unlike
  /// every other endpoint here. Carries `id`, `user_name` and `employee_id` but no
  /// display name, so it is not part of the login flow; it is useful as a cheap
  /// token-validity probe.
  ///
  /// [bearerToken] overrides the stored session token. Login needs that: it has a token
  /// in hand but must not persist it yet, because persisting emits on the session
  /// stream and the router would navigate away from the login screen while the request
  /// completing that very login is still in flight.
  Future<Response<dynamic>> getAuthenticatedUser({String? bearerToken}) {
    return _dio.get<dynamic>(
      '/user',
      options: bearerToken == null
          ? null
          : Options(headers: <String, dynamic>{'Authorization': 'Bearer $bearerToken'}),
    );
  }

  /// `GET /requisitions` — the caller's own requisitions; scoping is implicit in the
  /// token, there is no owner parameter.
  ///
  /// [fromDate] and [toDate] are bare `YYYY-MM-DD` dates, deliberately a different
  /// format from the date-*time* used in request bodies. Omitting them is meaningful:
  /// the server then defaults to the last month.
  Future<Response<dynamic>> listRequisitions({
    required int page,
    required int perPage,
    String? fromDate,
    String? toDate,
  }) {
    return _dio.get<dynamic>(
      '/requisitions',
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'fdate': ?fromDate,
        'tdate': ?toDate,
      },
    );
  }

  /// `POST /requisitions` — creates a requisition owned by the caller, starting in
  /// `Pending`.
  ///
  /// No `X-Requisition-Source` header: the contract flagged it as an open question and
  /// the answer is that the server ignores it. Sending an invented value would have
  /// been dead weight at best, and a 422 if it turned out to be validated.
  Future<Response<dynamic>> createRequisition(Map<String, dynamic> body) {
    return _dio.post<dynamic>('/requisitions', data: body);
  }

  /// `GET /requisitions/{id}` — full detail including driver, vehicle and audit log.
  /// Returns 403, not 404, when the caller is not the creator.
  Future<Response<dynamic>> getRequisition(String id) =>
      _dio.get<dynamic>('/requisitions/$id');

  /// `PUT /requisitions/{id}` — full replacement of the mutable fields.
  ///
  /// Server-enforced and worth restating: `req_type` must equal the requisition's
  /// existing type (this endpoint cannot convert between types), the status must still
  /// be `Pending`, and the caller must be the creator.
  Future<Response<dynamic>> updateRequisition(String id, Map<String, dynamic> body) =>
      _dio.put<dynamic>('/requisitions/$id', data: body);

  /// `POST /requisitions/{id}/cancel` — takes no body. A 409 here is routine, not
  /// exceptional: it means an approver acted while this client held a stale list.
  Future<Response<dynamic>> cancelRequisition(String id) =>
      _dio.post<dynamic>('/requisitions/$id/cancel');
}
