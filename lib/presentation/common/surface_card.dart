import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/shapes.dart';

/// The white, hairline-outlined container every group sits in — list sections, form
/// sections, detail sections, the activity timeline.
///
/// One shape, one border, no elevation: the daylight design separates surfaces with a
/// 1px rule rather than a shadow, and a Material `Card` with its default tint and
/// elevation reads as a different component beside these.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = tracGoRadiusCard,
    this.color = tracGoSurfaceWhite,
    this.borderColor = tracGoBorder,
    this.borderWidth = 1,
    this.clipContent = false,
  });

  /// A card whose children are stacked rows *separated* by the inner hairline.
  ///
  /// Rules go between rows only — never above the first one. The design file draws a
  /// leading rule wherever the card has top padding, but on device it reads as a stray
  /// line under the card's own border rather than as the group's opening, so it is not
  /// reproduced. A group opens on whitespace.
  factory SurfaceCard.rows({
    Key? key,
    required List<Widget> rows,
    EdgeInsets padding = EdgeInsets.zero,
    double radius = tracGoRadiusCard,
    Color color = tracGoSurfaceWhite,
    Color borderColor = tracGoBorder,
  }) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(const Divider(height: 1, thickness: 1, color: tracGoDivider));
      }
      children.add(rows[i]);
    }
    return SurfaceCard(
      key: key,
      padding: padding,
      radius: radius,
      color: color,
      borderColor: borderColor,
      // Rows carry ink splashes and rounded selections of their own; without clipping
      // the topmost and bottom-most paint square over the card's corners.
      clipContent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  /// Null draws no outline at all — used by the dark hero cards, which are defined by
  /// their fill.
  final Color? borderColor;
  final double borderWidth;
  final bool clipContent;

  @override
  Widget build(BuildContext context) {
    final border = borderColor;
    return Container(
      padding: padding,
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        borderRadius: tracGoBorderRadius(radius),
        border: border == null
            ? null
            : Border.all(color: border, width: borderWidth),
      ),
      child: child,
    );
  }
}

/// A dashed-outline placeholder card — an empty slot the user cannot fill in yet
/// ("No driver or vehicle assigned yet").
///
/// Flutter has no dashed `BorderSide`, so the dashes are painted. The alternative — a
/// solid border — is exactly what the design uses for slots that *are* filled, so
/// reusing it would erase the distinction the card exists to make.
class DashedSurfaceCard extends StatelessWidget {
  const DashedSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = tracGoRadiusCard,
    this.borderColor = tracGoDashedBorder,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // foregroundPainter, not painter: a background painter draws *behind* the child,
      // and the child's own white fill reaches the same rounded edge — it would cover
      // the inner half of every dash and leave a hairline that reads as solid.
      foregroundPainter: _DashedBorderPainter(color: borderColor, radius: radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: tracGoSurfaceWhite,
          borderRadius: tracGoBorderRadius(radius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 5.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    // A zero-area box (a card in a collapsed layout) has no outline to draw and
    // `PathMetric` would divide by a zero length below.
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
