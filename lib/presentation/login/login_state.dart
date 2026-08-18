import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginUiState with _$LoginUiState {
  const factory LoginUiState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool isLoading,
    String? errorMessage,

    /// A non-failure note shown in the same slot as [errorMessage] — set only by
    /// [LoginNotifier.onPasswordResetComplete], so the user who just changed their
    /// password is told to sign in with the new one rather than landing on a form that
    /// looks like nothing happened.
    String? infoMessage,
  }) = _LoginUiState;
}

sealed class LoginEvent {
  const LoginEvent();
}

class NavigateToDashboard extends LoginEvent {
  const NavigateToDashboard();
}
