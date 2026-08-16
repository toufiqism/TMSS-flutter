import 'package:flutter/material.dart';

import 'colors.dart';
import 'shapes.dart';
import 'typography.dart';

/// Light-only, matching the Android app (dark mode was explicitly removed there — no
/// values-night equivalent exists, so this never branches on Brightness).
ThemeData buildTracGoTheme() {
  final colorScheme = const ColorScheme.light(
    primary: tracGoGreen,
    onPrimary: tracGoSurfaceWhite,
    primaryContainer: tracGoGreenLight,
    onPrimaryContainer: tracGoTextDark,
    secondary: tracGoGreenDark,
    onSecondary: tracGoSurfaceWhite,
    secondaryContainer: tracGoGreenLight,
    onSecondaryContainer: tracGoGreen,
    error: tracGoStatusRejectedRed,
    onError: tracGoSurfaceWhite,
    surface: tracGoSurfaceWhite,
    onSurface: tracGoTextDark,
    surfaceContainerHighest: tracGoInputBackground,
    onSurfaceVariant: tracGoTextSubtle,
    outline: tracGoBorder,
    outlineVariant: tracGoDivider,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tracGoPageBackground,
    textTheme: tracGoTextTheme,
    fontFamily: bodyFontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: tracGoSurfaceWhite,
      foregroundColor: tracGoTextDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tracGoInputBackground,
      border: OutlineInputBorder(borderRadius: tracGoBorderRadius(tracGoRadiusSmall), borderSide: const BorderSide(color: tracGoBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: tracGoBorderRadius(tracGoRadiusSmall), borderSide: const BorderSide(color: tracGoBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: tracGoBorderRadius(tracGoRadiusSmall), borderSide: const BorderSide(color: tracGoBorder)),
      errorBorder: OutlineInputBorder(borderRadius: tracGoBorderRadius(tracGoRadiusSmall), borderSide: const BorderSide(color: tracGoStatusRejectedRed)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tracGoGreen,
        foregroundColor: tracGoSurfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: tracGoBorderRadius(tracGoRadiusSmall)),
      ),
    ),
    cardTheme: CardThemeData(
      color: tracGoSurfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusMedium),
        side: const BorderSide(color: tracGoDivider),
      ),
    ),
    dividerTheme: const DividerThemeData(color: tracGoDivider),
  );
}
