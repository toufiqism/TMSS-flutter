import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../common/strings.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardUiState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardUiState> {
  final StreamController<DashboardEvent> _events = StreamController<DashboardEvent>.broadcast();
  Stream<DashboardEvent> get events => _events.stream;

  @override
  DashboardUiState build() {
    ref.onDispose(_events.close);
    Future.microtask(load);
    return const DashboardUiState.loading();
  }

  /// Full-screen loading spinner: initial load and error-state retry.
  Future<void> load() async {
    state = const DashboardUiState.loading();
    await _fetch();
  }

  /// Pull-to-refresh: keeps the existing summary on screen while re-fetching.
  Future<void> refresh() async {
    final current = state;
    if (current is DashboardSuccess) {
      state = current.copyWith(isRefreshing: true);
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    final hadDataBeforeFetch = state is DashboardSuccess;
    final getDashboardSummaryUseCase = ref.read(getDashboardSummaryUseCaseProvider);
    final result = await getDashboardSummaryUseCase();
    final sessionExpirationHandler = ref.read(sessionExpirationHandlerProvider);

    await result.when(
      success: (summary) async {
        state = DashboardUiState.success(summary);
      },
      error: (message, _) async {
        await _onFetchFailed(hadDataBeforeFetch, message ?? TmsStrings.dashboardErrorGeneric);
      },
      offline: (message) async {
        await _onFetchFailed(hadDataBeforeFetch, message);
      },
      maintenance: (message, _) async {
        await _onFetchFailed(hadDataBeforeFetch, message);
      },
      logout: (message, _) async {
        await sessionExpirationHandler.handle();
        _clearRefreshingFlag();
        _events.add(DashboardSessionExpired(message));
      },
    );
  }

  Future<void> _onFetchFailed(bool hadDataBeforeFetch, String message) async {
    if (hadDataBeforeFetch) {
      // Refresh failed but we still have a summary on screen — keep it, don't blow the
      // whole dashboard away for a transient error. Surface it as a one-shot message instead.
      _clearRefreshingFlag();
      _events.add(DashboardRefreshFailed(message));
    } else {
      state = DashboardUiState.error(message);
    }
  }

  void _clearRefreshingFlag() {
    final current = state;
    if (current is DashboardSuccess) {
      state = current.copyWith(isRefreshing: false);
    }
  }
}
