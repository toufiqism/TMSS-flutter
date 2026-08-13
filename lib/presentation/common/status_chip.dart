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
      RequisitionStatus.pending => const _StatusColors(tmsStatusPendingOrangeText, tmsStatusPendingOrangeBg),
      RequisitionStatus.approved => const _StatusColors(tmsStatusApprovedGreen, tmsStatusApprovedGreenBg),
      RequisitionStatus.assigned => const _StatusColors(tmsStatusAssignedTeal, tmsStatusAssignedTealBg),
      RequisitionStatus.rejected => const _StatusColors(tmsStatusRejectedRed, tmsStatusRejectedRedBg),
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
        style: tmsTextTheme.labelSmall?.copyWith(color: colors.text),
      ),
    );
  }
}
