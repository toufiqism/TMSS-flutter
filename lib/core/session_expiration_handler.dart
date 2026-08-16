import '../domain/repository/auth_repository.dart';
import '../domain/repository/requisition_repository.dart';

/// Reacts to a 401: the token is already dead, so the session is dropped locally and
/// the user lands back on Login.
///
/// Deliberately **not** [AuthRepository.logout]. That posts the token to `/logout`, and
/// the token in hand is the one the server just rejected — the call could only ever
/// come back 401 a second time. The user-visible outcome is identical; the difference
/// is one pointless request on every expiry.
///
/// The employee-directory cache goes too, for the same reason as in `LogoutUseCase`:
/// it holds the real staff list, it outlives the session, and whoever signs in next
/// must fetch it under their own token.
class SessionExpirationHandler {
  SessionExpirationHandler(this._authRepository, this._requisitionRepository);

  final AuthRepository _authRepository;
  final RequisitionRepository _requisitionRepository;

  Future<void> handle() async {
    await _authRepository.clearSession();
    _requisitionRepository.invalidateEmployeeCache();
  }
}
