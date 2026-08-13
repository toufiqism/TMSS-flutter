import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/requisition.dart';

part 'requisition_detail_state.freezed.dart';

@freezed
sealed class RequisitionDetailUiState with _$RequisitionDetailUiState {
  const factory RequisitionDetailUiState.loading() = RequisitionDetailLoading;

  const factory RequisitionDetailUiState.success(
    Requisition requisition, {
    /// A refetch running underneath content that is already on screen — pull-to-refresh,
    /// or the resync after a save or a 409.
    @Default(false) bool isRefreshing,

    /// A cancel in flight. Keeps the action disabled without blanking the screen.
    @Default(false) bool isCancelling,
  }) = RequisitionDetailSuccess;

  /// [canRetry] is false for terminal failures — a 403 is not going to succeed on a
  /// second tap, and offering Retry there just wastes the user's time.
  const factory RequisitionDetailUiState.error(
    String message, {
    @Default(true) bool canRetry,
  }) = RequisitionDetailError;
}

sealed class RequisitionDetailEvent {
  const RequisitionDetailEvent();
}

/// A transient message that does not replace the content on screen.
class RequisitionDetailShowMessage extends RequisitionDetailEvent {
  const RequisitionDetailShowMessage(this.message);
  final String message;
}

/// The requisition is gone or was cancelled — the screen should close and the list
/// behind it should resync.
class RequisitionDetailClosed extends RequisitionDetailEvent {
  const RequisitionDetailClosed(this.message);
  final String message;
}

class RequisitionDetailSessionExpired extends RequisitionDetailEvent {
  const RequisitionDetailSessionExpired(this.message);
  final String message;
}
