import 'package:flutter/material.dart';

// Motion tokens for the "daylight" design system.
//
// The design file is silent on motion, so these are chosen to match its restraint rather
// than ported from it: short, tight, vertical-only travel, nothing that overshoots. The
// rule of thumb is that a user should notice the *absence* of these animations, never the
// animations themselves.
//
// Named for their role, like the colour and shape tokens, so a future retune touches one
// file instead of every call site.

/// Press feedback, chip fills, selection changes — anything that must feel like a direct
/// response to a finger already on the glass.
const tracGoMotionFast = Duration(milliseconds: 120);

/// The workhorse: cross-fades, state swaps, content entrances.
const tracGoMotionBase = Duration(milliseconds: 220);

/// Route transitions and anything that moves a whole screen's worth of pixels.
const tracGoMotionSlow = Duration(milliseconds: 320);

/// Delay between consecutive items in a staggered entrance.
const tracGoMotionStagger = Duration(milliseconds: 40);

/// Items past this index share the last item's delay.
///
/// Without a cap the twentieth row of a list would wait 800 ms to appear, which stops
/// reading as choreography and starts reading as jank. Six is roughly what fits on screen
/// at once, so the cap only ever affects rows the user cannot see yet.
const tracGoMotionStaggerCap = 6;

/// One full sweep of a skeleton's shimmer.
const tracGoMotionShimmer = Duration(milliseconds: 1400);

/// Entrances and anything settling into place: fast out of the gate, gentle at the end.
const tracGoMotionCurve = Curves.easeOutCubic;

/// Route-scale movement, where the extra deceleration keeps a full-screen slide from
/// feeling like it stops abruptly.
const tracGoMotionCurveEmphasized = Curves.easeOutQuint;

/// Exits. Deliberately the mirror of [tracGoMotionCurve] — an element leaving should
/// accelerate away rather than linger.
const tracGoMotionCurveExit = Curves.easeInCubic;

/// Vertical travel for an element fading into place inside a card.
const tracGoMotionTravelSmall = 8.0;

/// Vertical travel for a whole section or list group entering.
const tracGoMotionTravelLarge = 16.0;

/// Horizontal travel for the incoming screen of a push transition.
const tracGoMotionTravelRoute = 24.0;

/// How far the *outgoing* screen slides back on a push. Less than the incoming screen
/// travels, so the two do not read as a conveyor belt.
const tracGoMotionTravelRouteOutgoing = 12.0;

/// Scale a pressable settles to while held.
const tracGoMotionPressScale = 0.97;

/// The resolved motion settings for a subtree, with accessibility applied.
///
/// Every animation in the app goes through this rather than reading the tokens directly,
/// because "Reduce Motion" (iOS) / "Remove animations" (Android) is not a suggestion: a
/// user who turns it on can be made ill by exactly the kind of slide-and-fade this file
/// exists to add. When [enabled] is false every duration collapses to zero and every
/// travel distance to zero — the widgets still build and still swap, they simply arrive
/// already in place.
///
/// Note that zero-duration is the right answer rather than "no animation at all": an
/// `AnimatedSwitcher` with a zero duration still swaps its child correctly, so no call
/// site needs to branch.
@immutable
class TracGoMotion {
  const TracGoMotion._({required this.enabled});

  /// Resolves against the ambient [MediaQuery].
  ///
  /// Falls back to enabled when there is no MediaQuery above this context — that only
  /// happens in a widget test that pumps a bare widget, where animations are harmless.
  factory TracGoMotion.of(BuildContext context) {
    final disabled = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TracGoMotion._(enabled: !disabled);
  }

  /// Motion as it resolves on a device with no accessibility override — what every
  /// screen gets by default. Exposed so the stagger arithmetic can be checked without
  /// pumping a widget for a MediaQuery.
  static const TracGoMotion standard = TracGoMotion._(enabled: true);

  /// False when the platform asks for reduced motion.
  final bool enabled;

  Duration get fast => enabled ? tracGoMotionFast : Duration.zero;
  Duration get base => enabled ? tracGoMotionBase : Duration.zero;
  Duration get slow => enabled ? tracGoMotionSlow : Duration.zero;

  /// Zero when motion is off, so a staggered group appears all at once instead of
  /// popping in one item at a time with no transition to soften it.
  Duration get stagger => enabled ? tracGoMotionStagger : Duration.zero;

  double get travelSmall => enabled ? tracGoMotionTravelSmall : 0;
  double get travelLarge => enabled ? tracGoMotionTravelLarge : 0;
  double get travelRoute => enabled ? tracGoMotionTravelRoute : 0;
  double get travelRouteOutgoing =>
      enabled ? tracGoMotionTravelRouteOutgoing : 0;

  /// 1.0 when motion is off: a button that does not move is the point.
  double get pressScale => enabled ? tracGoMotionPressScale : 1.0;

  /// The delay item [index] waits before entering, capped per [tracGoMotionStaggerCap].
  Duration staggerDelay(int index) {
    if (!enabled || index <= 0) return Duration.zero;
    final steps = index > tracGoMotionStaggerCap
        ? tracGoMotionStaggerCap
        : index;
    return tracGoMotionStagger * steps;
  }

  @override
  bool operator ==(Object other) =>
      other is TracGoMotion && other.enabled == enabled;

  @override
  int get hashCode => enabled.hashCode;
}
