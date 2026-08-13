import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'requisition_list_state.dart';

const _searchDebounce = Duration(milliseconds: 400);

/// Kept alive so the list survives a trip to the create screen and back. Freshness
/// comes from [RequisitionListNotifier.refresh] being called explicitly after a
/// successful create — never from `ref.invalidate`, which would tear down the event
/// stream out from under a mounted screen (see [NotifierLifecycle]).
final requisitionListNotifierProvider =
    NotifierProvider<RequisitionListNotifier, RequisitionListUiState>(
  RequisitionListNotifier.new,
);

class RequisitionListNotifier extends Notifier<RequisitionListUiState>
    with NotifierLifecycle<RequisitionListUiState, RequisitionListEvent> {
  Timer? _searchDebounceTimer;
  int _loadToken = 0;

  @override
  RequisitionListUiState build() {
    registerLifecycle();
    ref.onDispose(() => _searchDebounceTimer?.cancel());
    unawaited(Future.microtask(refresh));
    return const RequisitionListUiState();
  }

  void onSearchQueryChange(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () => unawaited(refresh()));
  }

  void onDateRangeChange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    unawaited(refresh());
  }

  void resetFilters() {
    _searchDebounceTimer?.cancel();
    state = state.copyWith(
      searchQuery: '',
      startDate: null,
      endDate: null,
      sortBy: RequisitionSortField.date,
      sortDescending: true,
    );
    unawaited(refresh());
  }

  Future<void> refresh() async {
    if (isDisposed) return;
    final token = ++_loadToken;
    setStateIfAlive(state.copyWith(
      isRefreshing: true,
      isInitialLoading: state.items.isEmpty,
      errorMessage: null,
    ));
    final getRequisitionsUseCase = ref.read(getRequisitionsUseCaseProvider);
    final result = await getRequisitionsUseCase(_filterFor(page: 1));
    if (isDisposed || token != _loadToken) return;
    await _applyPageResult(result, append: false);
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (isDisposed || current.isLoadingMore || current.isRefreshing || !current.hasMore) {
      return;
    }
    final token = ++_loadToken;
    setStateIfAlive(current.copyWith(isLoadingMore: true));
    final getRequisitionsUseCase = ref.read(getRequisitionsUseCaseProvider);
    final result = await getRequisitionsUseCase(_filterFor(page: current.nextPageToLoad));
    if (isDisposed || token != _loadToken) return;
    await _applyPageResult(result, append: true);
  }

  Future<void> cancelRequisition(String id) async {
    if (isDisposed) return;
    final cancelRequisitionUseCase = ref.read(cancelRequisitionUseCaseProvider);
    final result = await cancelRequisitionUseCase(id);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<void>():
        // Refetch rather than splicing the item out locally. Offset pagination is
        // computed from items.length (see nextPageToLoad), so a local removal shifts
        // the window and makes the next page skip a row.
        await refresh();
      case ApiError<void>(:final message, :final errorCode):
        emitEvent(RequisitionListShowMessage(
          message ?? TmsStrings.requisitionListCancelFailed,
        ));
        // 409 means the requisition left `Pending` while this list was on screen —
        // the contract calls this out as an expected path, and the fix is to resync
        // rather than leave a stale Cancel button on a row that can no longer be
        // cancelled.
        if (errorCode == _httpConflict) await refresh();
      case ApiOffline<void>(:final message):
        emitEvent(RequisitionListShowMessage(message));
      case ApiMaintenance<void>(:final message):
        emitEvent(RequisitionListShowMessage(message));
      case ApiLogout<void>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        emitEvent(RequisitionListSessionExpired(message));
    }
  }

  Future<void> _applyPageResult(
    ApiResult<List<Requisition>> result, {
    required bool append,
  }) async {
    switch (result) {
      case ApiSuccess<List<Requisition>>(:final response):
        final items = append ? [...state.items, ...response] : response;
        setStateIfAlive(state.copyWith(
          items: items,
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: response.length == requisitionListPageSize,
          errorMessage: null,
        ));
      case ApiError<List<Requisition>>(:final message):
        _applyFailure(message ?? TmsStrings.requisitionListLoadFailed);
      case ApiOffline<List<Requisition>>(:final message):
        _applyFailure(message);
      case ApiMaintenance<List<Requisition>>(:final message):
        _applyFailure(message);
      case ApiLogout<List<Requisition>>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        setStateIfAlive(state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
        ));
        emitEvent(RequisitionListSessionExpired(message));
    }
  }

  void _applyFailure(String message) {
    setStateIfAlive(state.copyWith(
      isInitialLoading: false,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: message,
    ));
  }

  RequisitionListFilter _filterFor({required int page}) {
    final s = state;
    return RequisitionListFilter(
      startDate: s.startDate,
      endDate: s.endDate?.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      searchQuery: s.searchQuery,
      page: page,
      pageSize: requisitionListPageSize,
      sortBy: s.sortBy,
      sortDescending: s.sortDescending,
    );
  }
}

const _httpConflict = 409;
