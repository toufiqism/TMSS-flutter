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
  });

  final Requisition requisition;
  final Widget? trailingAction;

  /// Opens the detail screen. Null leaves the row inert.
  final VoidCallback? onTap;
  final bool timeOnly;

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
                  child: Text(
                    formatter.format(requisition.pickupDateTime),
                    style: tracGoTextTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(child: StatusChip(status: requisition.status)),
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

/// The tighter two-line row the dashboard's "Recent" card uses: a status dot instead of
/// a leading date, and the timing folded into the supporting line.
class RequisitionRecentRow extends StatelessWidget {
  const RequisitionRecentRow({super.key, required this.requisition, this.onTap});

  final Requisition requisition;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nudged down to sit on the first line's optical centre rather than its
            // ascender. Not text-scaled — a 3x dot would be a blob.
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: StatusDot(status: requisition.status),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${requisition.pickupLocation} → ${requisition.dropLocation}',
                    style: tracGoTextTheme.titleSmall?.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_dateTimeFormatter.format(requisition.pickupDateTime)} · '
                    '${requisition.purposeText}',
                    style: tracGoTextTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusChip(status: requisition.status),
          ],
        ),
      ),
    );
  }
}
