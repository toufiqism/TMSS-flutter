import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/user.dart';
import 'profile_state.dart';

const _httpForbidden = 403;

/// `isAutoDispose: true`: the profile is a leaf screen, and account details should be
/// refetched per visit rather than shown stale from a previous one.
final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileUiState>(
  ProfileNotifier.new,
  isAutoDispose: true,
);

/// Owns only the `GET /user` account block.
///
/// Identity is not here on purpose — see [ProfileUiState]. That keeps this notifier a
/// plain request/response unit with no dependency on when the session stream resolves.
class ProfileNotifier extends Notifier<ProfileUiState>
    with NotifierLifecycle<ProfileUiState, ProfileEvent> {
  @override
  ProfileUiState build() {
    registerLifecycle();
    return const ProfileUiState();
  }

  Future<void> load() async {
    if (isDisposed) return;
    setStateIfAlive(state.copyWith(isLoading: true, errorMessage: null));

    final result = await ref.read(getUserAccountUseCaseProvider)();
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<UserAccount>(:final response):
        setStateIfAlive(
          state.copyWith(account: response, isLoading: false, errorMessage: null),
        );
      case ApiError<UserAccount>(:final message, :final errorCode):
        _onFailed(
          message ?? NetworkMessages.generic,
          // 403 is terminal — retrying cannot turn the caller into someone else.
          canRetry: errorCode != _httpForbidden,
        );
      case ApiOffline<UserAccount>(:final message):
        _onFailed(message);
      case ApiMaintenance<UserAccount>(:final message):
        _onFailed(message);
      case ApiLogout<UserAccount>(:final message):
        await ref.read(sessionExpirationHandlerProvider).handle();
        if (isDisposed) return;
        emitEvent(ProfileSessionExpired(message));
    }
  }

  /// A failure is confined to the account section. The identity above it comes from the
  /// session and stays on screen regardless.
  void _onFailed(String message, {bool canRetry = true}) {
    setStateIfAlive(
      state.copyWith(isLoading: false, errorMessage: message, canRetry: canRetry),
    );
  }
}
