import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';

part 'requisition_create_state.freezed.dart';

enum RequisitionFormType { passenger, logistics }

@freezed
abstract class PassengerFormState with _$PassengerFormState {
  const factory PassengerFormState({
    DateTime? pickupDateTime,
    @Default('') String pickupLocation,
    @Default('') String dropLocation,
    // pickupAndDrop, not pickup: `UsedType.pickup` is not in the contract's enum and
    // so is absent from UsedType.selectable — defaulting to it would seed the dropdown
    // with a value its own option list does not contain.
    @Default(UsedType.pickupAndDrop) UsedType usedType,
    @Default('') String customerName,
    @Default('') String numberOfPersons,
    @Default(RequiredFor.ownUser) RequiredFor requiredFor,
    @Default(RequisitionUserType.internal) RequisitionUserType userType,
    @Default(<Employee>[]) List<Employee> selectedEmployees,
    @Default('') String purpose,
    @Default('') String remarks,
  }) = _PassengerFormState;
}

@freezed
abstract class LogisticsFormState with _$LogisticsFormState {
  const factory LogisticsFormState({
    DateTime? pickupDateTime,
    @Default('') String pickupLocation,
    @Default('') String dropLocation,
    @Default(VehicleType.coverVan) VehicleType vehicleType,
    @Default('') String customerName,
    @Default('') String userDepartment,
    // ton2, not the old ton1To5: `1-5 Ton` is rejected by the server's `in:` rule,
    // so the previous default made every untouched logistics form fail validation.
    @Default(LoadingCapacity.ton2) LoadingCapacity loadingCapacity,
    @Default('') String goodsWeight,
    @Default('') String storeName,
    @Default('') String goodsDetails,
    @Default('') String remarks,
  }) = _LogisticsFormState;
}

@freezed
abstract class RequisitionCreateUiState with _$RequisitionCreateUiState {
  const factory RequisitionCreateUiState({
    @Default(RequisitionFormType.passenger) RequisitionFormType formType,
    @Default(PassengerFormState()) PassengerFormState passengerForm,
    @Default(LogisticsFormState()) LogisticsFormState logisticsForm,
    @Default('') String employeeSearchQuery,
    @Default(<Employee>[]) List<Employee> employeeSearchResults,
    @Default(false) bool isSearchingEmployees,
    /// Surfaced under the employee picker. Without it a failed lookup is
    /// indistinguishable from "this search genuinely matched nobody".
    String? employeeSearchError,
    @Default(false) bool isSubmitting,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    String? submitError,
  }) = _RequisitionCreateUiState;
}

sealed class RequisitionCreateEvent {
  const RequisitionCreateEvent();
}

class RequisitionSubmitted extends RequisitionCreateEvent {
  const RequisitionSubmitted();
}

class RequisitionCreateSessionExpired extends RequisitionCreateEvent {
  const RequisitionCreateSessionExpired(this.message);
  final String message;
}

class RequisitionFormField {
  RequisitionFormField._();

  static const pickupDateTime = 'pickupDateTime';
  static const pickupLocation = 'pickupLocation';
  static const dropLocation = 'dropLocation';
  static const customerName = 'customerName';
  static const numberOfPersons = 'numberOfPersons';
  static const purpose = 'purpose';
  static const employees = 'employees';
  static const userDepartment = 'userDepartment';
  static const goodsWeight = 'goodsWeight';
  static const storeName = 'storeName';
  static const goodsDetails = 'goodsDetails';
}
