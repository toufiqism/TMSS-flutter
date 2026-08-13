import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'requisition_create_state.dart';

const _employeeSearchDebounce = Duration(milliseconds: 300);

final requisitionCreateNotifierProvider =
    NotifierProvider<RequisitionCreateNotifier, RequisitionCreateUiState>(RequisitionCreateNotifier.new);

class RequisitionCreateNotifier extends Notifier<RequisitionCreateUiState> {
  final StreamController<RequisitionCreateEvent> _events = StreamController<RequisitionCreateEvent>.broadcast();
  Stream<RequisitionCreateEvent> get events => _events.stream;

  Timer? _employeeSearchTimer;

  @override
  RequisitionCreateUiState build() {
    ref.onDispose(() {
      _events.close();
      _employeeSearchTimer?.cancel();
    });
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
      final updated = isSelected ? current.where((e) => e.id != employee.id).toList() : [...current, employee];
      return form.copyWith(selectedEmployees: updated);
    });
  }

  Future<void> onEmployeeSearchQueryChange(String query) async {
    state = state.copyWith(employeeSearchQuery: query);
    _employeeSearchTimer?.cancel();
    final completer = Completer<void>();
    _employeeSearchTimer = Timer(_employeeSearchDebounce, () => completer.complete());
    await completer.future;

    state = state.copyWith(isSearchingEmployees: true);
    final searchEmployeesUseCase = ref.read(searchEmployeesUseCaseProvider);
    final sessionExpirationHandler = ref.read(sessionExpirationHandlerProvider);
    final result = await searchEmployeesUseCase(query);
    await result.when(
      success: (results) async {
        state = state.copyWith(employeeSearchResults: results, isSearchingEmployees: false);
      },
      logout: (message, _) async {
        await sessionExpirationHandler.handle();
        state = state.copyWith(isSearchingEmployees: false);
        _events.add(RequisitionCreateSessionExpired(message));
      },
      error: (message, code) async => state = state.copyWith(isSearchingEmployees: false),
      offline: (message) async => state = state.copyWith(isSearchingEmployees: false),
      maintenance: (message, code) async => state = state.copyWith(isSearchingEmployees: false),
    );
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
    final sessionExpirationHandler = ref.read(sessionExpirationHandlerProvider);
    final result = await submitRequisitionUseCase(request);
    await result.when(
      success: (_) async {
        state = state.copyWith(isSubmitting: false);
        _events.add(const RequisitionSubmitted());
      },
      error: (message, _) async {
        state = state.copyWith(isSubmitting: false, submitError: message ?? TmsStrings.newRequisitionSubmitFailed);
      },
      offline: (message) async {
        state = state.copyWith(isSubmitting: false, submitError: message);
      },
      maintenance: (message, _) async {
        state = state.copyWith(isSubmitting: false, submitError: message);
      },
      logout: (message, _) async {
        await sessionExpirationHandler.handle();
        state = state.copyWith(isSubmitting: false);
        _events.add(RequisitionCreateSessionExpired(message));
      },
    );
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
    if (form.requiredFor == RequiredFor.someoneElse && form.selectedEmployees.isEmpty) {
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
