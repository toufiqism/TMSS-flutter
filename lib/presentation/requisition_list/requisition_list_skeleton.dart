import 'package:flutter/material.dart';

import '../common/page_width.dart';
import '../common/skeleton.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';

/// Placeholder for the grouped requisition list.
///
/// Two groups of three rows: enough to fill the viewport it replaces, few enough that the
/// real list arriving does not visibly shrink the scroll extent under the user's thumb.
///
/// The search-and-filter header above it is *not* skeletonised — it is chrome the screen
/// owns rather than data it is waiting for, and it works (and is worth using) before the
/// first row lands.
class RequisitionListSkeleton extends StatelessWidget {
  const RequisitionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonSemantics(
      label: TracGoStrings.loadingRequisitions,
      child: SkeletonHost(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20,
          ).constrainToContentWidth(context),
          children: const [
            _GroupSkeleton(rows: 3),
            SizedBox(height: 18),
            _GroupSkeleton(rows: 2),
          ],
        ),
      ),
    );
  }
}

class _GroupSkeleton extends StatelessWidget {
  const _GroupSkeleton({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The uppercase day header.
        const Padding(
          padding: EdgeInsets.only(bottom: 9),
          child: SkeletonBox(width: 104, height: 11, radius: 5),
        ),
        SurfaceCard.rows(
          rows: [for (var i = 0; i < rows; i++) const _RowSkeleton()],
        ),
      ],
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 74, height: 13, radius: 6),
              SkeletonBox(width: 82, height: 26, radius: 999),
            ],
          ),
          SizedBox(height: 12),
          SkeletonLine(widthFactor: 0.66, height: 16),
          SizedBox(height: 9),
          SkeletonLine(widthFactor: 0.4, height: 12),
        ],
      ),
    );
  }
}
