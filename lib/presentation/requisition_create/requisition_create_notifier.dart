import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/api_capabilities.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../../domain/model/user.dart';
import '../../domain/requisition_field_limits.dart';
import '../common/strings.dart';
import 'requisition_create_state.dart';

const _employeeSearchDebounce = Duration(milliseconds: 300);
const _httpConflict = 409;

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

  /// Loads an existing requisition into the form for editing.
  ///
  /// Called once, from the edit screen's first frame. The requisition's own type
  /// decides which form is shown and is then frozen: `PUT` rejects a `req_type` that
  /// differs from the stored one, so the toggle is locked for the rest of the session.
  void seedFrom(Requisition requisition) {
    if (state.isEditing) return;

    final details = requisition.details;
    state = switch (details) {
      PassengerDetails() => state.copyWith(
          editingRequisitionId: requisition.id,
          editingRequesterName: requisition.requesterName,
          editingRequesterCode: requisition.requesterCode,
          editingRequesterDepartment: requisition.departmentName,
          editingRequesterCompany: requisition.companyName,
          formType: RequisitionFormType.passenger,
          passengerForm: PassengerFormState(
            pickupDateTime: requisition.pickupDateTime,
            pickupLocation: requisition.pickupLocation,
            dropLocation: requisition.dropLocation,
            usedType: details.usedType,
            customerName: details.customerName,
            // Derived from the seeded riders, not copied from the stored
            // `no_of_person`: the two must agree on submit, and if the detail response
            // carried fewer riders than it claims persons, the selection is the half we
            // can actually send.
            numberOfPersons: '${details.riders.length}',
            requiredFor: details.requiredFor,
            userType: details.userType ?? RequisitionUserType.internal,
            // Seeded from the names the response itself carried, then enriched from the
            // directory below. Without this the edit form opened with an empty picker
            // and — since `employee_id` REPLACES the whole list — saving would silently
            // drop every rider from someone's trip.
            selectedEmployees: details.riders.map(_seededRider).toList(),
            purpose: details.purpose,
            remarks: requisition.remarks ?? '',
          ),
        ),
      LogisticsDetails() => state.copyWith(
          editingRequisitionId: requisition.id,
          editingRequesterName: requisition.requesterName,
          editingRequesterCode: requisition.requesterCode,
          editingRequesterDepartment: requisition.departmentName,
          editingRequesterCompany: requisition.companyName,
          formType: RequisitionFormType.logistics,
          logisticsForm: LogisticsFormState(
            pickupDateTime: requisition.pickupDateTime,
            pickupLocation: requisition.pickupLocation,
            dropLocation: requisition.dropLocation,
            // vehicleType now round-trips: it is the logistics meaning of
            // `requisition_for`, so the stored value is real and is sent back.
            vehicleType: details.vehicleType,
            customerName: details.customerName,
            userDepartment: details.userDepartment,
            loadingCapacity: details.loadingCapacity,
            goodsWeight: details.goodsWeight,
            storeName: details.storeName,
            goodsDetails: details.goodsDetails,
            remarks: requisition.remarks ?? '',
          ),
        ),
    };

    if (state.formType == RequisitionFormType.passenger &&
        state.passengerForm.selectedEmployees.isNotEmpty) {
      unawaited(_resolveSeededRiders());
    }
  }

  /// A rider as the requisition itself described them.
  ///
  /// `employees[]` carries `full_name` and `id_no`, so the chip reads correctly on the
  /// first frame instead of waiting on the 92KB directory — which may also fail, or be
  /// missing this person entirely if they have since gone inactive. Designation,
  /// department and company are genuinely unknown here and stay empty until
  /// [_resolveSeededRiders] fills them.
  ///
  /// A rider with no name (a bare-id wire entry) keeps the unresolved label. Either
  /// way [Employee.id] holds the submittable id, so an edit saved before the directory
  /// arrives still sends the right riders rather than dropping them.
  static Employee _seededRider(RequisitionRider rider) => Employee(
        id: rider.id,
        name: rider.hasName
            ? rider.name
            : TracGoStrings.newRequisitionRiderUnresolved,
        employeeCode: rider.employeeCode.isNotEmpty ? rider.employeeCode : rider.id,
        designation: '',
        department: '',
        company: '',
      );

  /// Replaces seeded placeholders with their real directory records.
  ///
  /// Ids with no match are left as placeholders rather than dropped: an employee who
  /// has since gone inactive is absent from the directory but is still genuinely on the
  /// requisition, and silently removing them would be the same unintended replacement
  /// this seeding exists to prevent. The server has the final say on submit.
  Future<void> _resolveSeededRiders() async {
    final result = await ref.read(searchEmployeesUseCaseProvider)('');
    if (isDisposed || result is! ApiSuccess<List<Employee>>) return;

    final byId = {for (final e in result.response) e.id: e};
    final current = state.passengerForm.selectedEmployees;
    final resolved = current.map((e) => byId[e.id] ?? e).toList();
    setStateIfAlive(
      state.copyWith(
        passengerForm: state.passengerForm.copyWith(selectedEmployees: resolved),
      ),
    );
  }

  void switchFormType(RequisitionFormType type) {
    // Guarded rather than merely hidden in the UI: this resets both forms, so reaching
    // it while editing would silently discard the loaded requisition.
    if (state.isEditing) return;
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
  // `onNumberOfPersonsChange` is deliberately gone. `no_of_person` must equal the
  // number of selected riders exactly — the server rejects any other combination — so
  // it is derived from the selection in [toggleEmployeeSelection] and shown read-only.
  // Leaving it editable would let the user express a state that can only ever 422.
  void onRequiredForChange(RequiredFor value) {
    _updatePassenger(null, (f) => f.copyWith(requiredFor: value));
    // Switching to "Own User" is the moment the requester becomes a rider by default.
    if (value == RequiredFor.ownUser) unawaited(_preselectRequester());
  }
  void onUserTypeChange(RequisitionUserType value) => _updatePassenger(null, (f) => f.copyWith(userType: value));
  void onPurposeChange(String value) => _updatePassenger(RequisitionFormField.purpose, (f) => f.copyWith(purpose: value));
  void onPassengerRemarksChange(String value) => _updatePassenger(null, (f) => f.copyWith(remarks: value));

  void toggleEmployeeSelection(Employee employee) {
    final current = state.passengerForm.selectedEmployees;
    final isSelected = current.any((e) => e.id == employee.id);
    // `no_of_person` is derived from this list and the server caps it at 15, so an
    // addition beyond the cap is refused here with a message rather than accepted into
    // a selection that could only ever 422 on submit. Deselection is always allowed —
    // it is the way back down from an over-cap seeded edit.
    if (!isSelected && current.length >= RequisitionFieldLimits.maxPassengers) {
      state = state.copyWith(
        fieldErrors: {
          ...state.fieldErrors,
          RequisitionFormField.employees:
              TracGoStrings.newRequisitionErrorTooManyEmployees(
            RequisitionFieldLimits.maxPassengers,
          ),
        },
      );
      return;
    }

    _updatePassenger(RequisitionFormField.employees, (form) {
      final current = form.selectedEmployees;
      final isSelected = current.any((e) => e.id == employee.id);
      final updated = isSelected
          ? current.where((e) => e.id != employee.id).toList()
          : [...current, employee];
      // Keyed by id, so re-tapping a row deselects rather than adding a second copy —
      // which is also what keeps the server's `distinct` rule unreachable.
      return form.copyWith(
        selectedEmployees: updated,
        // Derived, never typed. See the note where the setter used to be.
        numberOfPersons: '${updated.length}',
      );
    });
  }

  /// Pre-selects the signed-in user as a rider on an "Own User" requisition.
  ///
  /// Only for a fresh create with nothing chosen yet: in edit mode the seeded rider
  /// list is the truth, and overwriting it would silently change someone's trip.
  ///
  /// **The identity comes from `GET /user`, and it has to.** The session's `user.id` is
  /// the *email* — `POST /login` returns no id at all, so the login mapper uses the
  /// username as the local identifier. Comparing that against the directory's `id`
  /// (3035) or `id_no` ("2-765") matched nothing, ever, which meant this pre-selection
  /// had never once fired.
  ///
  /// `GET /user` is the only endpoint that bridges the two: it returns both the account
  /// id (864) and `employee_id` (3035), and the latter is exactly the directory's
  /// surrogate `id` — verified against the live server for this account. The account id
  /// is deliberately not used as a fallback; it is a different key space and would
  /// match a stranger's employee row.
  ///
  /// If anything here comes back empty the requester is simply not pre-selected and the
  /// user picks manually, which is far better than seeding the wrong person.
  Future<void> _preselectRequester() async {
    if (state.isEditing) return;
    if (state.passengerForm.requiredFor != RequiredFor.ownUser) return;
    if (state.passengerForm.selectedEmployees.isNotEmpty) return;

    final account = await ref.read(getUserAccountUseCaseProvider)();
    if (isDisposed || account is! ApiSuccess<UserAccount>) return;
    final employeeId = account.response.employeeId;
    if (employeeId == null || employeeId.isEmpty) return;

    // Empty query returns the whole directory, served from cache after the first call.
    final result = await ref.read(searchEmployeesUseCaseProvider)('');
    if (isDisposed || result is! ApiSuccess<List<Employee>>) return;

    final match = result.response.where((e) => e.id == employeeId).firstOrNull;
    if (match == null) return;

    // Re-checked after the await: the user may have picked someone, switched to
    // "Someone Else", or started editing while the directory was loading.
    if (state.isEditing ||
        state.passengerForm.requiredFor != RequiredFor.ownUser ||
        state.passengerForm.selectedEmployees.isNotEmpty) {
      return;
    }
    toggleEmployeeSelection(match);
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
        _onEmployeeSearchFailed(message ?? TracGoStrings.newRequisitionEmployeeSearchFailed);
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
    final editingId = s.editingRequisitionId;
    // Same payload either way — PUT is a full replacement with exactly the create body,
    // so one builder serves both and the two cannot drift apart.
    final result = editingId == null
        ? await ref.read(submitRequisitionUseCaseProvider)(request)
        : await ref.read(updateRequisitionUseCaseProvider)(editingId, request);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<Requisition>():
        setStateIfAlive(state.copyWith(isSubmitting: false));
        emitEvent(RequisitionSubmitted(wasEdit: s.isEditing));
      // Gated on editingId: only an edit can be rejected for having left `Pending`.
      // A 409 from create (a duplicate-submission guard, say) must not pop the screen
      // and throw away everything the user typed.
      case ApiError<Requisition>(:final message, :final errorCode)
          when errorCode == _httpConflict && editingId != null:
        // The requisition left `Pending` while this form was open. The edit can never
        // succeed now, so the screen closes and the detail behind it resyncs rather
        // than leaving the user retrying a save the server will keep refusing.
        setStateIfAlive(state.copyWith(isSubmitting: false));
        emitEvent(RequisitionEditRejected(message ?? NetworkMessages.stale));
      case ApiError<Requisition>(:final message, :final fieldErrors):
        // An "inactive employee" rejection is proof the cached directory has gone stale
        // mid-session: it lists somebody the server no longer accepts. Drop it so the
        // next search refetches — otherwise the user re-picks from the same stale list
        // and earns the same 422. Only this message triggers a refetch; a count
        // mismatch says nothing about freshness and would cost a needless 146KB.
        if (_mentionsInactiveEmployee(fieldErrors)) {
          ref.read(requisitionRepositoryProvider).invalidateEmployeeCache();
        }
        // A 422 carries field-keyed messages; pin them to the offending inputs
        // instead of dumping one opaque banner at the top of the form.
        setStateIfAlive(state.copyWith(
          isSubmitting: false,
          submitError: message ?? TracGoStrings.newRequisitionSubmitFailed,
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

  /// Whether a 422's field errors say a selected employee is no longer selectable.
  ///
  /// Two things about this were wrong before, and each on its own made it never fire:
  ///
  /// 1. **The key is indexed.** Laravel reports the failure per item, as
  ///    `employee_id.0`, not `employee_id` — so a plain map lookup found nothing.
  /// 2. **The wording is not the contract's.** The contract advertises "One or more
  ///    selected employees are inactive or do not have an active user account."; the
  ///    server actually answers `exists`-rule boilerplate, "The selected employee_id.0
  ///    is invalid." Matching on "inactive" alone missed every real occurrence.
  ///
  /// Both spellings are accepted now. The count-mismatch and duplicate-value errors
  /// share the `employee_id` prefix and must *not* match: neither says anything about
  /// the cache being stale, and refetching 94KB on them would be pure waste.
  static bool _mentionsInactiveEmployee(Map<String, String>? fieldErrors) {
    if (fieldErrors == null) return false;
    for (final entry in fieldErrors.entries) {
      if (entry.key.split('.').first != 'employee_id') continue;
      final message = entry.value.toLowerCase();
      if (message.contains('inactive') || message.contains('is invalid')) return true;
    }
    return false;
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
      'remarks': RequisitionFormField.remarks,
      // The logistics-only inputs. These were missing, which mattered once the server's
      // length rules came to light: `user_department` caps at 100 and `goods_weight` at
      // 25, so a 422 on either was landing in the summary banner with no indication of
      // which of the eight fields on that form the user had to fix.
      'user_department': RequisitionFormField.userDepartment,
      'goods_weight': RequisitionFormField.goodsWeight,
      'store_name': RequisitionFormField.storeName,
      'goods_details': RequisitionFormField.goodsDetails,
      // All three employee failure modes — count mismatch, inactive member, duplicate —
      // land on the picker, which is the only control the user can act on to fix any of
      // them.
      'employee_id': RequisitionFormField.employees,
      // `requisition_for`, `requisition_for_user` and `loading_capacity` are absent on
      // purpose: each is a closed dropdown or radio whose every option is server-valid,
      // so a 422 on one means the enum has drifted from the server's `in:` list — a
      // developer problem, not something the user can fix by editing a field. Those
      // fall through to the summary banner, as the doc above describes, and to
      // Crashlytics via safeApiCall.
    };
    final mapped = <String, String>{};
    for (final entry in wireErrors.entries) {
      // Laravel reports per-item failures as `employee_id.1`, not `employee_id`. Without
      // trimming the index the duplicate-value error would match nothing and vanish from
      // the form entirely.
      final key = entry.key.split('.').first;
      final field = wireToField[key];
      if (field != null) mapped.putIfAbsent(field, () => entry.value);
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
        // Both derived from the one selection, so they cannot disagree. Sending
        // `no_of_person` from a separate text field is what the server's count rule
        // exists to catch.
        numberOfPersons: form.selectedEmployees.length,
        requiredFor: form.requiredFor,
        // "Own User" admits only "Internal User"; sending anything else is a documented
        // 422. Null lets the mapper apply that default rather than encoding it twice.
        userType: form.requiredFor == RequiredFor.someoneElse ? form.userType : null,
        // Riders go on every passenger requisition now, not just "Someone Else" — the
        // contract's own worked example is an "Own User" trip with three of them.
        employeeIds: form.selectedEmployees.map((e) => e.id).toList(),
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
    const required = TracGoStrings.newRequisitionErrorRequired;
    final errors = <String, String>{};
    if (form.pickupDateTime == null) errors[RequisitionFormField.pickupDateTime] = required;
    _checkText(errors, RequisitionFormField.pickupLocation, form.pickupLocation);
    _checkText(errors, RequisitionFormField.dropLocation, form.dropLocation);
    _checkText(errors, RequisitionFormField.customerName, form.customerName);
    _checkText(errors, RequisitionFormField.purpose, form.purpose);
    _checkOptionalText(errors, RequisitionFormField.remarks, form.remarks);
    // Now demanded on every passenger requisition, not just "Someone Else":
    // `employee_id` must hold exactly `no_of_person` active ids, and `no_of_person` is
    // the selection count, so an empty picker means a zero-person trip the server will
    // reject. There is no separate number-of-persons check any more — it cannot
    // disagree with a value derived from this same list.
    if (ApiCapabilities.employeeDirectory) {
      final count = form.selectedEmployees.length;
      if (count < RequisitionFieldLimits.minPassengers) {
        errors[RequisitionFormField.employees] = TracGoStrings.newRequisitionErrorSelectEmployee;
      } else if (count > RequisitionFieldLimits.maxPassengers) {
        // Unreachable through the picker, which stops accepting additions at the cap.
        // Kept because a seeded edit can arrive over it: the requisition was created
        // elsewhere, and the user must be told why it will not save rather than being
        // handed a bare server 422.
        errors[RequisitionFormField.employees] =
            TracGoStrings.newRequisitionErrorTooManyEmployees(
          RequisitionFieldLimits.maxPassengers,
        );
      }
    }
    return errors;
  }

  Map<String, String> _validateLogistics(LogisticsFormState form) {
    const required = TracGoStrings.newRequisitionErrorRequired;
    final errors = <String, String>{};
    if (form.pickupDateTime == null) errors[RequisitionFormField.pickupDateTime] = required;
    _checkText(errors, RequisitionFormField.pickupLocation, form.pickupLocation);
    _checkText(errors, RequisitionFormField.dropLocation, form.dropLocation);
    _checkText(errors, RequisitionFormField.customerName, form.customerName);
    _checkText(errors, RequisitionFormField.userDepartment, form.userDepartment,
        maximum: RequisitionFieldLimits.shortMaxLength);
    _checkText(errors, RequisitionFormField.storeName, form.storeName,
        maximum: RequisitionFieldLimits.shortMaxLength);
    _checkText(errors, RequisitionFormField.goodsDetails, form.goodsDetails);
    // `goods_weight` is required but carries no `min:3` — "1t" is a legitimate answer —
    // so it gets the emptiness check and its own much tighter cap, nothing else.
    if (form.goodsWeight.trim().isEmpty) {
      errors[RequisitionFormField.goodsWeight] = required;
    } else if (form.goodsWeight.trim().length > RequisitionFieldLimits.goodsWeightMaxLength) {
      errors[RequisitionFormField.goodsWeight] = TracGoStrings.newRequisitionErrorTooLong(
        RequisitionFieldLimits.goodsWeightMaxLength,
      );
    }
    _checkOptionalText(errors, RequisitionFormField.remarks, form.remarks);
    return errors;
  }

  /// Required text: present, at least [RequisitionFieldLimits.minTextLength] characters,
  /// no longer than [maximum].
  ///
  /// Length is measured on the *trimmed* value because that is what
  /// [_buildRequest]/the mapper send — checking the untrimmed string would pass a value
  /// of three spaces that the server then rejects as empty.
  static void _checkText(
    Map<String, String> errors,
    String field,
    String value, {
    int maximum = RequisitionFieldLimits.defaultMaxLength,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      errors[field] = TracGoStrings.newRequisitionErrorRequired;
    } else if (trimmed.length < RequisitionFieldLimits.minTextLength) {
      errors[field] = TracGoStrings.newRequisitionErrorTooShort(
        RequisitionFieldLimits.minTextLength,
      );
    } else if (trimmed.length > maximum) {
      errors[field] = TracGoStrings.newRequisitionErrorTooLong(maximum);
    }
  }

  /// Optional text: only the cap applies. An empty `remarks` is sent as null, and the
  /// server has no minimum on it.
  static void _checkOptionalText(
    Map<String, String> errors,
    String field,
    String value, {
    int maximum = RequisitionFieldLimits.defaultMaxLength,
  }) {
    final trimmed = value.trim();
    if (trimmed.length > maximum) {
      errors[field] = TracGoStrings.newRequisitionErrorTooLong(maximum);
    }
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
