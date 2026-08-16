import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/api_capabilities.dart';
import '../../domain/model/employee.dart';
import '../../domain/model/requisition.dart';
import '../../domain/requisition_field_limits.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/choice_pill.dart';
import '../common/date_time_field.dart';
import '../common/safe_insets.dart';
import '../common/section_label.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';
import 'form_controls.dart';
import 'requisition_create_notifier.dart';
import 'requisition_create_state.dart';

String _vehicleHint(VehicleType type) => switch (type) {
  VehicleType.coverVan => TracGoStrings.vehicleTypeCoverVanHint,
  VehicleType.openTruck => TracGoStrings.vehicleTypeOpenTruckHint,
};

class RequisitionCreateScreen extends ConsumerStatefulWidget {
  const RequisitionCreateScreen({
    super.key,
    required this.onBack,
    required this.onSubmitted,
    this.existing,
    this.onEditRejected,
  });

  final VoidCallback onBack;
  final VoidCallback onSubmitted;

  /// Invoked when the server refuses the edit outright (409 — no longer `Pending`).
  /// Distinct from [onBack] because the caller must also resync: the screen underneath
  /// is showing a status that is now wrong. Falls back to [onBack] when not supplied.
  final VoidCallback? onEditRejected;

  /// Non-null puts the screen in edit mode: the form is seeded from this requisition,
  /// submit becomes a PUT, and the type toggle locks. The whole point of reusing this
  /// screen is that create and edit cannot drift apart — same widgets, same validation,
  /// same field-error wiring.
  final Requisition? existing;

  @override
  ConsumerState<RequisitionCreateScreen> createState() => _RequisitionCreateScreenState();
}

