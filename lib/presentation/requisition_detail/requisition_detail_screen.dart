import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/key_value_row.dart';
import '../common/safe_insets.dart';
import '../common/section_label.dart';
import '../common/status_chip.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';
import 'requisition_detail_notifier.dart';
import 'requisition_detail_state.dart';

final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');
final _shortDateFormatter = DateFormat('dd MMM');
final _activityFormatter = DateFormat('dd MMM, hh:mm a');

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
        title: const Text(TracGoStrings.requisitionListCancelConfirmTitle),
        content: const Text(TracGoStrings.requisitionListCancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(TracGoStrings.requisitionListCancelConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(TracGoStrings.requisitionListCancelConfirmYes),
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
      backgroundColor: tracGoPageBackground,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          TracGoStrings.requisitionDetailTitle,
          style: tracGoScreenTitleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tracGoInk),
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
              style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextMutedAlt),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text(TracGoStrings.requisitionListRetry),
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
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        26,
      ).addBottomSystemInset(context),
      children: [
        _HeroCard(requisition: requisition),
        const SizedBox(height: 20),
        // Pickup and drop are the hero's subject, so the Trip section carries only what
        // the hero does not already say.
        _Section(
          title: TracGoStrings.requisitionDetailSectionTrip,
          rows: [
            KeyValueRow(
              TracGoStrings.requisitionDetailPickupAt,
              _dateTimeFormatter.format(requisition.pickupDateTime),
            ),
            // Only filled in once dispatch sets it; null on every pending row.
            if (requisition.endDateTime != null)
              KeyValueRow(
                TracGoStrings.requisitionDetailEndsAt,
                _dateTimeFormatter.format(requisition.endDateTime!),
              ),
            if (requisition.remarks != null && requisition.remarks!.isNotEmpty)
              KeyValueRow(
                TracGoStrings.newRequisitionFieldRemarks,
                requisition.remarks!,
              ),
          ],
        ),
        const SizedBox(height: 20),
        switch (details) {
          PassengerDetails() => _Section(
              title: TracGoStrings.requisitionDetailSectionPassenger,
              rows: [
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldUsedType,
                  details.usedType.label,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldCustomerName,
                  details.customerName,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldNumberOfPersons,
                  '${details.numberOfPersons}',
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldRequiredFor,
                  details.requiredFor.label,
                ),
                if (details.userType != null)
                  KeyValueRow(
                    TracGoStrings.newRequisitionFieldUserType,
                    details.userType!.label,
                  ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldPurpose,
                  details.purpose,
                ),
                ..._riderRows(details.riders),
              ],
            ),
          LogisticsDetails() => _Section(
              title: TracGoStrings.requisitionDetailSectionLogistics,
              rows: [
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldLoadingCapacity,
                  details.loadingCapacity.label,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldGoodsWeight,
                  details.goodsWeight,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldStoreName,
                  details.storeName,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldGoodsDetails,
                  details.goodsDetails,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldCustomerName,
                  details.customerName,
                ),
                KeyValueRow(
                  TracGoStrings.newRequisitionFieldUserDepartment,
                  details.userDepartment,
                ),
              ],
            ),
        },
        const SizedBox(height: 20),
        // Rendered for both requisition types, and unconditionally: the requester is
        // part of what a requisition *is*, so an absent name reads as an em dash rather
        // than as a section that quietly disappears.
        _Section(
          title: TracGoStrings.requisitionDetailSectionRequester,
          rows: [
            KeyValueRow(
              TracGoStrings.requisitionDetailRequestedBy,
              _personLabel(requisition.requesterName, requisition.requesterCode),
            ),
            if (requisition.departmentName != null)
              KeyValueRow(
                TracGoStrings.requisitionDetailDepartment,
                requisition.departmentName!,
              ),
            if (requisition.companyName != null)
              KeyValueRow(
                TracGoStrings.requisitionDetailCompany,
                requisition.companyName!,
              ),
          ],
        ),
        const SizedBox(height: 20),
        _AssignmentSection(requisition: requisition),
        const SizedBox(height: 20),
        _ActivitySection(
          entries: requisition.auditLog,
          canBeModified: requisition.canBeModified,
        ),
        const SizedBox(height: 22),
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

