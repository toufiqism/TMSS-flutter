import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/providers.dart';
import '../common/strings.dart';
import '../dashboard/dashboard_notifier.dart';
import '../dashboard/dashboard_screen.dart';
import '../login/login_screen.dart';
import '../requisition_create/requisition_create_screen.dart';
import '../requisition_list/requisition_list_notifier.dart';
import '../requisition_list/requisition_list_screen.dart';
import '../../theme/typography.dart';
import 'app_shell.dart';
import 'route_paths.dart';

/// Bridges the Riverpod session stream into a Listenable go_router can watch, so `redirect`
/// re-runs on every session change (login/logout) — the Dart equivalent of Kotlin's
/// `key(isAuthenticated) { TmssNavHost(...) }` rebuild-on-auth-change trick.
class _SessionRefreshListenable extends ChangeNotifier {
  _SessionRefreshListenable(Ref ref) {
    ref.listen(sessionStreamProvider, (previous, next) {
      if (previous?.value != null && next.value == null) {
        _resetFeatureState(ref);
      }
      notifyListeners();
    });
  }
}

/// Discards per-feature state when the session ends.
///
/// The dashboard and list notifiers are deliberately kept alive, which means `build()`
/// — and therefore their initial load — runs exactly once per notifier instance. That
/// is right while a session lasts and wrong across sessions: after an expiry the
/// dashboard holds a `DashboardError` from the 401 that ended it, and signing back in
/// returns the user to that stale error with no way to clear it but restarting the app.
///
/// `ref.invalidate` is safe *here specifically*, unlike the refresh-after-create path
/// (see [_refreshRequisitionViews]): the session going null redirects to login, which
/// unmounts both screens and cancels their event subscriptions, so there is nobody left
/// listening to the stream that invalidation closes.
void _resetFeatureState(Ref ref) {
  if (ref.exists(dashboardNotifierProvider)) {
    ref.invalidate(dashboardNotifierProvider);
  }
  if (ref.exists(requisitionListNotifierProvider)) {
    ref.invalidate(requisitionListNotifierProvider);
  }
}

/// Resyncs the two screens that show requisition data after one is created.
///
/// Both notifiers are deliberately kept alive so they survive the trip to the create
/// screen and back, which also means neither notices the new row on its own — before
/// this the new requisition was invisible until the app restarted.
///
/// Refresh by calling a method, never `ref.invalidate`: invalidation re-runs `build()`
/// and closes the notifier's event stream out from under any screen still listening to
/// it (see `NotifierLifecycle`). `ref.exists` keeps this from *creating* a notifier
/// that was never used — a user who goes dashboard → create → back has no list
/// notifier yet, and spinning one up here would fire a request for a screen nobody
/// has opened.
void _refreshRequisitionViews(Ref ref) {
  if (ref.exists(requisitionListNotifierProvider)) {
    unawaited(ref.read(requisitionListNotifierProvider.notifier).refresh());
  }
  if (ref.exists(dashboardNotifierProvider)) {
    unawaited(ref.read(dashboardNotifierProvider.notifier).refresh());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _SessionRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final sessionAsync = ref.read(sessionStreamProvider);
      if (!sessionAsync.hasValue) {
        // Still hydrating the secure-storage read — stay on /splash until it resolves.
        return state.matchedLocation == RoutePaths.splash ? null : RoutePaths.splash;
      }
      final isAuthenticated = sessionAsync.value != null;
      final atSplash = state.matchedLocation == RoutePaths.splash;
      final atLogin = state.matchedLocation == RoutePaths.login;

      if (!isAuthenticated && !atLogin) return RoutePaths.login;
      if (isAuthenticated && (atLogin || atSplash)) return RoutePaths.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => LoginScreen(onLoginSuccess: () => context.go(RoutePaths.dashboard)),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final topBarTitle = state.matchedLocation == RoutePaths.requisitionList
              ? Text(TmsStrings.requisitionListTitle, style: tmsTextTheme.titleMedium)
              : null;
          return AppShell(
            currentPath: state.matchedLocation,
            onNavigate: (path) => context.go(path),
            topBarTitle: topBarTitle,
            showNotificationBell: state.matchedLocation != RoutePaths.requisitionList,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (context, state) => DashboardScreen(
              onViewAllRequisitions: () => context.go(RoutePaths.requisitionList),
              onRequisitionNow: () => context.push(RoutePaths.newRequisition),
            ),
          ),
          GoRoute(
            path: RoutePaths.requisitionList,
            builder: (context, state) => RequisitionListScreen(
              onNewRequisition: () => context.push(RoutePaths.newRequisition),
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.newRequisition,
        builder: (context, state) => RequisitionCreateScreen(
          onBack: () => context.pop(),
          onSubmitted: () {
            context.pop();
            _refreshRequisitionViews(ref);
          },
        ),
      ),
    ],
  );
});
