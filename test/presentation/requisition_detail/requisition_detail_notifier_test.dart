import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/core/session_expiration_handler.dart';
import 'package:tmss/di/providers.dart';
import 'package:tmss/domain/model/requisition.dart';
import 'package:tmss/domain/usecase/cancel_requisition_use_case.dart';
import 'package:tmss/domain/usecase/get_requisition_use_case.dart';
import 'package:tmss/presentation/requisition_detail/requisition_detail_notifier.dart';
import 'package:tmss/presentation/requisition_detail/requisition_detail_state.dart';

class MockGetRequisitionUseCase extends Mock implements GetRequisitionUseCase {}

class MockCancelRequisitionUseCase extends Mock implements CancelRequisitionUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

Requisition _requisition({
  String id = 'r1',
  RequisitionStatus status = RequisitionStatus.pending,
}) {
  return Requisition(
    id: id,
    pickupDateTime: DateTime(2026, 8, 20, 10),
    pickupLocation: 'Test',
    dropLocation: 'Test',
    status: status,
    details: const RequisitionDetails.passenger(
      usedType: UsedType.pickupAndDrop,
      customerName: 'Test',
      numberOfPersons: 1,
      requiredFor: RequiredFor.ownUser,
      purpose: 'Test',
    ),
    createdAt: DateTime(2026, 8, 14),
  );
}

