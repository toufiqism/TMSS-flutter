import 'dart:io';

import 'package:dio/dio.dart';

import 'api_result.dart';

/// Prepared but unused until real API endpoints exist (base URL is still a placeholder).
/// Maps 401 -> logout, 503 -> maintenance, no connectivity -> offline, everything else -> error.
/// Mirrors SafeApiCall.kt's mapping exactly.
Future<ApiResult<T>> safeApiCall<T>(Future<Response<T>> Function() call) async {
  try {
    final response = await call();
    final body = response.data;
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        body != null) {
      return ApiResult.success(body);
    }
    return switch (response.statusCode) {
      401 => const ApiResult.logout('Session expired', 401),
      503 => const ApiResult.maintenance('Under maintenance', 503),
      _ => ApiResult.error('HTTP ${response.statusCode}', response.statusCode),
    };
  } on SocketException {
    return const ApiResult.offline();
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError) {
      return const ApiResult.offline();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const ApiResult.logout('Session expired', 401);
    }
    if (statusCode == 503) {
      return const ApiResult.maintenance('Under maintenance', 503);
    }
    return ApiResult.error(e.message, statusCode);
  } catch (e) {
    return ApiResult.error(e.toString());
  }
}
