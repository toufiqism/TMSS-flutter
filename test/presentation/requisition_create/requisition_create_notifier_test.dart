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
    // This provider is isAutoDispose, so without a listener it is torn down as soon as
    // the read that created it completes — and any debounced work would be dropped by
    // the notifier's own disposal guards. A mounted screen holds exactly this kind of
    // subscription, so holding one here keeps the test faithful.
    container.listen(requisitionCreateNotifierProvider, (_, _) {}, fireImmediately: true);
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

  void fillValidPassengerForm(RequisitionCreateNotifier notifier) {
    notifier
      ..onPassengerPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onPassengerPickupLocationChange('A')
      ..onPassengerDropLocationChange('B')
      ..onPassengerCustomerNameChange('Test')
      ..onNumberOfPersonsChange('1')
      ..onPurposeChange('Purpose');
  }

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

  test('"someone else" submits without an employee selection', () async {
    // The server accepts requisition_for: "Someone Else" and asks for no employee
    // field, and there is no directory endpoint to pick one from — so demanding a
    // selection the user cannot make would render the option unusable.
    when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.success(createdRequisition()));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    fillValidPassengerForm(notifier);
    notifier.onRequiredForChange(RequiredFor.someoneElse);

    await notifier.submit();

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.fieldErrors, isEmpty);
    verify(() => mockSubmit(any())).called(1);
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

  test('submit while offline surfaces the offline message', () async {
    when(() => mockSubmit(any())).thenAnswer((_) async => const ApiResult.offline());
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    fillValidPassengerForm(notifier);

    await notifier.submit();

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.submitError, 'No internet connection available');
  });

  test('submit under maintenance surfaces the maintenance message', () async {
    when(() => mockSubmit(any()))
        .thenAnswer((_) async => const ApiResult.maintenance('Under maintenance', 503));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    fillValidPassengerForm(notifier);

    await notifier.submit();

    expect(container.read(requisitionCreateNotifierProvider).submitError, 'Under maintenance');
  });

  test('a 422 pins server field errors onto the matching inputs', () async {
    // The contract's stated client action for 422 is to map `errors` onto the
    // offending form fields rather than showing one opaque banner.
    when(() => mockSubmit(any())).thenAnswer(
      (_) async => const ApiResult.error('Invalid', 422, {
        'pick_up_date_time': 'Must be a future date.',
        'unmapped_field': 'ignored',
      }),
    );
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    fillValidPassengerForm(notifier);

    await notifier.submit();

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.fieldErrors[RequisitionFormField.pickupDateTime], 'Must be a future date.');
    expect(state.fieldErrors.containsKey('unmapped_field'), isFalse);
    expect(state.submitError, 'Invalid');
  });

  test('a failed employee search reports itself instead of showing an empty list', () async {
    when(() => mockSearch(any())).thenAnswer((_) async => const ApiResult.error('boom'));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);

    notifier.onEmployeeSearchQueryChange('rafiq');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final state = container.read(requisitionCreateNotifierProvider);
    expect(state.isSearchingEmployees, isFalse);
    expect(state.employeeSearchError, 'boom');
    expect(state.employeeSearchResults, isEmpty);
  });

  test('only the last keystroke in a burst reaches the use case', () async {
    when(() => mockSearch(any())).thenAnswer((_) async => const ApiResult.success([]));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);

    notifier.onEmployeeSearchQueryChange('r');
    notifier.onEmployeeSearchQueryChange('ra');
    notifier.onEmployeeSearchQueryChange('raf');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    verify(() => mockSearch('raf')).called(1);
    verifyNever(() => mockSearch('r'));
    verifyNever(() => mockSearch('ra'));
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