/// One row per rider, numbered so a repeated name (or a pair of unresolved ids) is
/// still countable against `No. of Persons`.
///
/// An empty list is not silently dropped: the list endpoint omits `employees[]`
/// entirely, so "no riders returned" would otherwise look identical to a trip nobody
/// is riding on. It renders as a single placeholder row instead.
List<Widget> _riderRows(List<RequisitionRider> riders) {
  if (riders.isEmpty) {
    return const [KeyValueRow(TracGoStrings.requisitionDetailPassengers, '')];
  }
  return [
    for (var i = 0; i < riders.length; i++)
      KeyValueRow(
        TracGoStrings.requisitionDetailPassengerNumbered(i + 1),
        riders[i].hasName
            ? _personLabel(riders[i].name, riders[i].employeeCode)
            // Id-only rider: the server gave no name, and the raw surrogate id means
            // nothing to the user, so it is not shown in its place.
            : TracGoStrings.newRequisitionRiderUnresolved,
      ),
  ];
}

/// `Name · 2-765`, or just the name when there is no staff number — never a bare
/// separator. Returns an empty string when there is no name at all, which
/// [KeyValueRow] renders as an em dash.
String _personLabel(String? name, String? code) {
  final trimmedName = name?.trim() ?? '';
  final trimmedCode = code?.trim() ?? '';
  if (trimmedName.isEmpty) return trimmedCode;
  if (trimmedCode.isEmpty) return trimmedName;
  return '$trimmedName · $trimmedCode';
}

/// The navy summary card: reference, status, the route as an origin/destination pair,
/// and when it happens.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.requisition});

  final Requisition requisition;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: tracGoBorderRadius(tracGoRadiusExtraLarge),
      child: Container(
        width: double.infinity,
        color: tracGoInk,
        child: Stack(
          children: [
            // Decorative lime bloom in the corner, exactly as the design draws it.
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x427AB648), Color(0x0012122B)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SectionLabel(
                          TracGoStrings.requisitionDetailReference(
                            requisition.id,
                          ),
                          color: tracGoSurfaceWhite.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusChip(status: requisition.status, onDark: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _RoutePoint(
                    label: requisition.pickupLocation,
                    isOrigin: true,
                  ),
                  // The connector between the two markers, inset to line up with the
                  // centre of the 8px dot above it.
                  Container(
                    margin: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
                    width: 2,
                    height: 14,
                    color: tracGoSurfaceWhite.withValues(alpha: 0.25),
                  ),
                  _RoutePoint(
                    label: requisition.dropLocation,
                    isOrigin: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${TracGoStrings.requisitionDetailPickupAt} '
                    '${_dateTimeFormatter.format(requisition.pickupDateTime)} · '
                    '${TracGoStrings.requisitionDetailRaisedOn.toLowerCase()} '
                    '${_shortDateFormatter.format(requisition.createdAt)}',
                    style: tracGoTextTheme.bodySmall?.copyWith(
                      color: tracGoSurfaceWhite.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One end of the journey. The origin gets a lime dot, the destination a white square —
/// the same shorthand every mapping app uses, and the only thing distinguishing the two
/// lines at a glance.
class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.label, required this.isOrigin});

  final String label;
  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOrigin ? tracGoLime : tracGoSurfaceWhite,
              borderRadius: isOrigin
                  ? const BorderRadius.all(Radius.circular(4))
                  : const BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Expanded so a long address wraps inside the card instead of overflowing it.
        Expanded(
          child: Text(
            label.trim().isEmpty ? '—' : label,
            style: tracGoTextTheme.titleMedium?.copyWith(
              fontSize: 19,
              color: tracGoSurfaceWhite,
            ),
          ),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: SectionLabel(title),
        ),
        SurfaceCard.rows(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          rows: rows,
        ),
      ],
    );
  }
}

class _AssignmentSection extends StatelessWidget {
  const _AssignmentSection({required this.requisition});

  final Requisition requisition;

