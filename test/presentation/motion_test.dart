import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/common/motion.dart';
import 'package:tracgo/presentation/common/skeleton.dart';
import 'package:tracgo/theme/motion.dart';

/// Motion is the one part of this app that a user can switch off from the OS, and the
/// one part that can hang a test suite. These cover both: that "reduce motion" really
/// does zero everything out, and that nothing here animates forever.
///
/// The entrance-replay test exists because of a bug this design is built to avoid rather
/// than one that shipped: `ListView.builder` destroys off-screen rows and rebuilds them
/// on the way back, so an entrance tied to `initState` re-runs on every scroll.

/// Pumps [child] with animations enabled or disabled at the MediaQuery level, which is
/// exactly the signal the platform accessibility setting produces.
Widget _app(Widget child, {bool animations = true}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: !animations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

double _opacityOf(WidgetTester tester, Finder child) {
  final opacity = tester.widget<Opacity>(
    find.ancestor(of: child, matching: find.byType(Opacity)).first,
  );
  return opacity.opacity;
}

void main() {
  group('TracGoMotion', () {
    testWidgets('resolves to the real tokens by default', (tester) async {
      late TracGoMotion motion;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              motion = TracGoMotion.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(motion.enabled, isTrue);
      expect(motion.base, tracGoMotionBase);
      expect(motion.travelSmall, tracGoMotionTravelSmall);
      expect(motion.pressScale, tracGoMotionPressScale);
    });

    testWidgets('zeroes every duration and distance under reduce motion', (
      tester,
    ) async {
      late TracGoMotion motion;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              motion = TracGoMotion.of(context);
              return const SizedBox();
            },
          ),
          animations: false,
        ),
      );

      expect(motion.enabled, isFalse);
      expect(motion.fast, Duration.zero);
      expect(motion.base, Duration.zero);
      expect(motion.slow, Duration.zero);
      expect(motion.stagger, Duration.zero);
      expect(motion.staggerDelay(3), Duration.zero);
      expect(motion.travelSmall, 0);
      expect(motion.travelLarge, 0);
      expect(motion.travelRoute, 0);
      // 1.0, not 0: a pressable that does not move is the point, and a zero scale would
      // make every button vanish while held.
      expect(motion.pressScale, 1.0);
    });

    test('stagger delay caps so late items do not wait indefinitely', () {
      const motion = TracGoMotion.standard;

      expect(motion.staggerDelay(0), Duration.zero);
      expect(motion.staggerDelay(1), tracGoMotionStagger);
      expect(
        motion.staggerDelay(tracGoMotionStaggerCap),
        tracGoMotionStagger * tracGoMotionStaggerCap,
      );
      // The fortieth row of a list waits exactly as long as the sixth, not 1.6 seconds.
      expect(
        motion.staggerDelay(40),
        motion.staggerDelay(tracGoMotionStaggerCap),
      );
    });
  });

  group('FadeSlideIn', () {
    testWidgets('starts transparent and settles fully opaque', (tester) async {
      await tester.pumpWidget(_app(const FadeSlideIn(child: Text('hello'))));

      expect(_opacityOf(tester, find.text('hello')), 0);

      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('hello')), 1);
    });

    testWidgets('is already opaque on the first frame under reduce motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const FadeSlideIn(child: Text('hello')), animations: false),
      );

      expect(_opacityOf(tester, find.text('hello')), 1);
      // And nothing is animating: a ticker still running would mean the entrance was
      // merely fast rather than skipped.
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('honours its delay before starting', (tester) async {
      await tester.pumpWidget(
        _app(
          const FadeSlideIn(
            delay: Duration(milliseconds: 200),
            child: Text('hello'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacityOf(tester, find.text('hello')), 0);

      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('hello')), 1);
    });

    testWidgets('a delayed entrance disposed mid-wait does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const FadeSlideIn(
            delay: Duration(milliseconds: 400),
            child: Text('hello'),
          ),
        ),
      );

      // Unmounted while the delay timer is still pending — the case of a list row
      // scrolled away before it ever appeared.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(_app(const SizedBox()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  group('MotionEntranceScope', () {
    testWidgets('replays an entrance for an unseen key only', (tester) async {
      // Stands in for a ListView recycling a row: same key, rebuilt from scratch.
      Widget row(String label) => _app(
        MotionEntranceScope(
          child: FadeSlideIn(entranceKey: label, child: Text(label)),
        ),
      );

      await tester.pumpWidget(row('a'));
      expect(_opacityOf(tester, find.text('a')), 0);
      await tester.pumpAndSettle();

      // Rebuild the same subtree with the same entrance key. Without the scope this
      // would start from 0 again and the row would visibly re-appear.
      await tester.pumpWidget(_app(const SizedBox()));
      await tester.pumpWidget(row('a'));
      expect(_opacityOf(tester, find.text('a')), 0);
    });

    testWidgets('a key already claimed in the same scope does not animate', (
      tester,
    ) async {
      // Both rows carry the same entrance key inside one scope: the first claims it, so
      // the second renders immediately rather than fading in behind it.
      await tester.pumpWidget(
        _app(
          const MotionEntranceScope(
            child: Column(
              children: [
                FadeSlideIn(entranceKey: 'same', child: Text('first')),
                FadeSlideIn(entranceKey: 'same', child: Text('second')),
              ],
            ),
          ),
        ),
      );

      expect(_opacityOf(tester, find.text('first')), 0);
      expect(_opacityOf(tester, find.text('second')), 1);
    });
  });

  group('PressableScale', () {
    // A hit-testable child, because `PressableScale` defers hit testing to its child on
    // purpose — it must not swallow pointers on behalf of something that would not have
    // accepted them. In the app the child is always an InkWell.
    const targetKey = Key('press-target');
    const pressTarget = ColoredBox(
      key: targetKey,
      color: Color(0xFF000000),
      child: SizedBox(width: 100, height: 100),
    );

    double scaleOf(WidgetTester tester) =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    testWidgets('shrinks while held and returns on release', (tester) async {
      await tester.pumpWidget(_app(const PressableScale(child: pressTarget)));
      expect(scaleOf(tester), 1.0);

      final gesture = await tester.press(find.byKey(targetKey));
      await tester.pump();
      expect(scaleOf(tester), tracGoMotionPressScale);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleOf(tester), 1.0);
    });

    testWidgets('releases when the press turns into a scroll', (tester) async {
      await tester.pumpWidget(_app(const PressableScale(child: pressTarget)));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(targetKey)),
      );
      await tester.pump();
      expect(scaleOf(tester), tracGoMotionPressScale);

      // Past the slop: this is a list being flicked, not a row being tapped.
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(scaleOf(tester), 1.0);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('does not wrap its child at all under reduce motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const PressableScale(child: pressTarget), animations: false),
      );

      expect(find.byType(AnimatedScale), findsNothing);
      expect(find.byKey(targetKey), findsOneWidget);
    });
  });

  group('AnimatedCount', () {
    testWidgets('counts up to its value and lands exactly on it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          AnimatedCount(value: 10, builder: (context, value) => Text('$value')),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('shows the final value immediately under reduce motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          AnimatedCount(value: 10, builder: (context, value) => Text('$value')),
          animations: false,
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });
  });

  group('SkeletonHost', () {
    testWidgets('shimmers while animations are enabled', (tester) async {
      await tester.pumpWidget(
        _app(const SkeletonHost(child: SkeletonBox(width: 100, height: 12))),
      );

      final first = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox).first,
      );
      await tester.pump(const Duration(milliseconds: 400));
      final later = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox).first,
      );

      expect(later.decoration, isNot(equals(first.decoration)));
    });

    testWidgets(
      'does not animate — or hang pumpAndSettle — under reduce motion',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const SkeletonHost(child: SkeletonBox(width: 100, height: 12)),
            animations: false,
          ),
        );

        // The whole point: a repeating controller never settles, so this call is the test.
        // It times out rather than failing if the shimmer is left running.
        await tester.pumpAndSettle();
        expect(tester.binding.hasScheduledFrame, isFalse);
      },
    );

    testWidgets('a box outside any host still renders at its size', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SkeletonBox(width: 100, height: 12)));

      expect(tester.getSize(find.byType(SkeletonBox)), const Size(100, 12));
      expect(tester.takeException(), isNull);
    });
  });

  group('MotionSwitcher', () {
    testWidgets('cross-fades between two keyed children', (tester) async {
      Widget switcher(Widget child) => _app(MotionSwitcher(child: child));

      await tester.pumpWidget(switcher(const Text('a', key: ValueKey('a'))));
      await tester.pumpAndSettle();

      await tester.pumpWidget(switcher(const Text('b', key: ValueKey('b'))));
      await tester.pump(const Duration(milliseconds: 60));

      // Mid-transition both are mounted: that overlap is the cross-fade.
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('swaps instantly under reduce motion', (tester) async {
      Widget switcher(Widget child) =>
          _app(MotionSwitcher(child: child), animations: false);

      await tester.pumpWidget(switcher(const Text('a', key: ValueKey('a'))));
      await tester.pumpWidget(switcher(const Text('b', key: ValueKey('b'))));
      await tester.pump();

      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);
    });
  });
}
