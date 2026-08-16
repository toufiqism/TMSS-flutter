import 'package:flutter/material.dart';

import 'colors.dart';

/// Headlines, brand wordmark, button labels, big numbers, section titles.
///
/// Space Grotesk replaced Manrope with the Sign In redesign. Its weight axis stops at
/// 700, so the three roles that asked for Manrope's 800 now ask for 700 — requesting a
/// weight a family does not ship makes the engine synthesise a fake bold, which is
/// heavier and blurrier than the real cut.
const displayFontFamily = 'Space Grotesk';

/// Body copy, field labels, nav items — everything without an explicit display override.
const bodyFontFamily = 'Plus Jakarta Sans';

/// Ported 1:1 from ui/theme/Type.kt's Typography() mapping, onto Flutter's TextTheme roles.
const tracGoTextTheme = TextTheme(
  headlineSmall: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 27,
    height: 34 / 27,
    letterSpacing: -0.01,
    color: tracGoTextDark,
  ),
  titleLarge: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 21,
    height: 27 / 21,
    color: tracGoTextDark,
  ),
  titleMedium: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 17,
    height: 22 / 17,
    color: tracGoTextDark,
  ),
  bodyLarge: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 22 / 15,
    color: tracGoTextDark,
  ),
  bodyMedium: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 20 / 13.5,
    color: tracGoTextDark,
  ),
  bodySmall: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 17 / 12.5,
    color: tracGoTextMutedAlt,
  ),
  labelLarge: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 18 / 14,
    color: tracGoTextDark,
  ),
  labelMedium: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.04,
    color: tracGoTextSubtle,
  ),
  labelSmall: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 11.5,
    height: 15 / 11.5,
    color: tracGoTextDark,
  ),
);
