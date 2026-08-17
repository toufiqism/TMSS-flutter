import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The widest a content column is allowed to grow.
///
/// Every screen in this app is a single scrollable column laid out at phone widths —
/// roughly 350pt of content inside a 20pt gutter. Left unbounded on an iPad in landscape
/// that column becomes 1326pt wide, which does not fail any assertion but destroys the
/// layouts that depend on a readable measure: `KeyValueRow` puts its label hard left and
/// its value hard right, so the two end up a screen apart with nothing between them, and
/// the stat tiles stretch into billboards.
///
/// 600 rather than the 700–800 a text-heavy page would take: this is a phone design, and
/// the cards have to keep looking deliberate rather than merely stretched.
const double tracGoMaxContentWidth = 600;

/// Widest the navigation drawer may get.
///
/// The drawer was sized as a fraction of the window, which is right on a phone and absurd
/// on a tablet — 82% of an iPad in landscape is a 1088pt panel holding three menu rows.
const double tracGoMaxDrawerWidth = 320;

/// Drawer width for the current window: the phone-proportional value, capped.
double tracGoDrawerWidth(BuildContext context) =>
    math.min(MediaQuery.sizeOf(context).width * 0.82, tracGoMaxDrawerWidth);

/// Centres a content column by widening the gutter, rather than by wrapping the scroll
/// view in a `Center`.
///
/// Deliberately padding and not a `ConstrainedBox`: the scroll view keeps its full width,
/// so the scrollbar stays on the screen edge where both platforms put it, the overscroll
/// glow and `RefreshIndicator` still span the window, and a pinned footer bar can be given
/// the same call to line its contents up with the column above it.
///
/// Widening only — `math.max` against what the caller already asked for — so a window
/// narrower than [maxContentWidth] (every phone, and an iPad in a 1/3 Split View) keeps
/// the original phone padding untouched. That is what makes one call site correct at every
/// size instead of needing a breakpoint.
extension ResponsivePageWidth on EdgeInsets {
  EdgeInsets constrainToContentWidth(
    BuildContext context, {
    double maxContentWidth = tracGoMaxContentWidth,
  }) {
    final gutter = (MediaQuery.sizeOf(context).width - maxContentWidth) / 2;
    // Also covers the degenerate case of a zero-width window during a resize, where the
    // gutter goes negative and must not eat the existing padding.
    if (gutter <= 0) return this;
    return copyWith(left: math.max(left, gutter), right: math.max(right, gutter));
  }
}
