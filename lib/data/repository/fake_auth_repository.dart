import 'dart:math';

import '../../core/api_result.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/session_local_data_source.dart';

/// Stands in for the real backend until it's available. Seeded with the current user's profile
/// (name/designation/email) but a demo password, not the real one, since that shouldn't live in
/// source. Swap the DI binding to a Dio-backed impl once the API exists. Same seed data as the
/// Android app's FakeAuthRepository.kt.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._sessionLocalDataSource);
  final SessionLocalDataSource _sessionLocalDataSource;

  static const _seededUsername = 'tofiq.akbar@btracsl.com';
  static const _seededPassword = 'demo1234';
  static const _seededUser = User(
    id: '1',
    name: 'Md. Tofiq Akbar',
    designation: 'Senior Engineer',
    email: _seededUsername,
  );

  @override
  Stream<Session?> get session => _sessionLocalDataSource.session;

  @override
  Future<ApiResult<Session>> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (username.trim().isEmpty || password.isEmpty) {
      return const ApiResult.error('Username/Password is invalid!');
    }
    if (username != _seededUsername || password != _seededPassword) {
      return const ApiResult.error('Username/Password is invalid!');
    }
    final session = Session(token: _generateToken(), user: _seededUser);
    await _sessionLocalDataSource.save(session);
    return ApiResult.success(session);
  }

  @override
  Future<void> logout() => _sessionLocalDataSource.clear();

  String _generateToken() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
