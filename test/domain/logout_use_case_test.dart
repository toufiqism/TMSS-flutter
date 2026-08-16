import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/core/session_expiration_handler.dart';
import 'package:tracgo/domain/repository/auth_repository.dart';
import 'package:tracgo/domain/repository/requisition_repository.dart';
import 'package:tracgo/domain/usecase/logout_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRequisitionRepository extends Mock implements RequisitionRepository {}

void main() {
  late MockAuthRepository auth;
  late MockRequisitionRepository requisitions;

  setUp(() {
    auth = MockAuthRepository();
    requisitions = MockRequisitionRepository();
    when(auth.logout).thenAnswer((_) async => const ApiResult.success(null));
    when(auth.clearSession).thenAnswer((_) async {});
    when(requisitions.invalidateEmployeeCache).thenReturn(null);
  });

  group('LogoutUseCase', () {
    test('revokes the token and drops the cached staff directory', () async {
      // The directory is the real staff list and the repository outlives the session,
      // so without this the next person to sign in on the device inherits it.
      final result = await LogoutUseCase(auth, requisitions)();

      verify(auth.logout).called(1);
      verify(requisitions.invalidateEmployeeCache).called(1);
      expect(result, isA<ApiSuccess<void>>());
    });

    test('drops the directory even when the revoke failed', () async {
      // The local session is gone regardless of what the server said, so a cache left
      // behind here would leak on exactly the path that already went wrong.
      when(auth.logout).thenAnswer((_) async => const ApiResult.offline('No network'));

      final result = await LogoutUseCase(auth, requisitions)();

      verify(requisitions.invalidateEmployeeCache).called(1);
      expect(result, isA<ApiOffline<void>>(),
          reason: 'the caller warns that the token may still be live');
    });

    test('drops the directory even if the repository throws outright', () async {
      // The repository is contracted to return an ApiResult rather than throw, but an
      // unexpected throw must not be the one path that leaves the previous user's
      // directory in memory.
      when(auth.logout).thenThrow(StateError('unexpected'));

      await expectLater(LogoutUseCase(auth, requisitions).call, throwsStateError);

      verify(requisitions.invalidateEmployeeCache).called(1);
    });
  });

  group('SessionExpirationHandler', () {
    test('clears locally without posting the dead token back', () async {
      await SessionExpirationHandler(auth, requisitions).handle();

      verify(auth.clearSession).called(1);
      verifyNever(auth.logout);
      verify(requisitions.invalidateEmployeeCache).called(1);
    });

    test('is safe to run twice, as concurrent 401s make it', () async {
      // Two screens in flight both get a 401 and both call handle().
      final handler = SessionExpirationHandler(auth, requisitions);

      await Future.wait([handler.handle(), handler.handle()]);

      verify(auth.clearSession).called(2);
      verifyNever(auth.logout);
    });
  });
}
