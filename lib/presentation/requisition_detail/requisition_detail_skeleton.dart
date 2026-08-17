import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../common/safe_insets.dart';
import '../common/skeleton.dart';
import '../common/strings.dart';
import '../common/surface_card.dart';

/// Placeholder for the requisition detail page.
///
/// The hero keeps its navy fill rather than being greyed out with everything else: it is
/// the one block whose colour is not data, so blanking it would make the page flash from
/// light to dark the moment the request returns.
class RequisitionDetailSkeleton extends StatelessWidget {
  const RequisitionDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonSemantics(
      label: TracGoStrings.loadingRequisitionDetails,
      child: SkeletonHost(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            26,
          ).addBottomSystemInset(context),
          children: const [
            _HeroSkeleton(),
            SizedBox(height: 20),
            _SectionSkeleton(rows: 2),
            SizedBox(height: 20),
            _SectionSkeleton(rows: 5),
            SizedBox(height: 20),
            _SectionSkeleton(rows: 3),
          ],
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: tracGoInk,
      borderColor: null,
      radius: tracGoRadiusExtraLarge,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tinted for the navy card: the page-level placeholder grey vanishes
              // against ink, and a hero that reads as empty is worse than one that reads
              // as loading.
              _OnInkBox(width: 108, height: 13),
              _OnInkBox(width: 92, height: 28, radius: 999),
            ],
          ),
          SizedBox(height: 20),
          _OnInkBox(width: 168, height: 20),
          SizedBox(height: 14),
          _OnInkBox(width: 148, height: 20),
          SizedBox(height: 18),
          _OnInkBox(width: 236, height: 12),
        ],
      ),
    );
  }
}

class _OnInkBox extends StatelessWidget {
  const _OnInkBox({required this.width, required this.height, this.radius = 6});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tracGoSurfaceWhite.withValues(alpha: 0.12),
        borderRadius: tracGoBorderRadius(radius),
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: SkeletonBox(width: 88, height: 11, radius: 5),
        ),
        SurfaceCard.rows(
          rows: [for (var i = 0; i < rows; i++) const _KeyValueRowSkeleton()],
        ),
      ],
    );
  }
}

class _KeyValueRowSkeleton extends StatelessWidget {
  const _KeyValueRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonBox(width: 96, height: 13, radius: 6),
          SkeletonBox(width: 132, height: 13, radius: 6),
        ],
      ),
    );
  }
}
