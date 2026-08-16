import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/core/session_expiration_handler.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/employee.dart';
import 'package:tracgo/domain/model/requisition.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/domain/repository/requisition_repository.dart';
import 'package:tracgo/domain/requisition_field_limits.dart';
import 'package:tracgo/domain/usecase/get_user_account_use_case.dart';
import 'package:tracgo/domain/usecase/search_employees_use_case.dart';
import 'package:tracgo/domain/usecase/submit_requisition_use_case.dart';
import 'package:tracgo/domain/usecase/update_requisition_use_case.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/requisition_create/requisition_create_notifier.dart';
import 'package:tracgo/presentation/requisition_create/requisition_create_state.dart';

class MockSubmitRequisitionUseCase extends Mock implements SubmitRequisitionUseCase {}

class MockUpdateRequisitionUseCase extends Mock implements UpdateRequisitionUseCase {}

class MockSearchEmployeesUseCase extends Mock implements SearchEmployeesUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

/// Only `invalidateEmployeeCache` is exercised — the notifier reaches the repository
/// directly for exactly that one call, everything else goes through use cases.
class MockRequisitionRepository extends Mock implements RequisitionRepository {}

/// `GET /user`, which is how the create form finds the signed-in user's own row in the
/// employee directory.
class MockGetUserAccountUseCase extends Mock implements GetUserAccountUseCase {}

/// Synthetic rider. Never the real directory — see CLAUDE.md.
Employee rider({String id = '1036'}) => Employee(
      id: id,
      name: 'Synthetic Rider $id',
      employeeCode: 'E-$id',
      designation: 'Officer',
      department: 'Operations',
      company: 'Synthetic Co.',
    );

