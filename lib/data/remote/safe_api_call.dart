import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/telemetry/crash_reporter.dart';
import 'dto/json_reader.dart';

/// Wraps a Dio call and turns every outcome — including the thrown ones — into an
/// [ApiResult]. Nothing above this layer sees a `DioException`.
///
/// Status mapping follows the contract's documented client actions:
///
/// | Code | Branch | Contract's stated client action |
/// |------|--------|---------------------------------|
/// | 401  | `logout` | "clear the stored session and route to login" |
/// | 403  | `error` | "terminal — do not retry, surface as a permission message" |
/// | 404  | `error` | no requisition with that id |
/// | 409  | `error` (code 409) | "usually means the local copy is stale — refetch" |
/// | 422  | `error` + fieldErrors | "map `errors` onto the offending form fields" |
/// | 503  | `maintenance` | — |
///
/// The error envelope itself is unverified ("No error payload appears anywhere in the
/// collection"), so [_messageFrom] treats every shape as optional and falls back to a
/// generic string rather than surfacing a raw exception to the user.
///
/// ## Telemetry
///
/// Pass [reporter] and [operation] to have failures reach Crashlytics. Both are
/// optional so that tests — and any call site that has no reporter to hand — behave
/// exactly as they did before telemetry existed.
///
/// Not every failure becomes an issue in the console. The split is deliberate, because
/// a non-fatal per failed request would bury the real defects under the ones that are
/// working as designed:
///
/// - **Recorded as a non-fatal** — anything that means *something is wrong*: 5xx
///   (excluding 503, which is an announced state), timeouts, a rejected certificate, a
///   2xx body the client could not decode, and any unclassified throw.
/// - **Breadcrumb only** — anything that means *the system is behaving as specified*:
///   being offline, a cancelled request, and the documented 4xx codes (401 expiry, 403
///   permission, 404 missing, 409 stale, 422 validation) plus 503 maintenance. These
///   still appear in the trail attached to whatever is reported next, so a crash after
///   a string of 401s is still diagnosable.
///
/// [operation] is the label the console groups on, e.g. `'GET /requisitions'`. Keep it
/// free of ids and user data: it is a group key, not a log line.
Future<ApiResult<T>> safeApiCall<T>(
  Future<Response<dynamic>> Function() call, {
  required T Function(dynamic body) decode,
  CrashReporter? reporter,
  String? operation,
}) async {
  final label = operation ?? 'api call';
  try {
    final response = await call();
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300) {
      final body = response.data;
      if (body == null) {
        // A 2xx with no body is fine for operations whose decoder ignores it (cancel),
        // and a decoder that needs a body reports its own failure below.
        return _decodeOrError<T>(null, decode, reporter, label);
      }
      return _decodeOrError<T>(body, decode, reporter, label);
    }

    _reportStatus(reporter, label, status);
    return _mapFailure<T>(status, response.data);
  } on DioException catch (e, stackTrace) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        _breadcrumb(reporter, '$label: offline (${e.type.name})');
        return const ApiResult.offline();
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        // Recorded, unlike a plain connection failure: a request that reached the
        // server and then ran out of time points at the server or the payload, not at
        // the user's signal.
        _record(reporter, e, stackTrace, label, 'timeout', {'type': e.type.name});
        return const ApiResult.error(NetworkMessages.timeout);
      case DioExceptionType.badCertificate:
        _record(reporter, e, stackTrace, label, 'bad certificate', const {});
        return const ApiResult.error(NetworkMessages.secureConnection);
      case DioExceptionType.cancel:
        _breadcrumb(reporter, '$label: cancelled');
        return const ApiResult.error(null);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          _breadcrumb(reporter, '$label: offline (socket)');
          return const ApiResult.offline();
        }
        final status = e.response?.statusCode;
        if (status == null) {
          _record(reporter, e, stackTrace, label, 'transport failure', {
            'type': e.type.name,
          });
          return const ApiResult.error(NetworkMessages.generic);
        }
        _reportStatus(reporter, label, status);
        return _mapFailure<T>(status, e.response?.data);
    }
  } on SocketException {
    _breadcrumb(reporter, '$label: offline (socket)');
    return const ApiResult.offline();
  } catch (error, stackTrace) {
    // Decoder bugs and genuinely unexpected failures. The exception text is
    // deliberately not shown to the user; it would be noise at best. It is exactly
    // what telemetry wants, though — this branch is where client bugs land.
    _record(reporter, error, stackTrace, label, 'unhandled failure', const {});
    return const ApiResult.error(NetworkMessages.generic);
  }
}

