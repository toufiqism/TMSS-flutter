import 'package:flutter/material.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';

class _StatusColors {
  const _StatusColors(this.text, this.background);
  final Color text;
  final Color background;
}

_StatusColors _colorsFor(RequisitionStatus status) => switch (status) {
      RequisitionStatus.pending => const _StatusColors(tracGoStatusPendingOrangeText, tracGoStatusPendingOrangeBg),
      RequisitionStatus.approved => const _StatusColors(tracGoStatusApprovedGreen, tracGoStatusApprovedGreenBg),
      RequisitionStatus.assigned => const _StatusColors(tracGoStatusAssignedTeal, tracGoStatusAssignedTealBg),
      RequisitionStatus.rejected => const _StatusColors(tracGoStatusRejectedRed, tracGoStatusRejectedRedBg),
      // Neither status carries a colour in the redesign — cancelled is a terminal
      // non-event and unknown means the server sent a value this build predates — so
      // both read as neutral rather than borrowing another status's semantic colour.
      RequisitionStatus.cancelled ||
      RequisitionStatus.unknown =>
        const _StatusColors(tracGoTextMutedAlt, tracGoDivider),
    };

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final RequisitionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: colors.background, borderRadius: pillBorderRadius),
      child: Text(
        status.label,
        style: tracGoTextTheme.labelSmall?.copyWith(color: colors.text),
      ),
    );
  }
}
