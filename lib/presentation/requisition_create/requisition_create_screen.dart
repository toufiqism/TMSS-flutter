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
import '../common/date_time_field.dart';
import '../common/safe_insets.dart';
import '../common/strings.dart';
import '../common/synced_text_field.dart';
import 'form_controls.dart';
import 'requisition_create_notifier.dart';
import 'requisition_create_state.dart';

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
      appBar: AppBar(
        title: Text(
          uiState.isEditing
              ? TracGoStrings.editRequisitionTitle
              : TracGoStrings.newRequisitionTitle,
          style: tracGoTextTheme.titleMedium,
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: tracGoTextDark), onPressed: widget.onBack),
      ),
      backgroundColor: tracGoPageBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _PillSegmentedToggle(
              selected: uiState.formType,
              onSelect: notifier.switchFormType,
              // req_type is immutable server-side, so the choice is fixed once the
              // requisition exists.
              locked: uiState.isEditing,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editing only, and only when the server actually reported a
                  // requester: it answers "whose requisition am I changing?" before the
                  // first field, and there is nobody to name on a fresh create.
                  if (uiState.isEditing && uiState.hasRequesterInfo) ...[
                    _RequesterHeader(uiState: uiState),
                    const SizedBox(height: 16),
                  ],
                  if (uiState.submitError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(uiState.submitError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  if (uiState.formType == RequisitionFormType.passenger)
                    _PassengerFormFields(uiState: uiState, notifier: notifier)
                  else
                    _LogisticsFormFields(uiState: uiState, notifier: notifier),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            // Submit is the last thing in a Column, not a bottomNavigationBar, so
            // Scaffold reserves no space for it and nothing applies the system inset —
            // it rendered under Android's navigation buttons.
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                .addBottomSystemInset(context),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // minimumSize, not a fixed height, so the label survives large text scales.
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed:
                    uiState.isSubmitting ? null : () => unawaited(notifier.submit()),
                child: uiState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: tracGoSurfaceWhite),
                      )
                    : Text(
                        uiState.isEditing
                            ? TracGoStrings.editRequisitionSave
                            : TracGoStrings.newRequisitionSubmit,
                        style: tracGoTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: tracGoSurfaceWhite),
                      ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tracGoGreenLight,
        borderRadius: tracGoBorderRadius(tracGoRadiusMedium),
        border: Border.all(color: tracGoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TracGoStrings.requisitionDetailRequestedBy.toUpperCase(),
            style: tracGoTextTheme.labelMedium?.copyWith(color: tracGoGreen),
          ),
          if (primary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              primary,
              style: tracGoTextTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: tracGoTextDark,
              ),
            ),
          ],
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              secondary,
              style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextSubtle),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: tracGoSurfaceWhite,
            borderRadius: pillBorderRadius,
            border: Border.all(color: tracGoBorder, width: 1.5),
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
              style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextMutedAlt),
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
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? tracGoGreen : Colors.transparent,
            borderRadius: pillBorderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: tracGoTextTheme.bodyMedium?.copyWith(
              color: selected
                  ? tracGoSurfaceWhite
                  : (enabled ? tracGoTextMutedAlt : tracGoPlaceholder),
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(text.toUpperCase(), style: tracGoTextTheme.labelMedium?.copyWith(color: tracGoGreen)),
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
    const spacing = SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(TracGoStrings.newRequisitionSectionTripDetails),
        DateTimeField(
          label: TracGoStrings.newRequisitionFieldPickupDatetime,
          value: form.pickupDateTime,
          onChanged: notifier.onPassengerPickupDateTimeChange,
          isError: errors.containsKey(RequisitionFormField.pickupDateTime),
          errorText: errors[RequisitionFormField.pickupDateTime],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldPickupLocation,
          value: form.pickupLocation,
          onChanged: notifier.onPassengerPickupLocationChange,
          error: errors[RequisitionFormField.pickupLocation],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldDropLocation,
          value: form.dropLocation,
          onChanged: notifier.onPassengerDropLocationChange,
          error: errors[RequisitionFormField.dropLocation],
        ),
        spacing,
        DropdownField<UsedType>(
          label: TracGoStrings.newRequisitionFieldUsedType,
          options: UsedType.values,
          selected: form.usedType,
          labelFor: (v) => v.label,
          onSelect: notifier.onUsedTypeChange,
        ),
        const _SectionHeader(TracGoStrings.newRequisitionSectionPassengerDetails),
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldCustomerName,
          value: form.customerName,
          onChanged: notifier.onPassengerCustomerNameChange,
          error: errors[RequisitionFormField.customerName],
        ),
        spacing,
        // Read-only and derived from the rider selection below: the server requires
        // `no_of_person` to equal the number of selected employees exactly, so an
        // editable field here could only ever be used to create an invalid state.
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldNumberOfPersons,
          value: form.numberOfPersons,
          onChanged: (_) {},
          enabled: false,
          error: errors[RequisitionFormField.numberOfPersons],
          keyboardType: TextInputType.number,
        ),
        spacing,
        DropdownField<RequiredFor>(
          label: TracGoStrings.newRequisitionFieldRequiredFor,
          options: RequiredFor.values,
          selected: form.requiredFor,
          labelFor: (v) => v.label,
          onSelect: notifier.onRequiredForChange,
        ),
        if (!ApiCapabilities.employeeDirectory)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              TracGoStrings.unsupportedEmployeePicker,
              style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextMutedAlt),
            ),
          ),
        // The user type radio stays specific to "Someone Else": an "Own User"
        // requisition admits only "Internal User", and offering the other option would
        // let the user build a combination the server documents as a 422.
        if (ApiCapabilities.employeeDirectory &&
            form.requiredFor == RequiredFor.someoneElse) ...[
          spacing,
          Text(TracGoStrings.newRequisitionFieldUserType, style: tracGoTextTheme.bodySmall),
          const SizedBox(height: 8),
          RadioRow<RequisitionUserType>(
            options: RequisitionUserType.values,
            selected: form.userType,
            labelFor: (v) => v.label,
            onSelect: notifier.onUserTypeChange,
          ),
        ],
        // The picker itself is shown for both values of "Required For". Riders are
        // required on every passenger requisition now — the contract's worked example
        // is an "Own User" trip with three of them — where previously this was only
        // offered for "Someone Else".
        if (ApiCapabilities.employeeDirectory) ...[
          spacing,
          _EmployeePicker(
            query: uiState.employeeSearchQuery,
            results: uiState.employeeSearchResults,
            selected: form.selectedEmployees,
            isSearching: uiState.isSearchingEmployees,
            error: errors[RequisitionFormField.employees],
            searchError: uiState.employeeSearchError,
            onQueryChange: notifier.onEmployeeSearchQueryChange,
            onToggle: notifier.toggleEmployeeSelection,
          ),
        ],
        const _SectionHeader(TracGoStrings.newRequisitionSectionPurpose),
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldPurpose,
          value: form.purpose,
          onChanged: notifier.onPurposeChange,
          error: errors[RequisitionFormField.purpose],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldRemarks,
          value: form.remarks,
          onChanged: notifier.onPassengerRemarksChange,
          error: errors[RequisitionFormField.remarks],
          singleLine: false,
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
    const spacing = SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(TracGoStrings.newRequisitionSectionVehicleDetails),
        RadioRow<VehicleType>(
          options: VehicleType.values,
          selected: form.vehicleType,
          labelFor: (v) => v.label,
          onSelect: notifier.onVehicleTypeChange,
        ),
        spacing,
        DropdownField<LoadingCapacity>(
          label: TracGoStrings.newRequisitionFieldLoadingCapacity,
          options: LoadingCapacity.values,
          selected: form.loadingCapacity,
          labelFor: (v) => v.label,
          onSelect: notifier.onLoadingCapacityChange,
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldGoodsWeight,
          value: form.goodsWeight,
          onChanged: notifier.onGoodsWeightChange,
          error: errors[RequisitionFormField.goodsWeight],
          maxLength: RequisitionFieldLimits.goodsWeightMaxLength,
        ),
        const _SectionHeader(TracGoStrings.newRequisitionSectionTripDetails),
        DateTimeField(
          label: TracGoStrings.newRequisitionFieldPickupDatetime,
          value: form.pickupDateTime,
          onChanged: notifier.onLogisticsPickupDateTimeChange,
          isError: errors.containsKey(RequisitionFormField.pickupDateTime),
          errorText: errors[RequisitionFormField.pickupDateTime],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldPickupLocation,
          value: form.pickupLocation,
          onChanged: notifier.onLogisticsPickupLocationChange,
          error: errors[RequisitionFormField.pickupLocation],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldDropLocation,
          value: form.dropLocation,
          onChanged: notifier.onLogisticsDropLocationChange,
          error: errors[RequisitionFormField.dropLocation],
        ),
        const _SectionHeader(TracGoStrings.newRequisitionSectionRequesterDetails),
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldCustomerName,
          value: form.customerName,
          onChanged: notifier.onLogisticsCustomerNameChange,
          error: errors[RequisitionFormField.customerName],
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldUserDepartment,
          value: form.userDepartment,
          onChanged: notifier.onUserDepartmentChange,
          error: errors[RequisitionFormField.userDepartment],
          maxLength: RequisitionFieldLimits.shortMaxLength,
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldStoreName,
          value: form.storeName,
          onChanged: notifier.onStoreNameChange,
          error: errors[RequisitionFormField.storeName],
          maxLength: RequisitionFieldLimits.shortMaxLength,
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldGoodsDetails,
          value: form.goodsDetails,
          onChanged: notifier.onGoodsDetailsChange,
          error: errors[RequisitionFormField.goodsDetails],
          singleLine: false,
        ),
        spacing,
        _TracGoTextField(
          label: TracGoStrings.newRequisitionFieldRemarks,
          value: form.remarks,
          onChanged: notifier.onLogisticsRemarksChange,
          error: errors[RequisitionFormField.remarks],
          singleLine: false,
        ),
      ],
    );
  }
}

