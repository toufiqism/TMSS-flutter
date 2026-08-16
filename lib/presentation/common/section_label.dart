import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// The uppercase micro-caption that opens every group in the daylight design — section
/// titles, day headers, the "ALL REQUISITIONS" eyebrow.
///
/// Takes sentence-case text and uppercases it itself, so callers never hard-code a
/// shouted string: the same constant is read aloud by a screen reader, and
/// "REQUISITION DETAILS" is spelled out letter by letter by some of them.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  final String text;

  /// Defaults to the muted caption grey. The step headers on the create form pass the
  /// darker body colour, because they sit beside a filled badge and would otherwise
  /// look disabled next to it.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // The visual is uppercase; the label announced is not.
      label: text,
      excludeSemantics: true,
      child: Text(
        text.toUpperCase(),
        style: tracGoTextTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

/// A numbered step header: filled green circle, then the section caption.
///
/// Used by the create/edit form, where the design breaks the fields into numbered
/// groups (1 Trip, 2 Passengers, 3 Purpose).
class StepSectionLabel extends StatelessWidget {
  const StepSectionLabel({super.key, required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    // The badge is a fixed 20px circle in the design. It is *not* scaled with the text
    // scale factor: a 3.1x badge would be 62px of solid green beside a two-line caption.
    // The number inside is clamped for the same reason, and the caption beside it is
    // left free to grow.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: tracGoGreen,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.0,
            child: Text(
              '$step',
              style: tracGoTextTheme.labelSmall?.copyWith(
                fontFamily: displayFontFamily,
                fontSize: 12,
                letterSpacing: 0,
                color: tracGoSurfaceWhite,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Expanded, not a bare label: a long caption at a large text scale would
        // otherwise push the Row past the screen width.
        Expanded(child: SectionLabel(label, color: tracGoTextBody)),
      ],
    );
  }
}
