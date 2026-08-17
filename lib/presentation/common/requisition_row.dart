import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/typography.dart';
import 'status_chip.dart';

final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');
final _timeFormatter = DateFormat('hh:mm a');

/// One requisition inside a day group on the list screen.
///
/// Deliberately borderless: in the daylight design the rows share a single white
/// [SurfaceCard.rows] container and are separated by its inner hairline, so a row that
/// drew its own card would nest a border inside a border.
class RequisitionRow extends StatelessWidget {
  const RequisitionRow({
    super.key,
    required this.requisition,
    this.trailingAction,
    this.onTap,

    /// True when the row already sits under a day header, so only the time is worth
    /// repeating. False on any flat list, where the row has to say which day it is.
    this.timeOnly = false,

    /// Draws the status dot inline ahead of the date. Off by default: the row already
    /// carries a [StatusChip], so the dot is a second encoding of the same value and is
    /// opt-in for surfaces that want the extra scan line down the card.
    this.showStatusDot = false,
  });

  final Requisition requisition;
  final Widget? trailingAction;

  /// Opens the detail screen. Null leaves the row inert.
  final VoidCallback? onTap;
  final bool timeOnly;
  final bool showStatusDot;

  @override
  Widget build(BuildContext context) {
    final formatter = timeOnly ? _timeFormatter : _dateTimeFormatter;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Both children are Flexible: at large accessibility text sizes the
            // formatted date and the status chip together exceed the card width and
            // the Row overflows. Letting each shrink keeps both readable.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Dot and date travel together as one unit so `spaceBetween` still has
                  // exactly two children to push apart. mainAxisSize.min keeps the pair
                  // shrink-wrapped, and the inner Flexible lets the date — not the dot —
                  // absorb the truncation when the chip grows at large text sizes.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showStatusDot && requisition.status.hasValue) ...[
                        // Vertically centred against the date rather than top-aligned:
                        // the dot is a fixed 8px and the text line grows with the scale
                        // factor, so a top-aligned dot drifts upward as text enlarges.
                        StatusDot(status: requisition.status),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          formatter.format(requisition.pickupDateTime),
                          style: tracGoTextTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gap and chip together, so a requisition the server sent no status for
                // leaves the date flush right rather than trailing 10px of nothing.
                if (requisition.status.hasValue) ...[
                  const SizedBox(width: 10),
                  Flexible(child: StatusChip(status: requisition.status)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${requisition.pickupLocation} → ${requisition.dropLocation}',
              style: tracGoTextTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              requisition.purposeText,
              style: tracGoTextTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (trailingAction != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [trailingAction!],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
