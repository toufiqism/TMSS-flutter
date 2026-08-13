import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/core/session_expiration_handler.dart';
import 'package:tmss/di/providers.dart';
import 'package:tmss/domain/model/requisition.dart';
import 'package:tmss/domain/usecase/search_employees_use_case.dart';
import 'package:tmss/domain/usecase/submit_requisition_use_case.dart';
import 'package:tmss/presentation/requisition_create/requisition_create_notifier.dart';
import 'package:tmss/presentation/requisition_create/requisition_create_state.dart';

class MockSubmitRequisitionUseCase extends Mock implements SubmitRequisitionUseCase {}

class MockSearchEmployeesUseCase extends Mock implements SearchEmployeesUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

void main() {
  late MockSubmitRequisitionUseCase mockSubmit;
  late MockSearchEmployeesUseCase mockSearch;
  late MockSessionExpirationHandler mockSessionExpirationHandler;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(NewRequisitionRequest.passenger(
      pickupDateTime: DateTime(2026, 1, 1),
      pickupLocation: '',
      dropLocation: '',
      usedType: UsedType.pickup,
      customerName: '',
      numberOfPersons: 1,
      requiredFor: RequiredFor.ownUser,
      purpose: '',
    ));
  });

  setUp(() {
    mockSubmit = MockSubmitRequisitionUseCase();
    mockSearch = MockSearchEmployeesUseCase();
    mockSessionExpirationHandler = MockSessionExpirationHandler();
    when(() => mockSessionExpirationHandler.handle()).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      submitRequisitionUseCaseProvider.overrideWithValue(mockSubmit),
      searchEmployeesUseCaseProvider.overrideWithValue(mockSearch),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpirationHandler),
    ]);
    addTearDown(container.dispose);
  });

  Requisition createdRequisition() => Requisition(
        id: 'new1',
        pickupDateTime: DateTime(2026, 1, 1, 9, 0),
        pickupLocation: 'A',
        dropLocation: 'B',
        status: RequisitionStatus.pending,
        details: const RequisitionDetails.passenger(
          usedType: UsedType.pickup,
          customerName: 'Test',
          numberOfPersons: 1,
          requiredFor: RequiredFor.ownUser,
          purpose: 'Purpose',
        ),
        createdAt: DateTime(2026, 1, 1),
      );

  test('submit with an empty passenger form sets field errors without calling the use case', () async {
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);

    await notifier.submit();

    expect(container.read(requisitionCreateNotifierProvider).fieldErrors, isNotEmpty);
    verifyNever(() => mockSubmit(any()));
  });

  test('submit with a valid passenger form succeeds and emits RequisitionSubmitted', () async {
    when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.success(createdRequisition()));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier
      ..onPassengerPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onPassengerPickupLocationChange('A')
      ..onPassengerDropLocationChange('B')
      ..onPassengerCustomerNameChange('Test')
      ..onNumberOfPersonsChange('1')
      ..onPurposeChange('Purpose');

    final events = <RequisitionCreateEvent>[];
    final sub = notifier.events.listen(events.add);

    await notifier.submit();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.fieldErrors, isEmpty);
    expect(events, [isA<RequisitionSubmitted>()]);
    await sub.cancel();
  });

  test('requiring "someone else" without selecting an employee fails validation', () async {
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier
      ..onPassengerPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onPassengerPickupLocationChange('A')
      ..onPassengerDropLocationChange('B')
      ..onPassengerCustomerNameChange('Test')
      ..onNumberOfPersonsChange('1')
      ..onPurposeChange('Purpose')
      ..onRequiredForChange(RequiredFor.someoneElse);

    await notifier.submit();

    expect(container.read(requisitionCreateNotifierProvider).fieldErrors, containsPair(RequisitionFormField.employees, isNotNull));
    verifyNever(() => mockSubmit(any()));
  });

  test('submit failure surfaces submitError and clears isSubmitting', () async {
    when(() => mockSubmit(any())).thenAnswer((_) async => const ApiResult.error('Could not submit'));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier
      ..onPassengerPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onPassengerPickupLocationChange('A')
      ..onPassengerDropLocationChange('B')
      ..onPassengerCustomerNameChange('Test')
      ..onNumberOfPersonsChange('1')
      ..onPurposeChange('Purpose');

    await notifier.submit();

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.submitError, 'Could not submit');
  });

  test('logout on submit invokes the session expiration handler and emits SessionExpired', () async {
    when(() => mockSubmit(any())).thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier
      ..onPassengerPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onPassengerPickupLocationChange('A')
      ..onPassengerDropLocationChange('B')
      ..onPassengerCustomerNameChange('Test')
      ..onNumberOfPersonsChange('1')
      ..onPurposeChange('Purpose');

    final events = <RequisitionCreateEvent>[];
    final sub = notifier.events.listen(events.add);

    await notifier.submit();
    await Future<void>.delayed(Duration.zero);

    verify(() => mockSessionExpirationHandler.handle()).called(1);
    expect(events, [isA<RequisitionCreateSessionExpired>()]);
    await sub.cancel();
  });

  test('switchFormType resets both forms and clears errors', () async {
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier.onPassengerCustomerNameChange('Test');
    await notifier.submit();
    expect(container.read(requisitionCreateNotifierProvider).fieldErrors, isNotEmpty);

    notifier.switchFormType(RequisitionFormType.logistics);

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.fieldErrors, isEmpty);
    expect(state.passengerForm.customerName, isEmpty);
  });
}
