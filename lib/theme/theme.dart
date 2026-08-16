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
    primaryContainer: tracGoStatusApprovedBg,
    onPrimaryContainer: tracGoGreen,
    secondary: tracGoInk,
    onSecondary: tracGoSurfaceWhite,
    secondaryContainer: tracGoSurfaceSoft,
    onSecondaryContainer: tracGoInk,
    error: tracGoDestructiveRed,
    onError: tracGoSurfaceWhite,
    surface: tracGoSurfaceWhite,
    onSurface: tracGoInk,
    surfaceContainerHighest: tracGoInputBackground,
    onSurfaceVariant: tracGoTextMuted,
    outline: tracGoBorder,
    outlineVariant: tracGoDivider,
  );

  // Inset fields carry no outline in the daylight design — the fill is the affordance.
  // Only the error state draws a border, because a red fill would be unreadable.
  final fieldBorder = OutlineInputBorder(
    borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
    borderSide: BorderSide.none,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tracGoPageBackground,
    textTheme: tracGoTextTheme,
    fontFamily: bodyFontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: tracGoSurfaceWhite,
      foregroundColor: tracGoInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // The design separates the top bar from the page with a hairline, not a shadow.
      shape: Border(bottom: BorderSide(color: tracGoBorder)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tracGoInputBackground,
      hintStyle: tracGoTextTheme.bodyLarge?.copyWith(color: tracGoPlaceholder),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder,
      disabledBorder: fieldBorder,
      errorBorder: OutlineInputBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
        borderSide: const BorderSide(color: tracGoDestructiveRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
        borderSide: const BorderSide(color: tracGoDestructiveRed),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tracGoGreen,
        foregroundColor: tracGoSurfaceWhite,
        disabledBackgroundColor: tracGoGreen.withValues(alpha: 0.45),
        disabledForegroundColor: tracGoSurfaceWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        // Every button in the design is a pill; none of them are rounded rectangles.
        shape: pillShape,
        textStyle: tracGoTextTheme.labelLarge?.copyWith(fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tracGoInk,
        backgroundColor: tracGoSurfaceWhite,
        side: const BorderSide(color: tracGoBorder),
        shape: pillShape,
        textStyle: tracGoTextTheme.labelLarge?.copyWith(fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: tracGoGreen),
    ),
    cardTheme: CardThemeData(
      color: tracGoSurfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusCard),
        side: const BorderSide(color: tracGoBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tracGoSurfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusExtraLarge),
      ),
      titleTextStyle: tracGoTextTheme.titleMedium,
      contentTextStyle: tracGoTextTheme.bodyLarge?.copyWith(color: tracGoTextMuted),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: tracGoInk,
      contentTextStyle: tracGoTextTheme.bodyMedium?.copyWith(
        color: tracGoSurfaceWhite,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
      ),
    ),
    dividerTheme: const DividerThemeData(color: tracGoDivider, space: 1, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: tracGoGreen),
  );
}
