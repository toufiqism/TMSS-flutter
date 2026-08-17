import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/motion.dart';
import '../common/requisition_row.dart';
import '../common/safe_insets.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';
import 'dashboard_notifier.dart';
import 'dashboard_skeleton.dart';
import 'dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onViewAllRequisitions,
    required this.onRequisitionNow,
    required this.onOpenRequisition,
  });

  final VoidCallback onViewAllRequisitions;
  final VoidCallback onRequisitionNow;
  final ValueChanged<Requisition> onOpenRequisition;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  StreamSubscription<DashboardEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventSub = ref.read(dashboardNotifierProvider.notifier).events.listen((
        event,
      ) {
        if (!mounted) return;
        final message = switch (event) {
          DashboardSessionExpired(:final message) => message,
          DashboardRefreshFailed(:final message) => message,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      });
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: tracGoPageBackground,
      // The three states cross-fade rather than snapping. Each branch carries a distinct
      // key: the switcher compares child keys, and two `RefreshIndicator`s of the same
      // type would otherwise look like one child being rebuilt, so the fade would never
      // run on the load-to-content swap that matters most.
      body: MotionSwitcher(
        child: switch (uiState) {
          DashboardLoading() => const DashboardSkeleton(
            key: ValueKey('loading'),
          ),
          DashboardError(:final message) => _ErrorState(
            key: const ValueKey('error'),
            message: message,
            onRetry: notifier.load,
          ),
          DashboardSuccess(:final summary) => RefreshIndicator(
            key: const ValueKey('content'),
            onRefresh: notifier.refresh,
            child: _DashboardContent(
              summary: summary,
              onViewAllRequisitions: widget.onViewAllRequisitions,
              onRequisitionNow: widget.onRequisitionNow,
              onOpenRequisition: widget.onOpenRequisition,
            ),
          ),
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                color: tracGoTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(TracGoStrings.dashboardRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
    required this.onViewAllRequisitions,
    required this.onRequisitionNow,
    required this.onOpenRequisition,
  });

  final DashboardSummary summary;
  final VoidCallback onViewAllRequisitions;
  final VoidCallback onRequisitionNow;
  final ValueChanged<Requisition> onOpenRequisition;

  @override
  Widget build(BuildContext context) {
    final motion = TracGoMotion.of(context);

    // The four blocks that make up the page, and the gaps between them. Kept as parallel
    // lists so the stagger indexes the *blocks* — a spacer given its own beat would
    // double every gap in the timing and animate nothing visible.
    final blocks = <Widget>[
      _HeroCount(total: summary.allCount),
      _StatGrid(summary: summary),
      // Wrap, not Row: the section title plus both actions outgrow a single line
      // at large accessibility text sizes, and a Wrap reflows them onto another
      // run instead of overflowing.
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text(
            TracGoStrings.dashboardRecentRequisitions,
            style: tracGoTextTheme.titleMedium,
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              _NewRequisitionButton(onPressed: onRequisitionNow),
              TextButton(
                onPressed: onViewAllRequisitions,
                style: TextButton.styleFrom(
                  // Default TextButton padding is 16dp a side and a 64dp minimum,
                  // which is what pushes this action onto a second run at phone
                  // widths. The 48dp tap target is preserved by the default
                  // MaterialTapTargetSize.
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  TracGoStrings.dashboardViewAll,
                  style: tracGoTextTheme.bodySmall?.copyWith(
                    color: tracGoGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      if (summary.recentRequisitions.isEmpty)
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Text(
            TracGoStrings.dashboardNoRecentRequisitions,
            textAlign: TextAlign.center,
            style: tracGoTextTheme.bodyMedium?.copyWith(
              color: tracGoTextMutedAlt,
            ),
          ),
        )
      else
        SurfaceCard.rows(
          rows: [
            for (final requisition in summary.recentRequisitions)
              // Press feedback on the row itself rather than the card: the card holds
              // several rows, and scaling all of them because one was touched would say
              // the wrong thing about what the tap is going to open.
              PressableScale(
                // The same RequisitionRow the list screen uses, so the two read as one
                // component rather than two takes on the same data.
                //
                // timeOnly stays false — the default — because this card has no day
                // headers to supply the date. It is the one difference from the list, and
                // it is the row saying which day it is rather than a different layout.
                //
                // No trailingAction either: cancelling belongs on the list screen, which
                // exists to manage requisitions. A Cancel button here would also make
                // pending rows taller than their neighbours.
                //
                // showStatusDot is the one element the list screen does not draw: this
                // card is a five-row glance, so the dot gives it a colour rail to scan
                // without reading the chips.
                child: RequisitionRow(
                  requisition: requisition,
                  showStatusDot: true,
                  onTap: () => onOpenRequisition(requisition),
                ),
              ),
          ],
        ),
    ];
    const gaps = [14.0, 24.0, 12.0];

    return ListView(
      // Without this the dashboard cannot be over-scrolled when its content is
      // shorter than the viewport, and the enclosing RefreshIndicator never fires.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
      ).addBottomSystemInset(context),
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) SizedBox(height: gaps[i - 1]),
          FadeSlideIn(delay: motion.staggerDelay(i), child: blocks[i]),
        ],
      ],
    );
  }
}

