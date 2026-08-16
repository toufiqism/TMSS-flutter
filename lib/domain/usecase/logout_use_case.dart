import '../../core/api_result.dart';
import '../repository/auth_repository.dart';
import '../repository/requisition_repository.dart';

/// Ends the session: revokes the token server-side, clears it locally, and drops
/// everything the previous user's token fetched.
///
/// The employee directory is the reason this use case touches two repositories. It is
/// the real staff list — 537 rows of names, staff numbers, designations and departments
/// — cached in memory for the lifetime of the repository, which is the lifetime of the
/// *app*, not of the session: [RequisitionRepository] is bound to a plain provider that
/// nothing rebuilds when the session clears. Without this call the next person to sign
/// in on the same device gets the previous user's directory, served from cache without
/// a request their token would have had to authorise.
class LogoutUseCase {
  LogoutUseCase(this._authRepository, this._requisitionRepository);

  final AuthRepository _authRepository;
  final RequisitionRepository _requisitionRepository;

  /// Returns the *server's* verdict on the revoke. The local session is cleared either
  /// way — see [AuthRepository.logout].
  Future<ApiResult<void>> call() async {
    try {
      return await _authRepository.logout();
    } finally {
      // `finally`, not a plain statement after the await: the local session is gone
      // regardless of what the server said, and an unexpected throw out of the
      // repository must not be the one path that leaves the previous user's directory
      // sitting in memory.
      _requisitionRepository.invalidateEmployeeCache();
    }
  }
}
