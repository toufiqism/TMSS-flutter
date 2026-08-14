import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';

class DropdownField<T> extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelect,
  });

  final String label;
  final List<T> options;
  final T selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: selected,
      decoration: InputDecoration(hintText: label),
      icon: const Icon(Icons.keyboard_arrow_down, color: tmsTextSubtle),
      style: tmsTextTheme.bodyLarge,
      // Without isExpanded the dropdown sizes its internal Row to the *natural* width of
      // the selected label, so a long value plus the chevron overflows the field at
      // large accessibility text sizes ("Pickup & Drop" by 20px, "2 Ton" by 93px once
      // the label wraps). Expanding makes the label take the space that is actually
      // available and ellipsize instead.
      isExpanded: true,
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option,
              child: Text(labelFor(option), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onSelect(value);
      },
    );
  }
}

/// Pill chips with a dot indicator, matching the redesign mock's Vehicle Type control.
class RadioRow<T> extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelect,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    // Wrap, not Row: two or three pills side by side do not fit the width at large
    // accessibility text sizes, and a Row simply clips the last option off the screen —
    // making it unselectable. Wrapping moves it to the next line instead.
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          _RadioPill(
            label: labelFor(option),
            isSelected: option == selected,
            onTap: () => onSelect(option),
          ),
      ],
    );
  }
}

class _RadioPill extends StatelessWidget {
  const _RadioPill({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: pillBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tmsGreenLight : Colors.transparent,
          borderRadius: pillBorderRadius,
          border: Border.all(color: isSelected ? tmsGreen : tmsBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? tmsGreen : tmsPlaceholder, width: isSelected ? 5 : 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: tmsTextTheme.bodyMedium?.copyWith(
                color: isSelected ? tmsTextDark : tmsTextMutedAlt,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
