import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../../domain/model/user.dart';
import '../common/strings.dart';
import '../password_reset/password_reset_handoff.dart';
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
    // A reset that finished while this screen did *not* exist — the one started from
    // Profile, which ends by clearing the session and routing here — leaves its email
    // in the handoff. Consumed on the way in, so the note and the prefill survive the
    // navigation that destroys and rebuilds everything else.
    final prefill = ref.read(passwordResetHandoffProvider).take();
    if (prefill == null) return const LoginUiState();
    return LoginUiState(
      username: prefill,
      infoMessage: TracGoStrings.loginPasswordResetSuccess,
    );
  }

  void onUsernameChange(String value) {
    state = state.copyWith(username: value, errorMessage: null, infoMessage: null);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value, errorMessage: null, infoMessage: null);
  }

  /// Called when the password-reset flow finishes, before it pops back to this screen.
  ///
  /// The server invalidates the account's token on reset, so there is nothing to sign
  /// the user in with — the new password only exists on the server and must be typed
  /// again here. Prefilling the username removes the one part of that re-entry that is
  /// pure friction, and the note says why the form is being shown at all.
  ///
  /// The password field is cleared rather than left alone: whatever is in it is, by
  /// definition, the old password.
  void onPasswordResetComplete(String username) {
    state = state.copyWith(
      username: username,
      password: '',
      isLoading: false,
      errorMessage: null,
      infoMessage: TracGoStrings.loginPasswordResetSuccess,
    );
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    if (state.username.trim().isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        errorMessage: TracGoStrings.loginErrorRequiredFields,
        infoMessage: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, infoMessage: null);
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
          errorMessage: message ?? TracGoStrings.loginErrorInvalidCredentials,
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
