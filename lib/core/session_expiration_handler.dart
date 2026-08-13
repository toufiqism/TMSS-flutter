import '../domain/repository/auth_repository.dart';

class SessionExpirationHandler {
  SessionExpirationHandler(this._authRepository);
  final AuthRepository _authRepository;

  Future<void> handle() => _authRepository.logout();
}
