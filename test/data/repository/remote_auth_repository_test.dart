import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/core/network_messages.dart';
import 'package:tracgo/data/local/session_local_data_source.dart';
import 'package:tracgo/data/remote/tracgo_api_client.dart';
import 'package:tracgo/data/repository/remote_auth_repository.dart';
import 'package:tracgo/domain/model/user.dart';

class MockTracGoApiClient extends Mock implements TracGoApiClient {}

class MockSessionLocalDataSource extends Mock implements SessionLocalDataSource {}

class FakeSession extends Fake implements Session {}

Response<dynamic> _response(int status, [dynamic body]) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/login'),
      statusCode: status,
      data: body,
    );

/// The real `POST /login` body, captured from the live server.
Map<String, dynamic> _loginBody({String token = 'abc123'}) => {
      'success': true,
      'message': 'Login successful',
      'data': {
        'token': token,
        'expires_at': '2027-08-14 00:32:59',
        'name': 'Md. Tofiq Akbar',
        'designation': 'Senior Engineer',
        'phone': '01700000000',
        'company_name': 'B-Trac Solutions Limited',
      },
    };

void main() {
  late MockTracGoApiClient api;
  late MockSessionLocalDataSource storage;
  late RemoteAuthRepository repository;

  setUpAll(() => registerFallbackValue(FakeSession()));

  setUp(() {
    api = MockTracGoApiClient();
    storage = MockSessionLocalDataSource();
    repository = RemoteAuthRepository(api, storage);
    when(() => storage.save(any())).thenAnswer((_) async {});
    when(storage.clear).thenAnswer((_) async {});
    when(api.logout).thenAnswer((_) async => _response(200, {'success': true}));
  });

  void stubLogin(Response<dynamic> response) {
    when(() => api.login(
          userName: any(named: 'userName'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => response);
  }

  test('login builds the whole session from one call', () async {
    // The contract implied a second GET /user was needed for the account. It is not:
    // the login response carries name and designation.
    stubLogin(_response(200, _loginBody()));

    final result = await repository.login('tofiq.akbar@btracsl.com', 'pw');

    final session = (result as ApiSuccess<Session>).response;
    expect(session.token, 'abc123');
    expect(session.user.name, 'Md. Tofiq Akbar');
    expect(session.user.designation, 'Senior Engineer');
    expect(session.user.email, 'tofiq.akbar@btracsl.com');
    // expires_at is Dhaka wall-clock, like start_time and unlike created_at.
    expect(session.expiresAt!.toUtc(), DateTime.utc(2027, 8, 13, 18, 32, 59));
    expect(session.isExpired, isFalse);
    verify(() => storage.save(any())).called(1);
    verifyNever(() => api.getAuthenticatedUser(bearerToken: any(named: 'bearerToken')));
  });

  test('a login response with no expires_at yields an unknown, not expired, session', () async {
    // The client must not invent an expiry: "unknown" keeps the session usable and lets
    // a 401 be the thing that ends it.
    stubLogin(_response(200, {
      'success': true,
      'data': {'token': 'abc123', 'name': 'Md. Tofiq Akbar'},
    }));

    final result = await repository.login('tofiq.akbar@btracsl.com', 'pw');

    final session = (result as ApiSuccess<Session>).response;
    expect(session.expiresAt, isNull);
    expect(session.isExpired, isFalse);
  });

  test('a login response without a name falls back to one derived from the email', () async {
    stubLogin(_response(200, {
      'success': true,
      'data': {'token': 'abc123'},
    }));

    final result = await repository.login('tofiq.akbar@btracsl.com', 'pw');

    expect((result as ApiSuccess<Session>).response.user.name, 'Tofiq Akbar');
  });

  test('401 on login is bad credentials, not an expired session', () async {
    // Mapping it to `logout` would bounce the user to the screen they are already on.
    stubLogin(_response(401, {
      'success': false,
      'message': 'Invalid credentials',
      'errors': null,
    }));

    final result = await repository.login('someone@example.com', 'wrong');

    expect(result, isA<ApiError<Session>>());
    expect((result as ApiError<Session>).message, 'Invalid credentials');
    verifyNever(() => storage.save(any()));
  });

  test('a 200 with no token is a contract mismatch, not a wrong password', () async {
    stubLogin(_response(200, {'success': true, 'data': <String, dynamic>{}}));

    final result = await repository.login('someone@example.com', 'pw');

    expect(result, isA<ApiError<Session>>());
    verifyNever(() => storage.save(any()));
  });

  test('offline propagates as offline', () async {
    when(() => api.login(
          userName: any(named: 'userName'),
          password: any(named: 'password'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(await repository.login('a@b.com', 'pw'), isA<ApiOffline<Session>>());
  });

  test('maintenance propagates as maintenance', () async {
    stubLogin(_response(503));

    expect(await repository.login('a@b.com', 'pw'), isA<ApiMaintenance<Session>>());
  });

  group('logout', () {
    test('revokes server-side before clearing locally', () async {
      // Tokens last a year, so a purely local sign-out would leave a working token
      // behind for anyone who captured it.
      await repository.logout();

      verify(api.logout).called(1);
      verify(storage.clear).called(1);
    });

    test('still clears locally when the revoke call fails', () async {
      when(api.logout).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/logout'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.logout();

      // Leaving the user signed in because the network hiccuped would be worse than a
      // token that outlives the session.
      verify(storage.clear).called(1);
      // ...but the caller is told, so the drawer can say the token may still be live.
      expect(result, isA<ApiOffline<void>>());
    });

    test('a successful revoke reports success', () async {
      expect(await repository.logout(), isA<ApiSuccess<void>>());
    });

    test('a 401 revoke is success, not a failure worth warning about', () async {
      // The token was already dead — which is the state logout exists to reach. Warning
      // here would tell the user something went wrong when nothing did.
      when(api.logout).thenAnswer(
        (_) async => _response(401, {'success': false, 'message': 'Unauthenticated.'}),
      );

      final result = await repository.logout();

      expect(result, isA<ApiSuccess<void>>());
      verify(storage.clear).called(1);
    });

    test('a 500 revoke is reported, and the session is still cleared', () async {
      when(api.logout).thenAnswer(
        (_) async => _response(500, {'success': false, 'message': 'Server error'}),
      );

      final result = await repository.logout();

      expect(result, isA<ApiError<void>>());
      verify(storage.clear).called(1);
    });
  });

  group('clearSession', () {
    test('clears locally without calling the server', () async {
      // The 401 path: the token in hand is the one the server just rejected, so posting
      // it to /logout could only ever 401 a second time.
      await repository.clearSession();

      verify(storage.clear).called(1);
      verifyNever(api.logout);
    });
  });

  // ---------------------------------------------------------------------------------
  // Password reset — POST /forgot-password, POST /reset-password
  // ---------------------------------------------------------------------------------

  void stubForgot(Response<dynamic> response) {
    when(() => api.forgotPassword(userName: any(named: 'userName')))
        .thenAnswer((_) async => response);
  }

  void stubResetPassword(Response<dynamic> response) {
    when(() => api.resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        )).thenAnswer((_) async => response);
  }

  test('forgot password returns the server message and touches no local state',
      () async {
    stubForgot(_response(200, {
      'success': true,
      'message': 'If an account matches, a password reset OTP has been sent.',
    }));

    final result = await repository.requestPasswordReset('tofiq.akbar@btracsl.com');

    expect(
      (result as ApiSuccess<String>).response,
      'If an account matches, a password reset OTP has been sent.',
    );
    verify(() => api.forgotPassword(userName: 'tofiq.akbar@btracsl.com')).called(1);
    // Nothing is signed in or out by asking for a code.
    verifyNever(() => storage.save(any()));
    verifyNever(storage.clear);
  });

  test('a 200 with no message falls back to the client string', () async {
    stubForgot(_response(200, {'success': true}));

    final result = await repository.requestPasswordReset('tofiq.akbar@btracsl.com');

    expect(
      (result as ApiSuccess<String>).response,
      NetworkMessages.passwordResetCodeSent,
    );
  });

  test('a 200 that declares failure is not reported as success', () async {
    // Undocumented — every specified failure is a 422 — but a self-declared failure
    // read as success would tell the user their password had changed when it had not.
    stubResetPassword(_response(200, {
      'success': false,
      'message': 'The OTP is invalid or has expired.',
    }));

    final result = await repository.resetPassword(
      userName: 'tofiq.akbar@btracsl.com',
      otpCode: '123456',
      password: 'demo12345',
      passwordConfirmation: 'demo12345',
    );

    expect((result as ApiError<String>).message, 'The OTP is invalid or has expired.');
  });

  test('a 422 on forgot password carries the field errors through', () async {
    stubForgot(_response(422, {
      'success': false,
      'message': 'The given data was invalid.',
      'errors': {
        'user_name': ['The user name field is required.'],
      },
    }));

    final result = await repository.requestPasswordReset('nope');

    final error = result as ApiError<String>;
    expect(error.errorCode, 422);
    expect(error.fieldErrors, {'user_name': 'The user name field is required.'});
  });

  test('a 429 on forgot password is an error, never a logout', () async {
    stubForgot(_response(429, {'success': false, 'message': 'Too Many Attempts.'}));

    final result = await repository.requestPasswordReset('tofiq.akbar@btracsl.com');

    final error = result as ApiError<String>;
    expect(error.errorCode, 429);
    expect(error.message, 'Too Many Attempts.');
  });

  test('a 429 with no message uses the throttle wording', () async {
    stubForgot(_response(429));

    final result = await repository.requestPasswordReset('tofiq.akbar@btracsl.com');

    expect((result as ApiError<String>).message, NetworkMessages.tooManyRequests);
  });

  test('reset password sends all four fields and returns the message', () async {
    stubResetPassword(_response(200, {
      'success': true,
      'message': 'Password has been reset successfully.',
    }));

    final result = await repository.resetPassword(
      userName: 'tofiq.akbar@btracsl.com',
      otpCode: '123456',
      password: 'demo12345',
      passwordConfirmation: 'demo12345',
    );

    expect(
      (result as ApiSuccess<String>).response,
      'Password has been reset successfully.',
    );
    verify(() => api.resetPassword(
          userName: 'tofiq.akbar@btracsl.com',
          otpCode: '123456',
          password: 'demo12345',
          passwordConfirmation: 'demo12345',
        )).called(1);
    // The server invalidates the account's token, but this device has no session to
    // clear — the flow only runs while signed out.
    verifyNever(storage.clear);
  });

  test('an invalid OTP arrives as a 422 with a message and no field errors', () async {
    stubResetPassword(_response(422, {
      'success': false,
      'message': 'The OTP is invalid or has expired.',
    }));

    final result = await repository.resetPassword(
      userName: 'tofiq.akbar@btracsl.com',
      otpCode: '000000',
      password: 'demo12345',
      passwordConfirmation: 'demo12345',
    );

    final error = result as ApiError<String>;
    expect(error.errorCode, 422);
    expect(error.message, 'The OTP is invalid or has expired.');
    expect(error.fieldErrors, isNull);
  });

  test('a 422 confirmation mismatch is pinned to its field', () async {
    stubResetPassword(_response(422, {
      'success': false,
      'message': 'The given data was invalid.',
      'errors': {
        'password': ['The password confirmation does not match.'],
      },
    }));

    final result = await repository.resetPassword(
      userName: 'tofiq.akbar@btracsl.com',
      otpCode: '123456',
      password: 'demo12345',
      passwordConfirmation: 'demo54321',
    );

    expect(
      (result as ApiError<String>).fieldErrors,
      {'password': 'The password confirmation does not match.'},
    );
  });

  test('a dropped connection on reset is offline, not a failed reset', () async {
    when(() => api.resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        )).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/reset-password'),
      type: DioExceptionType.connectionError,
    ));

    final result = await repository.resetPassword(
      userName: 'tofiq.akbar@btracsl.com',
      otpCode: '123456',
      password: 'demo12345',
      passwordConfirmation: 'demo12345',
    );

    expect(result, isA<ApiOffline<String>>());
  });

  test('a 401 on the unauthenticated endpoints is an error, not a session expiry',
      () async {
    stubForgot(_response(401, {'message': 'Unauthenticated.'}));

    final result = await repository.requestPasswordReset('tofiq.akbar@btracsl.com');

    // `ApiLogout` here would route the user to login — the screen they are on because
    // they cannot sign in.
    expect(result, isA<ApiError<String>>());
    expect((result as ApiError<String>).errorCode, 401);
  });
}
