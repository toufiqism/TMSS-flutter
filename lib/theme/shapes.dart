import 'package:flutter/material.dart';

// Corner radii per the redesign mock: inputs 14px, cards 16px, icon badges 10px, screen frame 20px.
const tmsRadiusExtraSmall = 10.0;
const tmsRadiusSmall = 14.0;
const tmsRadiusMedium = 16.0;
const tmsRadiusLarge = 20.0;
const tmsRadiusExtraLarge = 24.0;

BorderRadius tmsBorderRadius(double radius) => BorderRadius.circular(radius);

/// Fully-rounded pill shape used for buttons, toggles, filter chips, and status badges.
const pillBorderRadius = BorderRadius.all(Radius.circular(999));
final pillShape = RoundedRectangleBorder(borderRadius: pillBorderRadius);

final tmsInputShape = RoundedRectangleBorder(
  borderRadius: tmsBorderRadius(tmsRadiusSmall),
);
final tmsCardShape = RoundedRectangleBorder(
  borderRadius: tmsBorderRadius(tmsRadiusMedium),
);