class _RequisitionCreateScreenState extends ConsumerState<RequisitionCreateScreen> {
  StreamSubscription<RequisitionCreateEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(requisitionCreateNotifierProvider.notifier);
      _eventSub = notifier.events.listen((event) {
        if (!mounted) return;
        switch (event) {
          case RequisitionSubmitted():
            widget.onSubmitted();
          case RequisitionEditRejected(:final message):
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            // Nothing here can succeed any more; hand control back so the detail
            // underneath refetches and shows what the requisition actually is now.
            (widget.onEditRejected ?? widget.onBack)();
          case RequisitionCreateSessionExpired(:final message):
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      });
      final existing = widget.existing;
      if (existing != null) notifier.seedFrom(existing);
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(requisitionCreateNotifierProvider);
    final notifier = ref.read(requisitionCreateNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          uiState.isEditing
              ? TracGoStrings.editRequisitionTitle
              : TracGoStrings.newRequisitionTitle,
          style: tracGoScreenTitleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tracGoInk),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PillSegmentedToggle(
                    selected: uiState.formType,
                    onSelect: notifier.switchFormType,
                    // req_type is immutable server-side, so the choice is fixed once
                    // the requisition exists.
                    locked: uiState.isEditing,
                  ),
                  const SizedBox(height: 22),
                  // Editing only, and only when the server actually reported a
                  // requester: it answers "whose requisition am I changing?" before the
                  // first field, and there is nobody to name on a fresh create.
                  if (uiState.isEditing && uiState.hasRequesterInfo) ...[
                    _RequesterHeader(uiState: uiState),
                    const SizedBox(height: 22),
                  ],
                  if (uiState.submitError != null) ...[
                    _SubmitError(message: uiState.submitError!),
                    const SizedBox(height: 18),
                  ],
                  if (uiState.formType == RequisitionFormType.passenger)
                    _PassengerFormFields(uiState: uiState, notifier: notifier)
                  else
                    _LogisticsFormFields(uiState: uiState, notifier: notifier),
                ],
              ),
            ),
          ),
          Padding(
            // Submit is the last thing in a Column, not a bottomNavigationBar, so
            // Scaffold reserves no space for it and nothing applies the system inset —
            // it rendered under Android's navigation buttons.
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16)
                .addBottomSystemInset(context),
            child: ElevatedButton(
              // minimumSize, not a fixed height, so the label survives large text scales.
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
              ),
              onPressed:
                  uiState.isSubmitting ? null : () => unawaited(notifier.submit()),
              child: uiState.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tracGoSurfaceWhite,
                      ),
                    )
                  : Text(
                      uiState.isEditing
                          ? TracGoStrings.editRequisitionSave
                          : TracGoStrings.newRequisitionSubmit,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A whole-form failure (a 422 with no field mapping, a network error). Boxed rather
/// than set as bare red text, so it reads as a banner about the form rather than as the
/// error message of whichever field happens to sit under it.
class _SubmitError extends StatelessWidget {
  const _SubmitError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: tracGoStatusRejectedBg,
      borderColor: null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: tracGoStatusRejectedText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: tracGoTextTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tracGoStatusRejectedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only requester card shown above the edit form.
///
/// Purely informational — none of it is editable, because none of it is in the `PUT`
/// body. Every line is conditional: the fields arrive independently, and a row for a
/// value the server never sent would read as an empty department rather than an unknown
/// one.
class _RequesterHeader extends StatelessWidget {
  const _RequesterHeader({required this.uiState});

  final RequisitionCreateUiState uiState;

  @override
  Widget build(BuildContext context) {
    final name = uiState.editingRequesterName?.trim() ?? '';
    final code = uiState.editingRequesterCode?.trim() ?? '';
    final department = uiState.editingRequesterDepartment?.trim() ?? '';
    final company = uiState.editingRequesterCompany?.trim() ?? '';

    final primary = switch ((name.isNotEmpty, code.isNotEmpty)) {
      (true, true) => '$name · $code',
      (true, false) => name,
      (false, true) => code,
      (false, false) => '',
    };
    // Department and company are joined on one line to keep the card two lines tall at
    // default text size; the Text below still wraps at large scales rather than
    // clipping.
    final secondary = [department, company].where((v) => v.isNotEmpty).join(' · ');

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(TracGoStrings.requisitionDetailRequestedBy),
          if (primary.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              primary,
              style: tracGoTextTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(secondary, style: tracGoTextTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _PillSegmentedToggle extends StatelessWidget {
  const _PillSegmentedToggle({
    required this.selected,
    required this.onSelect,
    this.locked = false,
  });

  final RequisitionFormType selected;
  final ValueChanged<RequisitionFormType> onSelect;

  /// Editing an existing requisition. Both segments become inert.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    // Logistics is live: the server accepts `req_type: logistic_support`. This kept a
    // disabled branch while that was unconfirmed; the flag remains so the segment can
    // be switched off again from one place if the backend ever withdraws it.
    const logisticsEnabled = ApiCapabilities.logisticsRequisitions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: tracGoBorder,
            borderRadius: pillBorderRadius,
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _SegmentPill(
                  label: TracGoStrings.newRequisitionTogglePassenger,
                  selected: selected == RequisitionFormType.passenger,
                  enabled: !locked,
                  onTap: locked ? null : () => onSelect(RequisitionFormType.passenger),
                ),
              ),
              Expanded(
                child: _SegmentPill(
                  label: TracGoStrings.newRequisitionToggleLogistics,
                  selected: selected == RequisitionFormType.logistics,
                  enabled: logisticsEnabled && !locked,
                  onTap: logisticsEnabled && !locked
                      ? () => onSelect(RequisitionFormType.logistics)
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (locked)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              TracGoStrings.editRequisitionTypeLocked,
              style: tracGoTextTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: enabled,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: pillBorderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? tracGoInk : Colors.transparent,
            borderRadius: pillBorderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: tracGoTextTheme.bodyMedium?.copyWith(
              color: selected
                  ? tracGoSurfaceWhite
                  : (enabled ? tracGoTextMuted : tracGoPlaceholder),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// A numbered step: header, then the card of fields belonging to it.
class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.step,
    required this.label,
    required this.children,
  });

  final int step;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepSectionLabel(step: step, label: label),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _PassengerFormFields extends StatelessWidget {
  const _PassengerFormFields({required this.uiState, required this.notifier});

  final RequisitionCreateUiState uiState;
  final RequisitionCreateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final form = uiState.passengerForm;
    final errors = uiState.fieldErrors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormStep(
          step: 1,
          label: TracGoStrings.newRequisitionSectionTripDetails,
          children: [
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldPickupDatetime,
                  error: errors[RequisitionFormField.pickupDateTime],
                  child: DateTimeField(
                    hint: TracGoStrings.newRequisitionHintPickupDatetime,
                    value: form.pickupDateTime,
                    onChanged: notifier.onPassengerPickupDateTimeChange,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldPickupLocation,
                  error: errors[RequisitionFormField.pickupLocation],
                  child: InlineTextField(
                    value: form.pickupLocation,
                    onChanged: notifier.onPassengerPickupLocationChange,
                    hint: TracGoStrings.newRequisitionHintPickupLocation,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldDropLocation,
                  error: errors[RequisitionFormField.dropLocation],
                  child: InlineTextField(
                    value: form.dropLocation,
                    onChanged: notifier.onPassengerDropLocationChange,
                    hint: TracGoStrings.newRequisitionHintDropLocation,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldUsedType,
                  child: ChoicePillRow<UsedType>(
                    options: UsedType.values,
                    selected: form.usedType,
                    labelFor: (v) => v.label,
                    onSelect: notifier.onUsedTypeChange,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        _FormStep(
          step: 2,
          label: TracGoStrings.newRequisitionSectionPassengerDetails,
          children: [
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldCustomerName,
                  error: errors[RequisitionFormField.customerName],
                  child: InlineTextField(
                    value: form.customerName,
                    onChanged: notifier.onPassengerCustomerNameChange,
                    hint: TracGoStrings.newRequisitionHintCustomerName,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldRequiredFor,
                  child: ChoicePillRow<RequiredFor>(
                    options: RequiredFor.values,
                    selected: form.requiredFor,
                    labelFor: (v) => v.label,
                    onSelect: notifier.onRequiredForChange,
                  ),
                ),
                // The user type control stays specific to "Someone Else": an "Own User"
                // requisition admits only "Internal User", and offering the other option
                // would let the user build a combination the server documents as a 422.
                if (ApiCapabilities.employeeDirectory &&
                    form.requiredFor == RequiredFor.someoneElse)
                  FormFieldRow(
                    label: TracGoStrings.newRequisitionFieldUserType,
                    child: ChoicePillRow<RequisitionUserType>(
                      options: RequisitionUserType.values,
                      selected: form.userType,
                      labelFor: (v) => v.label,
                      onSelect: notifier.onUserTypeChange,
                    ),
                  ),
                // The picker itself is shown for both values of "Required For". Riders
                // are required on every passenger requisition now — the contract's
                // worked example is an "Own User" trip with three of them.
                if (ApiCapabilities.employeeDirectory)
                  _EmployeePicker(
                    query: uiState.employeeSearchQuery,
                    results: uiState.employeeSearchResults,
                    selected: form.selectedEmployees,
                    isSearching: uiState.isSearchingEmployees,
                    error: errors[RequisitionFormField.employees],
                    searchError: uiState.employeeSearchError,
                    onQueryChange: notifier.onEmployeeSearchQueryChange,
                    onToggle: notifier.toggleEmployeeSelection,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      TracGoStrings.unsupportedEmployeePicker,
                      style: tracGoTextTheme.bodySmall,
                    ),
                  ),
                // Derived from the rider selection above: the server requires
                // `no_of_person` to equal the number of selected employees exactly.
                DerivedValueRow(
                  label: TracGoStrings.newRequisitionFieldNumberOfPersons,
                  value: form.numberOfPersons,
                  error: errors[RequisitionFormField.numberOfPersons],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        _FormStep(
          step: 3,
          label: TracGoStrings.newRequisitionSectionPurpose,
          children: [
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldPurpose,
                  error: errors[RequisitionFormField.purpose],
                  child: InlineTextField(
                    value: form.purpose,
                    onChanged: notifier.onPurposeChange,
                    hint: TracGoStrings.newRequisitionHintPurpose,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldRemarks,
                  error: errors[RequisitionFormField.remarks],
                  child: InlineTextField(
                    value: form.remarks,
                    onChanged: notifier.onPassengerRemarksChange,
                    hint: TracGoStrings.newRequisitionHintRemarks,
                    singleLine: false,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _LogisticsFormFields extends StatelessWidget {
  const _LogisticsFormFields({required this.uiState, required this.notifier});

  final RequisitionCreateUiState uiState;
  final RequisitionCreateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final form = uiState.logisticsForm;
    final errors = uiState.fieldErrors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormStep(
          step: 1,
          label: TracGoStrings.newRequisitionSectionVehicleDetails,
          children: [
            // IntrinsicHeight so a wrapped title in one card does not leave the card
            // beside it visibly shorter.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final type in VehicleType.values) ...[
                    if (type != VehicleType.values.first)
                      const SizedBox(width: 10),
                    Expanded(
                      child: SelectableTypeCard(
                        title: type.label,
                        subtitle: _vehicleHint(type),
                        selected: form.vehicleType == type,
                        onTap: () => notifier.onVehicleTypeChange(type),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldLoadingCapacity,
                  child: ChoicePillRow<LoadingCapacity>(
                    options: LoadingCapacity.values,
                    selected: form.loadingCapacity,
                    labelFor: (v) => v.label,
                    onSelect: notifier.onLoadingCapacityChange,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldGoodsWeight,
                  error: errors[RequisitionFormField.goodsWeight],
                  child: InlineTextField(
                    value: form.goodsWeight,
                    onChanged: notifier.onGoodsWeightChange,
                    hint: TracGoStrings.newRequisitionHintGoodsWeight,
                    maxLength: RequisitionFieldLimits.goodsWeightMaxLength,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        _FormStep(
          step: 2,
          label: TracGoStrings.newRequisitionSectionTripDetails,
          children: [
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldPickupDatetime,
                  error: errors[RequisitionFormField.pickupDateTime],
                  child: DateTimeField(
                    hint: TracGoStrings.newRequisitionHintPickupDatetime,
                    value: form.pickupDateTime,
                    onChanged: notifier.onLogisticsPickupDateTimeChange,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldPickupLocation,
                  error: errors[RequisitionFormField.pickupLocation],
                  child: InlineTextField(
                    value: form.pickupLocation,
                    onChanged: notifier.onLogisticsPickupLocationChange,
                    hint: TracGoStrings.newRequisitionHintPickupSite,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldDropLocation,
                  error: errors[RequisitionFormField.dropLocation],
                  child: InlineTextField(
                    value: form.dropLocation,
                    onChanged: notifier.onLogisticsDropLocationChange,
                    hint: TracGoStrings.newRequisitionHintDropSite,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        _FormStep(
          step: 3,
          label: TracGoStrings.newRequisitionSectionRequesterDetails,
          children: [
            FormCard(
              rows: [
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldCustomerName,
                  error: errors[RequisitionFormField.customerName],
                  child: InlineTextField(
                    value: form.customerName,
                    onChanged: notifier.onLogisticsCustomerNameChange,
                    hint: TracGoStrings.newRequisitionHintCustomerName,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldUserDepartment,
                  error: errors[RequisitionFormField.userDepartment],
                  child: InlineTextField(
                    value: form.userDepartment,
                    onChanged: notifier.onUserDepartmentChange,
                    hint: TracGoStrings.newRequisitionHintUserDepartment,
                    maxLength: RequisitionFieldLimits.shortMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldStoreName,
                  error: errors[RequisitionFormField.storeName],
                  child: InlineTextField(
                    value: form.storeName,
                    onChanged: notifier.onStoreNameChange,
                    hint: TracGoStrings.newRequisitionHintStoreName,
                    maxLength: RequisitionFieldLimits.shortMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldGoodsDetails,
                  error: errors[RequisitionFormField.goodsDetails],
                  child: InlineTextField(
                    value: form.goodsDetails,
                    onChanged: notifier.onGoodsDetailsChange,
                    hint: TracGoStrings.newRequisitionHintGoodsDetails,
                    singleLine: false,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
                FormFieldRow(
                  label: TracGoStrings.newRequisitionFieldRemarks,
                  error: errors[RequisitionFormField.remarks],
                  child: InlineTextField(
                    value: form.remarks,
                    onChanged: notifier.onLogisticsRemarksChange,
                    hint: TracGoStrings.newRequisitionHintRemarks,
                    singleLine: false,
                    maxLength: RequisitionFieldLimits.defaultMaxLength,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Selected riders as removable pills, with a search field underneath and the result
/// list below that.
class _EmployeePicker extends StatefulWidget {
  const _EmployeePicker({
    required this.query,
    required this.results,
    required this.selected,
    required this.isSearching,
    required this.error,
    required this.searchError,
    required this.onQueryChange,
    required this.onToggle,
  });

  final String query;
  final List<Employee> results;
  final List<Employee> selected;
  final bool isSearching;
  final String? error;

  /// A failed lookup, as opposed to [error]'s "you must pick someone". Without this
  /// the two are indistinguishable: both leave an empty result list on screen.
  final String? searchError;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<Employee> onToggle;

  @override
  State<_EmployeePicker> createState() => _EmployeePickerState();
}

class _EmployeePickerState extends State<_EmployeePicker> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return FormFieldRow(
      label: TracGoStrings.newRequisitionFieldSelectEmployees,
      error: widget.error ?? widget.searchError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final employee in widget.selected)
                    _SelectedEmployeeChip(
                      name: employee.name,
                      onRemove: () => widget.onToggle(employee),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              const Icon(Icons.search, size: 18, color: tracGoTextMutedAlt),
              const SizedBox(width: 8),
              Expanded(
                child: InlineTextField(
                  value: widget.query,
                  onChanged: (value) {
                    widget.onQueryChange(value);
                    setState(() => _expanded = true);
                  },
                  hint: TracGoStrings.newRequisitionHintEmployeeSearch,
                ),
              ),
              if (widget.isSearching)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          // A search that matched nobody used to render exactly nothing, which is
          // indistinguishable from the dropdown having failed to open. Guarded on
          // `searchError == null` so a failed lookup keeps saying it failed rather than
          // claiming there were no matches.
          if (_expanded &&
              widget.results.isEmpty &&
              !widget.isSearching &&
              widget.searchError == null &&
              widget.query.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                TracGoStrings.newRequisitionEmployeeNoMatches,
                style: tracGoTextTheme.bodySmall,
              ),
            ),
          if (_expanded && widget.results.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10),
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: tracGoInputBackground,
                borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final employee in widget.results)
                    ListTile(
                      dense: true,
                      title: Text(
                        employee.name,
                        style: tracGoTextTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${employee.designation}, ${employee.department}',
                        style: tracGoTextTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                      onTap: () {
                        widget.onToggle(employee);
                        setState(() => _expanded = false);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedEmployeeChip extends StatelessWidget {
  const _SelectedEmployeeChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: const BoxDecoration(
        color: tracGoSurfaceSoft,
        borderRadius: pillBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A long name is bounded by the enclosing Wrap's run width rather than
          // pushing the chip past the card.
          Flexible(
            child: Text(
              name,
              style: tracGoTextTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tracGoInk,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: Semantics(
              button: true,
              label: TracGoStrings.newRequisitionRemoveEmployee(name),
              excludeSemantics: true,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 15, color: tracGoTextMutedAlt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
