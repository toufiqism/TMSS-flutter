import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../common/strings.dart';
import 'route_paths.dart';

/// How long after the first back press the second one counts as "yes, exit".
const backExitWindow = Duration(seconds: 2);

/// Sends the user back one step, falling back to the dashboard when there is no step
/// to take.
///
/// Every screen except the dashboard routes both its app-bar arrow and the system
/// back gesture through here, so the two can never diverge.
///
/// The fallback is not theoretical: `/profile`, `/requisitions/new` and
/// `/requisitions/:id` are all reachable as deep links, and arriving that way leaves an
/// empty stack. A bare `context.pop()` there pops nothing — go_router logs an assertion
/// in debug and does nothing in release, stranding the user on a screen whose back
/// button appears dead.
void backOrDashboard(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
    return;
  }
  router.go(RoutePaths.dashboard);
}

/// The "press back again to exit" window, kept free of `BuildContext` so it can be
/// unit-tested without pumping a widget.
///
/// Deliberately timestamp-based rather than `Timer`-based: there is no pending callback
/// to cancel when the screen is disposed, so a backgrounded app cannot fire anything
/// after the widget is gone.
class BackExitGuard {
  BackExitGuard({this.window = backExitWindow});

  final Duration window;

  DateTime? _lastPressAt;

  /// Records a back press and reports whether it should close the app.
  ///
  /// Returns `false` for the first press (the caller shows the prompt) and `true` for a
  /// second press inside [window]. A press *outside* the window restarts the sequence
  /// rather than exiting, so a stray press minutes later can never quit the app.
  bool registerBackPress(DateTime now) {
    final previous = _lastPressAt;
    if (previous != null && now.difference(previous) <= window) {
      // Cleared so that if the exit does not happen — iOS, where the app must not close
      // itself — the next press starts a fresh prompt instead of silently re-arming.
      _lastPressAt = null;
      return true;
    }
    _lastPressAt = now;
    return false;
  }
}

/// Wraps the dashboard in the double-press-to-exit behaviour.
///
/// Must be mounted *inside* the `ShellRoute`'s nested navigator — i.e. around the
/// dashboard screen itself, not around `AppShell`. This is the opposite of what
/// `GoRouterDelegate.popRoute` suggests, and the difference is predictive back:
///
/// * Legacy back sent the press to the framework unconditionally, and go_router walked
///   shell navigator → root navigator looking for a handler. A `PopScope` above the
///   nested navigator was reached on that second hop.
/// * Android 13+ predictive back (default-on at targetSdk 36) asks the framework
///   *first* whether it handles back, via `setFrameworkHandlesBack`. That answer comes
///   from the innermost navigator's top route. With the scope outside it, the shell's
///   navigator reports "nothing to pop", the platform closes the app, and this handler
///   is never consulted.
///
/// Verified on an API 36 emulator: mounted outside, back on the requisition list quit
/// the app; mounted here, it navigates. No widget test catches the difference —
/// `tester.binding.handlePopRoute()` drives the framework directly, which is precisely
/// the path predictive back stops using.
class DashboardBackScope extends StatefulWidget {
  const DashboardBackScope({super.key, required this.child});

  final Widget child;

  @override
  State<DashboardBackScope> createState() => _DashboardBackScopeState();
}

class _DashboardBackScopeState extends State<DashboardBackScope> {
  final _guard = BackExitGuard();

  void _handleBack() {
    // Resolved from this context rather than passed in: the scope now sits inside the
    // shell's navigator, which is itself inside `AppShell`'s Scaffold, so the drawer is
    // an ancestor lookup away. `maybeOf` because a test can mount this bare.
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }

    if (_guard.registerBackPress(DateTime.now())) {
      // Android only. iOS apps must not terminate themselves — Apple treats it as a
      // crash from the user's point of view (App Store guideline 2.5.x), and
      // `SystemNavigator.pop()` there just animates the app away. iOS users get the
      // prompt and nothing more; the home gesture is how they leave.
      //
      // Read from the theme rather than `defaultTargetPlatform` so a test can select a
      // platform with `ThemeData(platform:)`. The global
      // `debugDefaultTargetPlatformOverride` cannot be used here: `flutter_test` asserts
      // it is back to null the instant the test body ends, which is before `tearDown`.
      if (Theme.of(context).platform == TargetPlatform.android) {
        SystemNavigator.pop();
      }
      return;
    }

    ScaffoldMessenger.of(context)
      // Without this a rapid press queues a second identical snack bar behind the
      // first, so the prompt lingers long after the window has closed.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(TracGoStrings.backExitPrompt),
          duration: backExitWindow,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Always false: the decision is ours on every press, and letting the framework
      // pop first would close the app before the prompt could be shown.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: widget.child,
    );
  }
}

/// Wraps a pushed screen so the system back gesture behaves exactly like its app-bar
/// arrow: pop when there is somewhere to pop to, otherwise land on the dashboard.
class PopOrDashboardScope extends StatelessWidget {
  const PopOrDashboardScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        backOrDashboard(context);
      },
      child: child,
    );
  }
}
