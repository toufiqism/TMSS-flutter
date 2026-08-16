import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'dashboard_state.dart';

/// Deliberately kept alive: the dashboard is the post-login landing screen and is
/// re-entered constantly via the drawer, so re-fetching on every visit would be
/// wasteful. Freshness is handled by [DashboardNotifier.load] being called
/// explicitly after a requisition is created, plus pull-to-refresh.
final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardUiState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardUiState>
    with NotifierLifecycle<DashboardUiState, DashboardEvent> {
  @override
  DashboardUiState build() {
    registerLifecycle();
    unawaited(Future.microtask(load));
    return const DashboardUiState.loading();
  }

  /// Full-screen loading spinner: initial load and error-state retry.
  Future<void> load() async {
    setStateIfAlive(const DashboardUiState.loading());
    await _fetch();
  }

  /// Pull-to-refresh: keeps the existing summary on screen while re-fetching.
  Future<void> refresh() async {
    final current = state;
    if (current is DashboardSuccess) {
      setStateIfAlive(current.copyWith(isRefreshing: true));
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    final hadDataBeforeFetch = state is DashboardSuccess;
    final getDashboardSummaryUseCase = ref.read(getDashboardSummaryUseCaseProvider);
    final result = await getDashboardSummaryUseCase();
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<DashboardSummary>(:final response):
        setStateIfAlive(DashboardUiState.success(response));
      case ApiError<DashboardSummary>(:final message):
        _onFetchFailed(hadDataBeforeFetch, message ?? TracGoStrings.dashboardErrorGeneric);
      case ApiOffline<DashboardSummary>(:final message):
        _onFetchFailed(hadDataBeforeFetch, message);
      case ApiMaintenance<DashboardSummary>(:final message):
        _onFetchFailed(hadDataBeforeFetch, message);
      case ApiLogout<DashboardSummary>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        // A terminal state, not just a cleared flag. `_clearRefreshingFlag` alone was a
        // no-op on the *initial* load — it only touches a `DashboardSuccess` — so a 401
        // there left this notifier on `DashboardLoading` with nothing able to move it
        // off again. That is a permanent spinner: the notifier is kept alive, so
        // `build()` never re-runs, and the only other entry points are pull-to-refresh
        // (unreachable, the content is not on screen) and the create-flow refresh.
        //
        // Observed exactly that: a stale token hydrated from secure storage 401'd the
        // first dashboard load, and signing back in returned the user to the spinner
        // this branch had stranded.
        if (hadDataBeforeFetch) {
          _clearRefreshingFlag();
        } else {
          setStateIfAlive(DashboardUiState.error(message));
        }
        emitEvent(DashboardSessionExpired(message));
    }
  }

  void _onFetchFailed(bool hadDataBeforeFetch, String message) {
    if (hadDataBeforeFetch) {
      // Refresh failed but we still have a summary on screen — keep it, don't blow the
      // whole dashboard away for a transient error. Surface it as a one-shot message instead.
      _clearRefreshingFlag();
      emitEvent(DashboardRefreshFailed(message));
    } else {
      setStateIfAlive(DashboardUiState.error(message));
    }
  }

  void _clearRefreshingFlag() {
    final current = state;
    if (current is DashboardSuccess) {
      setStateIfAlive(current.copyWith(isRefreshing: false));
    }
  }
}
