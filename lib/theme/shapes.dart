import 'package:flutter/material.dart';

// Corner radii per the redesign mock: inputs 14px, cards 16px, icon badges 10px, screen frame 20px.
const tracGoRadiusExtraSmall = 10.0;
const tracGoRadiusSmall = 14.0;
const tracGoRadiusMedium = 16.0;
const tracGoRadiusLarge = 20.0;
const tracGoRadiusExtraLarge = 24.0;

BorderRadius tracGoBorderRadius(double radius) => BorderRadius.circular(radius);

/// Fully-rounded pill shape used for buttons, toggles, filter chips, and status badges.
const pillBorderRadius = BorderRadius.all(Radius.circular(999));
final pillShape = RoundedRectangleBorder(borderRadius: pillBorderRadius);

final tracGoInputShape = RoundedRectangleBorder(
  borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
);
final tracGoCardShape = RoundedRectangleBorder(
  borderRadius: tracGoBorderRadius(tracGoRadiusMedium),
);
