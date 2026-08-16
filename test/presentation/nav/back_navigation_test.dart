import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/nav/app_shell.dart';
import 'package:tracgo/presentation/nav/back_navigation.dart';
import 'package:tracgo/presentation/nav/route_paths.dart';

const _session = Session(
  token: 'abc',
  user: User(
    id: 'tofiq.akbar@btracsl.com',
    name: 'Md. Tofiq Akbar',
    designation: 'Senior Engineer',
    email: 'tofiq.akbar@btracsl.com',
  ),
);

/// The platform is selected through the theme rather than
/// `debugDefaultTargetPlatformOverride`: `flutter_test` asserts that debug variable is
/// null the moment a test body ends — before `tearDown` gets a chance to reset it.
Widget _shell({
  String currentPath = RoutePaths.dashboard,
  TargetPlatform platform = TargetPlatform.android,
}) {
  return ProviderScope(
    overrides: [
      sessionStreamProvider.overrideWith((ref) => Stream.value(_session)),
    ],
    child: MaterialApp(
      theme: ThemeData(platform: platform),
      home: AppShell(
        currentPath: currentPath,
        onNavigate: (_) {},
        onOpenProfile: () {},
        // Mounted the way the router mounts it: inside the shell's content, below the
        // Scaffold, so the drawer lookup resolves.
        child: const DashboardBackScope(child: SizedBox.shrink()),
      ),
    ),
  );
}

void main() {
  group('BackExitGuard', () {
    // The window is checked against an injected `now` precisely so expiry is testable:
    // `tester.pump` advances fake time, but the guard reads the wall clock, so a widget
    // test can never observe the window closing.
    test('the first press never exits', () {
      final guard = BackExitGuard();
      expect(guard.registerBackPress(DateTime(2026, 8, 16, 12)), isFalse);
    });

    test('a second press inside the window exits', () {
      final guard = BackExitGuard();
      final first = DateTime(2026, 8, 16, 12);
      guard.registerBackPress(first);

      expect(
        guard.registerBackPress(first.add(const Duration(milliseconds: 1500))),
        isTrue,
      );
    });

    test('a press exactly on the window boundary still exits', () {
      final guard = BackExitGuard();
      final first = DateTime(2026, 8, 16, 12);
      guard.registerBackPress(first);

      expect(guard.registerBackPress(first.add(backExitWindow)), isTrue);
    });

    test('a second press after the window re-prompts instead of exiting', () {
      final guard = BackExitGuard();
      final first = DateTime(2026, 8, 16, 12);
      guard.registerBackPress(first);

      expect(
        guard.registerBackPress(first.add(const Duration(seconds: 5))),
        isFalse,
        reason: 'a stray press minutes later must not quit the app',
      );
    });

    test('the sequence resets after an exit is signalled', () {
      final guard = BackExitGuard();
      final first = DateTime(2026, 8, 16, 12);
      guard.registerBackPress(first);
      guard.registerBackPress(first.add(const Duration(milliseconds: 500)));

      // Matters on iOS, where the exit is *not* carried out: without the reset the very
      // next press would quit-that-isn't, skipping the prompt entirely.
      expect(
        guard.registerBackPress(first.add(const Duration(milliseconds: 700))),
        isFalse,
      );
    });
  });

  group('dashboard back', () {
    late List<MethodCall> platformCalls;

    setUp(() {
      platformCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            platformCalls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    bool exitRequested() =>
        platformCalls.any((call) => call.method == 'SystemNavigator.pop');

    testWidgets('the first back press prompts instead of leaving', (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.text(TracGoStrings.backExitPrompt), findsOneWidget);
      expect(exitRequested(), isFalse);
    });

    testWidgets('a second press inside the window exits on Android', (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(exitRequested(), isTrue);
    });

    testWidgets('iOS shows the prompt but never closes the app', (tester) async {
      // Apple treats a self-terminating app as a crash (App Store guideline 2.5.x), so
      // this asymmetry is deliberate, not an oversight.
      await tester.pumpWidget(_shell(platform: TargetPlatform.iOS));
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(TracGoStrings.backExitPrompt), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(exitRequested(), isFalse);
    });

    testWidgets('an open drawer swallows the press', (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pump();

      await tester.tap(find.byTooltip(TracGoStrings.navOpenMenu));
      await tester.pumpAndSettle();
      expect(find.text(TracGoStrings.navLogout), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(TracGoStrings.navLogout), findsNothing, reason: 'drawer closed');
      expect(
        find.text(TracGoStrings.backExitPrompt),
        findsNothing,
        reason: 'closing the drawer is not a request to leave the app',
      );
      expect(exitRequested(), isFalse);
    });

  });

  group('back with a real router', () {
    late List<MethodCall> platformCalls;

    setUp(() {
      platformCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            platformCalls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    bool exitRequested() =>
        platformCalls.any((call) => call.method == 'SystemNavigator.pop');

    /// Mirrors the real router's shape — a `ShellRoute` for dashboard/list plus a pushed
    /// route above it — because that shape is the whole point. A `PopScope` inside the
    /// shell registers on the *root* navigator's shell page, and only a nested navigator
    /// reproduces that.
    Widget routedApp(GoRouter router) {
      return ProviderScope(
        overrides: [
          sessionStreamProvider.overrideWith((ref) => Stream.value(_session)),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    GoRouter buildRouter(String initialLocation) {
      return GoRouter(
        initialLocation: initialLocation,
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(
              currentPath: state.matchedLocation,
              onNavigate: (path) => context.go(path),
              onOpenProfile: () {},
              child: child,
            ),
            routes: [
              // Scopes go inside the shell's children, mirroring app_router.dart. The
              // placement matters on device and not here: predictive back asks the
              // innermost navigator whether the framework handles back, while
              // `handlePopRoute` below drives the framework directly and would pass
              // either way. Keeping the harness faithful stops the test from
              // documenting a structure the app does not use.
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) =>
                    const DashboardBackScope(child: Text('dashboard')),
              ),
              GoRoute(
                path: RoutePaths.requisitionList,
                builder: (context, state) =>
                    const PopOrDashboardScope(child: Text('list')),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (context, state) => const PopOrDashboardScope(
              child: Scaffold(body: Text('profile')),
            ),
          ),
        ],
      );
    }

    testWidgets('back on the requisition list goes to the dashboard', (tester) async {
      await tester.pumpWidget(routedApp(buildRouter(RoutePaths.requisitionList)));
      await tester.pumpAndSettle();
      expect(find.text('list'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(
        find.text(TracGoStrings.backExitPrompt),
        findsNothing,
        reason: 'only the dashboard prompts',
      );
      expect(exitRequested(), isFalse, reason: 'the list must never drop out of the app');
    });

    testWidgets('back on a pushed screen returns to the screen beneath it', (
      tester,
    ) async {
      final router = buildRouter(RoutePaths.requisitionList);
      await tester.pumpWidget(routedApp(router));
      await tester.pumpAndSettle();

      unawaited(router.push(RoutePaths.profile));
      await tester.pumpAndSettle();
      expect(find.text('profile'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // The list, not the dashboard: a screen with somewhere to go back to keeps its
      // natural back target.
      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('back on a deep-linked screen falls through to the dashboard', (
      tester,
    ) async {
      // Entered directly at /profile, so there is no stack. A bare `pop()` would do
      // nothing at all and the screen would look frozen.
      await tester.pumpWidget(routedApp(buildRouter(RoutePaths.profile)));
      await tester.pumpAndSettle();
      expect(find.text('profile'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(exitRequested(), isFalse);
    });
  });
}