  @override
  Widget build(BuildContext context) {
    if (!requisition.hasAssignment) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 9),
            child: SectionLabel(
              TracGoStrings.requisitionDetailSectionAssignment,
            ),
          ),
          DashedSurfaceCard(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: tracGoSurfaceSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '—',
                    style: tracGoTextTheme.bodyMedium?.copyWith(
                      color: tracGoTextMutedAlt,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expanded so the sentence wraps inside the card at large text scales.
                Expanded(
                  child: Text(
                    TracGoStrings.requisitionDetailNotAssigned,
                    style: tracGoTextTheme.bodyMedium?.copyWith(
                      color: tracGoTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final driver = requisition.driver;
    final vehicle = requisition.vehicle;
    return _Section(
      title: TracGoStrings.requisitionDetailSectionAssignment,
      rows: [
        // Field names for these objects are unverified, so only what actually parsed
        // is shown — no empty placeholders for keys that may not exist.
        if (driver?.name != null)
          KeyValueRow(TracGoStrings.requisitionDetailDriver, driver!.name!),
        if (driver?.phone != null) KeyValueRow('Phone', driver!.phone!),
        if (driver?.identifier != null) KeyValueRow('Driver ID', driver!.identifier!),
        if (vehicle?.registrationNumber != null)
          KeyValueRow(
            TracGoStrings.requisitionDetailVehicle,
            vehicle!.registrationNumber!,
          ),
        if (vehicle?.model != null) KeyValueRow('Model', vehicle!.model!),
        if (vehicle?.type != null) KeyValueRow('Vehicle type', vehicle!.type!),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.entries, required this.canBeModified});

  final List<AuditLogEntry> entries;

  /// Drives the footnote. Shown only when the actions above are *absent*, so it
  /// explains their absence rather than contradicting buttons the user can see.
  final bool canBeModified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 9),
          child: SectionLabel(TracGoStrings.requisitionDetailSectionActivity),
        ),
        SurfaceCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (entries.isEmpty)
                Text(
                  TracGoStrings.requisitionDetailNoActivity,
                  style: tracGoTextTheme.bodyMedium?.copyWith(
                    color: tracGoTextMutedAlt,
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++)
                  _ActivityRow(
                    entry: entries[i],
                    isLast: i == entries.length - 1,
                  ),
              if (!canBeModified) ...[
                const SizedBox(height: 2),
                Text(
                  TracGoStrings.requisitionDetailNotEditable,
                  style: tracGoTextTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: tracGoPlaceholder,
                  ),
                ),
              ],
            ],
          ),
        ),
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
    final palette = StatusPalette.of(entry.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: dot per entry, connector down to the next. IntrinsicHeight
          // gives the connector a bounded height to fill — without it the Expanded
          // below sits in an unbounded column and cannot resolve.
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: palette.dot,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                const Expanded(
                  child: SizedBox(
                    width: 2,
                    child: ColoredBox(color: tracGoBorder),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flexible on both: the status label and the timestamp together
                  // outgrow the timeline's remaining width at large text sizes.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          entry.status.label,
                          style: tracGoTextTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (entry.at != null) ...[
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _activityFormatter.format(entry.at!),
                            style: tracGoTextTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: tracGoPlaceholder,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(entry.remarks!, style: tracGoTextTheme.bodySmall),
                  ],
                  if (entry.actorName != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      entry.actorCode == null
                          ? entry.actorName!
                          : '${entry.actorName} · ${entry.actorCode}',
                      style: tracGoTextTheme.bodySmall,
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
    // walk the user into a 409. The activity card above says why they are missing.
    if (!requisition.canBeModified) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          // minimumSize, not a fixed height, so the label survives large text scales.
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: isCancelling ? null : onEdit,
          child: const Text(TracGoStrings.requisitionDetailEdit),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: tracGoDestructiveRedTint,
            foregroundColor: tracGoDestructiveRed,
            shape: pillShape,
            textStyle: tracGoTextTheme.labelLarge?.copyWith(fontSize: 15),
          ),
          onPressed: isCancelling ? null : onCancel,
          child: isCancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tracGoDestructiveRed,
                  ),
                )
              : const Text(TracGoStrings.requisitionListCancel),
        ),
      ],
    );
  }
}
