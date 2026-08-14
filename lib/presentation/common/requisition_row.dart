import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'status_chip.dart';

final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');

class RequisitionRow extends StatelessWidget {
  const RequisitionRow({
    super.key,
    required this.requisition,
    this.trailingAction,
    this.onTap,
  });

  final Requisition requisition;
  final Widget? trailingAction;

  /// Opens the detail screen. Null leaves the row inert.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      // The ink splash has to be clipped to the card's rounded corners, or it paints
      // square over them on tap.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                      _dateTimeFormatter.format(requisition.pickupDateTime),
                      style: tmsTextTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: StatusChip(status: requisition.status)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${requisition.pickupLocation} → ${requisition.dropLocation}',
                style: tmsTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                requisition.purposeText,
                style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (trailingAction != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [trailingAction!],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
