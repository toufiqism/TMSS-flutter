import 'package:flutter/material.dart';

// Corner radii per the daylight redesign. The design uses a wider spread than the old
// forest-green mock did: icon wells stay tight at 10, inset fields sit at 14, tiles at
// 18-20, and the outer card containers open right up to 22-24.
const tracGoRadiusExtraSmall = 10.0;
const tracGoRadiusSmall = 14.0;
const tracGoRadiusMedium = 16.0;
const tracGoRadiusLarge = 20.0;
const tracGoRadiusExtraLarge = 24.0;

/// Dashboard status tiles.
const tracGoRadiusStatTile = 18.0;

/// The outer white container every grouped list, form section and detail section sits
/// in. The most-used radius in the app.
const tracGoRadiusCard = 22.0;

BorderRadius tracGoBorderRadius(double radius) => BorderRadius.circular(radius);

/// Fully-rounded pill shape used for buttons, toggles, filter chips, and status badges.
const pillBorderRadius = BorderRadius.all(Radius.circular(999));
final pillShape = RoundedRectangleBorder(borderRadius: pillBorderRadius);

final tracGoInputShape = RoundedRectangleBorder(
  borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
);
final tracGoCardShape = RoundedRectangleBorder(
  borderRadius: tracGoBorderRadius(tracGoRadiusCard),
);
