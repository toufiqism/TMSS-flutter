import 'package:flutter/material.dart';

/// Compass-mark badge from the redesign mock: a rounded-square badge with a circle+tick glyph
/// (viewBox 24x24: circle r=8 centered, diagonal tick from (17,7) to (20,4)), drawn directly
/// rather than shipped as a raster asset so it can be recolored per context (dark badge on
/// light screens, translucent badge on the drawer's gradient header). Ports TmsLogoMark.kt 1:1.
class TmsLogoMark extends StatelessWidget {
  const TmsLogoMark({
    super.key,
    required this.badgeColor,
    required this.glyphColor,
    this.size = 32,
    this.cornerRadius = 9,
  });

  final Color badgeColor;
  final Color glyphColor;
  final double size;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _CompassGlyphPainter(glyphColor: glyphColor),
      ),
    );
  }
}

class _CompassGlyphPainter extends CustomPainter {
  _CompassGlyphPainter({required this.glyphColor});

  final Color glyphColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final strokeWidth = 2 * scale;
    final paint = Paint()
      ..color = glyphColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(12 * scale, 12 * scale), 8 * scale, paint);
    canvas.drawLine(Offset(17 * scale, 7 * scale), Offset(20 * scale, 4 * scale), paint);
  }

  @override
  bool shouldRepaint(covariant _CompassGlyphPainter oldDelegate) => oldDelegate.glyphColor != glyphColor;
}
