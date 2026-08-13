import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/user.dart';
import '../common/strings.dart';
import 'login_state.dart';

/// `isAutoDispose: true` is load-bearing, not a micro-optimisation. Riverpod 3 keeps
/// providers alive by default, and this state holds the typed password: without
/// auto-dispose it would sit in memory for the whole process lifetime and, worse,
/// repopulate the password field the next time the user is bounced to this screen
/// after a logout.
final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginUiState>(
  LoginNotifier.new,
  isAutoDispose: true,
);

class LoginNotifier extends Notifier<LoginUiState>
    with NotifierLifecycle<LoginUiState, LoginEvent> {
  @override
  LoginUiState build() {
    registerLifecycle();
    return const LoginUiState();
  }

  void onUsernameChange(String value) {
    state = state.copyWith(username: value, errorMessage: null);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    if (state.username.trim().isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: TmsStrings.loginErrorRequiredFields);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(state.username.trim(), state.password);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<Session>():
        // Drop the password the moment it is no longer needed, so it does not
        // outlive the request even for the short window before auto-dispose.
        setStateIfAlive(state.copyWith(isLoading: false, password: ''));
        emitEvent(const NavigateToDashboard());
      case ApiError<Session>(:final message):
        setStateIfAlive(state.copyWith(
          isLoading: false,
          errorMessage: message ?? TmsStrings.loginErrorInvalidCredentials,
        ));
      case ApiOffline<Session>(:final message):
        setStateIfAlive(state.copyWith(isLoading: false, errorMessage: message));
      case ApiLogout<Session>(:final message):
        setStateIfAlive(state.copyWith(isLoading: false, errorMessage: message));
      case ApiMaintenance<Session>(:final message):
        setStateIfAlive(state.copyWith(isLoading: false, errorMessage: message));
    }
  }
}
