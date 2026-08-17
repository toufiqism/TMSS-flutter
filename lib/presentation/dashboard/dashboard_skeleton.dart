import 'package:flutter/material.dart';

import '../../theme/shapes.dart';
import '../common/page_width.dart';
import '../common/safe_insets.dart';
import '../common/skeleton.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';

/// The dashboard's shape, drawn before its data arrives.
///
/// Deliberately laid out from the same numbers as `_DashboardContent` — same padding,
/// same 14/24/12 gaps, same four-tile strip — so the real content lands where the
/// placeholder stood instead of shifting the page under the reader's eye.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonSemantics(
      label: TracGoStrings.loadingDashboard,
      child: SkeletonHost(
        child: ListView(
          // Matches the real content's physics so the pull-to-refresh gesture behaves
          // identically while loading.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            22,
            20,
            20,
          ).addBottomSystemInset(context).constrainToContentWidth(context),
          children: [
            // Hero count line + period badge.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SkeletonBox(width: 150, height: 34, radius: 8),
                SkeletonBox(width: 110, height: 28, radius: 999),
              ],
            ),
            const SizedBox(height: 14),
            const _StatStripSkeleton(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 96, height: 20, radius: 6),
                SkeletonBox(width: 130, height: 32, radius: 999),
              ],
            ),
            const SizedBox(height: 12),
            SurfaceCard.rows(
              rows: const [
                _RecentRowSkeleton(),
                _RecentRowSkeleton(),
                _RecentRowSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatStripSkeleton extends StatelessWidget {
  const _StatStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            const Expanded(
              child: SurfaceCard(
                radius: tracGoRadiusMedium,
                padding: EdgeInsets.fromLTRB(10, 11, 10, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(width: 26, height: 26, radius: 9),
                    SizedBox(height: 6),
                    SkeletonBox(width: 22, height: 19, radius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 44, height: 10, radius: 5),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentRowSkeleton extends StatelessWidget {
  const _RecentRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          SkeletonBox(width: 8, height: 8, shape: BoxShape.circle),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(widthFactor: 0.62, height: 15),
                SizedBox(height: 9),
                SkeletonLine(widthFactor: 0.85, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 78, height: 26, radius: 999),
        ],
      ),
    );
  }
}
