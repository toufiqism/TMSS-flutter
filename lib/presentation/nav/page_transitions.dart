import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/motion.dart';

// Route transitions for the app's three kinds of navigation. The distinction is the
// point: a user should be able to tell, from the movement alone, whether they went
// *deeper* into the app or *sideways* within it.
//
//   deeper   (list → detail, → create, → profile)   horizontal slide + fade
//   sideways (dashboard ↔ list, via the drawer)     fade-through, no travel
//   session  (splash → login → dashboard)           scale + fade
//
// All three collapse to an instant swap under "reduce motion": the page functions
// identically, it simply arrives without the movement.
//
// Note on predictive back: these are `CustomTransitionPage`s, so the Android 14 system
// back gesture pops without the platform's peek-the-previous-screen animation. The pop
// itself, and every `PopScope` the app relies on (see `back_navigation.dart`), is
// unaffected — the manifest's `enableOnBackInvokedCallback` is what those depend on.

/// Push transition: the incoming screen slides in from the right as it fades up, while
/// the screen it covers slides a shorter distance the other way.
///
/// The asymmetry is deliberate. Equal travel in both directions reads as a filmstrip
/// being dragged past the window; a shorter movement underneath reads as one card sliding
/// over another, which is what actually happened.
CustomTransitionPage<T> axisPage<T>({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  final motion = TracGoMotion.of(context);
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: motion.slow,
    reverseTransitionDuration: motion.slow,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final motion = TracGoMotion.of(context);
      // Curves applied with `transform` rather than by wrapping each animation in a
      // `CurvedAnimation`. `transitionsBuilder` runs every frame of the transition, and
      // building two listener-holding objects per frame to throw them away again is
      // avoidable churn.
      return AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        builder: (context, child) {
          final enter = tracGoMotionCurveEmphasized.transform(
            animation.value.clamp(0.0, 1.0),
          );
          final exit = tracGoMotionCurveEmphasized.transform(
            secondaryAnimation.value.clamp(0.0, 1.0),
          );
          final dx =
              (1 - enter) * motion.travelRoute -
              exit * motion.travelRouteOutgoing;
          return Opacity(
            // The covered screen is allowed to fade only part way: it is still visible
            // through the incoming screen's own fade, and dropping it to zero leaves a
            // flash of bare scaffold in the gap.
            opacity: (enter * (1 - exit * 0.7)).clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(dx, 0), child: child),
          );
        },
        child: child,
      );
    },
  );
}

/// Sibling transition: no travel at all, just a cross-fade with a whisper of scale.
///
/// Used where the two screens are peers rather than parent and child — the drawer's
/// Dashboard and My Requisition. Sliding these would imply a hierarchy that does not
/// exist, and would also mean the direction of travel depended on the order of the
/// drawer's rows, which is meaningless to the user.
CustomTransitionPage<T> fadeThroughPage<T>({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  final motion = TracGoMotion.of(context);
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: motion.base,
    reverseTransitionDuration: motion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade-through: the outgoing screen is most of the way gone before the incoming one
      // commits, so the two are never both half-visible over each other. The interval is
      // what creates that gap.
      const gap = Interval(0.35, 1, curve: tracGoMotionCurve);
      return AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        builder: (context, child) {
          final fadeIn = gap.transform(animation.value.clamp(0.0, 1.0));
          final fadeOut = gap.transform(
            (1 - secondaryAnimation.value).clamp(0.0, 1.0),
          );
          return Opacity(
            opacity: (fadeIn * fadeOut).clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.98 + 0.02 * fadeIn, child: child),
          );
        },
        child: child,
      );
    },
  );
}

/// Session transition: scale and fade, no direction.
///
/// Splash → login → dashboard are not navigation in the user's mental model; they are the
/// app deciding who you are. Movement with a direction would imply a place they could go
/// back to, and there is none — the redirect replaces the stack.
CustomTransitionPage<T> scaleFadePage<T>({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  final motion = TracGoMotion.of(context);
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: motion.slow,
    reverseTransitionDuration: motion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = tracGoMotionCurve.transform(
            animation.value.clamp(0.0, 1.0),
          );
          return Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
          );
        },
        child: child,
      );
    },
  );
}
