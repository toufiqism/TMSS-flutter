import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/status_chip.dart';
import '../common/safe_insets.dart';
import '../common/strings.dart';
import 'requisition_detail_notifier.dart';
import 'requisition_detail_state.dart';

final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');

/// Read-only view of one requisition, with Edit and Cancel offered only while the
/// server would actually accept them (see [Requisition.canBeModified]).
class RequisitionDetailScreen extends ConsumerStatefulWidget {
  const RequisitionDetailScreen({
    super.key,
    required this.requisitionId,
    required this.onBack,
    required this.onEdit,
    required this.onClosed,
  });

  final String requisitionId;
  final VoidCallback onBack;
  final ValueChanged<Requisition> onEdit;

  /// The requisition is gone — cancelled or deleted. The caller pops and resyncs.
  final VoidCallback onClosed;

  @override
  ConsumerState<RequisitionDetailScreen> createState() =>
      _RequisitionDetailScreenState();
}

class _RequisitionDetailScreenState extends ConsumerState<RequisitionDetailScreen> {
  StreamSubscription<RequisitionDetailEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(requisitionDetailNotifierProvider.notifier);
      _eventSub = notifier.events.listen((event) {
        if (!mounted) return;
        switch (event) {
          case RequisitionDetailShowMessage(:final message):
          case RequisitionDetailSessionExpired(:final message):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          case RequisitionDetailClosed(:final message):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            widget.onClosed();
        }
      });
      unawaited(notifier.load(widget.requisitionId));
    });
  }

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(TmsStrings.requisitionListCancelConfirmTitle),
        content: const Text(TmsStrings.requisitionListCancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(TmsStrings.requisitionListCancelConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(TmsStrings.requisitionListCancelConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(requisitionDetailNotifierProvider.notifier).cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(requisitionDetailNotifierProvider);
    final notifier = ref.read(requisitionDetailNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tmsPageBackground,
      appBar: AppBar(
        title: Text(TmsStrings.requisitionDetailTitle, style: tmsTextTheme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tmsTextDark),
          onPressed: widget.onBack,
        ),
      ),
      body: switch (uiState) {
        RequisitionDetailLoading() => const Center(child: CircularProgressIndicator()),
        RequisitionDetailError(:final message, :final canRetry) => _ErrorState(
            message: message,
            onRetry: canRetry
                ? () => unawaited(notifier.load(widget.requisitionId))
                : null,
          ),
        RequisitionDetailSuccess(:final requisition, :final isCancelling) =>
          RefreshIndicator(
            onRefresh: notifier.refresh,
            child: _Content(
              requisition: requisition,
              isCancelling: isCancelling,
              onEdit: () => widget.onEdit(requisition),
              onCancel: () => unawaited(_confirmCancel()),
            ),
          ),
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;

  /// Null for terminal failures such as 403, where retrying cannot help.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(shape: pillShape),
                child: const Text(TmsStrings.requisitionListRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.requisition,
    required this.isCancelling,
    required this.onEdit,
    required this.onCancel,
  });

  final Requisition requisition;
  final bool isCancelling;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final details = requisition.details;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Actions sit at the very bottom of this list; without the system inset they
      // render under Android's navigation bar.
      padding: const EdgeInsets.all(20).addBottomSystemInset(context),
      children: [
        _HeaderCard(requisition: requisition),
        const SizedBox(height: 16),
        _Section(
          title: TmsStrings.requisitionDetailSectionTrip,
          rows: [
            _Row(TmsStrings.requisitionDetailPickup, requisition.pickupLocation),
            _Row(TmsStrings.requisitionDetailDrop, requisition.dropLocation),
            _Row(
              TmsStrings.requisitionDetailPickupAt,
              _dateTimeFormatter.format(requisition.pickupDateTime),
            ),
            // Only rendered once dispatch fills it in; null on every pending row.
            if (requisition.endDateTime != null)
              _Row(
                TmsStrings.requisitionDetailEndsAt,
                _dateTimeFormatter.format(requisition.endDateTime!),
              ),
            if (requisition.remarks != null && requisition.remarks!.isNotEmpty)
              _Row(TmsStrings.newRequisitionFieldRemarks, requisition.remarks!),
          ],
        ),
        const SizedBox(height: 16),
        switch (details) {
          PassengerDetails() => _Section(
              title: TmsStrings.requisitionDetailSectionPassenger,
              rows: [
                _Row(TmsStrings.newRequisitionFieldUsedType, details.usedType.label),
                _Row(TmsStrings.newRequisitionFieldCustomerName, details.customerName),
                _Row(
                  TmsStrings.newRequisitionFieldNumberOfPersons,
                  '${details.numberOfPersons}',
                ),
                _Row(
                  TmsStrings.newRequisitionFieldRequiredFor,
                  details.requiredFor.label,
                ),
                if (details.userType != null)
                  _Row(TmsStrings.newRequisitionFieldUserType, details.userType!.label),
                _Row(TmsStrings.newRequisitionFieldPurpose, details.purpose),
              ],
            ),
          LogisticsDetails() => _Section(
              title: TmsStrings.requisitionDetailSectionLogistics,
              rows: [
                _Row(
                  TmsStrings.newRequisitionFieldLoadingCapacity,
                  details.loadingCapacity.label,
                ),
                _Row(TmsStrings.newRequisitionFieldGoodsWeight, details.goodsWeight),
                _Row(TmsStrings.newRequisitionFieldStoreName, details.storeName),
                _Row(TmsStrings.newRequisitionFieldGoodsDetails, details.goodsDetails),
                _Row(TmsStrings.newRequisitionFieldCustomerName, details.customerName),
                _Row(
                  TmsStrings.newRequisitionFieldUserDepartment,
                  details.userDepartment,
                ),
              ],
            ),
        },
        if (requisition.departmentName != null || requisition.companyName != null) ...[
          const SizedBox(height: 16),
          _Section(
            title: TmsStrings.requisitionDetailSectionRequester,
            rows: [
              if (requisition.departmentName != null)
                _Row(
                  TmsStrings.requisitionDetailDepartment,
                  requisition.departmentName!,
                ),
              if (requisition.companyName != null)
                _Row(TmsStrings.requisitionDetailCompany, requisition.companyName!),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _AssignmentSection(requisition: requisition),
        const SizedBox(height: 16),
        _ActivitySection(entries: requisition.auditLog),
        const SizedBox(height: 20),
        _Actions(
          requisition: requisition,
          isCancelling: isCancelling,
          onEdit: onEdit,
          onCancel: onCancel,
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.requisition});

  final Requisition requisition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: tmsBorderRadius(tmsRadiusLarge),
        gradient: const LinearGradient(colors: [tmsGreenLight, tmsGreenLightAlt]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${requisition.pickupLocation} → ${requisition.dropLocation}',
                  style: tmsTextTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(status: requisition.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${TmsStrings.requisitionDetailRaisedOn} '
            '${_dateTimeFormatter.format(requisition.createdAt)}',
            style: tmsTextTheme.bodySmall?.copyWith(color: tmsTextSubtle),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title.toUpperCase(),
            style: tmsTextTheme.labelMedium?.copyWith(color: tmsGreen),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

/// One label/value pair. Values that are empty on the wire render as an em dash rather
/// than collapsing, so the row count stays stable and a missing value is visible as
/// missing rather than simply absent.
class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proportional, not a fixed 132px: at large accessibility text sizes a fixed
          // label column leaves the label wrapping to many lines while the value column
          // sits half empty. Flex keeps the split sane at every scale.
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: tmsTextTheme.bodyMedium?.copyWith(
                color: tmsTextDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentSection extends StatelessWidget {
  const _AssignmentSection({required this.requisition});

  final Requisition requisition;

  @override
  Widget build(BuildContext context) {
    if (!requisition.hasAssignment) {
      return _Section(
        title: TmsStrings.requisitionDetailSectionAssignment,
        rows: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(TmsStrings.requisitionDetailNotAssigned),
          ),
        ],
      );
    }

    final driver = requisition.driver;
    final vehicle = requisition.vehicle;
    return _Section(
      title: TmsStrings.requisitionDetailSectionAssignment,
      rows: [
        // Field names for these objects are unverified, so only what actually parsed
        // is shown — no empty placeholders for keys that may not exist.
        if (driver?.name != null)
          _Row(TmsStrings.requisitionDetailDriver, driver!.name!),
        if (driver?.phone != null) _Row('Phone', driver!.phone!),
        if (driver?.identifier != null) _Row('Driver ID', driver!.identifier!),
        if (vehicle?.registrationNumber != null)
          _Row(TmsStrings.requisitionDetailVehicle, vehicle!.registrationNumber!),
        if (vehicle?.model != null) _Row('Model', vehicle!.model!),
        if (vehicle?.type != null) _Row('Vehicle type', vehicle!.type!),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.entries});

  final List<AuditLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _Section(
        title: TmsStrings.requisitionDetailSectionActivity,
        rows: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(TmsStrings.requisitionDetailNoActivity),
          ),
        ],
      );
    }

    return _Section(
      title: TmsStrings.requisitionDetailSectionActivity,
      rows: [
        for (var i = 0; i < entries.length; i++)
          _ActivityRow(entry: entries[i], isLast: i == entries.length - 1),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry, required this.isLast});

  final AuditLogEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: dot per entry, connector to the next. IntrinsicHeight gives
          // the connector a bounded height to fill — without it the Expanded below sits
          // in an unbounded column and cannot resolve.
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(color: tmsGreen, shape: BoxShape.circle),
              ),
              if (!isLast)
                const Expanded(child: VerticalDivider(width: 1, color: tmsDivider)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flexible on both: the chip and the timestamp together outgrow the
                  // timeline's remaining width at large accessibility text sizes.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: StatusChip(status: entry.status)),
                      if (entry.at != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _dateTimeFormatter.format(entry.at!),
                            style: tmsTextTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(entry.remarks!, style: tmsTextTheme.bodyMedium),
                  ],
                  if (entry.actorName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.actorCode == null
                          ? entry.actorName!
                          : '${entry.actorName} · ${entry.actorCode}',
                      style: tmsTextTheme.bodySmall?.copyWith(color: tmsTextMutedAlt),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.requisition,
    required this.isCancelling,
    required this.onEdit,
    required this.onCancel,
  });

  final Requisition requisition;
  final bool isCancelling;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // Actions are withheld entirely rather than shown disabled: the server rejects both
    // edit and cancel once a requisition leaves Pending, so offering them would only
    // walk the user into a 409.
    if (!requisition.canBeModified) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          TmsStrings.requisitionDetailNotEditable,
          style: tmsTextTheme.bodySmall?.copyWith(color: tmsTextMutedAlt),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: isCancelling ? null : onEdit,
            child: Text(
              TmsStrings.requisitionDetailEdit,
              style: tmsTextTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: tmsSurfaceWhite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: tmsDestructiveRed),
              shape: RoundedRectangleBorder(
                borderRadius: tmsBorderRadius(tmsRadiusSmall),
              ),
            ),
            onPressed: isCancelling ? null : onCancel,
            child: isCancelling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    TmsStrings.requisitionListCancel,
                    style: tmsTextTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tmsDestructiveRed,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
