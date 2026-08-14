import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_config.dart';
import '../core/session_expiration_handler.dart';
import '../data/local/session_local_data_source.dart';
import '../data/remote/auth_interceptor.dart';
import '../data/remote/tmss_api_client.dart';
import '../data/repository/remote_auth_repository.dart';
import '../data/repository/remote_requisition_repository.dart';
import '../domain/model/user.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/repository/requisition_repository.dart';
import '../domain/usecase/cancel_requisition_use_case.dart';
import '../domain/usecase/get_dashboard_summary_use_case.dart';
import '../domain/usecase/get_requisition_use_case.dart';
import '../domain/usecase/get_requisitions_use_case.dart';
import '../domain/usecase/get_user_account_use_case.dart';
import '../domain/usecase/login_use_case.dart';
import '../domain/usecase/logout_use_case.dart';
import '../domain/usecase/observe_session_use_case.dart';
import '../domain/usecase/search_employees_use_case.dart';
import '../domain/usecase/submit_requisition_use_case.dart';
import '../domain/usecase/update_requisition_use_case.dart';

final sessionLocalDataSourceProvider = Provider<SessionLocalDataSource>((ref) {
  final dataSource = SessionLocalDataSource();
  // The data source owns a broadcast StreamController; without this it outlives the
  // provider that created it.
  ref.onDispose(dataSource.dispose);
  return dataSource;
});

/// Dio, configured once.
///
/// `validateStatus: (_) => true` is deliberate: it stops Dio throwing on 4xx/5xx so
/// that every status code is interpreted in one place (`safeApiCall`) instead of being
/// split across a return path and a catch block.
final dioProvider = Provider<Dio>((ref) {
  final sessionLocalDataSource = ref.watch(sessionLocalDataSourceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // `Accept: application/json` is not optional against Laravel. Without it the
      // framework's `expectsJson()` is false and it answers auth and validation
      // failures with an HTML redirect instead of the JSON error envelope — the error
      // mapper would then see an unparseable body where a 401 or 422 should be.
      headers: <String, dynamic>{'Accept': Headers.jsonContentType},
      validateStatus: (_) => true,
    ),
  );

  dio.interceptors.add(AuthInterceptor(() => sessionLocalDataSource.currentToken));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // Redacting rather than just gating on kDebugMode: the login body contains a
        // plaintext password, and debug output is not private — it goes to the console,
        // to `flutter run` transcripts, and to CI logs. There is no reason a developer
        // ever needs to see it.
        logPrint: (entry) => debugPrint(_redactSecrets(entry.toString())),
      ),
    );
  }

  ref.onDispose(dio.close);
  return dio;
});

/// Masks credential-bearing values in debug log lines.
///
/// `replaceAllMapped`, not `replaceAll`: Dart's `replaceAll` takes a literal
/// replacement and does **not** expand `$1`, so the group-reference form silently wrote
/// the characters `$1` into the log and destroyed the surrounding context instead of
/// masking just the secret.
String _redactSecrets(String line) {
  String mask(RegExp pattern, String input) =>
      input.replaceAllMapped(pattern, (m) => '${m.group(1)}********');

  var result = line;
  result = mask(RegExp(r'(password:\s*)[^,}\s]+'), result);
  result = mask(RegExp(r'("password"\s*:\s*")[^"]*'), result);
  result = mask(RegExp(r'(token:\s*)[^,}\s]+'), result);
  result = mask(RegExp(r'("token"\s*:\s*")[^"]*'), result);
  result = mask(RegExp(r'(Bearer\s+)\S+'), result);
  return result;
}

final tmssApiClientProvider = Provider<TmssApiClient>((ref) {
  return TmssApiClient(ref.watch(dioProvider));
});

/// Riverpod providers ARE the DI graph. These two bindings are the seam: the fake
/// in-memory repositories that stood in before the contract landed have been replaced
/// by the Dio-backed implementations, and nothing above this file changed.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(
    ref.watch(tmssApiClientProvider),
    ref.watch(sessionLocalDataSourceProvider),
  );
});

final requisitionRepositoryProvider = Provider<RequisitionRepository>((ref) {
  return RemoteRequisitionRepository(ref.watch(tmssApiClientProvider));
});

final sessionExpirationHandlerProvider = Provider<SessionExpirationHandler>((ref) {
  return SessionExpirationHandler(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final getUserAccountUseCaseProvider = Provider<GetUserAccountUseCase>((ref) {
  return GetUserAccountUseCase(ref.watch(authRepositoryProvider));
});

final observeSessionUseCaseProvider = Provider<ObserveSessionUseCase>((ref) {
  return ObserveSessionUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>((ref) {
  return GetDashboardSummaryUseCase(ref.watch(requisitionRepositoryProvider));
});

final getRequisitionsUseCaseProvider = Provider<GetRequisitionsUseCase>((ref) {
  return GetRequisitionsUseCase(ref.watch(requisitionRepositoryProvider));
});

final getRequisitionUseCaseProvider = Provider<GetRequisitionUseCase>((ref) {
  return GetRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final submitRequisitionUseCaseProvider = Provider<SubmitRequisitionUseCase>((ref) {
  return SubmitRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final updateRequisitionUseCaseProvider = Provider<UpdateRequisitionUseCase>((ref) {
  return UpdateRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final cancelRequisitionUseCaseProvider = Provider<CancelRequisitionUseCase>((ref) {
  return CancelRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final searchEmployeesUseCaseProvider = Provider<SearchEmployeesUseCase>((ref) {
  return SearchEmployeesUseCase(ref.watch(requisitionRepositoryProvider));
});

/// Session-gated redirect (nav/app_router.dart) and the drawer header (AppShell) both
/// watch this.
final sessionStreamProvider = StreamProvider<Session?>((ref) {
  return ref.watch(observeSessionUseCaseProvider)();
});
