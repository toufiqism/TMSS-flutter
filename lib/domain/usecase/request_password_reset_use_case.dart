import '../../core/api_result.dart';
import '../repository/auth_repository.dart';

/// Step 1 of the reset flow: ask for an OTP to be emailed.
///
/// Trims here rather than at the call site so every caller — screen, test, future
/// deep link — sends the same normalised value the second step will send back.
class RequestPasswordResetUseCase {
  RequestPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<ApiResult<String>> call(String userName) {
    return _repository.requestPasswordReset(userName.trim());
  }
}
