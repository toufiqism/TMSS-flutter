import '../../core/api_result.dart';
import '../repository/auth_repository.dart';

/// Step 2 of the reset flow: verify the OTP and set the new password.
///
/// The confirmation is sent as the server requires it, not folded into one argument:
/// the client checks the two match before calling, but the server checks again, and a
/// client that silently duplicated one field would hide a real mismatch bug rather
/// than surface it as a 422.
class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<ApiResult<String>> call({
    required String userName,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.resetPassword(
      userName: userName.trim(),
      otpCode: otpCode.trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
