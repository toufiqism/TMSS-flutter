import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/requisition.dart';

part 'dashboard_state.freezed.dart';

@freezed
sealed class DashboardUiState with _$DashboardUiState {
  const factory DashboardUiState.loading() = DashboardLoading;
  const factory DashboardUiState.success(DashboardSummary summary, {@Default(false) bool isRefreshing}) = DashboardSuccess;
  const factory DashboardUiState.error(String message) = DashboardError;
}

sealed class DashboardEvent {
  const DashboardEvent();
}

class DashboardSessionExpired extends DashboardEvent {
  const DashboardSessionExpired(this.message);
  final String message;
}

class DashboardRefreshFailed extends DashboardEvent {
  const DashboardRefreshFailed(this.message);
  final String message;
}
