import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/core/session_expiration_handler.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/requisition.dart';
import 'package:tracgo/domain/usecase/get_dashboard_summary_use_case.dart';
import 'package:tracgo/presentation/dashboard/dashboard_notifier.dart';
import 'package:tracgo/presentation/dashboard/dashboard_state.dart';

class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

void main() {
  late MockGetDashboardSummaryUseCase mockUseCase;
  late MockSessionExpirationHandler mockSessionExpirationHandler;
  late ProviderContainer container;

  const summary = DashboardSummary(
    allCount: 5,
    approvedCount: 2,
    assignedCount: 1,
    pendingCount: 1,
    rejectedCount: 1,
    recentRequisitions: [],
  );

  setUp(() {
    mockUseCase = MockGetDashboardSummaryUseCase();
    mockSessionExpirationHandler = MockSessionExpirationHandler();
    when(() => mockSessionExpirationHandler.handle()).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      getDashboardSummaryUseCaseProvider.overrideWithValue(mockUseCase),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpirationHandler),
    ]);
    addTearDown(container.dispose);
  });

  test('initial load succeeds and exposes the summary', () async {
    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.success(summary));
    final notifier = container.read(dashboardNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(dashboardNotifierProvider);
    expect(state, isA<DashboardSuccess>());
    expect((state as DashboardSuccess).summary.allCount, 5);
    expect(notifier, isNotNull);
  });

  test('initial load failure with no prior data surfaces DashboardError', () async {
    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.error('boom'));
    container.read(dashboardNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(dashboardNotifierProvider), isA<DashboardError>());
  });

  test('initial load while offline surfaces DashboardError with the offline message', () async {
    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.offline());
    container.read(dashboardNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(dashboardNotifierProvider) as DashboardError;
    expect(state.message, 'No internet connection available');
  });

  test('initial load under maintenance surfaces DashboardError', () async {
    when(() => mockUseCase())
        .thenAnswer((_) async => const ApiResult.maintenance('Under maintenance', 503));
    container.read(dashboardNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(dashboardNotifierProvider) as DashboardError;
    expect(state.message, 'Under maintenance');
  });

  test('refresh failure after a successful load keeps the stale summary and emits RefreshFailed', () async {
    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.success(summary));
    final notifier = container.read(dashboardNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(dashboardNotifierProvider), isA<DashboardSuccess>());

    final events = <DashboardEvent>[];
    final sub = notifier.events.listen(events.add);

    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.error('refresh failed'));
    await notifier.refresh();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(dashboardNotifierProvider) as DashboardSuccess;
    expect(state.summary.allCount, 5, reason: 'stale data must survive a failed refresh');
    expect(state.isRefreshing, isFalse);
    expect(events, [isA<DashboardRefreshFailed>()]);
    await sub.cancel();
  });

  test('logout result triggers the session expiration handler and emits SessionExpired', () async {
    when(() => mockUseCase()).thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
    final notifier = container.read(dashboardNotifierProvider.notifier);

    final events = <DashboardEvent>[];
    final sub = notifier.events.listen(events.add);

    await Future<void>.delayed(Duration.zero);

    verify(() => mockSessionExpirationHandler.handle()).called(1);
    expect(events, [isA<DashboardSessionExpired>()]);
    await sub.cancel();
  });
}
