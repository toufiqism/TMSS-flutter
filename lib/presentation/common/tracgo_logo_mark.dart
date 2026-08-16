import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'strings.dart';

/// Which cut of the brand mark to draw.
enum TracGoLogoVariant {
  /// The full-colour pin: green swoosh, navy road with lane dashes, car, traffic light
  /// and signal arcs. For light surfaces.
  color,

  /// A single white pin with the road knocked out of it, for dark surfaces where the
  /// colour art turns into an unreadable smudge — the drawer's green gradient header.
  mono,
}

/// The TracGo pin, traced from the brand artwork into SVG so it stays sharp at any size.
///
/// Symbol only, no wordmark: every place this appears, the name "TracGo" is already set
/// in text beside it, and baking the lettering in would print the name twice.
///
/// This replaced a hand-drawn `CustomPainter` badge (a circle with a tick) that took
/// `badgeColor` and `glyphColor`. Those are gone rather than deprecated — the artwork is
/// ten fixed brand colours and cannot be recoloured to a caller's two, so a parameter
/// that silently did nothing would be worse than a compile error.
class TracGoLogoMark extends StatelessWidget {
  const TracGoLogoMark({
    super.key,
    this.size = 32,
    this.variant = TracGoLogoVariant.color,
  });

  final double size;
  final TracGoLogoVariant variant;

  static const _colorAsset = 'assets/images/tracgo_logo.svg';
  static const _monoAsset = 'assets/images/tracgo_logo_mono.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      variant == TracGoLogoVariant.mono ? _monoAsset : _colorAsset,
      width: size,
      height: size,
      // The artwork is very slightly taller than it is wide. `contain` centres it in the
      // square instead of stretching the pin.
      fit: BoxFit.contain,
      semanticsLabel: TracGoStrings.appName,
      // Decoding is asynchronous. Without this the surrounding row reflows once the
      // picture arrives — visible as a jump on the drawer header and the top bar.
      placeholderBuilder: (context) => SizedBox(width: size, height: size),
    );
  }
}