void main() {
  late MockGetRequisitionUseCase mockGet;
  late MockCancelRequisitionUseCase mockCancel;
  late MockSessionExpirationHandler mockSessionExpiration;
  late ProviderContainer container;

  setUp(() {
    mockGet = MockGetRequisitionUseCase();
    mockCancel = MockCancelRequisitionUseCase();
    mockSessionExpiration = MockSessionExpirationHandler();
    when(() => mockSessionExpiration.handle()).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      getRequisitionUseCaseProvider.overrideWithValue(mockGet),
      cancelRequisitionUseCaseProvider.overrideWithValue(mockCancel),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpiration),
    ]);
    addTearDown(container.dispose);
    // isAutoDispose: hold a subscription so the notifier survives across awaits, the
    // same way the mounted screen does.
    container.listen(requisitionDetailNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  group('load', () {
    test('success exposes the requisition', () async {
      when(() => mockGet('r1')).thenAnswer((_) async => ApiResult.success(_requisition()));

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      final state = container.read(requisitionDetailNotifierProvider);
      expect(state, isA<RequisitionDetailSuccess>());
      expect((state as RequisitionDetailSuccess).requisition.id, 'r1');
    });

    test('a 403 is terminal, so Retry is not offered', () async {
      // The contract is explicit that the caller is not the creator and never will be.
      when(() => mockGet('r1'))
          .thenAnswer((_) async => const ApiResult.error('Forbidden', 403));

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      final state = container.read(requisitionDetailNotifierProvider)
          as RequisitionDetailError;
      expect(state.canRetry, isFalse);
    });

    test('a 404 closes the screen rather than showing an error for a dead row', () async {
      when(() => mockGet('r1'))
          .thenAnswer((_) async => const ApiResult.error('Requisition not found', 404));
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      final events = <RequisitionDetailEvent>[];
      final sub = notifier.events.listen(events.add);

      await notifier.load('r1');
      await Future<void>.delayed(Duration.zero);

      expect(events, [isA<RequisitionDetailClosed>()]);
      // State must also be set: a deep link opened as the navigation root has nothing
      // to pop to, and returning early would leave a permanent spinner.
      expect(container.read(requisitionDetailNotifierProvider),
          isA<RequisitionDetailError>());
      await sub.cancel();
    });

    test('a generic error keeps Retry available', () async {
      when(() => mockGet('r1')).thenAnswer((_) async => const ApiResult.error('boom', 500));

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      expect(
        (container.read(requisitionDetailNotifierProvider) as RequisitionDetailError)
            .canRetry,
        isTrue,
      );
    });

    test('offline surfaces the offline message', () async {
      when(() => mockGet('r1')).thenAnswer((_) async => const ApiResult.offline());

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      expect(
        (container.read(requisitionDetailNotifierProvider) as RequisitionDetailError)
            .message,
        'No internet connection available',
      );
    });

    test('maintenance surfaces the maintenance message', () async {
      when(() => mockGet('r1'))
          .thenAnswer((_) async => const ApiResult.maintenance('Under maintenance', 503));

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      expect(
        (container.read(requisitionDetailNotifierProvider) as RequisitionDetailError)
            .message,
        'Under maintenance',
      );
    });

    test('logout triggers the session handler and emits SessionExpired', () async {
      when(() => mockGet('r1'))
          .thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      final events = <RequisitionDetailEvent>[];
      final sub = notifier.events.listen(events.add);

      await notifier.load('r1');
      await Future<void>.delayed(Duration.zero);

      verify(() => mockSessionExpiration.handle()).called(1);
      expect(events, [isA<RequisitionDetailSessionExpired>()]);
      await sub.cancel();
    });
  });

  group('refresh', () {
    Future<RequisitionDetailNotifier> loaded() async {
      when(() => mockGet('r1')).thenAnswer((_) async => ApiResult.success(_requisition()));
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      await notifier.load('r1');
      return notifier;
    }

    test('a failed refresh keeps the requisition on screen', () async {
      // Losing the page you are reading because the lift has no signal is far worse
      // than simply not refreshing.
      final notifier = await loaded();
      final events = <RequisitionDetailEvent>[];
      final sub = notifier.events.listen(events.add);
      when(() => mockGet('r1')).thenAnswer((_) async => const ApiResult.offline());

      await notifier.refresh();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(requisitionDetailNotifierProvider);
      expect(state, isA<RequisitionDetailSuccess>());
      expect((state as RequisitionDetailSuccess).requisition.id, 'r1');
      expect(state.isRefreshing, isFalse, reason: 'the spinner must not stick');
      expect(events, [isA<RequisitionDetailShowMessage>()]);
      await sub.cancel();
    });

    test('a failed *initial* load still becomes an error screen', () async {
      // Nothing to preserve, so the error is the only thing worth showing.
      when(() => mockGet('r1')).thenAnswer((_) async => const ApiResult.offline());

      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');

      expect(container.read(requisitionDetailNotifierProvider),
          isA<RequisitionDetailError>());
    });

    test('a successful refresh swaps in the new data', () async {
      final notifier = await loaded();
      when(() => mockGet('r1')).thenAnswer(
        (_) async => ApiResult.success(_requisition(status: RequisitionStatus.approved)),
      );

      await notifier.refresh();

      final state = container.read(requisitionDetailNotifierProvider)
          as RequisitionDetailSuccess;
      expect(state.requisition.status, RequisitionStatus.approved);
    });

    test('refresh before any load is a no-op', () async {
      await container.read(requisitionDetailNotifierProvider.notifier).refresh();

      verifyNever(() => mockGet(any()));
    });
  });

  group('cancel', () {
    Future<void> loadPending() async {
      when(() => mockGet('r1')).thenAnswer((_) async => ApiResult.success(_requisition()));
      await container.read(requisitionDetailNotifierProvider.notifier).load('r1');
    }

    test('success closes the screen', () async {
      await loadPending();
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      final events = <RequisitionDetailEvent>[];
      final sub = notifier.events.listen(events.add);
      when(() => mockCancel('r1')).thenAnswer((_) async => const ApiResult.success(null));

      await notifier.cancel();
      await Future<void>.delayed(Duration.zero);

      expect(events, [isA<RequisitionDetailClosed>()]);
      await sub.cancel();
    });

    test('a 409 refetches, because the row is stale rather than broken', () async {
      await loadPending();
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      final events = <RequisitionDetailEvent>[];
      final sub = notifier.events.listen(events.add);

      clearInteractions(mockGet);
      when(() => mockCancel('r1'))
          .thenAnswer((_) async => const ApiResult.error('Not pending', 409));
      when(() => mockGet('r1')).thenAnswer(
        (_) async => ApiResult.success(_requisition(status: RequisitionStatus.approved)),
      );

      await notifier.cancel();
      await Future<void>.delayed(Duration.zero);

      expect(events, [isA<RequisitionDetailShowMessage>()]);
      verify(() => mockGet('r1')).called(1);
      final state = container.read(requisitionDetailNotifierProvider)
          as RequisitionDetailSuccess;
      expect(state.requisition.status, RequisitionStatus.approved);
      expect(state.requisition.canBeModified, isFalse,
          reason: 'the refetch must remove the actions that are no longer legal');
      await sub.cancel();
    });

    test('a plain failure keeps the requisition on screen and clears the spinner', () async {
      await loadPending();
      final notifier = container.read(requisitionDetailNotifierProvider.notifier);
      when(() => mockCancel('r1')).thenAnswer((_) async => const ApiResult.error('nope'));

      await notifier.cancel();

      final state = container.read(requisitionDetailNotifierProvider)
          as RequisitionDetailSuccess;
      expect(state.isCancelling, isFalse);
      expect(state.requisition.id, 'r1');
    });

    test('is a no-op before anything has loaded', () async {
      await container.read(requisitionDetailNotifierProvider.notifier).cancel();

      verifyNever(() => mockCancel(any()));
    });
  });
}