ApiResult<T> _decodeOrError<T>(
  dynamic body,
  T Function(dynamic body) decode,
  CrashReporter? reporter,
  String label,
) {
  try {
    return ApiResult.success(decode(body));
  } catch (error, stackTrace) {
    // The response was a 2xx the client could not understand. That is a contract
    // mismatch, not a user error, so it gets the generic message — and a non-fatal,
    // because it is the failure mode that is invisible from the outside: the user sees
    // a vague error and the server logs a success.
    _record(reporter, error, stackTrace, label, 'response decode failed', const {});
    return const ApiResult.error(NetworkMessages.unexpectedResponse);
  }
}

/// True for statuses that indicate a defect rather than a specified outcome.
///
/// 503 is excluded even though it is 5xx: maintenance is an announced state the app
/// already handles with its own branch, so reporting it would file an issue every time
/// someone opens the app during a deploy window.
bool _isDefect(int status) => status >= 500 && status != 503;

void _reportStatus(CrashReporter? reporter, String label, int status) {
  if (reporter == null) return;
  if (_isDefect(status)) {
    unawaited(
      reporter.recordError(
        // A synthetic error object, because there is no exception here — a non-2xx
        // arrives as an ordinary response (`validateStatus: (_) => true`). The type
        // name is what Crashlytics groups on, so it stays a dedicated class rather
        // than a bare String.
        ApiStatusFailure(operation: label, statusCode: status),
        StackTrace.current,
        reason: '$label failed with HTTP $status',
        keys: {'operation': label, 'status': status},
      ),
    );
    return;
  }
  _breadcrumb(reporter, '$label: HTTP $status');
}

void _record(
  CrashReporter? reporter,
  Object error,
  StackTrace stackTrace,
  String label,
  String reason,
  Map<String, Object> keys,
) {
  if (reporter == null) return;
  unawaited(
    reporter.recordError(
      error,
      stackTrace,
      reason: '$label: $reason',
      keys: {'operation': label, ...keys},
    ),
  );
}

/// `unawaited` throughout: a request must not wait on a telemetry channel to return
/// its result, and [CrashReporter] implementations already swallow their own failures,
/// so there is nothing here for a caller to await or catch.
void _breadcrumb(CrashReporter? reporter, String message) {
  if (reporter == null) return;
  unawaited(reporter.log(message));
}

/// The error object stood up for a failing HTTP status, which arrives without an
/// exception of its own.
class ApiStatusFailure implements Exception {
  const ApiStatusFailure({required this.operation, required this.statusCode});

  final String operation;
  final int statusCode;

  @override
  String toString() => 'ApiStatusFailure($operation, HTTP $statusCode)';
}

ApiResult<T> _mapFailure<T>(int status, dynamic body) {
  final message = _messageFrom(body);
  return switch (status) {
    401 => ApiResult.logout(message ?? NetworkMessages.sessionExpired, 401),
    403 => ApiResult.error(message ?? NetworkMessages.notPermitted, 403),
    404 => ApiResult.error(message ?? NetworkMessages.notFound, 404),
    409 => ApiResult.error(message ?? NetworkMessages.stale, 409),
    422 => ApiResult.error(
        message ?? NetworkMessages.validation,
        422,
        _fieldErrorsFrom(body),
      ),
    503 => ApiResult.maintenance(message ?? NetworkMessages.maintenance, 503),
    _ => ApiResult.error(message ?? NetworkMessages.generic, status),
  };
}

String? _messageFrom(dynamic body) {
  if (body is! Map<String, dynamic>) return null;
  return body.stringFrom(['message', 'error', 'detail']);
}

/// Flattens Laravel-style `{"errors": {"field": ["msg", ...]}}` to one message per
/// field. Returns null when the payload carries nothing usable, so the caller can tell
/// "no field errors" apart from "an empty map of them".
Map<String, String>? _fieldErrorsFrom(dynamic body) {
  if (body is! Map<String, dynamic>) return null;
  final errors = body.mapOrNull('errors');
  if (errors == null || errors.isEmpty) return null;

  final flattened = <String, String>{};
  for (final entry in errors.entries) {
    final value = entry.value;
    if (value is List) {
      final first = value.whereType<String>().firstOrNull;
      if (first != null) flattened[entry.key] = first;
    } else if (value is String && value.trim().isNotEmpty) {
      flattened[entry.key] = value.trim();
    }
  }
  return flattened.isEmpty ? null : flattened;
}
