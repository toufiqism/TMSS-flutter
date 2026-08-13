import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/core/session_expiration_handler.dart';
import 'package:tmss/di/providers.dart';
import 'package:tmss/domain/model/requisition.dart';
import 'package:tmss/domain/usecase/cancel_requisition_use_case.dart';
import 'package:tmss/domain/usecase/get_requisitions_use_case.dart';
import 'package:tmss/presentation/requisition_list/requisition_list_notifier.dart';
import 'package:tmss/presentation/requisition_list/requisition_list_state.dart';

class MockGetRequisitionsUseCase extends Mock implements GetRequisitionsUseCase {}

class MockCancelRequisitionUseCase extends Mock implements CancelRequisitionUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

Requisition _requisition(String id, {RequisitionStatus status = RequisitionStatus.pending}) {
  return Requisition(
    id: id,
    pickupDateTime: DateTime(2026, 1, 1),
    pickupLocation: 'A',
    dropLocation: 'B',
    status: status,
    details: const RequisitionDetails.passenger(
      usedType: UsedType.pickup,
      customerName: 'Test',
      numberOfPersons: 1,
      requiredFor: RequiredFor.ownUser,
      purpose: 'Purpose',
    ),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockGetRequisitionsUseCase mockGetRequisitions;
  late MockCancelRequisitionUseCase mockCancelRequisition;
  late MockSessionExpirationHandler mockSessionExpirationHandler;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const RequisitionListFilter());
  });

  setUp(() {
    mockGetRequisitions = MockGetRequisitionsUseCase();
    mockCancelRequisition = MockCancelRequisitionUseCase();
    mockSessionExpirationHandler = MockSessionExpirationHandler();
    when(() => mockSessionExpirationHandler.handle()).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      getRequisitionsUseCaseProvider.overrideWithValue(mockGetRequisitions),
      cancelRequisitionUseCaseProvider.overrideWithValue(mockCancelRequisition),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpirationHandler),
    ]);
    addTearDown(container.dispose);
  });

  test('initial refresh succeeds and a full page marks hasMore true', () async {
    final page = List.generate(requisitionListPageSize, (i) => _requisition('r$i'));
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => ApiResult.success(page));
    container.read(requisitionListNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(requisitionListNotifierProvider);
    expect(state.items.length, requisitionListPageSize);
    expect(state.hasMore, isTrue);
    expect(state.isInitialLoading, isFalse);
  });

  test('a short page (less than pageSize) marks hasMore false', () async {
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => ApiResult.success([_requisition('r1')]));
    container.read(requisitionListNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(requisitionListNotifierProvider).hasMore, isFalse);
  });

  test('load failure surfaces an error message', () async {
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => const ApiResult.error('could not load'));
    container.read(requisitionListNotifierProvider.notifier);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(requisitionListNotifierProvider).errorMessage, 'could not load');
  });

  test('cancelling a pending requisition removes it from the list on success', () async {
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => ApiResult.success([_requisition('r1')]));
    final notifier = container.read(requisitionListNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    when(() => mockCancelRequisition('r1')).thenAnswer((_) async => const ApiResult.success(null));
    await notifier.cancelRequisition('r1');

    expect(container.read(requisitionListNotifierProvider).items, isEmpty);
  });

  test('cancel failure emits ShowMessage and keeps the item in the list', () async {
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => ApiResult.success([_requisition('r1')]));
    final notifier = container.read(requisitionListNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    final events = <RequisitionListEvent>[];
    final sub = notifier.events.listen(events.add);
    when(() => mockCancelRequisition('r1')).thenAnswer((_) async => const ApiResult.error('Only pending requisitions can be cancelled'));
    await notifier.cancelRequisition('r1');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(requisitionListNotifierProvider).items, hasLength(1));
    expect(events, [isA<RequisitionListShowMessage>()]);
    await sub.cancel();
  });

  test('logout on refresh emits SessionExpired and invokes the handler', () async {
    when(() => mockGetRequisitions(any())).thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
    final notifier = container.read(requisitionListNotifierProvider.notifier);

    final events = <RequisitionListEvent>[];
    final sub = notifier.events.listen(events.add);
    await Future<void>.delayed(Duration.zero);

    verify(() => mockSessionExpirationHandler.handle()).called(1);
    expect(events, [isA<RequisitionListSessionExpired>()]);
    await sub.cancel();
  });
}
