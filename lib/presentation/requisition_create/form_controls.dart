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
      items: options
          .map((option) => DropdownMenuItem<T>(value: option, child: Text(labelFor(option))))
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
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _RadioPill(
            label: labelFor(options[i]),
            isSelected: options[i] == selected,
            onTap: () => onSelect(options[i]),
          ),
        ],
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