/// The count line that opens the dashboard, with the period badge opposite it.
///
/// The design dropped the "ALL REQUISITIONS" eyebrow that used to sit above this and
/// folded the meaning into the qualifier — "10 requisitions" says the same thing on one
/// line, and buys the four status tiles below it the vertical room they now need.
class _HeroCount extends StatelessWidget {
  const _HeroCount({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    // allCount is a server field and is not validated upstream; a negative total would
    // render as "-3" here, so floor it.
    final safeTotal = total < 0 ? 0 : total;

    // Wrap, not Row. Two things pushed it here: `Flexible` defaults to `flex: 1`, so a
    // flexible badge takes an equal share of the row and sits at the start of it rather
    // than hugging the right edge — and a non-flexible one overflows instead, once its
    // label outgrows the phone at a large accessibility text scale. `spaceBetween` puts
    // the badge on the far edge while they fit, and drops it to its own run when they
    // do not. Same pattern as the "Recent" header below.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      // flex-end in the design: the badge sits on the count's bottom edge.
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 10,
      children: [
        // One rich Text, not a Row of two: the design baseline-aligns the 34px count
        // with its 13px qualifier, and inline spans share a baseline for free. A Row
        // would need `CrossAxisAlignment.baseline`, which silently top-aligns any child
        // that reports no baseline.
        // Counts up rather than appearing at its final value. The one number on the
        // dashboard big enough for the movement to read as intent rather than a glitch —
        // and it lands on `safeTotal` in 220ms, so it is never what the user is waiting
        // for. Semantics announce the real total, not whatever frame the tween is on.
        Semantics(
          label: '$safeTotal ${TracGoStrings.dashboardStatQualifier}',
          excludeSemantics: true,
          child: AnimatedCount(
            value: safeTotal,
            builder: (context, animated) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$animated',
                    style: tracGoTextTheme.titleLarge?.copyWith(
                      fontSize: 34,
                      height: 0.9,
                      letterSpacing: -1.02, // -0.03em at 34px
                    ),
                  ),
                  TextSpan(
                    text: '  ${TracGoStrings.dashboardStatQualifier}',
                    style: tracGoTextTheme.bodySmall?.copyWith(
                      color: tracGoTextMuted,
                    ),
                  ),
                ],
              ),
              // A five-digit total plus the qualifier does not fit one line on a phone,
              // and neither does either of them at a large text scale. Wrapping is the
              // graceful failure; ellipsis on a headline number is not.
              maxLines: 2,
            ),
          ),
        ),
        const _PeriodBadge(),
      ],
    );
  }
}

/// The lime-tinted pill naming the window the count covers.
class _PeriodBadge extends StatelessWidget {
  const _PeriodBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: const BoxDecoration(
        color: tracGoLimeTint,
        borderRadius: pillBorderRadius,
      ),
      child: Text(
        TracGoStrings.dashboardStatPeriod,
        style: tracGoTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tracGoGreen,
        ),
      ),
    );
  }
}

class _StatSpec {
  const _StatSpec(
    this.count,
    this.label,
    this.shortLabel,
    this.icon,
    this.tint,
    this.tintBg,
  );

  final int count;
  final String label;

  /// Fallback for when [label] does not fit the tile — see [_StatLabel].
  final String shortLabel;
  final IconData icon;
  final Color tint;
  final Color tintBg;
}

