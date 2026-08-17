import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import 'motion.dart';

/// The small pill used for an inline choice inside a form card — trip type, loading
/// capacity, who the trip is for.
///
/// Selected reads as a lime-tinted green pill; unselected as a flat inset chip. There is
/// no border in either state, so the two never differ by more than fill and weight —
/// which is what keeps a row of them from looking like a row of buttons.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Null makes the pill inert *and* mutes it — used while a form section is locked.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final motion = TracGoMotion.of(context);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: PressableScale(
        enabled: enabled,
        child: InkWell(
          onTap: onTap,
          borderRadius: pillBorderRadius,
          // Animated fill and label colour: selecting one pill in a row deselects
          // another, and two chips changing at once is exactly the moment a hard cut is
          // most visible. `AnimatedDefaultTextStyle` carries the weight change too, so
          // the label thickens over the same 120ms rather than jumping a frame early.
          child: AnimatedContainer(
            duration: motion.fast,
            curve: tracGoMotionCurve,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? tracGoLimeTintStrong : tracGoInputBackground,
              borderRadius: pillBorderRadius,
            ),
            child: AnimatedDefaultTextStyle(
              duration: motion.fast,
              curve: tracGoMotionCurve,
              style: (tracGoTextTheme.bodySmall ?? const TextStyle()).copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? tracGoGreen
                    : (enabled ? tracGoTextMuted : tracGoPlaceholder),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of [ChoicePill]s bound to an enum-ish option list.
///
/// Wrap, not Row: three pills side by side do not fit a phone at large accessibility
/// text sizes, and a Row clips the last option off the screen — making it unselectable
/// rather than merely ugly.
class ChoicePillRow<T> extends StatelessWidget {
  const ChoicePillRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelect,
    this.enabled = true,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoicePill(
            label: labelFor(option),
            selected: option == selected,
            onTap: enabled ? () => onSelect(option) : null,
          ),
      ],
    );
  }
}

/// The list screen's filter chips: solid navy when active, outlined white when not.
///
/// A different component from [ChoicePill] on purpose — these filter a whole screen,
/// and the design gives them the heavier treatment to say so.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? tracGoSurfaceWhite : tracGoTextBody;
    final motion = TracGoMotion.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        child: InkWell(
          onTap: onTap,
          borderRadius: pillBorderRadius,
          // White-to-navy is the largest colour jump in the app; crossing it in one frame
          // reads as the chip being replaced rather than changing state.
          child: AnimatedContainer(
            duration: motion.fast,
            curve: tracGoMotionCurve,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? tracGoInk : tracGoSurfaceWhite,
              borderRadius: pillBorderRadius,
              border: Border.all(color: selected ? tracGoInk : tracGoBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  // The icon has to be animated separately: it takes a colour, not a
                  // text style, so the DefaultTextStyle below does not reach it.
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: foreground),
                    duration: motion.fast,
                    curve: tracGoMotionCurve,
                    builder: (context, color, _) =>
                        Icon(icon, size: 14, color: color ?? foreground),
                  ),
                  const SizedBox(width: 6),
                ],
                AnimatedDefaultTextStyle(
                  duration: motion.fast,
                  curve: tracGoMotionCurve,
                  style: (tracGoTextTheme.bodySmall ?? const TextStyle())
                      .copyWith(fontWeight: FontWeight.w600, color: foreground),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
