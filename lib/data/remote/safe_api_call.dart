import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
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
Future<ApiResult<T>> safeApiCall<T>(Future<Response<dynamic>> Function() call, {
  required T Function(dynamic body) decode,
}) async {
  try {
    final response = await call();
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300) {
      final body = response.data;
      if (body == null) {
        // A 2xx with no body is fine for operations whose decoder ignores it (cancel),
        // and a decoder that needs a body reports its own failure below.
        return _decodeOrError<T>(null, decode);
      }
      return _decodeOrError<T>(body, decode);
    }

    return _mapFailure<T>(status, response.data);
  } on DioException catch (e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return const ApiResult.offline();
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiResult.error(NetworkMessages.timeout);
      case DioExceptionType.badCertificate:
        return const ApiResult.error(NetworkMessages.secureConnection);
      case DioExceptionType.cancel:
        return const ApiResult.error(null);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        if (e.error is SocketException) return const ApiResult.offline();
        final status = e.response?.statusCode;
        if (status == null) return const ApiResult.error(NetworkMessages.generic);
        return _mapFailure<T>(status, e.response?.data);
    }
  } on SocketException {
    return const ApiResult.offline();
  } catch (_) {
    // Decoder bugs and genuinely unexpected failures. The exception text is
    // deliberately not shown to the user; it would be noise at best.
    return const ApiResult.error(NetworkMessages.generic);
  }
}

ApiResult<T> _decodeOrError<T>(dynamic body, T Function(dynamic body) decode) {
  try {
    return ApiResult.success(decode(body));
  } catch (_) {
    // The response was a 2xx the client could not understand. That is a contract
    // mismatch, not a user error, so it gets the generic message.
    return const ApiResult.error(NetworkMessages.unexpectedResponse);
  }
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
