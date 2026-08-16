import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/surface_card.dart';
import '../common/synced_text_field.dart';

/// A grouped form section: white card, hairline-separated rows, the design's padding.
///
/// Fields are rows in a shared card rather than individually-boxed inputs. That is the
/// single biggest visual difference from the old form, and it is why the inputs here are
/// borderless — the card *is* the box.
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard.rows(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      rows: rows,
    );
  }
}

/// One labelled row inside a [FormCard].
class FormFieldRow extends StatelessWidget {
  const FormFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.error,
  });

  final String label;
  final Widget child;

  /// Field-level validation message. Rendered under the control in the destructive red,
  /// inside the row, so it never displaces the row below it by more than its own height.
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tracGoTextTheme.labelMedium),
          const SizedBox(height: 5),
          child,
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              style: tracGoTextTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: tracGoDestructiveRed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The borderless input a [FormFieldRow] wraps.
///
/// `bare` strips Material's fill, underline and 48px content padding: the row's label
/// and the card's hairline already say where the field starts and ends, and Material's
/// own chrome on top of them reads as a box inside a box.
class InlineTextField extends StatelessWidget {
  const InlineTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.enabled = true,
    this.singleLine = true,
    this.keyboardType,
    this.maxLength,
    this.trailing,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool enabled;
  final bool singleLine;
  final TextInputType? keyboardType;

  /// The server's `max:` rule for this field, enforced at the keyboard.
  final int? maxLength;

  /// Sits at the end of the input row — the calendar glyph on a date field.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = tracGoTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      color: enabled ? tracGoInk : tracGoTextMutedAlt,
    );

    final field = SyncedTextField(
      value: value,
      onChanged: onChanged,
      hintText: hint,
      enabled: enabled,
      maxLines: singleLine ? 1 : 3,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: style,
      hintStyle: style?.copyWith(color: tracGoPlaceholder),
      bare: true,
    );

    if (trailing == null) return field;
    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        trailing!,
      ],
    );
  }
}

/// A read-only row: label on the left, a value the form derives on the right.
///
/// Used for `No. of Persons`, which the server requires to equal the rider count
/// exactly — an editable control there could only ever be used to build an invalid
/// state, so it renders as a fact rather than an input.
class DerivedValueRow extends StatelessWidget {
  const DerivedValueRow({
    super.key,
    required this.label,
    required this.value,
    this.error,
  });

  final String label;
  final String value;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: tracGoTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value.trim().isEmpty ? '0' : value,
                style: tracGoTextTheme.titleMedium?.copyWith(fontSize: 17),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              style: tracGoTextTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: tracGoDestructiveRed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The logistics form's vehicle picker: two cards side by side, the selected one ringed
/// in green.
///
/// A card rather than a pill because each option carries a second line of description,
/// which is what tells a requester what "Cover van" actually means.
class SelectableTypeCard extends StatelessWidget {
  const SelectableTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: tracGoBorderRadius(tracGoRadiusLarge),
        child: SurfaceCard(
          radius: tracGoRadiusLarge,
          borderColor: selected ? tracGoGreen : tracGoBorder,
          // 2px on the selected card, per the design. The unselected card keeps its 1px
          // hairline, so the two differ by weight as well as hue — which is what makes
          // the selection legible without relying on colour alone.
          borderWidth: selected ? 2 : 1,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tracGoTextTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: selected ? tracGoInk : tracGoTextMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: tracGoTextTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: selected ? tracGoTextFaint : tracGoPlaceholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
