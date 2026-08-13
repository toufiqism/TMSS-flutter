import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/session_expiration_handler.dart';
import '../data/local/session_local_data_source.dart';
import '../data/repository/fake_auth_repository.dart';
import '../data/repository/fake_requisition_repository.dart';
import '../domain/model/user.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/repository/requisition_repository.dart';
import '../domain/usecase/cancel_requisition_use_case.dart';
import '../domain/usecase/get_dashboard_summary_use_case.dart';
import '../domain/usecase/get_requisitions_use_case.dart';
import '../domain/usecase/login_use_case.dart';
import '../domain/usecase/logout_use_case.dart';
import '../domain/usecase/observe_session_use_case.dart';
import '../domain/usecase/search_employees_use_case.dart';
import '../domain/usecase/submit_requisition_use_case.dart';

/// Prepared for when real endpoints exist. Base URL is a placeholder, same caveat as the
/// Android app's TmssApiService.BASE_URL — update before real network calls matter.
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com/'));
});

final sessionLocalDataSourceProvider = Provider<SessionLocalDataSource>((ref) {
  return SessionLocalDataSource();
});

/// Riverpod providers ARE the DI graph — swap these two bindings to Dio-backed
/// implementations once the real API exists; nothing above or below this file changes.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository(ref.watch(sessionLocalDataSourceProvider));
});

final requisitionRepositoryProvider = Provider<RequisitionRepository>((ref) {
  return FakeRequisitionRepository();
});

final sessionExpirationHandlerProvider = Provider<SessionExpirationHandler>((ref) {
  return SessionExpirationHandler(ref.watch(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
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

final submitRequisitionUseCaseProvider = Provider<SubmitRequisitionUseCase>((ref) {
  return SubmitRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final cancelRequisitionUseCaseProvider = Provider<CancelRequisitionUseCase>((ref) {
  return CancelRequisitionUseCase(ref.watch(requisitionRepositoryProvider));
});

final searchEmployeesUseCaseProvider = Provider<SearchEmployeesUseCase>((ref) {
  return SearchEmployeesUseCase(ref.watch(requisitionRepositoryProvider));
});

/// Session-gated redirect (nav/router.dart) and the drawer header (AppShell) both watch this.
final sessionStreamProvider = StreamProvider<Session?>((ref) {
  return ref.watch(observeSessionUseCaseProvider)();
});
