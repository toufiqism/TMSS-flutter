import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/requisition.dart';
import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/requisition_row.dart';
import '../common/safe_insets.dart';
import '../common/strings.dart';
import 'dashboard_notifier.dart';
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
      body: switch (uiState) {
        DashboardLoading() => const Center(child: CircularProgressIndicator()),
        DashboardError(:final message) => _ErrorState(
          message: message,
          onRetry: notifier.load,
        ),
        DashboardSuccess(:final summary) => RefreshIndicator(
          onRefresh: notifier.refresh,
          child: _DashboardContent(
            summary: summary,
            onViewAllRequisitions: widget.onViewAllRequisitions,
            onRequisitionNow: widget.onRequisitionNow,
            onOpenRequisition: widget.onOpenRequisition,
          ),
        ),
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(TracGoStrings.dashboardRetry),
          ),
        ],
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
    return ListView(
      // Without this the dashboard cannot be over-scrolled when its content is
      // shorter than the viewport, and the enclosing RefreshIndicator never fires.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20).addBottomSystemInset(context),
      children: [
        _StatPanel(summary: summary),
        const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    TracGoStrings.dashboardViewAll,
                    style: tracGoTextTheme.bodyMedium?.copyWith(
                      color: tracGoGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (summary.recentRequisitions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              TracGoStrings.dashboardNoRecentRequisitions,
              textAlign: TextAlign.center,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                color: tracGoTextMutedAlt,
              ),
            ),
          )
        else
          for (final requisition in summary.recentRequisitions) ...[
            const SizedBox(height: 14),
            RequisitionRow(
              requisition: requisition,
              onTap: () => onOpenRequisition(requisition),
            ),
          ],
      ],
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

class _StatSpec {
  const _StatSpec(this.count, this.label, this.icon, this.tint, this.tintBg);
  final int count;
  final String label;
  final IconData icon;
  final Color tint;
  final Color tintBg;
}

/// Type scale and geometry for the summary card. The mock is a 1000px desktop grid;
/// its side-by-side structure holds at every width, but its paddings and 64sp count do
/// not fit a ~110dp hero column on a phone, so the compact set shrinks them and moves
/// the hero label under its badge instead of beside it.
class _StatMetrics {
  const _StatMetrics({
    required this.heroPadding,
    required this.heroBadgeSize,
    required this.heroBadgeRadius,
    required this.heroIconSize,
    required this.heroLabelSize,
    required this.heroLabelBesideBadge,
    required this.heroCountSize,
    required this.tilePadding,
    required this.tileBadgeSize,
    required this.tileBadgeRadius,
    required this.tileIconSize,
    required this.tileCountSize,
    required this.tileLabelSize,
  });

  static const compact = _StatMetrics(
    heroPadding: EdgeInsets.fromLTRB(16, 16, 16, 14),
    heroBadgeSize: 32,
    heroBadgeRadius: 11,
    heroIconSize: 18,
    heroLabelSize: 12.5,
    heroLabelBesideBadge: false,
    heroCountSize: 40,
    tilePadding: EdgeInsets.all(12),
    tileBadgeSize: 28,
    tileBadgeRadius: 9,
    tileIconSize: 16,
    tileCountSize: 22,
    tileLabelSize: 12,
  );

  static const comfortable = _StatMetrics(
    heroPadding: EdgeInsets.fromLTRB(26, 26, 26, 22),
    heroBadgeSize: 40,
    heroBadgeRadius: 12,
    heroIconSize: 20,
    heroLabelSize: 14,
    heroLabelBesideBadge: true,
    heroCountSize: 64,
    tilePadding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
    tileBadgeSize: 36,
    tileBadgeRadius: 11,
    tileIconSize: 18,
    tileCountSize: 32,
    tileLabelSize: 14,
  );