void main() {
  late MockSubmitRequisitionUseCase mockSubmit;
  late MockUpdateRequisitionUseCase mockUpdate;
  late MockSearchEmployeesUseCase mockSearch;
  late MockSessionExpirationHandler mockSessionExpirationHandler;
  late MockRequisitionRepository mockRepository;
  late MockGetUserAccountUseCase mockGetAccount;
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
    mockUpdate = MockUpdateRequisitionUseCase();
    mockSearch = MockSearchEmployeesUseCase();
    mockSessionExpirationHandler = MockSessionExpirationHandler();
    mockRepository = MockRequisitionRepository();
    mockGetAccount = MockGetUserAccountUseCase();
    // Reached by every "Own User" pre-selection; unstubbed it would throw inside an
    // unawaited call.
    when(mockGetAccount.call)
        .thenAnswer((_) async => ApiResult.success(const UserAccount()));
    when(() => mockSessionExpirationHandler.handle()).thenAnswer((_) async {});
    when(mockRepository.invalidateEmployeeCache).thenReturn(null);
    // seedFrom resolves seeded rider ids against the directory, so this is reached by
    // every edit-mode test. Unstubbed, mocktail would throw inside an unawaited call.
    when(() => mockSearch(any()))
        .thenAnswer((_) async => ApiResult.success(<Employee>[rider()]));
    container = ProviderContainer(overrides: [
      submitRequisitionUseCaseProvider.overrideWithValue(mockSubmit),
      updateRequisitionUseCaseProvider.overrideWithValue(mockUpdate),
      searchEmployeesUseCaseProvider.overrideWithValue(mockSearch),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpirationHandler),
      requisitionRepositoryProvider.overrideWithValue(mockRepository),
      getUserAccountUseCaseProvider.overrideWithValue(mockGetAccount),
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
      ..onPassengerPickupLocationChange('Pickup')
      ..onPassengerDropLocationChange('Drop')
      ..onPassengerCustomerNameChange('Test')
      ..toggleEmployeeSelection(rider())
      ..onPurposeChange('Purpose');
  }

  /// Every value at least 3 characters, because the server's `min:3` rule applies to
  /// all six required logistics strings and a shorter fixture would fail for the wrong
  /// reason.
  void fillValidLogisticsForm(RequisitionCreateNotifier notifier) {
    notifier
      ..onLogisticsPickupDateTimeChange(DateTime(2026, 1, 1, 9, 0))
      ..onLogisticsPickupLocationChange('Pickup')
      ..onLogisticsDropLocationChange('Drop')
      ..onLogisticsCustomerNameChange('Customer')
      ..onUserDepartmentChange('Logistics')
      ..onGoodsWeightChange('500 kg')
      ..onStoreNameChange('Store')
      ..onGoodsDetailsChange('Spare parts');
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
      ..onPassengerPickupLocationChange('Pickup')
      ..onPassengerDropLocationChange('Drop')
      ..onPassengerCustomerNameChange('Test')
      ..toggleEmployeeSelection(rider())
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
      ..onPassengerPickupLocationChange('Pickup')
      ..onPassengerDropLocationChange('Drop')
      ..onPassengerCustomerNameChange('Test')
      ..toggleEmployeeSelection(rider())
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
      ..onPassengerPickupLocationChange('Pickup')
      ..onPassengerDropLocationChange('Drop')
      ..onPassengerCustomerNameChange('Test')
      ..toggleEmployeeSelection(rider())
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

  group('edit mode', () {
    Requisition existingPassenger() => Requisition(
          id: '2836',
          pickupDateTime: DateTime(2026, 8, 20, 10),
          pickupLocation: 'Head Office',
          dropLocation: 'Gulshan',
          remarks: 'Bring an AC vehicle',
          status: RequisitionStatus.pending,
          details: const RequisitionDetails.passenger(
            usedType: UsedType.drop,
            customerName: 'Bangla Trac',
            numberOfPersons: 1,
            requiredFor: RequiredFor.ownUser,
            userType: RequisitionUserType.internal,
            riders: [
              RequisitionRider(
                id: '1036',
                name: 'Md. Tofiq Akbar',
                employeeCode: '2-765',
              ),
            ],
            purpose: 'Client meeting',
          ),
          createdAt: DateTime(2026, 8, 14),
          requesterName: 'Md. Tofiq Akbar',
          requesterCode: '2-765',
          departmentName: 'IT',
          companyName: 'Bangla Trac Ltd.',
        );

    test('seedFrom fills the form from the requisition', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(existingPassenger());

      final state = container.read(requisitionCreateNotifierProvider);
      expect(state.isEditing, isTrue);
      expect(state.editingRequisitionId, '2836');
      expect(state.formType, RequisitionFormType.passenger);
      expect(state.passengerForm.pickupLocation, 'Head Office');
      expect(state.passengerForm.dropLocation, 'Gulshan');
      // Derived from the seeded rider list, not copied from the stored
      // no_of_person — the two must agree on submit.
      expect(state.passengerForm.numberOfPersons, '1');
      expect(state.passengerForm.selectedEmployees.single.id, '1036');
      expect(state.passengerForm.usedType, UsedType.drop);
      expect(state.passengerForm.purpose, 'Client meeting');
      expect(state.passengerForm.remarks, 'Bring an AC vehicle');
    });

    test('seeded riders carry the names the response gave, before the directory answers',
        () async {
      // The point of the assertion running before any await: the directory fetch is
      // 92KB and may fail outright, so a chip that only reads correctly *after* it
      // lands is the bug this seeding exists to avoid.
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(existingPassenger());

      final seeded =
          container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees;
      expect(seeded.single.name, 'Md. Tofiq Akbar');
      expect(seeded.single.employeeCode, '2-765');
    });

    test('a rider the response named only by id keeps the unresolved label', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(
        existingPassenger().copyWith(
          details: const RequisitionDetails.passenger(
            usedType: UsedType.drop,
            customerName: 'Bangla Trac',
            numberOfPersons: 1,
            requiredFor: RequiredFor.ownUser,
            // The older bare-id wire shape: submittable, but with nothing to display.
            riders: [RequisitionRider(id: '99999')],
            purpose: 'Client meeting',
          ),
        ),
      );

      final seeded =
          container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees;
      expect(seeded.single.id, '99999', reason: 'the submittable id is never lost');
      expect(seeded.single.name, TracGoStrings.newRequisitionRiderUnresolved);
    });

    test('seedFrom captures the requester for the read-only header', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(existingPassenger());

      final state = container.read(requisitionCreateNotifierProvider);
      expect(state.editingRequesterName, 'Md. Tofiq Akbar');
      expect(state.editingRequesterCode, '2-765');
      expect(state.editingRequesterDepartment, 'IT');
      expect(state.editingRequesterCompany, 'Bangla Trac Ltd.');
      expect(state.hasRequesterInfo, isTrue);
    });

    test('a requisition with no requester fields reports nothing to show', () async {
      // `created_by_name` is a detail-response field; a requisition reached without it
      // must not render an empty header card.
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(
        existingPassenger().copyWith(
          requesterName: null,
          requesterCode: null,
          departmentName: null,
          companyName: null,
        ),
      );

      expect(
        container.read(requisitionCreateNotifierProvider).hasRequesterInfo,
        isFalse,
      );
    });

    test('seeding a logistics requisition selects the logistics form', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.seedFrom(
        existingPassenger().copyWith(
          details: const RequisitionDetails.logistics(
            vehicleType: VehicleType.coverVan,
            customerName: 'Bangla Trac',
            userDepartment: 'Operations',
            loadingCapacity: LoadingCapacity.ton5,
            goodsWeight: '4 Ton',
            storeName: 'Central',
            goodsDetails: 'Pallets',
          ),
        ),
      );

      final state = container.read(requisitionCreateNotifierProvider);
      expect(state.formType, RequisitionFormType.logistics);
      expect(state.logisticsForm.loadingCapacity, LoadingCapacity.ton5);
      expect(state.logisticsForm.storeName, 'Central');
    });

    test('switchFormType is inert while editing, so the loaded form is not wiped', () async {
      // req_type is immutable server-side; switching would also reset both forms and
      // silently discard everything that was loaded.
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      notifier.seedFrom(existingPassenger());

      notifier.switchFormType(RequisitionFormType.logistics);

      final state = container.read(requisitionCreateNotifierProvider);
      expect(state.formType, RequisitionFormType.passenger);
      expect(state.passengerForm.pickupLocation, 'Head Office');
    });

    test('submit calls update, not create, and preserves the id', () async {
      when(() => mockUpdate(any(), any()))
          .thenAnswer((_) async => ApiResult.success(createdRequisition()));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      notifier.seedFrom(existingPassenger());

      final events = <RequisitionCreateEvent>[];
      final sub = notifier.events.listen(events.add);
      await notifier.submit();
      await Future<void>.delayed(Duration.zero);

      verify(() => mockUpdate('2836', any())).called(1);
      verifyNever(() => mockSubmit(any()));
      expect(events.single, isA<RequisitionSubmitted>());
      expect((events.single as RequisitionSubmitted).wasEdit, isTrue);
      await sub.cancel();
    });

    test('a 409 on save gives up rather than letting the user retry forever', () async {
      // The requisition left Pending while the form was open; no retry can succeed.
      when(() => mockUpdate(any(), any()))
          .thenAnswer((_) async => const ApiResult.error('Not pending', 409));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      notifier.seedFrom(existingPassenger());

      final events = <RequisitionCreateEvent>[];
      final sub = notifier.events.listen(events.add);
      await notifier.submit();
      await Future<void>.delayed(Duration.zero);

      expect(events.single, isA<RequisitionEditRejected>());
      expect(container.read(requisitionCreateNotifierProvider).isSubmitting, isFalse);
      await sub.cancel();
    });

    test('validation still applies when editing', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      notifier.seedFrom(existingPassenger());
      notifier.onPassengerPickupLocationChange('');

      await notifier.submit();

      expect(container.read(requisitionCreateNotifierProvider).fieldErrors, isNotEmpty);
      verifyNever(() => mockUpdate(any(), any()));
    });
  });

  // Every rule below was read off the live server's own 422 and none of it is in either
  // API contract, so these tests are the only thing keeping the form's idea of "valid"
  // attached to the server's.
  group('server length and range rules', () {
    test('a required field under 3 characters is rejected before submitting', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);
      notifier.onPurposeChange('ab');

      await notifier.submit();

      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.purpose],
        TracGoStrings.newRequisitionErrorTooShort(RequisitionFieldLimits.minTextLength),
      );
      verifyNever(() => mockSubmit(any()));
    });

    test('length is measured after trimming, so spaces do not pass as characters',
        () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);
      notifier.onPurposeChange('     ');

      await notifier.submit();

      // Empty after trimming, so this is the "required" case rather than "too short" —
      // and either way it must not reach the network.
      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.purpose],
        TracGoStrings.newRequisitionErrorRequired,
      );
      verifyNever(() => mockSubmit(any()));
    });

    test('a field over its cap is rejected, with the per-field cap applied', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);
      notifier.onPurposeChange('A' * (RequisitionFieldLimits.defaultMaxLength + 1));

      await notifier.submit();

      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.purpose],
        TracGoStrings.newRequisitionErrorTooLong(RequisitionFieldLimits.defaultMaxLength),
      );
      verifyNever(() => mockSubmit(any()));
    });

    test('goods_weight has a much tighter cap and no minimum', () async {
      // The 1-character half of this test is expected to pass validation and reach the
      // network, so the submit call needs an answer.
      when(() => mockSubmit(any()))
          .thenAnswer((_) async => ApiResult.success(createdRequisition()));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      notifier.switchFormType(RequisitionFormType.logistics);
      fillValidLogisticsForm(notifier);

      // One character: accepted by the server, so it must be accepted here.
      notifier.onGoodsWeightChange('1');
      await notifier.submit();
      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.goodsWeight],
        isNull,
      );

      notifier.onGoodsWeightChange('A' * (RequisitionFieldLimits.goodsWeightMaxLength + 1));
      await notifier.submit();
      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.goodsWeight],
        TracGoStrings.newRequisitionErrorTooLong(
          RequisitionFieldLimits.goodsWeightMaxLength,
        ),
      );
    });

    test('remarks is optional but still capped', () async {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);
      notifier.onPassengerRemarksChange('A' * (RequisitionFieldLimits.defaultMaxLength + 1));

      await notifier.submit();

      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.remarks],
        TracGoStrings.newRequisitionErrorTooLong(RequisitionFieldLimits.defaultMaxLength),
      );
      verifyNever(() => mockSubmit(any()));
    });

    test('the rider picker stops at the server cap on no_of_person', () {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      for (var i = 0; i < RequisitionFieldLimits.maxPassengers; i++) {
        notifier.toggleEmployeeSelection(rider(id: '$i'));
      }
      expect(
        container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees,
        hasLength(RequisitionFieldLimits.maxPassengers),
      );

      notifier.toggleEmployeeSelection(rider(id: 'one-too-many'));

      final state = container.read(requisitionCreateNotifierProvider);
      expect(state.passengerForm.selectedEmployees,
          hasLength(RequisitionFieldLimits.maxPassengers));
      expect(
        state.fieldErrors[RequisitionFormField.employees],
        TracGoStrings.newRequisitionErrorTooManyEmployees(
          RequisitionFieldLimits.maxPassengers,
        ),
      );
    });

    test('deselection still works at the cap, so an over-full form can be fixed', () {
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      for (var i = 0; i < RequisitionFieldLimits.maxPassengers; i++) {
        notifier.toggleEmployeeSelection(rider(id: '$i'));
      }

      notifier.toggleEmployeeSelection(rider(id: '0'));

      expect(
        container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees,
        hasLength(RequisitionFieldLimits.maxPassengers - 1),
      );
    });
  });

  // This never once fired before: it compared the session's `user.id` — which is the
  // *email*, because the login response carries no id at all — against directory ids
  // and staff numbers. `GET /user.employee_id` is the only value that bridges the two.
  group('requester pre-selection on an "Own User" trip', () {
    test('pre-selects the directory row matching GET /user.employee_id', () async {
      when(mockGetAccount.call)
          .thenAnswer((_) async => ApiResult.success(const UserAccount(id: '864', employeeId: '3035')));
      when(() => mockSearch(any())).thenAnswer(
        (_) async => ApiResult.success([rider(id: '670'), rider(id: '3035')]),
      );
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.onRequiredForChange(RequiredFor.ownUser);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(requisitionCreateNotifierProvider)
            .passengerForm.selectedEmployees.map((e) => e.id),
        ['3035'],
      );
    });

    test('the account id is never used as a fallback — it is a different key space',
        () async {
      // 864 exists in this fake directory purely to prove it is not picked: matching on
      // it would put a stranger on the trip.
      when(mockGetAccount.call)
          .thenAnswer((_) async => ApiResult.success(const UserAccount(id: '864')));
      when(() => mockSearch(any())).thenAnswer(
        (_) async => ApiResult.success([rider(id: '864'), rider(id: '3035')]),
      );
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.onRequiredForChange(RequiredFor.ownUser);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees,
        isEmpty,
      );
    });

    test('a failed account lookup leaves the picker empty rather than guessing',
        () async {
      when(mockGetAccount.call)
          .thenAnswer((_) async => ApiResult.error('boom', 500));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);

      notifier.onRequiredForChange(RequiredFor.ownUser);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(requisitionCreateNotifierProvider).passengerForm.selectedEmployees,
        isEmpty,
      );
    });
  });

  group('employee_id 422 handling', () {
    // The server reports these per item — `employee_id.0`, not `employee_id` — and the
    // "inactive" case arrives as plain `exists`-rule wording. Both details defeated the
    // original stale-cache check, so both are pinned here.
    test('an indexed "is invalid" error drops the cached directory', () async {
      when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.error(
            'The given data was invalid.',
            422,
            const {'employee_id.0': 'The selected employee_id.0 is invalid.'},
          ));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);

      await notifier.submit();

      verify(() => mockRepository.invalidateEmployeeCache()).called(1);
      // It must also reach the picker, indexed key notwithstanding.
      expect(
        container.read(requisitionCreateNotifierProvider)
            .fieldErrors[RequisitionFormField.employees],
        isNotNull,
      );
    });

    test('a count mismatch does not, because it says nothing about staleness', () async {
      when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.error(
            'The given data was invalid.',
            422,
            const {
              'employee_id':
                  'The number of selected employees must equal no_of_person (3).',
            },
          ));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);

      await notifier.submit();

      verifyNever(() => mockRepository.invalidateEmployeeCache());
    });

    test('a duplicate-value error does not either', () async {
      when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.error(
            'The given data was invalid.',
            422,
            const {'employee_id.1': 'The employee_id.1 field has a duplicate value.'},
          ));
      final notifier = container.read(requisitionCreateNotifierProvider.notifier);
      fillValidPassengerForm(notifier);

      await notifier.submit();

      verifyNever(() => mockRepository.invalidateEmployeeCache());
    });
  });

  test('logistics-only 422 keys reach their own inputs, not just the banner', () async {
    when(() => mockSubmit(any())).thenAnswer((_) async => ApiResult.error(
          'The given data was invalid.',
          422,
          const {
            'user_department': 'The user department may not be greater than 100 characters.',
            'goods_weight': 'The goods weight may not be greater than 25 characters.',
            'store_name': 'The store name must be at least 3 characters.',
            'goods_details': 'The goods details must be at least 3 characters.',
          },
        ));
    final notifier = container.read(requisitionCreateNotifierProvider.notifier);
    notifier.switchFormType(RequisitionFormType.logistics);
    fillValidLogisticsForm(notifier);

    await notifier.submit();

    final errors = container.read(requisitionCreateNotifierProvider).fieldErrors;
    expect(errors[RequisitionFormField.userDepartment], isNotNull);
    expect(errors[RequisitionFormField.goodsWeight], isNotNull);
    expect(errors[RequisitionFormField.storeName], isNotNull);
    expect(errors[RequisitionFormField.goodsDetails], isNotNull);
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
