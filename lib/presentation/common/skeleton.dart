import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/shapes.dart';

/// Placeholder colours. Quieter than [tracGoBorder] so a screenful of them does not read
/// as content, and only barely lighter at the shimmer's peak — the sweep should be
/// perceptible, not decorative.
const _skeletonBase = Color(0xFFE9EBE4);
const _skeletonHighlight = Color(0xFFF5F6F1);

/// Drives the shimmer for every [SkeletonBox] beneath it.
///
/// One controller per screen rather than one per box: a detail skeleton has ~25 boxes,
/// and 25 independent tickers would both cost more and drift out of phase, so the sweep
/// would look like static rather than a wave.
///
/// The controller does not repeat when the platform asks for reduced motion. That is an
/// accessibility requirement, and it is also what keeps `pumpAndSettle` from hanging in
/// widget tests — an endlessly repeating animation never settles, so a test that pumps a
/// loading screen would time out rather than fail.
class SkeletonHost extends StatefulWidget {
  const SkeletonHost({super.key, required this.child});

  final Widget child;

  static Animation<double>? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SkeletonSweep>()?.sweep;
  }

  @override
  State<SkeletonHost> createState() => _SkeletonHostState();
}

class _SkeletonHostState extends State<SkeletonHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tracGoMotionShimmer,
  );
  bool _resolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolved on every dependency change, not just the first: a user can turn
    // "reduce motion" on while this screen is on display.
    final enabled = TracGoMotion.of(context).enabled;
    if (enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
    _resolved = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(_resolved);
    return _SkeletonSweep(sweep: _controller, child: widget.child);
  }
}

class _SkeletonSweep extends InheritedWidget {
  const _SkeletonSweep({required this.sweep, required super.child});

  final Animation<double> sweep;

  @override
  bool updateShouldNotify(_SkeletonSweep oldWidget) => oldWidget.sweep != sweep;
}

/// One placeholder block.
///
/// Sized by the caller to match the real content it stands in for — a skeleton whose
/// blocks do not land where the text will is worse than a spinner, because the page
/// visibly rearranges itself the moment data arrives.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.shape,
  });

  /// Null stretches to the parent's width.
  final double? width;
  final double height;
  final double radius;

  /// Overrides [radius] — used for the circular avatar placeholders.
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    final sweep = SkeletonHost._maybeOf(context);
    final isCircle = shape == BoxShape.circle;

    // No host above: render flat. Callers are expected to wrap their skeleton in a
    // SkeletonHost, but a missing one should cost the shimmer, not the layout.
    if (sweep == null) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _skeletonBase,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : tracGoBorderRadius(radius),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: sweep,
        builder: (context, _) {
          // -1 → 2 rather than 0 → 1 so the highlight starts fully off the left edge and
          // finishes fully off the right, instead of appearing and vanishing mid-box.
          final t = sweep.value * 3 - 1;
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : tracGoBorderRadius(radius),
              gradient: LinearGradient(
                begin: Alignment(t - 1, 0),
                end: Alignment(t + 1, 0),
                colors: const [
                  _skeletonBase,
                  _skeletonHighlight,
                  _skeletonBase,
                ],
                stops: const [0.35, 0.5, 0.65],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A placeholder for a single line of text, sized as a fraction of the available width so
/// the blocks look like prose rather than a bar chart.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SkeletonBox(height: height, radius: 6),
      ),
    );
  }
}

/// Hides a skeleton from screen readers and announces the wait instead.
///
/// Without this a loading screen reads out as a few dozen unlabelled boxes. With it, the
/// user hears one sentence and the rest is silent.
class SkeletonSemantics extends StatelessWidget {
  const SkeletonSemantics({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      excludeSemantics: true,
      child: child,
    );
  }
}
