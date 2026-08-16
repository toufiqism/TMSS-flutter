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

/// Mapped onto Flutter's TextTheme roles from the daylight redesign's type scale.
///
/// The design leans on tight negative tracking for display text and wide positive
/// tracking for uppercase micro-labels; both are baked in here rather than reapplied at
/// call sites, because a section label that forgets its 0.1em reads as a different
/// component.
const tracGoTextTheme = TextTheme(
  /// Sign In's "Welcome back." — the screen scales it up to 40 itself.
  headlineSmall: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.84, // -0.03em
    color: tracGoInk,
  ),

  /// Profile name, hero counts.
  titleLarge: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.22, // -0.01em
    color: tracGoInk,
  ),

  /// Screen titles, the top-bar wordmark, "Recent".
  titleMedium: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: -0.18, // -0.01em
    color: tracGoInk,
  ),

  /// The bold line in a list row — a route, a vehicle name. Body family, not display:
  /// the design sets these in Plus Jakarta Sans 700.
  titleSmall: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 21 / 16,
    letterSpacing: -0.16, // -0.01em
    color: tracGoInk,
  ),

  /// Form input text, running copy.
  bodyLarge: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 22 / 15,
    color: tracGoInk,
  ),

  /// Row values, drawer items.
  bodyMedium: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: tracGoInk,
  ),

  /// Row supporting text — "Today, 10:00 AM · Client pickup".
  bodySmall: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 18 / 13,
    color: tracGoTextFaint,
  ),

  /// Button labels. Display family, per the design's pill buttons.
  labelLarge: TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 20 / 16,
    color: tracGoInk,
  ),

  /// Field labels inside grouped form cards.
  labelMedium: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    color: tracGoTextMutedAlt,
  ),

  /// Uppercase micro-labels — section captions, the "ALL REQUISITIONS" eyebrow, day
  /// headers. Always drawn through `SectionLabel`, which uppercases the text for it.
  labelSmall: TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 15 / 11,
    letterSpacing: 1.1, // 0.1em
    color: tracGoTextMutedAlt,
  ),
);

/// The title in a screen's top bar. Two points larger than [TextTheme.titleMedium],
/// which is the wordmark's size — on a screen that names itself, the name is the
/// dominant element rather than a peer of the brand.
const tracGoScreenTitleStyle = TextStyle(
  fontFamily: displayFontFamily,
  fontWeight: FontWeight.w700,
  fontSize: 20,
  height: 26 / 20,
  letterSpacing: -0.2, // -0.01em
  color: tracGoInk,
);

/// Status pills and other small caps-y badges: 11px bold with only a hint of tracking,
/// as opposed to [TextTheme.labelSmall]'s full 0.1em.
const tracGoChipTextStyle = TextStyle(
  fontFamily: bodyFontFamily,
  fontWeight: FontWeight.w700,
  fontSize: 11,
  height: 15 / 11,
  letterSpacing: 0.44, // 0.04em
  color: tracGoInk,
);