/// The four status counts, side by side in one row.
///
/// The design moved these from a 2x2 board to a single 4-across strip, which halves the
/// vertical space the block costs and puts every status in one glance. It also costs
/// each tile about two thirds of its width — hence the abbreviated labels in
/// [_StatLabel].
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  static const _gap = 8.0;

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatSpec(
        summary.pendingCount,
        TracGoStrings.dashboardStatPending,
        TracGoStrings.dashboardStatPendingShort,
        Icons.access_time_rounded,
        tracGoStatusPendingDot,
        tracGoStatusPendingBg,
      ),
      _StatSpec(
        summary.approvedCount,
        TracGoStrings.dashboardStatApproved,
        TracGoStrings.dashboardStatApprovedShort,
        Icons.check_rounded,
        tracGoStatusApprovedText,
        tracGoStatusApprovedBg,
      ),
      _StatSpec(
        summary.assignedCount,
        TracGoStrings.dashboardStatAssigned,
        TracGoStrings.dashboardStatAssignedShort,
        Icons.assignment_turned_in_outlined,
        tracGoStatusAssignedDot,
        tracGoStatusAssignedBg,
      ),
      _StatSpec(
        summary.rejectedCount,
        TracGoStrings.dashboardStatRejected,
        TracGoStrings.dashboardStatRejectedShort,
        Icons.close_rounded,
        tracGoStatusRejectedDot,
        tracGoStatusRejectedBg,
      ),
    ];

    // The LayoutBuilder is outside the IntrinsicHeight, and has to be: IntrinsicHeight
    // asks its subtree for intrinsic dimensions, and LayoutBuilder refuses to answer
    // (it would have to run its callback speculatively). Measuring here and passing a
    // plain number down keeps both.
    return LayoutBuilder(
      builder: (context, constraints) {
        // How much room a tile's caption actually gets: the strip's width, less the
        // gaps, split four ways, less the tile's own padding and its 1px border.
        final tileWidth =
            (constraints.maxWidth - _gap * (tiles.length - 1)) / tiles.length;
        final labelWidth =
            tileWidth -
            _StatTile.horizontalPadding * 2 -
            _StatTile.borderWidth * 2;

        // IntrinsicHeight is load-bearing, not decoration. This Row sits in a ListView,
        // so its height is unbounded; `CrossAxisAlignment.stretch` there hands each tile
        // `h=Infinity` and the layout asserts. IntrinsicHeight bounds the Row to its
        // tallest child first, which is also what keeps the four bordered cards ending
        // flush when one of them scales its count or caption down.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                Expanded(
                  child: _StatTile(spec: tiles[i], labelMaxWidth: labelWidth),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.spec, required this.labelMaxWidth});

  static const horizontalPadding = 10.0;
  static const borderWidth = 1.0;

  final _StatSpec spec;

  /// Room the caption has, measured by [_StatGrid] rather than by a LayoutBuilder in
  /// here — see the note there.
  final double labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: tracGoRadiusMedium,
      borderWidth: borderWidth,
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        11,
        horizontalPadding,
        10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: spec.tintBg,
              borderRadius: tracGoBorderRadius(9),
            ),
            alignment: Alignment.center,
            child: Icon(spec.icon, size: 14, color: spec.tint),
          ),
          const SizedBox(height: 6),
          // scaleDown: a four-digit count does not fit a quarter-width tile, and neither
          // does a two-digit one at a large text scale.
          Semantics(
            label: '${spec.count}',
            excludeSemantics: true,
            child: AnimatedCount(
              value: spec.count,
              builder: (context, animated) => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$animated',
                  style: tracGoTextTheme.titleLarge?.copyWith(
                    fontSize: 19,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _StatLabel(
            label: spec.label,
            shortLabel: spec.shortLabel,
            maxWidth: labelMaxWidth,
          ),
        ],
      ),
    );
  }
}

/// The uppercase caption under a tile's count, abbreviated only when it has to be.
///
/// Four tiles across a 393dp phone leaves each label roughly 62dp. "APPROVED" fits at
/// the default text scale and stops fitting well before the accessibility sizes iOS
/// reaches (~3.1x), so the width is measured rather than guessed: the full word is used
/// whenever it fits, the design's own abbreviation when it does not, and `scaleDown` is
/// the last resort so a label can never overflow its tile.
class _StatLabel extends StatelessWidget {
  const _StatLabel({
    required this.label,
    required this.shortLabel,
    required this.maxWidth,
  });

  final String label;
  final String shortLabel;

  /// Room available, from [_StatGrid].
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final style = tracGoTextTheme.bodySmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4, // 0.04em at 10px
      color: tracGoTextMutedAlt,
    );

    final full = label.toUpperCase();
    final painter = TextPainter(
      text: TextSpan(text: full, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final fits = painter.width <= maxWidth;
    // TextPainter holds a native paragraph; dropping it without this leaks it.
    painter.dispose();

    return Semantics(
      // The visual may be an abbreviation; what is announced never is.
      label: label,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        // Last resort, and it does fire: even "REJD" outgrows a quarter-width tile
        // somewhere above 2x text scaling, and a caption that overflows its card is
        // worse than one that shrinks.
        child: Text(
          fits ? full : shortLabel.toUpperCase(),
          style: style,
          maxLines: 1,
        ),
      ),
    );
  }
}

class _NewRequisitionButton extends StatelessWidget {
  const _NewRequisitionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: pillShape,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // The default 64dp floor makes the pill wider than its label needs; the
        // enclosing Wrap already bounds it to the row width.
        minimumSize: Size.zero,
      ),
      // Flexible, not a bare Text: at large accessibility text sizes the label
      // plus the icon exceeds the available width and the Row would overflow.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              TracGoStrings.dashboardNewRequisition,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                color: tracGoSurfaceWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
