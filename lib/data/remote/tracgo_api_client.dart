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
  /// Documented in the updated contract as `Auth > Logout`: it nulls
  /// `acc_user_info.api_token` and `api_token_expires_at`, and the contract states —
  /// matching what a live probe shows — that the same token 401s on any request made
  /// afterwards.
  ///
  /// The contract sends an **empty** body with `Content-Type: application/json`, and
  /// that is reproduced literally: `contentType` is set explicitly because Dio omits
  /// the header entirely when there is no payload, and the endpoint is specified with
  /// it present. There is nothing to send — the token comes from the Authorization
  /// header, which [AuthInterceptor] attaches.
  Future<Response<dynamic>> logout() => _dio.post<dynamic>(
        '/logout',
        options: Options(contentType: Headers.jsonContentType),
      );

  /// `GET /user` — the account row behind the current token.
  ///
  /// Returns a **bare object**, with no `{success, message, data}` envelope, unlike
  /// every other endpoint here. Carries `id`, `user_name` and `employee_id` but no
  /// display name, so it is not part of the login flow.
  ///
  /// It has one job nothing else can do: `employee_id` (3035 for this account) is the
  /// **directory's surrogate `id`**, while `id` (864) is the account row. That is the
  /// only bridge between the signed-in session and a row in
  /// `GET /requisitions/employees`, and it is what lets the create form pre-select the
  /// requester as a rider. Do not substitute `id` for it — different key space,
  /// different person.
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
  /// `Pending`. Answers **201** with the complete detail object, including
  /// `audit_logs` and `employees`, so no follow-up `GET` is needed to show the result.
  ///
  /// No `X-Requisition-Source` header: the contract flagged it as an open question and
  /// the answer is that the server ignores it. Sending an invented value would have
  /// been dead weight at best, and a 422 if it turned out to be validated.
  ///
  /// **`pick_up_date_time` is not validated.** Confirmed by probe: `01/09/2026 10:00`
  /// was accepted with a 201 and stored as `0000-00-00 00:00:00`, silently destroying
  /// the requisition's own pickup time. There is no error to react to, so the format
  /// is entirely this client's responsibility — always go through
  /// `WireDateTime.format`, which emits `YYYY-MM-DD HH:mm:ss` and nothing else. The
  /// server also accepts a *past* pickup time without complaint.
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

  /// `POST /requisitions/{id}/cancel` — takes no body and returns the **full detail
  /// object** back, with `status: "Cancel"` and a third audit-log entry appended.
  ///
  /// A 409 here is routine, not exceptional: it means an approver acted while this
  /// client held a stale list. Verified — cancelling an already-cancelled requisition
  /// answers 409 `Only pending requisitions can be cancelled`.
  Future<Response<dynamic>> cancelRequisition(String id) =>
      _dio.post<dynamic>('/requisitions/$id/cancel');

  /// `GET /requisitions/employees` — the rider picker's source list.
  ///
  /// Returns every employee with an active `acc_user_info` account, in one
  /// **unpaginated** response: 537 rows / 92KB in the current sample, which is why the
  /// repository fetches it once per session and filters locally rather than calling
  /// this per keystroke.
  ///
  /// **It ignores query parameters entirely.** `search`, `q`, `keyword`, `name`,
  /// `term`, `filter`, `id_no`, `id`, `page`, `per_page` and `limit` were each probed
  /// and every one returned the identical 92KB body, byte for byte. There is no
  /// server-side search or paging to opt into, so do not add a parameter here on the
  /// assumption that one exists.
  ///
  /// Nested under `/requisitions/` despite being a directory lookup — that is the
  /// server's own path, not a mistake.
  Future<Response<dynamic>> listEmployees() =>
      _dio.get<dynamic>('/requisitions/employees');
}
