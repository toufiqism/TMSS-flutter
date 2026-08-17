import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/motion.dart';

/// Marks a subtree whose entrance animations should each run exactly once.
///
/// This exists because of `ListView.builder`. It destroys the elements of rows that
/// scroll out of view and rebuilds them on the way back, so an entrance animation keyed
/// to `initState` re-runs every time the user scrolls up — the list appears to reload
/// itself under the finger. The scope lives in the screen's State, above the list, and
/// remembers which entrance keys have already played.
///
/// Rows without a key (a fixed section of a screen, built once) do not need the scope and
/// work without one.
class MotionEntranceScope extends StatefulWidget {
  const MotionEntranceScope({super.key, required this.child});

  final Widget child;

  static _MotionEntranceScopeState? _maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_MotionEntranceMarker>()
        ?.state;
  }

  @override
  State<MotionEntranceScope> createState() => _MotionEntranceScopeState();
}

class _MotionEntranceScopeState extends State<MotionEntranceScope> {
  final _claimed = <Object>{};

  /// True the first time [key] is seen, false every time after.
  bool claim(Object key) => _claimed.add(key);

  @override
  Widget build(BuildContext context) {
    return _MotionEntranceMarker(state: this, child: widget.child);
  }
}

class _MotionEntranceMarker extends InheritedWidget {
  const _MotionEntranceMarker({required this.state, required super.child});

  final _MotionEntranceScopeState state;

  @override
  bool updateShouldNotify(_MotionEntranceMarker oldWidget) => false;
}

/// Fades a widget in while it rises the last few pixels into place.
///
/// The single entrance gesture in this app: content never slides in from the side, never
/// scales, and never travels more than [TracGoMotion.travelLarge].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.travel,
    this.entranceKey,
    this.enabled = true,
  });

  final Widget child;

  /// How long to wait before starting — see [StaggerColumn].
  final Duration delay;

  /// Vertical distance travelled. Defaults to [TracGoMotion.travelSmall].
  final double? travel;

  /// Identity used by an enclosing [MotionEntranceScope] to decide whether this entrance
  /// has already played. Null means "animate whenever I am built".
  final Object? entranceKey;

  /// False renders the child immediately, no animation. For call sites that decide at
  /// build time (an item far down a long list, say).
  final bool enabled;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tracGoMotionBase,
  );

  /// Built once and disposed with the controller. A `CurvedAnimation` created in `build`
  /// registers a listener on its parent every frame and never releases it.
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: tracGoMotionCurve,
  );
  Timer? _delayTimer;

  /// Resolved in the first `didChangeDependencies`, not `initState`: claiming an entrance
  /// requires reading an inherited widget, which is illegal before dependencies resolve.
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final motion = TracGoMotion.of(context);
    final key = widget.entranceKey;
    final alreadyPlayed =
        key != null &&
        !(MotionEntranceScope._maybeOf(context)?.claim(key) ?? true);

    // Three ways to skip: the caller said not to, the platform asks for reduced motion,
    // or this element has animated once already and is only back because the list
    // recycled it.
    if (!widget.enabled || !motion.enabled || alreadyPlayed) {
      _controller.value = 1;
      return;
    }

    _controller.duration = motion.base;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      // The timer outlives a dispose that happens inside the delay window — a row
      // scrolled away before it ever appeared — so it is cancelled there, and guarded
      // here as well because `Timer` gives no cancellation guarantee for a callback
      // already queued.
      _delayTimer = Timer(widget.delay, () {
        if (!mounted) return;
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travel = widget.travel ?? TracGoMotion.of(context).travelSmall;

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final t = _curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * travel),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A Column whose children enter one after another.
///
/// Used for the fixed sections of a screen (dashboard blocks, detail sections). Long
/// lists use [FadeSlideIn] directly with an `entranceKey`, so recycling does not replay
/// the entrance.
class StaggerColumn extends StatelessWidget {
  const StaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.travel,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double? travel;

  @override
  Widget build(BuildContext context) {
    final motion = TracGoMotion.of(context);
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++)
          FadeSlideIn(
            delay: motion.staggerDelay(i),
            travel: travel,
            child: children[i],
          ),
      ],
    );
  }
}

/// Wraps a list of children in staggered entrances without imposing a parent layout.
///
/// For call sites that already have their own Column/ListView and only want the timing.
List<Widget> staggerAll(
  BuildContext context,
  List<Widget> children, {
  double? travel,
}) {
  final motion = TracGoMotion.of(context);
  return [
    for (var i = 0; i < children.length; i++)
      FadeSlideIn(
        delay: motion.staggerDelay(i),
        travel: travel,
        child: children[i],
      ),
  ];
}

/// The app's state-swap transition: cross-fade with a short rise.
///
/// Replaces every hard `switch (uiState)` swap between loading, error, empty and content.
/// Children must carry distinct keys or the switcher cannot tell a swap from a rebuild —
/// most call sites get that for free from differing widget types.
class MotionSwitcher extends StatelessWidget {
  const MotionSwitcher({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.duration,
  });

  final Widget child;

  /// Top-aligned by default, unlike [AnimatedSwitcher]'s centre. A centred stack makes
  /// the outgoing and incoming screens jump vertically past each other whenever their
  /// heights differ, which for loading-to-content is always.
  final Alignment alignment;

  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final motion = TracGoMotion.of(context);
    return AnimatedSwitcher(
      duration: duration ?? motion.base,
      switchInCurve: tracGoMotionCurve,
      switchOutCurve: tracGoMotionCurveExit,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            // Fraction of the child's own height, so the travel scales with the thing
            // moving rather than being 8px on a full-page skeleton and 8px on a chip.
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Shrinks slightly while held.
///
/// Built on [Listener], not [GestureDetector], on purpose: the widgets this wraps already
/// have an `InkWell` handling the tap. A second gesture detector would enter the arena
/// and one of the two would lose — usually the InkWell, silently breaking the tap. Raw
/// pointer events do not compete.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// False for disabled controls — a dead button that still squashes reads as broken.
  final bool enabled;

  /// A drag this far from the press point is a scroll, not a press.
  static const _slop = 12.0;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  Offset? _origin;

  void _release() {
    _origin = null;
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final motion = TracGoMotion.of(context);
    if (!widget.enabled || !motion.enabled) return widget.child;

    return Listener(
      // Down events only; the child still receives everything.
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        _origin = event.position;
        setState(() => _pressed = true);
      },
      onPointerMove: (event) {
        final origin = _origin;
        if (origin == null) return;
        if ((event.position - origin).distance > PressableScale._slop) {
          // Far enough to be a scroll, not a press. Let go now, or the row stays
          // squashed for the whole flick.
          _release();
        }
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedScale(
        scale: _pressed ? motion.pressScale : 1.0,
        duration: motion.fast,
        curve: tracGoMotionCurve,
        child: widget.child,
      ),
    );
  }
}

/// Counts up to [value] instead of snapping to it.
///
/// Only ever used on the dashboard's totals. Numbers that change for a reason the user
/// caused (a form's person count) are not animated — a value that lags the tap that set
/// it reads as lag, not polish.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    required this.builder,
    this.duration,
  });

  final int value;
  final Widget Function(BuildContext context, int value) builder;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final motion = TracGoMotion.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration ?? motion.base,
      curve: tracGoMotionCurve,
      builder: (context, animated, _) => builder(context, animated.round()),
    );
  }
}
