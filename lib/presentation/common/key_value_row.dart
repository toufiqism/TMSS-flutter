import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// One label/value line inside a [SurfaceCard.rows] group: muted label on the left,
/// emphasised value hard against the right edge.
///
/// A value that is empty on the wire renders as [placeholder] rather than collapsing,
/// so a missing field is visible as missing instead of simply absent — and the row
/// count stays stable between two requisitions that differ only in what the server
/// filled in.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow(
    this.label,
    this.value, {
    super.key,
    this.placeholder = '—',
    this.valueColor,
  });

  final String label;
  final String? value;

  /// Shown when [value] is null or blank, in the placeholder grey.
  final String placeholder;

  /// Overrides the value colour for rows that carry a status of their own.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = value?.trim() ?? '';
    final isMissing = trimmed.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proportional, not a fixed label column: at large accessibility text sizes a
          // fixed width leaves the label wrapping to four lines while the value column
          // sits half empty.
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tracGoTextTheme.bodySmall?.copyWith(color: tracGoTextMutedAlt),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              isMissing ? placeholder : trimmed,
              textAlign: TextAlign.right,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontWeight: isMissing ? FontWeight.w400 : FontWeight.w600,
                color: isMissing
                    ? tracGoPlaceholder
                    : (valueColor ?? tracGoInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
