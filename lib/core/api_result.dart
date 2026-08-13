import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

/// Every repository call returns this instead of throwing. No `loading` branch —
/// a Future that "returns loading" is nonsensical; loading state belongs in the
/// caller's own UI state, not here. Mirrors ApiResult.kt 1:1.
@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T response) = ApiSuccess<T>;
  const factory ApiResult.error(String? message, [int? errorCode]) = ApiError<T>;
  const factory ApiResult.logout(String message, int code) = ApiLogout<T>;
  const factory ApiResult.maintenance(String message, int code) = ApiMaintenance<T>;
  const factory ApiResult.offline([
    @Default('No internet connection available') String message,
  ]) = ApiOffline<T>;
}

extension ApiResultMap<T> on ApiResult<T> {
  ApiResult<R> map<R>(R Function(T response) transform) {
    return when(
      success: (response) => ApiResult<R>.success(transform(response)),
      error: (message, code) => ApiResult<R>.error(message, code),
      logout: (message, code) => ApiResult<R>.logout(message, code),
      maintenance: (message, code) => ApiResult<R>.maintenance(message, code),
      offline: (message) => ApiResult<R>.offline(message),
    );
  }
}
