import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'requisition_list_state.dart';

const _searchDebounce = Duration(milliseconds: 400);

final requisitionListNotifierProvider =
    NotifierProvider<RequisitionListNotifier, RequisitionListUiState>(RequisitionListNotifier.new);

class RequisitionListNotifier extends Notifier<RequisitionListUiState> {
  final StreamController<RequisitionListEvent> _events = StreamController<RequisitionListEvent>.broadcast();
  Stream<RequisitionListEvent> get events => _events.stream;

  Timer? _searchDebounceTimer;
  int _loadToken = 0;

  @override
  RequisitionListUiState build() {
    ref.onDispose(() {
      _events.close();
      _searchDebounceTimer?.cancel();
    });
    Future.microtask(refresh);
    return const RequisitionListUiState();
  }

  void onSearchQueryChange(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, refresh);
  }

  void onDateRangeChange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    refresh();
  }

  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      startDate: null,
      endDate: null,
      sortBy: RequisitionSortField.date,
      sortDescending: true,
    );
    refresh();
  }

  Future<void> refresh() async {
    final token = ++_loadToken;
    state = state.copyWith(isRefreshing: true, isInitialLoading: state.items.isEmpty, errorMessage: null);
    final getRequisitionsUseCase = ref.read(getRequisitionsUseCaseProvider);
    final result = await getRequisitionsUseCase(_filterFor(page: 1));
    if (token != _loadToken) return;
    await _applyPageResult(result, append: false);
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (current.isLoadingMore || current.isRefreshing || !current.hasMore) return;
    final token = ++_loadToken;
    state = state.copyWith(isLoadingMore: true);
    final getRequisitionsUseCase = ref.read(getRequisitionsUseCaseProvider);
    final result = await getRequisitionsUseCase(_filterFor(page: current.nextPageToLoad));
    if (token != _loadToken) return;
    await _applyPageResult(result, append: true);
  }

  Future<void> cancelRequisition(String id) async {
    final cancelRequisitionUseCase = ref.read(cancelRequisitionUseCaseProvider);
    final sessionExpirationHandler = ref.read(sessionExpirationHandlerProvider);
    final result = await cancelRequisitionUseCase(id);
    await result.when(
      success: (_) async {
        state = state.copyWith(items: state.items.where((r) => r.id != id).toList());
      },
      error: (message, _) async {
        _events.add(RequisitionListShowMessage(message ?? TmsStrings.requisitionListCancelFailed));
      },
      offline: (message) async {
        _events.add(RequisitionListShowMessage(message));
      },
      maintenance: (message, _) async {
        _events.add(RequisitionListShowMessage(message));
      },
      logout: (message, _) async {
        await sessionExpirationHandler.handle();
        _events.add(RequisitionListSessionExpired(message));
      },
    );
  }

  Future<void> _applyPageResult(ApiResult<List<Requisition>> result, {required bool append}) async {
    final sessionExpirationHandler = ref.read(sessionExpirationHandlerProvider);
    await result.when(
      success: (page) async {
        final items = append ? [...state.items, ...page] : page;
        state = state.copyWith(
          items: items,
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: page.length == requisitionListPageSize,
          errorMessage: null,
        );
      },
      error: (message, _) async {
        state = state.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: message ?? TmsStrings.requisitionListLoadFailed,
        );
      },
      offline: (message) async {
        state = state.copyWith(isInitialLoading: false, isRefreshing: false, isLoadingMore: false, errorMessage: message);
      },
      maintenance: (message, _) async {
        state = state.copyWith(isInitialLoading: false, isRefreshing: false, isLoadingMore: false, errorMessage: message);
      },
      logout: (message, _) async {
        await sessionExpirationHandler.handle();
        state = state.copyWith(isInitialLoading: false, isRefreshing: false, isLoadingMore: false);
        _events.add(RequisitionListSessionExpired(message));
      },
    );
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
