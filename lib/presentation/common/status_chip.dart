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

  /// Switches on [RequisitionStatus.kind], never on the status value — the raw server
  /// string is display text and an open set, so it cannot drive an exhaustive switch.
  static StatusPalette of(RequisitionStatus status) => forKind(status.kind);

  static StatusPalette forKind(RequisitionStatusKind kind) => switch (kind) {
    RequisitionStatusKind.pending => const StatusPalette(
      tracGoStatusPendingText,
      tracGoStatusPendingBg,
      tracGoStatusPendingDot,
    ),
    RequisitionStatusKind.approved => const StatusPalette(
      tracGoStatusApprovedText,
      tracGoStatusApprovedBg,
      tracGoStatusApprovedDot,
    ),
    RequisitionStatusKind.assigned => const StatusPalette(
      tracGoStatusAssignedText,
      tracGoStatusAssignedBg,
      tracGoStatusAssignedDot,
    ),
    RequisitionStatusKind.rejected => const StatusPalette(
      tracGoStatusRejectedText,
      tracGoStatusRejectedBg,
      tracGoStatusRejectedDot,
    ),
    // Neither kind carries a colour in the redesign — cancelled is a terminal non-event,
    // and unrecognised means the server sent a state this build predates, which has no
    // semantics to colour by — so both read as neutral rather than borrowing another
    // status's meaning. The chip still shows the server's own wording in both cases.
    RequisitionStatusKind.cancelled ||
    RequisitionStatusKind.unrecognised => const StatusPalette(
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
    // No status on the wire means no chip: there is no word to show, and inventing one
    // ("Unknown", "—") would report a state the server never claimed. Callers that need
    // the surrounding gap to collapse too must check `status.hasValue` themselves — a
    // zero-size widget cannot remove its sibling's SizedBox.
    if (!status.hasValue) return const SizedBox.shrink();

    final palette = StatusPalette.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark ? const Color(0xFFD9DBE4) : palette.background,
        borderRadius: pillBorderRadius,
      ),
      // The server's own wording, verbatim. It is an open set and can be far longer than
      // the five canonical labels (`Vehicle Assigned` is already 16 characters), so it
      // truncates on one line instead of wrapping the pill to two or overflowing the row.
      // This only bites if an ancestor gives the chip a bounded width — every call site
      // wraps it in a Flexible for exactly that reason.
      child: Text(
        status.rawValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
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
    // Same rule as the chip: a dot for a status the server never sent is a coloured mark
    // with no meaning behind it.
    if (!status.hasValue) return const SizedBox.shrink();

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
