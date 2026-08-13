import 'package:flutter/material.dart';

import 'colors.dart';
import 'shapes.dart';
import 'typography.dart';

/// Light-only, matching the Android app (dark mode was explicitly removed there — no
/// values-night equivalent exists, so this never branches on Brightness).
ThemeData buildTmsTheme() {
  final colorScheme = const ColorScheme.light(
    primary: tmsGreen,
    onPrimary: tmsSurfaceWhite,
    primaryContainer: tmsGreenLight,
    onPrimaryContainer: tmsTextDark,
    secondary: tmsGreenDark,
    onSecondary: tmsSurfaceWhite,
    secondaryContainer: tmsGreenLight,
    onSecondaryContainer: tmsGreen,
    error: tmsStatusRejectedRed,
    onError: tmsSurfaceWhite,
    surface: tmsSurfaceWhite,
    onSurface: tmsTextDark,
    surfaceContainerHighest: tmsInputBackground,
    onSurfaceVariant: tmsTextSubtle,
    outline: tmsBorder,
    outlineVariant: tmsDivider,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tmsPageBackground,
    textTheme: tmsTextTheme,
    fontFamily: interFontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: tmsSurfaceWhite,
      foregroundColor: tmsTextDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tmsInputBackground,
      border: OutlineInputBorder(borderRadius: tmsBorderRadius(tmsRadiusSmall), borderSide: const BorderSide(color: tmsBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: tmsBorderRadius(tmsRadiusSmall), borderSide: const BorderSide(color: tmsBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: tmsBorderRadius(tmsRadiusSmall), borderSide: const BorderSide(color: tmsBorder)),
      errorBorder: OutlineInputBorder(borderRadius: tmsBorderRadius(tmsRadiusSmall), borderSide: const BorderSide(color: tmsStatusRejectedRed)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tmsGreen,
        foregroundColor: tmsSurfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: tmsBorderRadius(tmsRadiusSmall)),
      ),
    ),
    cardTheme: CardThemeData(
      color: tmsSurfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: tmsBorderRadius(tmsRadiusMedium),
        side: const BorderSide(color: tmsDivider),
      ),
    ),
    dividerTheme: const DividerThemeData(color: tmsDivider),
  );
}
