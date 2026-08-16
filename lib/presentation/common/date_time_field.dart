import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

final _displayFormatter = DateFormat('dd MMM yyyy, hh:mm a');

/// Pickup Date & Time on both forms: tap opens a date picker, then a time picker,
/// combined into one DateTime. Flutter ships both `showDatePicker` and `showTimePicker`
/// natively — no custom TimePickerDialog wrapper needed here, unlike the Android app
/// (Material3 for Compose lacks one).
///
/// Draws only the value row. The caption above it and any validation message below it
/// belong to the enclosing `FormFieldRow`, so this control looks identical to the text
/// fields it sits beside.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String hint;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    // The picker is dismissible, and the widget can be disposed while it is open —
    // both are checked before touching context again.
    if (date == null || !context.mounted) return;

    final initialTime = value != null
        ? TimeOfDay.fromDateTime(value!)
        : TimeOfDay.fromDateTime(now);
    final time = await showTimePicker(context: context, initialTime: initialTime);
    if (time == null) return;

    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final selected = value;
    return Semantics(
      button: true,
      value: selected == null ? hint : _displayFormatter.format(selected),
      child: InkWell(
        onTap: () => _pick(context),
        child: Padding(
          // Matches the vertical rhythm a bare text field gets from `isDense`, so the
          // date row does not sit higher than the fields around it.
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected == null ? hint : _displayFormatter.format(selected),
                  style: tracGoTextTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: selected == null ? tracGoPlaceholder : tracGoInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: tracGoGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
