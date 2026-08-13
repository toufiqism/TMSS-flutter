import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/providers.dart';
import '../common/strings.dart';
import '../dashboard/dashboard_screen.dart';
import '../login/login_screen.dart';
import '../requisition_create/requisition_create_screen.dart';
import '../requisition_list/requisition_list_screen.dart';
import '../../theme/typography.dart';
import 'app_shell.dart';
import 'route_paths.dart';

/// Bridges the Riverpod session stream into a Listenable go_router can watch, so `redirect`
/// re-runs on every session change (login/logout) — the Dart equivalent of Kotlin's
/// `key(isAuthenticated) { TmssNavHost(...) }` rebuild-on-auth-change trick.
class _SessionRefreshListenable extends ChangeNotifier {
  _SessionRefreshListenable(Ref ref) {
    ref.listen(sessionStreamProvider, (previous, next) => notifyListeners());
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
          onSubmitted: () => context.pop(),
        ),
      ),
    ],
  );
});
