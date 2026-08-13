import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginUiState with _$LoginUiState {
  const factory LoginUiState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LoginUiState;
}

sealed class LoginEvent {
  const LoginEvent();
}

class NavigateToDashboard extends LoginEvent {
  const NavigateToDashboard();
}
