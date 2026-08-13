import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/api_capabilities.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'requisition_create_state.dart';

const _employeeSearchDebounce = Duration(milliseconds: 300);

/// `isAutoDispose: true`: without it the notifier is kept alive by Riverpod 3's
/// default, so submitting a requisition, popping back, and re-opening this screen
/// would redisplay the previous submission's form still fully filled in.
final requisitionCreateNotifierProvider =
    NotifierProvider<RequisitionCreateNotifier, RequisitionCreateUiState>(
  RequisitionCreateNotifier.new,
  isAutoDispose: true,
);

class RequisitionCreateNotifier extends Notifier<RequisitionCreateUiState>
    with NotifierLifecycle<RequisitionCreateUiState, RequisitionCreateEvent> {
  Timer? _employeeSearchTimer;

  /// Monotonic counter guarding the debounced employee search. Every keystroke bumps
  /// it; a search that returns after a newer keystroke has landed is dropped rather
  /// than overwriting fresher results.
  int _employeeSearchToken = 0;

  @override
  RequisitionCreateUiState build() {
    registerLifecycle();
    ref.onDispose(() => _employeeSearchTimer?.cancel());
    return const RequisitionCreateUiState();
  }

  void switchFormType(RequisitionFormType type) {
    state = state.copyWith(
      formType: type,
      passengerForm: const PassengerFormState(),
      logisticsForm: const LogisticsFormState(),
      fieldErrors: const {},
      submitError: null,
    );
  }

  // --- Passenger form field updates ---

  void onPassengerPickupDateTimeChange(DateTime value) =>
      _updatePassenger(RequisitionFormField.pickupDateTime, (f) => f.copyWith(pickupDateTime: value));
  void onPassengerPickupLocationChange(String value) =>
      _updatePassenger(RequisitionFormField.pickupLocation, (f) => f.copyWith(pickupLocation: value));
  void onPassengerDropLocationChange(String value) =>
      _updatePassenger(RequisitionFormField.dropLocation, (f) => f.copyWith(dropLocation: value));
  void onUsedTypeChange(UsedType value) => _updatePassenger(null, (f) => f.copyWith(usedType: value));
  void onPassengerCustomerNameChange(String value) =>
      _updatePassenger(RequisitionFormField.customerName, (f) => f.copyWith(customerName: value));
  void onNumberOfPersonsChange(String value) =>
      _updatePassenger(RequisitionFormField.numberOfPersons, (f) => f.copyWith(numberOfPersons: value));
  void onRequiredForChange(RequiredFor value) => _updatePassenger(null, (f) => f.copyWith(requiredFor: value));
  void onUserTypeChange(RequisitionUserType value) => _updatePassenger(null, (f) => f.copyWith(userType: value));
  void onPurposeChange(String value) => _updatePassenger(RequisitionFormField.purpose, (f) => f.copyWith(purpose: value));
  void onPassengerRemarksChange(String value) => _updatePassenger(null, (f) => f.copyWith(remarks: value));

  void toggleEmployeeSelection(Employee employee) {
    _updatePassenger(RequisitionFormField.employees, (form) {
      final current = form.selectedEmployees;
      final isSelected = current.any((e) => e.id == employee.id);
      final updated = isSelected
          ? current.where((e) => e.id != employee.id).toList()
          : [...current, employee];
      return form.copyWith(selectedEmployees: updated);
    });
  }

  /// Debounced by rescheduling a timer, *not* by awaiting a Completer that the next
  /// keystroke cancels — that older shape stranded one suspended async frame per
  /// keystroke, since a cancelled Timer never completes its Completer and the
  /// awaiting frame is never resumed.
  void onEmployeeSearchQueryChange(String query) {
    state = state.copyWith(employeeSearchQuery: query);
    _employeeSearchTimer?.cancel();
    _employeeSearchTimer = Timer(
      _employeeSearchDebounce,
      () => unawaited(_runEmployeeSearch(query)),
    );
  }

  Future<void> _runEmployeeSearch(String query) async {
    if (isDisposed) return;
    final token = ++_employeeSearchToken;
    setStateIfAlive(state.copyWith(isSearchingEmployees: true, employeeSearchError: null));

    final searchEmployeesUseCase = ref.read(searchEmployeesUseCaseProvider);
    final result = await searchEmployeesUseCase(query);
    if (isDisposed || token != _employeeSearchToken) return;

    switch (result) {
      case ApiSuccess<List<Employee>>(:final response):
        setStateIfAlive(state.copyWith(
          employeeSearchResults: response,
          isSearchingEmployees: false,
          employeeSearchError: null,
        ));
      // Previously these three branches only cleared the spinner, leaving the user
      // staring at an empty result list with no idea the lookup had failed.
      case ApiError<List<Employee>>(:final message):
        _onEmployeeSearchFailed(message ?? TmsStrings.newRequisitionEmployeeSearchFailed);
      case ApiOffline<List<Employee>>(:final message):
        _onEmployeeSearchFailed(message);
      case ApiMaintenance<List<Employee>>(:final message):
        _onEmployeeSearchFailed(message);
      case ApiLogout<List<Employee>>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        setStateIfAlive(state.copyWith(isSearchingEmployees: false));
        emitEvent(RequisitionCreateSessionExpired(message));
    }
  }

  void _onEmployeeSearchFailed(String message) {
    setStateIfAlive(state.copyWith(
      isSearchingEmployees: false,
      employeeSearchResults: const [],
      employeeSearchError: message,
    ));
  }

  // --- Logistics form field updates ---

  void onLogisticsPickupDateTimeChange(DateTime value) =>
      _updateLogistics(RequisitionFormField.pickupDateTime, (f) => f.copyWith(pickupDateTime: value));
  void onLogisticsPickupLocationChange(String value) =>
      _updateLogistics(RequisitionFormField.pickupLocation, (f) => f.copyWith(pickupLocation: value));
  void onLogisticsDropLocationChange(String value) =>
      _updateLogistics(RequisitionFormField.dropLocation, (f) => f.copyWith(dropLocation: value));
  void onVehicleTypeChange(VehicleType value) => _updateLogistics(null, (f) => f.copyWith(vehicleType: value));
  void onLogisticsCustomerNameChange(String value) =>
      _updateLogistics(RequisitionFormField.customerName, (f) => f.copyWith(customerName: value));
  void onUserDepartmentChange(String value) =>
      _updateLogistics(RequisitionFormField.userDepartment, (f) => f.copyWith(userDepartment: value));
  void onLoadingCapacityChange(LoadingCapacity value) => _updateLogistics(null, (f) => f.copyWith(loadingCapacity: value));
  void onGoodsWeightChange(String value) => _updateLogistics(RequisitionFormField.goodsWeight, (f) => f.copyWith(goodsWeight: value));
  void onStoreNameChange(String value) => _updateLogistics(RequisitionFormField.storeName, (f) => f.copyWith(storeName: value));
  void onGoodsDetailsChange(String value) =>
      _updateLogistics(RequisitionFormField.goodsDetails, (f) => f.copyWith(goodsDetails: value));
  void onLogisticsRemarksChange(String value) => _updateLogistics(null, (f) => f.copyWith(remarks: value));

  Future<void> submit() async {
    final s = state;
    if (s.isSubmitting) return;
    final errors = s.formType == RequisitionFormType.passenger
        ? _validatePassenger(s.passengerForm)
        : _validateLogistics(s.logisticsForm);
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return;
    }

    final request = _buildRequest(s);
    state = state.copyWith(isSubmitting: true, submitError: null, fieldErrors: const {});
    final submitRequisitionUseCase = ref.read(submitRequisitionUseCaseProvider);
    final result = await submitRequisitionUseCase(request);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<Requisition>():
        setStateIfAlive(state.copyWith(isSubmitting: false));
        emitEvent(const RequisitionSubmitted());
      case ApiError<Requisition>(:final message, :final fieldErrors):
        // A 422 carries field-keyed messages; pin them to the offending inputs
        // instead of dumping one opaque banner at the top of the form.
        setStateIfAlive(state.copyWith(
          isSubmitting: false,
          submitError: message ?? TmsStrings.newRequisitionSubmitFailed,
          fieldErrors: _mapWireFieldErrors(fieldErrors),
        ));
      case ApiOffline<Requisition>(:final message):
        setStateIfAlive(state.copyWith(isSubmitting: false, submitError: message));
      case ApiMaintenance<Requisition>(:final message):
        setStateIfAlive(state.copyWith(isSubmitting: false, submitError: message));
      case ApiLogout<Requisition>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        setStateIfAlive(state.copyWith(isSubmitting: false));
        emitEvent(RequisitionCreateSessionExpired(message));
    }
  }

  /// Translates the API's snake_case field keys onto this form's field ids. Keys that
  /// do not correspond to a visible input are dropped — they still reach the user
  /// through the summary [RequisitionCreateUiState.submitError].
  Map<String, String> _mapWireFieldErrors(Map<String, String>? wireErrors) {
    if (wireErrors == null || wireErrors.isEmpty) return const {};
    const wireToField = <String, String>{
      'pick_up_date_time': RequisitionFormField.pickupDateTime,
      'pickup_location': RequisitionFormField.pickupLocation,
      'drop_location': RequisitionFormField.dropLocation,
      'customer_name': RequisitionFormField.customerName,
      'no_of_person': RequisitionFormField.numberOfPersons,
      'purpose': RequisitionFormField.purpose,
    };
    final mapped = <String, String>{};
    for (final entry in wireErrors.entries) {
      final field = wireToField[entry.key];
      if (field != null) mapped[field] = entry.value;
    }
    return mapped;
  }

  NewRequisitionRequest _buildRequest(RequisitionCreateUiState s) {
    if (s.formType == RequisitionFormType.passenger) {
      final form = s.passengerForm;
      return NewRequisitionRequest.passenger(
        pickupDateTime: form.pickupDateTime!,
        pickupLocation: form.pickupLocation,
        dropLocation: form.dropLocation,
        remarks: form.remarks.trim().isEmpty ? null : form.remarks,
        usedType: form.usedType,
        customerName: form.customerName,
        numberOfPersons: int.tryParse(form.numberOfPersons) ?? 1,
        requiredFor: form.requiredFor,
        userType: form.requiredFor == RequiredFor.someoneElse ? form.userType : null,
        employeeIds: form.requiredFor == RequiredFor.someoneElse
            ? form.selectedEmployees.map((e) => e.id).toList()
            : const [],
        purpose: form.purpose,
      );
    }
    final form = s.logisticsForm;
    return NewRequisitionRequest.logistics(
      pickupDateTime: form.pickupDateTime!,
      pickupLocation: form.pickupLocation,
      dropLocation: form.dropLocation,
      remarks: form.remarks.trim().isEmpty ? null : form.remarks,
      vehicleType: form.vehicleType,
      customerName: form.customerName,
      userDepartment: form.userDepartment,
      loadingCapacity: form.loadingCapacity,
      goodsWeight: form.goodsWeight,
      storeName: form.storeName,
      goodsDetails: form.goodsDetails,
    );
  }

  Map<String, String> _validatePassenger(PassengerFormState form) {
    const required = TmsStrings.newRequisitionErrorRequired;
    final errors = <String, String>{};
    if (form.pickupDateTime == null) errors[RequisitionFormField.pickupDateTime] = required;
    if (form.pickupLocation.trim().isEmpty) errors[RequisitionFormField.pickupLocation] = required;
    if (form.dropLocation.trim().isEmpty) errors[RequisitionFormField.dropLocation] = required;
    if (form.customerName.trim().isEmpty) errors[RequisitionFormField.customerName] = required;
    final persons = int.tryParse(form.numberOfPersons);
    if (persons == null || persons <= 0) {
      errors[RequisitionFormField.numberOfPersons] = TmsStrings.newRequisitionErrorNumberInvalid;
    }
    if (form.purpose.trim().isEmpty) errors[RequisitionFormField.purpose] = required;
    // Only demanded while the picker is actually shown. There is no directory endpoint
    // and no wire field for employee ids, so requiring a selection the user cannot make
    // would make "Someone Else" unsubmittable — and the server accepts it without one.
    if (ApiCapabilities.employeeDirectory &&
        form.requiredFor == RequiredFor.someoneElse &&
        form.selectedEmployees.isEmpty) {
      errors[RequisitionFormField.employees] = TmsStrings.newRequisitionErrorSelectEmployee;
    }
    return errors;
  }

  Map<String, String> _validateLogistics(LogisticsFormState form) {
    const required = TmsStrings.newRequisitionErrorRequired;
    final errors = <String, String>{};
    if (form.pickupDateTime == null) errors[RequisitionFormField.pickupDateTime] = required;
    if (form.pickupLocation.trim().isEmpty) errors[RequisitionFormField.pickupLocation] = required;
    if (form.dropLocation.trim().isEmpty) errors[RequisitionFormField.dropLocation] = required;
    if (form.customerName.trim().isEmpty) errors[RequisitionFormField.customerName] = required;
    if (form.userDepartment.trim().isEmpty) errors[RequisitionFormField.userDepartment] = required;
    if (form.goodsWeight.trim().isEmpty) errors[RequisitionFormField.goodsWeight] = required;
    if (form.storeName.trim().isEmpty) errors[RequisitionFormField.storeName] = required;
    if (form.goodsDetails.trim().isEmpty) errors[RequisitionFormField.goodsDetails] = required;
    return errors;
  }

  void _updatePassenger(String? field, PassengerFormState Function(PassengerFormState) transform) {
    final errors = {...state.fieldErrors};
    if (field != null) errors.remove(field);
    state = state.copyWith(passengerForm: transform(state.passengerForm), fieldErrors: errors);
  }

  void _updateLogistics(String? field, LogisticsFormState Function(LogisticsFormState) transform) {
    final errors = {...state.fieldErrors};
    if (field != null) errors.remove(field);
    state = state.copyWith(logisticsForm: transform(state.logisticsForm), fieldErrors: errors);
  }
}