class _TracGoTextField extends StatelessWidget {
  const _TracGoTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    this.singleLine = true,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLength = RequisitionFieldLimits.defaultMaxLength,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;
  final bool singleLine;
  final TextInputType keyboardType;

  /// The server's `max:` rule for this field. Defaults to the 200 that most of them
  /// carry; the three that differ pass their own.
  final int? maxLength;

  /// False for fields the form computes rather than accepts, so they render in the
  /// standard disabled style instead of inviting an edit that would be discarded.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SyncedTextField(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: singleLine ? 1 : 3,
      // The derived, read-only No. of Persons field is the one input with no server
      // string rule; capping it would be meaningless.
      maxLength: enabled ? maxLength : null,
      keyboardType: keyboardType,
      hintText: label,
      errorText: error,
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TracGoStrings.newRequisitionFieldSelectEmployees, style: tracGoTextTheme.bodySmall),
        if (widget.selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final employee in widget.selected)
                  InputChip(label: Text(employee.name), onDeleted: () => widget.onToggle(employee)),
              ],
            ),
          ),
        SyncedTextField(
          value: widget.query,
          onChanged: (value) {
            widget.onQueryChange(value);
            setState(() => _expanded = true);
          },
          hintText: TracGoStrings.newRequisitionFieldSelectEmployees,
          errorText: widget.error ?? widget.searchError,
          suffixIcon: widget.isSearching
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null,
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
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              TracGoStrings.newRequisitionEmployeeNoMatches,
              style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextMutedAlt),
            ),
          ),
        if (_expanded && widget.results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: tracGoSurfaceWhite,
              border: Border.all(color: tracGoBorder),
              borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final employee in widget.results)
                  ListTile(
                    title: Text(employee.name),
                    subtitle: Text('${employee.designation}, ${employee.department}'),
                    onTap: () {
                      widget.onToggle(employee);
                      setState(() => _expanded = false);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
