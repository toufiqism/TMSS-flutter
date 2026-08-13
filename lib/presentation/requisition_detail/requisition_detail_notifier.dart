import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/requisition.dart';
import '../common/strings.dart';
import 'requisition_detail_state.dart';

const _httpForbidden = 403;
const _httpNotFound = 404;
const _httpConflict = 409;

/// `isAutoDispose: true` so leaving the screen drops the requisition it was showing.
/// Without it, opening a second requisition would briefly render the first one's data.
///
/// Deliberately *not* a family keyed by id: only one detail screen is open at a time,
/// and [NotifierLifecycle] mixes into `Notifier`, not `FamilyNotifier`. The id arrives
/// through [RequisitionDetailNotifier.load] instead.
final requisitionDetailNotifierProvider =
    NotifierProvider<RequisitionDetailNotifier, RequisitionDetailUiState>(
  RequisitionDetailNotifier.new,
  isAutoDispose: true,
);

class RequisitionDetailNotifier extends Notifier<RequisitionDetailUiState>
    with NotifierLifecycle<RequisitionDetailUiState, RequisitionDetailEvent> {
  String? _id;

  @override
  RequisitionDetailUiState build() {
    registerLifecycle();
    return const RequisitionDetailUiState.loading();
  }

  /// Full-screen load. Called once from the screen, and again by Retry.
  Future<void> load(String id) async {
    _id = id;
    setStateIfAlive(const RequisitionDetailUiState.loading());
    await _fetch(id);
  }

  /// Refetch under existing content — pull-to-refresh, and the resync after a save.
  Future<void> refresh() async {
    final id = _id;
    if (id == null || isDisposed) return;
    final current = state;
    if (current is RequisitionDetailSuccess) {
      setStateIfAlive(current.copyWith(isRefreshing: true));
    }
    await _fetch(id);
  }

  Future<void> _fetch(String id) async {
    final result = await ref.read(getRequisitionUseCaseProvider)(id);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<Requisition>(:final response):
        setStateIfAlive(RequisitionDetailUiState.success(response));
      case ApiError<Requisition>(:final message, :final errorCode):
        if (errorCode == _httpNotFound) {
          // Nothing left to show. Close rather than stranding the user on an error
          // screen for a requisition that no longer exists.
          emitEvent(RequisitionDetailClosed(message ?? NetworkMessages.notFound));
          return;
        }
        setStateIfAlive(RequisitionDetailUiState.error(
          message ?? NetworkMessages.generic,
          // A 403 is terminal: the contract is explicit that the caller is not the
          // creator and never will be, so Retry would only fail again.
          canRetry: errorCode != _httpForbidden,
        ));
      case ApiOffline<Requisition>(:final message):
        setStateIfAlive(RequisitionDetailUiState.error(message));
      case ApiMaintenance<Requisition>(:final message):
        setStateIfAlive(RequisitionDetailUiState.error(message));
      case ApiLogout<Requisition>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        emitEvent(RequisitionDetailSessionExpired(message));
    }
  }

  Future<void> cancel() async {
    final current = state;
    final id = _id;
    if (id == null || isDisposed || current is! RequisitionDetailSuccess) return;
    if (current.isCancelling) return;

    setStateIfAlive(current.copyWith(isCancelling: true));
    final result = await ref.read(cancelRequisitionUseCaseProvider)(id);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<void>():
        emitEvent(
          const RequisitionDetailClosed(TmsStrings.requisitionDetailCancelled),
        );
      case ApiError<void>(:final message, :final errorCode):
        _clearCancelling();
        emitEvent(RequisitionDetailShowMessage(
          message ?? TmsStrings.requisitionListCancelFailed,
        ));
        // 409 means an approver moved it out of Pending while this screen was open.
        // Refetching swaps in the real status, which also removes the actions that are
        // no longer legal.
        if (errorCode == _httpConflict) await refresh();
      case ApiOffline<void>(:final message):
        _clearCancelling();
        emitEvent(RequisitionDetailShowMessage(message));
      case ApiMaintenance<void>(:final message):
        _clearCancelling();
        emitEvent(RequisitionDetailShowMessage(message));
      case ApiLogout<void>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        _clearCancelling();
        emitEvent(RequisitionDetailSessionExpired(message));
    }
  }

  void _clearCancelling() {
    final current = state;
    if (current is RequisitionDetailSuccess) {
      setStateIfAlive(current.copyWith(isCancelling: false));
    }
  }
}
