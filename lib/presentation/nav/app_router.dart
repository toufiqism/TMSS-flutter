import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/telemetry/crash_route_observer.dart';
import '../../di/providers.dart';
import '../common/strings.dart';
import '../../domain/model/requisition.dart';
import '../dashboard/dashboard_notifier.dart';
import '../dashboard/dashboard_screen.dart';
import '../requisition_detail/requisition_detail_notifier.dart';
import '../requisition_detail/requisition_detail_screen.dart';
import '../login/login_notifier.dart';
import '../login/login_screen.dart';
import '../password_reset/password_reset_handoff.dart';
import '../password_reset/password_reset_screen.dart';
import '../profile/profile_screen.dart';
import '../requisition_create/requisition_create_screen.dart';
import '../requisition_list/requisition_list_notifier.dart';
import '../requisition_list/requisition_list_screen.dart';
import '../../theme/typography.dart';
import 'app_shell.dart';
import 'back_navigation.dart';
import 'page_transitions.dart';
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
      // Signing *in* matters as much as signing out. Both notifiers are kept alive, so
      // one that already exists — holding another session's data, or stranded mid-load
      // — is what the newly signed-in user lands on, and nothing else would ever move
      // it. Reloading is not merely a freshness nicety here; it is the only exit.
      if (previous?.value == null && next.value != null) {
        _reloadFeatureState(ref);
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

/// Reloads the kept-alive notifiers for a session that has just begun.
///
/// [_resetFeatureState] handles the tidy case — session ends, state is discarded — but
/// it is not enough on its own, and this is the failure it misses:
///
/// 1. A stale token is hydrated from secure storage at launch, so the router treats the
///    user as signed in and goes straight to the dashboard.
/// 2. The dashboard's first load 401s. The session is cleared and the user is sent to
///    login — but the notifier is left behind, alive.
/// 3. The user signs in. `build()` does not re-run for a kept-alive notifier, so no
///    load is triggered, and the dashboard shows its spinner indefinitely.
///
/// Observed end to end against the live server. The notifier-state fix (settling on an
/// error instead of staying on `loading`) removes the spinner; this removes the
/// staleness — without it the user would land on the *previous* session's error screen
/// and have to press Retry to see their own data.
///
/// Calls a method rather than `ref.invalidate`, deliberately. Invalidation closes the
/// notifier's event stream (see `NotifierLifecycle`), and unlike the sign-out path
/// there is no unmount here to make that safe — the screens are about to be shown, not
/// torn down. `ref.exists` keeps this from creating a notifier nobody has opened.
void _reloadFeatureState(Ref ref) {
  if (ref.exists(dashboardNotifierProvider)) {
    unawaited(ref.read(dashboardNotifierProvider.notifier).load());
  }
  if (ref.exists(requisitionListNotifierProvider)) {
    unawaited(ref.read(requisitionListNotifierProvider.notifier).refresh());
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

/// Leaves the password-reset flow.
///
/// `backOrDashboard` is wrong here: the fallback would send a user who deep-linked into
/// `/forgot-password` to the dashboard, which the redirect immediately bounces back to
/// login anyway. Going there directly skips the flicker.
void _leaveResetFlow(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
    return;
  }
  router.go(RoutePaths.login);
}

/// Finishes the reset flow, from whichever entry point started it.
///
/// The two differ in one thing that matters: whether there is a session to end.
///
/// * **From Login** — nothing to clear, and the login screen is still mounted under the
///   pushed route, so its notifier is prefilled directly and the flow simply pops.
/// * **From Profile** — `POST /reset-password` has just invalidated this account's
///   `api_token` server-side. The session on this device is already dead; leaving it in
///   place would only mean the next request 401s and the user is thrown out mid-tap. So
///   it is cleared here, deliberately *without* `POST /logout` — the token that call
///   would present is the one the server has already revoked. Clearing emits on the
///   session stream, which is what carries the user to Login.
///
/// The email travels through [passwordResetHandoffProvider] on the Profile path because
/// the login notifier does not exist yet at this moment; it is created, and consumes the
/// handoff, once the router swaps Login in.
Future<void> _completePasswordReset(
  Ref ref,
  BuildContext context,
  String userName,
) async {
  final router = GoRouter.of(context);
  final isSignedIn = ref.read(sessionStreamProvider).value != null;

  if (!isSignedIn) {
    // `ref.exists` first: `loginNotifierProvider` is auto-dispose, so reading it when
    // nothing is listening would create an instance, prefill it, and throw it away
    // again. A deep link straight into the reset flow leaves no screen to prefill, and
    // the handoff covers that case for the Login screen that is about to be built.
    if (ref.exists(loginNotifierProvider)) {
      ref.read(loginNotifierProvider.notifier).onPasswordResetComplete(userName);
    } else {
      ref.read(passwordResetHandoffProvider).stage(userName);
    }
    _leaveResetFlow(context);
    return;
  }

  ref.read(passwordResetHandoffProvider).stage(userName);
  await ref.read(sessionExpirationHandlerProvider).handle();
  // `go`, not `pop`: popping would land on Profile for the frame before the cleared
  // session redirects away from it, and the user would watch their own account screen
  // flash past on the way out. `ref` here belongs to the router provider, which outlives
  // every screen, so there is nothing to check for mountedness.
  router.go(RoutePaths.login);
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

  // Two instances, not one shared observer: `Navigator` asserts that an observer
  // belongs to a single navigator, and the ShellRoute creates its own. Registering
  // only the root would also miss every move between Dashboard and Requisition List,
  // which is most of the navigation in this app.
  final reporter = ref.watch(crashReporterProvider);
  final rootObserver = CrashRouteObserver(reporter);
  final shellObserver = CrashRouteObserver(reporter);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshListenable,
    observers: [rootObserver],
    redirect: (context, state) {
      final sessionAsync = ref.read(sessionStreamProvider);
      if (!sessionAsync.hasValue) {
        // Still hydrating the secure-storage read — stay on /splash until it resolves.
        return state.matchedLocation == RoutePaths.splash
            ? null
            : RoutePaths.splash;
      }
      final isAuthenticated = sessionAsync.value != null;
      final atSplash = state.matchedLocation == RoutePaths.splash;
      final atLogin = state.matchedLocation == RoutePaths.login;
      // The reset flow is the one other place a signed-out user is allowed to be.
      // Without this it is redirected straight back to login and the flow is
      // unreachable — the screen would appear for a frame and vanish.
      final atForgotPassword = state.matchedLocation == RoutePaths.forgotPassword;

      if (!isAuthenticated && !atLogin && !atForgotPassword) return RoutePaths.login;
      // Note what is *not* bounced to the dashboard: the reset route, which Profile
      // opens while signed in. There is no authenticated change-password endpoint, so
      // both entry points land on the same unauthenticated flow.
      if (isAuthenticated && (atLogin || atSplash)) return RoutePaths.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) => scaleFadePage(
          context: context,
          key: state.pageKey,
          child: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => scaleFadePage(
          context: context,
          key: state.pageKey,
          child: LoginScreen(
            onLoginSuccess: () => context.go(RoutePaths.dashboard),
            onForgotPassword: () => context.push(RoutePaths.forgotPassword),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        pageBuilder: (context, state) => axisPage(
          context: context,
          key: state.pageKey,
          child: PasswordResetScreen(
            onBack: () => _leaveResetFlow(context),
            onCompleted: (userName) =>
                unawaited(_completePasswordReset(ref, context, userName)),
            // Prefilled when the flow was opened from Profile; null from Login, where
            // by definition there is no session to read an address from.
            initialEmail: ref.read(sessionStreamProvider).value?.user.email,
            // And fixed, not merely prefilled, on that Profile path: this is the
            // signed-in account changing its own password, and the code has to go to
            // the address the session belongs to. From Login there is no account to
            // lock to, so the field stays editable — which is the whole point of the
            // "forgotten password" entry point.
            lockEmail: ref.read(sessionStreamProvider).value != null,
          ),
        ),
      ),
      ShellRoute(
        observers: [shellObserver],
        builder: (context, state, child) {
          final topBarTitle =
              state.matchedLocation == RoutePaths.requisitionList
              ? const Text(
                  TracGoStrings.requisitionListTitle,
                  style: tracGoScreenTitleStyle,
                )
              : null;
          return AppShell(
            currentPath: state.matchedLocation,
            onNavigate: (path) => context.go(path),
            onOpenProfile: () => context.push(RoutePaths.profile),
            topBarTitle: topBarTitle,
            child: child,
          );
        },
        routes: [
          // Both scopes sit inside the shell's nested navigator, which is what
          // predictive back asks about. Wrapping `AppShell` instead put them one
          // navigator too high and the platform closed the app without consulting
          // them — see `DashboardBackScope`.
          // Both shell destinations use the sibling transition: they are peers reached
          // from the same drawer, and neither is "inside" the other.
          GoRoute(
            path: RoutePaths.dashboard,
            pageBuilder: (context, state) => fadeThroughPage(
              context: context,
              key: state.pageKey,
              child: DashboardBackScope(
                child: DashboardScreen(
                  onViewAllRequisitions: () =>
                      context.go(RoutePaths.requisitionList),
                  onRequisitionNow: () =>
                      context.push(RoutePaths.newRequisition),
                  onOpenRequisition: (requisition) =>
                      context.push(RoutePaths.detailFor(requisition.id)),
                ),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.requisitionList,
            // Reached with `go`, not `push`, so it has nothing to pop and would
            // otherwise drop straight out of the app.
            pageBuilder: (context, state) => fadeThroughPage(
              context: context,
              key: state.pageKey,
              child: PopOrDashboardScope(
                child: RequisitionListScreen(
                  onNewRequisition: () =>
                      context.push(RoutePaths.newRequisition),
                  onOpenRequisition: (requisition) =>
                      context.push(RoutePaths.detailFor(requisition.id)),
                ),
              ),
            ),
          ),
        ],
      ),
      // Declared before requisitionDetail on purpose: `/requisitions/:id` would
      // otherwise match the literal "new" and shadow this route entirely.
      GoRoute(
        path: RoutePaths.newRequisition,
        pageBuilder: (context, state) => axisPage(
          context: context,
          key: state.pageKey,
          child: PopOrDashboardScope(
            child: RequisitionCreateScreen(
              onBack: () => backOrDashboard(context),
              onSubmitted: () {
                backOrDashboard(context);
                _refreshRequisitionViews(ref);
              },
            ),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        pageBuilder: (context, state) => axisPage(
          context: context,
          key: state.pageKey,
          child: PopOrDashboardScope(
            child: ProfileScreen(
              onBack: () => backOrDashboard(context),
              onChangePassword: () => context.push(RoutePaths.forgotPassword),
            ),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.requisitionDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return axisPage(
            context: context,
            key: state.pageKey,
            child: PopOrDashboardScope(
              child: RequisitionDetailScreen(
                requisitionId: id,
                onBack: () => backOrDashboard(context),
                onEdit: (requisition) =>
                    context.push(RoutePaths.editFor(id), extra: requisition),
                onClosed: () {
                  // The requisition is gone (cancelled or deleted). Leave the screen and
                  // resync the views behind it rather than leaving a dead row on the
                  // list. Deep-linked here there is nothing to pop back to, so this
                  // lands on the dashboard instead of leaving the user staring at a
                  // requisition that no longer exists.
                  backOrDashboard(context);
                  _refreshRequisitionViews(ref);
                },
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.requisitionEdit,
        pageBuilder: (context, state) {
          // The requisition travels as `extra` rather than being refetched: the detail
          // screen has just loaded it, and a second GET would only add a spinner and a
          // failure mode between tapping Edit and seeing the form.
          final existing = state.extra;
          if (existing is! Requisition) {
            // Deep-linked straight to /edit with no payload. Nothing to seed, so send
            // the user to the detail screen, which can fetch it properly.
            //
            // Wrapped like every other pushed route: this is on screen for a frame, but
            // a back press landing in that frame would otherwise reach no handler at all
            // and drop the user out of the app from a deep link.
            return axisPage(
              context: context,
              key: state.pageKey,
              child: PopOrDashboardScope(
                child: _MissingEditPayload(
                  onRedirect: () => context.pushReplacement(
                    RoutePaths.detailFor(state.pathParameters['id']!),
                  ),
                ),
              ),
            );
          }
          return axisPage(
            context: context,
            key: state.pageKey,
            child: PopOrDashboardScope(
              child: RequisitionCreateScreen(
                existing: existing,
                onBack: () => backOrDashboard(context),
                onSubmitted: () {
                  backOrDashboard(context);
                  _refreshRequisitionViews(ref);
                },
                // A 409 means the requisition left `Pending` while the form was open. The
                // detail screen underneath still shows the old status — and therefore
                // still offers Edit and Cancel — so it has to resync, or the user's next
                // tap earns another 409.
                onEditRejected: () {
                  backOrDashboard(context);
                  _refreshRequisitionViews(ref);
                },
              ),
            ),
          );
        },
      ),
    ],
  );
});