  final EdgeInsets heroPadding;
  final double heroBadgeSize;
  final double heroBadgeRadius;
  final double heroIconSize;
  final double heroLabelSize;
  final bool heroLabelBesideBadge;
  final double heroCountSize;
  final EdgeInsets tilePadding;
  final double tileBadgeSize;
  final double tileBadgeRadius;
  final double tileIconSize;
  final double tileCountSize;
  final double tileLabelSize;
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.summary});

  /// Gap between the card's cells, and the card's own inner padding.
  static const _gap = 8.0;

  /// At or above this card width the mock's full desktop metrics are used; below it the
  /// compact set. The layout itself does not change — hero left, 2x2 grid right, at
  /// every width.
  static const _comfortableBreakpoint = 520.0;

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatSpec(summary.approvedCount, TracGoStrings.dashboardStatApproved, Icons.event_available_outlined, tracGoStatusApprovedGreen, tracGoStatusApprovedGreenBg),
      _StatSpec(summary.assignedCount, TracGoStrings.dashboardStatAssigned, Icons.check_box_outlined, tracGoStatusAssignedTeal, tracGoStatusAssignedTealBg),
      _StatSpec(summary.pendingCount, TracGoStrings.dashboardStatPending, Icons.access_time_outlined, tracGoStatusPendingOrange, tracGoStatusPendingOrangeBg),
      _StatSpec(summary.rejectedCount, TracGoStrings.dashboardStatRejected, Icons.cancel_outlined, tracGoStatusRejectedRed, tracGoStatusRejectedRedBg),
    ];

    return Container(
      padding: const EdgeInsets.all(_gap),
      decoration: BoxDecoration(
        color: tracGoSurfaceWhite,
        borderRadius: tracGoBorderRadius(tracGoRadiusExtraLarge),
        boxShadow: const [
          BoxShadow(color: Color(0x0A18281E), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D18281E), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = constraints.maxWidth < _comfortableBreakpoint
              ? _StatMetrics.compact
              : _StatMetrics.comfortable;

          // IntrinsicHeight bounds the row's height, which is what lets the grid split
          // it into two equal rows and both columns end flush at the bottom. The hero
          // is normally the taller of the two and therefore sets that height.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1.15fr / 2fr, straight from the mock's grid-template-columns.
                Expanded(flex: 115, child: _AllRequisitionsTile(summary: summary, metrics: metrics)),
                const SizedBox(width: _gap),
                Expanded(flex: 200, child: _StatTileGrid(specs: tiles, metrics: metrics)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AllRequisitionsTile extends StatelessWidget {
  const _AllRequisitionsTile({required this.summary, required this.metrics});

  final DashboardSummary summary;
  final _StatMetrics metrics;

  @override
  Widget build(BuildContext context) {
    // allCount is a server field and is not validated upstream; a negative total would
    // render as "-3" here, so floor it.
    final total = summary.allCount < 0 ? 0 : summary.allCount;

    final badge = _StatIconBadge(
      icon: Icons.assignment_outlined,
      tint: tracGoStatHeroAccent,
      tintBg: tracGoStatHeroBadgeBg,
      size: metrics.heroBadgeSize,
      radius: metrics.heroBadgeRadius,
      iconSize: metrics.heroIconSize,
    );
    final label = Text(
      TracGoStrings.dashboardStatAll,
      style: tracGoTextTheme.bodyMedium?.copyWith(
        fontSize: metrics.heroLabelSize,
        fontWeight: FontWeight.w600,
        letterSpacing: metrics.heroLabelSize * 0.01,
        color: tracGoStatHeroLabel,
      ),
    );

    return Container(
      padding: metrics.heroPadding,
      decoration: BoxDecoration(
        borderRadius: tracGoBorderRadius(tracGoRadiusStatTile),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tracGoStatHeroGradientTop, tracGoStatHeroGradientBottom],
        ),
      ),
      // space-between: the badge pins to the top and the count to the bottom, so the
      // tile keeps its shape when the status grid beside it is the taller column.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (metrics.heroLabelBesideBadge)
            Row(
              children: [
                badge,
                const SizedBox(width: 12),
                // Expanded so the label wraps inside the tile at large accessibility
                // text sizes instead of pushing the Row past its width.
                Expanded(child: label),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [badge, const SizedBox(height: 10), label],
            ),
          // scaleDown: the count already fills most of the tile, so a large text scale
          // or a four-digit total would otherwise overflow horizontally.
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$total',
                style: tracGoTextTheme.titleLarge?.copyWith(
                  fontSize: metrics.heroCountSize,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: metrics.heroCountSize * -0.03,
                  color: tracGoStatHeroCount,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTileGrid extends StatelessWidget {
  const _StatTileGrid({required this.specs, required this.metrics});

  final List<_StatSpec> specs;
  final _StatMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var rowStart = 0; rowStart < specs.length; rowStart += 2) ...[
          if (rowStart > 0) const SizedBox(height: _StatPanel._gap),
          // Expanded, not intrinsic: the two grid rows split the card height evenly so
          // the right column ends flush with the hero.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatTile(spec: specs[rowStart], metrics: metrics)),
                const SizedBox(width: _StatPanel._gap),
                Expanded(
                  child: rowStart + 1 < specs.length
                      ? _StatTile(spec: specs[rowStart + 1], metrics: metrics)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.spec, required this.metrics});

  final _StatSpec spec;
  final _StatMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: metrics.tilePadding,
      decoration: BoxDecoration(
        color: tracGoStatTileBackground,
        borderRadius: tracGoBorderRadius(tracGoRadiusStatTile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _StatIconBadge(
                icon: spec.icon,
                tint: spec.tint,
                tintBg: spec.tintBg,
                size: metrics.tileBadgeSize,
                radius: metrics.tileBadgeRadius,
                iconSize: metrics.tileIconSize,
              ),
              const SizedBox(width: 8),
              // Expanded + scaleDown: a quarter of the card is narrow, so the count
              // shrinks to fit beside the badge rather than overflowing the tile.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${spec.count}',
                    style: tracGoTextTheme.titleLarge?.copyWith(
                      fontSize: metrics.tileCountSize,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: metrics.tileCountSize * -0.02,
                      color: tracGoTextDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            spec.label,
            style: tracGoTextTheme.bodyMedium?.copyWith(
              fontSize: metrics.tileLabelSize,
              fontWeight: FontWeight.w500,
              color: tracGoTextSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatIconBadge extends StatelessWidget {
  const _StatIconBadge({
    required this.icon,
    required this.tint,
    required this.tintBg,
    required this.size,
    required this.radius,
    required this.iconSize,
  });

  final IconData icon;
  final Color tint;
  final Color tintBg;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tintBg, borderRadius: tracGoBorderRadius(radius)),
      alignment: Alignment.center,
      child: Icon(icon, color: tint, size: iconSize),
    );
  }
}
