import 'package:flutter/material.dart';

import 'colors.dart';

/// Headlines, brand wordmark, button labels, big numbers, section titles.
const manropeFontFamily = 'Manrope';

/// Body copy, field labels, nav items — everything without an explicit Manrope override.
const interFontFamily = 'Inter';

/// Ported 1:1 from ui/theme/Type.kt's Typography() mapping, onto Flutter's TextTheme roles.
const tmsTextTheme = TextTheme(
  headlineSmall: TextStyle(
    fontFamily: manropeFontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 27,
    height: 34 / 27,
    letterSpacing: -0.01,
    color: tmsTextDark,
  ),
  titleLarge: TextStyle(
    fontFamily: manropeFontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 21,
    height: 27 / 21,
    color: tmsTextDark,
  ),
  titleMedium: TextStyle(
    fontFamily: manropeFontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 17,
    height: 22 / 17,
    color: tmsTextDark,
  ),
  bodyLarge: TextStyle(
    fontFamily: interFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 22 / 15,
    color: tmsTextDark,
  ),
  bodyMedium: TextStyle(
    fontFamily: interFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 20 / 13.5,
    color: tmsTextDark,
  ),
  bodySmall: TextStyle(
    fontFamily: interFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 17 / 12.5,
    color: tmsTextMutedAlt,
  ),
  labelLarge: TextStyle(
    fontFamily: manropeFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 18 / 14,
    color: tmsTextDark,
  ),
  labelMedium: TextStyle(
    fontFamily: interFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.04,
    color: tmsTextSubtle,
  ),
  labelSmall: TextStyle(
    fontFamily: interFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 11.5,
    height: 15 / 11.5,
    color: tmsTextDark,
  ),
);
