import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

final _displayFormatter = DateFormat('dd MMM yyyy, hh:mm a');

/// Pickup Date & Time on both forms: tap opens a date picker, then a time picker, combined into
/// one DateTime. Flutter ships both showDatePicker and showTimePicker natively — no custom
/// TimePickerDialog wrapper needed here, unlike the Android app (Material3 for Compose lacks one).
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isError = false,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool isError;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return;

    final initialTime = value != null ? TimeOfDay.fromDateTime(value!) : TimeOfDay.fromDateTime(now);
    final time = await showTimePicker(context: context, initialTime: initialTime);
    if (time == null) return;

    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: tracGoTextTheme.bodyLarge?.copyWith(color: tracGoPlaceholder),
          suffixIcon: const Icon(Icons.calendar_month, color: tracGoTextSubtle),
          errorText: isError ? errorText : null,
        ),
        child: Text(
          value != null ? _displayFormatter.format(value!) : '',
          style: tracGoTextTheme.bodyLarge,
        ),
      ),
    );
  }
}
