import 'package:flutter/material.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';

/// The three colours a status carries in the daylight design: a text/background pair for
/// the pill, and a saturated dot for places where a full pill would shout — list rows,
/// the activity timeline, the detail hero's route markers.
class StatusPalette {
  const StatusPalette(this.text, this.background, this.dot);

  final Color text;
  final Color background;
  final Color dot;

  static StatusPalette of(RequisitionStatus status) => switch (status) {
    RequisitionStatus.pending => const StatusPalette(
      tracGoStatusPendingText,
      tracGoStatusPendingBg,
      tracGoStatusPendingDot,
    ),
    RequisitionStatus.approved => const StatusPalette(
      tracGoStatusApprovedText,
      tracGoStatusApprovedBg,
      tracGoStatusApprovedDot,
    ),
    RequisitionStatus.assigned => const StatusPalette(
      tracGoStatusAssignedText,
      tracGoStatusAssignedBg,
      tracGoStatusAssignedDot,
    ),
    RequisitionStatus.rejected => const StatusPalette(
      tracGoStatusRejectedText,
      tracGoStatusRejectedBg,
      tracGoStatusRejectedDot,
    ),
    // Neither status carries a colour in the redesign — cancelled is a terminal
    // non-event and unknown means the server sent a value this build predates — so
    // both read as neutral rather than borrowing another status's semantic colour.
    RequisitionStatus.cancelled || RequisitionStatus.unknown => const StatusPalette(
      tracGoStatusNeutralText,
      tracGoStatusNeutralBg,
      tracGoStatusNeutralDot,
    ),
  };
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.onDark = false});

  final RequisitionStatus status;

  /// Set on the detail screen's navy hero card. The tinted backgrounds are mixed for a
  /// white page and all but disappear on navy, so the chip inverts to a light fill with
  /// dark text instead.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final palette = StatusPalette.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark ? const Color(0xFFD9DBE4) : palette.background,
        borderRadius: pillBorderRadius,
      ),
      child: Text(
        status.label,
        style: tracGoChipTextStyle.copyWith(
          color: onDark ? tracGoInk : palette.text,
        ),
      ),
    );
  }
}

/// The 8px status dot that opens a list row.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status, this.size = 8});

  final RequisitionStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: StatusPalette.of(status).dot,
        shape: BoxShape.circle,
      ),
    );
  }
}
