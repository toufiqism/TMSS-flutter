import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

/// Every repository call returns this instead of throwing. No `loading` branch —
/// a Future that "returns loading" is nonsensical; loading state belongs in the
/// caller's own UI state, not here. Mirrors ApiResult.kt 1:1, with one addition:
/// [ApiError.fieldErrors], because the API contract's 422 response carries
/// field-keyed validation messages that the create form has to pin to individual
/// inputs ("Client action: map `errors` onto the offending form fields").
///
/// There is deliberately no `conflict` branch for HTTP 409. It arrives as an
/// [ApiError] carrying `errorCode: 409`, which callers match on — adding a sixth
/// branch would force every `switch` in the app to grow a case for a condition only
/// two call sites care about.
@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T response) = ApiSuccess<T>;
  const factory ApiResult.error(
    String? message, [
    int? errorCode,
    Map<String, String>? fieldErrors,
  ]) = ApiError<T>;
  const factory ApiResult.logout(String message, int code) = ApiLogout<T>;
  const factory ApiResult.maintenance(String message, int code) = ApiMaintenance<T>;
  const factory ApiResult.offline([
    @Default('No internet connection available') String message,
  ]) = ApiOffline<T>;
}

extension ApiResultMap<T> on ApiResult<T> {
  /// Re-wraps a result's payload without touching the failure branches, so a
  /// repository can map a DTO to a domain model in one line and keep every error
  /// case — including the field errors — intact.
  ///
  /// Named `mapSuccess` rather than `map` because freezed 3 generates its own `map`
  /// pattern-matching extension on this union, and two same-named extension members
  /// are ambiguous at every call site.
  ApiResult<R> mapSuccess<R>(R Function(T response) transform) {
    return switch (this) {
      ApiSuccess<T>(:final response) => ApiResult<R>.success(transform(response)),
      ApiError<T>(:final message, :final errorCode, :final fieldErrors) =>
        ApiResult<R>.error(message, errorCode, fieldErrors),
      ApiLogout<T>(:final message, :final code) => ApiResult<R>.logout(message, code),
      ApiMaintenance<T>(:final message, :final code) =>
        ApiResult<R>.maintenance(message, code),
      ApiOffline<T>(:final message) => ApiResult<R>.offline(message),
    };
  }
}
