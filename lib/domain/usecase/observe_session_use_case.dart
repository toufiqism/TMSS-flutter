import '../model/user.dart';
import '../repository/auth_repository.dart';

class ObserveSessionUseCase {
  ObserveSessionUseCase(this._repository);
  final AuthRepository _repository;

  Stream<Session?> call() => _repository.session;
}
