import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/requisition.dart';

part 'requisition_list_state.freezed.dart';

const requisitionListPageSize = 10;

@freezed
abstract class RequisitionListUiState with _$RequisitionListUiState {
  const RequisitionListUiState._();

  const factory RequisitionListUiState({
    @Default('') String searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    @Default(RequisitionSortField.date) RequisitionSortField sortBy,
    @Default(true) bool sortDescending,
    @Default(<Requisition>[]) List<Requisition> items,
    @Default(true) bool isInitialLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    @Default(true) bool hasMore,
    String? errorMessage,
  }) = _RequisitionListUiState;

  /// Valid only while hasMore is true, since that's the only time it's read (see loadNextPage).
  int get nextPageToLoad => (items.length ~/ requisitionListPageSize) + 1;
}

sealed class RequisitionListEvent {
  const RequisitionListEvent();
}

class RequisitionListShowMessage extends RequisitionListEvent {
  const RequisitionListShowMessage(this.message);
  final String message;
}

class RequisitionListSessionExpired extends RequisitionListEvent {
  const RequisitionListSessionExpired(this.message);
  final String message;
}
