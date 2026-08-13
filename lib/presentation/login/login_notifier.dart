import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';
import '../common/strings.dart';
import 'login_state.dart';

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginUiState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginUiState> {
  final StreamController<LoginEvent> _events = StreamController<LoginEvent>.broadcast();
  Stream<LoginEvent> get events => _events.stream;

  @override
  LoginUiState build() {
    ref.onDispose(_events.close);
    return const LoginUiState();
  }

  void onUsernameChange(String value) {
    state = state.copyWith(username: value, errorMessage: null);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<void> submit() async {
    if (state.username.trim().isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: TmsStrings.loginErrorRequiredFields);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(state.username.trim(), state.password);
    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _events.add(const NavigateToDashboard());
      },
      error: (message, _) => state = state.copyWith(
        isLoading: false,
        errorMessage: message ?? TmsStrings.loginErrorInvalidCredentials,
      ),
      offline: (message) => state = state.copyWith(isLoading: false, errorMessage: message),
      logout: (message, _) => state = state.copyWith(isLoading: false, errorMessage: message),
      maintenance: (message, _) => state = state.copyWith(isLoading: false, errorMessage: message),
    );
  }
}
