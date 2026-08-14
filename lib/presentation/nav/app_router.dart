import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/providers.dart';
import '../common/strings.dart';
import '../../domain/model/requisition.dart';
import '../dashboard/dashboard_notifier.dart';
import '../dashboard/dashboard_screen.dart';
import '../requisition_detail/requisition_detail_notifier.dart';
import '../requisition_detail/requisition_detail_screen.dart';
import '../login/login_screen.dart';
import '../profile/profile_screen.dart';
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
  // The detail screen too, when one is open beneath: after an edit it is the screen the
  // user is popped back onto, and without this it keeps rendering the values from
  // before the save. Its refresh preserves the content already on screen if the refetch
  // fails, so this cannot blank the page.
  if (ref.exists(requisitionDetailNotifierProvider)) {
    unawaited(ref.read(requisitionDetailNotifierProvider.notifier).refresh());
  }
}

/// Shown for the fraction of a frame it takes to bounce a payload-less `/edit` deep
/// link over to the detail screen, which knows how to load the requisition itself.
class _MissingEditPayload extends StatefulWidget {
  const _MissingEditPayload({required this.onRedirect});

  final VoidCallback onRedirect;

  @override
  State<_MissingEditPayload> createState() => _MissingEditPayloadState();
}

class _MissingEditPayloadState extends State<_MissingEditPayload> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onRedirect();
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            onOpenProfile: () => context.push(RoutePaths.profile),
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
              onOpenRequisition: (requisition) =>
                  context.push(RoutePaths.detailFor(requisition.id)),
            ),
          ),
          GoRoute(
            path: RoutePaths.requisitionList,
            builder: (context, state) => RequisitionListScreen(
              onNewRequisition: () => context.push(RoutePaths.newRequisition),
              onOpenRequisition: (requisition) =>
                  context.push(RoutePaths.detailFor(requisition.id)),
            ),
          ),
        ],
      ),
      // Declared before requisitionDetail on purpose: `/requisitions/:id` would
      // otherwise match the literal "new" and shadow this route entirely.
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
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => ProfileScreen(onBack: () => context.pop()),
      ),
      GoRoute(
        path: RoutePaths.requisitionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RequisitionDetailScreen(
            requisitionId: id,
            onBack: () => context.pop(),
            onEdit: (requisition) =>
                context.push(RoutePaths.editFor(id), extra: requisition),
            onClosed: () {
              // The requisition is gone (cancelled or deleted). Close the screen and
              // resync the views behind it rather than leaving a dead row on the list.
              if (context.canPop()) context.pop();
              _refreshRequisitionViews(ref);
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.requisitionEdit,
        builder: (context, state) {
          // The requisition travels as `extra` rather than being refetched: the detail
          // screen has just loaded it, and a second GET would only add a spinner and a
          // failure mode between tapping Edit and seeing the form.
          final existing = state.extra;
          if (existing is! Requisition) {
            // Deep-linked straight to /edit with no payload. Nothing to seed, so send
            // the user to the detail screen, which can fetch it properly.
            return _MissingEditPayload(
              onRedirect: () =>
                  context.pushReplacement(RoutePaths.detailFor(state.pathParameters['id']!)),
            );
          }
          return RequisitionCreateScreen(
            existing: existing,
            onBack: () => context.pop(),
            onSubmitted: () {
              context.pop();
              _refreshRequisitionViews(ref);
            },
            // A 409 means the requisition left `Pending` while the form was open. The
            // detail screen underneath still shows the old status — and therefore still
            // offers Edit and Cancel — so it has to resync, or the user's next tap earns
            // another 409.
            onEditRejected: () {
              context.pop();
              _refreshRequisitionViews(ref);
            },
          );
        },
      ),
    ],
  );
});
