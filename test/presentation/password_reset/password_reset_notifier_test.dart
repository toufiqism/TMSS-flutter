import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/usecase/request_password_reset_use_case.dart';
import 'package:tracgo/domain/usecase/reset_password_use_case.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/password_reset/password_reset_notifier.dart';
import 'package:tracgo/presentation/password_reset/password_reset_state.dart';

class MockRequestPasswordResetUseCase extends Mock
    implements RequestPasswordResetUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late MockRequestPasswordResetUseCase requestReset;
  late MockResetPasswordUseCase resetPassword;
  late ProviderContainer container;

  const email = 'tofiq.akbar@btracsl.com';
  const newPassword = 'demo12345';

  setUp(() {
    requestReset = MockRequestPasswordResetUseCase();
    resetPassword = MockResetPasswordUseCase();
    container = ProviderContainer(
      overrides: [
        requestPasswordResetUseCaseProvider.overrideWithValue(requestReset),
        resetPasswordUseCaseProvider.overrideWithValue(resetPassword),
      ],
    );
    addTearDown(container.dispose);
    // isAutoDispose: hold a subscription so the notifier survives across awaits, the
    // same way the mounted screen does.
    container.listen(passwordResetNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  PasswordResetNotifier notifier() =>
      container.read(passwordResetNotifierProvider.notifier);
  PasswordResetUiState state() => container.read(passwordResetNotifierProvider);

  void stubSend(ApiResult<String> result) {
    when(() => requestReset(any())).thenAnswer((_) async => result);
  }

  void stubReset(ApiResult<String> result) {
    when(() => resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        )).thenAnswer((_) async => result);
  }

  /// Gets the notifier to step 2 with a code already requested.
  Future<void> reachVerifyStep() async {
    stubSend(const ApiResult.success('Code sent.'));
    notifier().onUserNameChange(email);
    await notifier().sendCode();
  }

  // ---------------------------------------------------------------------------------
  // Step 1
  // ---------------------------------------------------------------------------------

  test('a blank email is rejected without spending a request', () async {
    await notifier().sendCode();

    expect(
      state().fieldError(PasswordResetFields.userName),
      isNotNull,
    );
    expect(state().step, PasswordResetStep.requestCode);
    verifyNever(() => requestReset(any()));
  });

  test('an address that is not email-shaped is rejected locally', () async {
    notifier().onUserNameChange('tofiq.akbar');

    await notifier().sendCode();

    expect(state().fieldError(PasswordResetFields.userName), isNotNull);
    verifyNever(() => requestReset(any()));
  });

  test('a successful send advances to the code step and starts both countdowns',
      () async {
    stubSend(const ApiResult.success('If an account matches, a code has been sent.'));
    notifier().onUserNameChange('  $email  ');

    await notifier().sendCode();

    final current = state();
    expect(current.step, PasswordResetStep.enterCode);
    // Trimmed before it is sent, and the trimmed value is what step 2 keeps.
    expect(current.userName, email);
    expect(current.isSubmitting, isFalse);
    expect(current.infoMessage, 'If an account matches, a code has been sent.');
    expect(current.resendSecondsLeft, PasswordResetUiState.resendCooldownSeconds);
    expect(current.expirySecondsLeft, PasswordResetUiState.otpLifetimeSeconds);
    expect(current.canResend, isFalse);
    verify(() => requestReset(email)).called(1);
  });

  test('a 422 on send pins the message to the email field, not to the banner',
      () async {
    stubSend(const ApiResult.error('The given data was invalid.', 422, {
      'user_name': 'The user name field is required.',
    }));
    notifier().onUserNameChange(email);

    await notifier().sendCode();

    expect(
      state().fieldError(PasswordResetFields.userName),
      'The user name field is required.',
    );
    expect(state().errorMessage, isNull);
    expect(state().step, PasswordResetStep.requestCode);
  });

  test('a 429 on send surfaces the throttle message and stays on step 1', () async {
    stubSend(
      const ApiResult.error('Too many attempts. Please wait a minute and try again.', 429),
    );
    notifier().onUserNameChange(email);

    await notifier().sendCode();

    expect(
      state().errorMessage,
      'Too many attempts. Please wait a minute and try again.',
    );
    expect(state().isSubmitting, isFalse);
    expect(state().step, PasswordResetStep.requestCode);
  });

  test('being offline on send is reported without advancing', () async {
    stubSend(const ApiResult.offline());
    notifier().onUserNameChange(email);

    await notifier().sendCode();

    expect(state().errorMessage, 'No internet connection available');
    expect(state().step, PasswordResetStep.requestCode);
  });

  test('maintenance on send is reported without advancing', () async {
    stubSend(const ApiResult.maintenance('Under maintenance', 503));
    notifier().onUserNameChange(email);

    await notifier().sendCode();

    expect(state().errorMessage, 'Under maintenance');
    expect(state().step, PasswordResetStep.requestCode);
  });

  test('a 401 on send is shown inline and never routes out of the flow', () async {
    // Cannot happen against a working server — the endpoint is unauthenticated — but
    // the branch exists so a stray 401 cannot bounce the user to a screen they came
    // from precisely because they have no session.
    stubSend(const ApiResult.logout('Unauthenticated.', 401));
    notifier().onUserNameChange(email);

    await notifier().sendCode();

    expect(state().errorMessage, 'Unauthenticated.');
    expect(state().step, PasswordResetStep.requestCode);
  });

  test('a resend during the cooldown does not reach the server', () async {
    await reachVerifyStep();
    clearInteractions(requestReset);

    await notifier().sendCode();

    verifyNever(() => requestReset(any()));
  });

  test('a failed resend still arms the cooldown', () {
    // Virtual time: the cooldown is a minute long, and a resend is only offered once it
    // has run out.
    fakeAsync((async) {
      stubSend(const ApiResult.success('Code sent.'));
      notifier().onUserNameChange(email);
      unawaited(notifier().sendCode());
      async.flushMicrotasks();
      notifier().onOtpChange('123456');

      async.elapse(
        const Duration(seconds: PasswordResetUiState.resendCooldownSeconds),
      );
      expect(state().canResend, isTrue);

      stubSend(const ApiResult.error('Too Many Attempts.', 429));
      unawaited(notifier().sendCode());
      async.flushMicrotasks();

      expect(state().errorMessage, 'Too Many Attempts.');
      expect(state().resendSecondsLeft, PasswordResetUiState.resendCooldownSeconds);
      expect(state().canResend, isFalse);
    });
  });

  test('a successful resend clears the code already typed', () {
    fakeAsync((async) {
      stubSend(const ApiResult.success('Code sent.'));
      notifier().onUserNameChange(email);
      unawaited(notifier().sendCode());
      async.flushMicrotasks();
      notifier().onOtpChange('123456');

      async.elapse(
        const Duration(seconds: PasswordResetUiState.resendCooldownSeconds),
      );
      unawaited(notifier().sendCode());
      async.flushMicrotasks();

      expect(state().otpCode, isEmpty);
      expect(state().expirySecondsLeft, PasswordResetUiState.otpLifetimeSeconds);
    });
  });

  // ---------------------------------------------------------------------------------
  // Step 2
  // ---------------------------------------------------------------------------------

  test('the code input keeps digits only and stops at six', () async {
    await reachVerifyStep();

    notifier().onOtpChange('12 34-56789');

    expect(state().otpCode, '123456');
  });

  test('an incomplete code, a short password and a mismatch are all caught locally',
      () async {
    await reachVerifyStep();
    notifier().onOtpChange('123');
    notifier().onPasswordChange('short');
    notifier().onConfirmPasswordChange('shorter');

    await notifier().submitReset();

    expect(state().fieldError(PasswordResetFields.otpCode), isNotNull);
    expect(state().fieldError(PasswordResetFields.password), isNotNull);
    verifyNever(() => resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        ));
  });

  test('the floor is inclusive: exactly minPasswordLength characters submits',
      () async {
    final atFloor = 'a' * PasswordResetUiState.minPasswordLength;
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(atFloor);
    notifier().onConfirmPasswordChange(atFloor);
    stubReset(const ApiResult.success('Password has been reset successfully.'));

    await notifier().submitReset();

    expect(state().fieldError(PasswordResetFields.password), isNull);
    verify(() => resetPassword(
          userName: email,
          otpCode: '123456',
          password: atFloor,
          passwordConfirmation: atFloor,
        )).called(1);
  });

  test('one character under the floor is rejected before spending a request',
      () async {
    final underFloor = 'a' * (PasswordResetUiState.minPasswordLength - 1);
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(underFloor);
    notifier().onConfirmPasswordChange(underFloor);

    await notifier().submitReset();

    expect(
      state().fieldError(PasswordResetFields.password),
      TracGoStrings.resetErrorPasswordTooShort(
        PasswordResetUiState.minPasswordLength,
      ),
    );
    verifyNever(() => resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        ));
  });

  test('a mismatch is reported on the confirmation field', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange('demo54321');

    await notifier().submitReset();

    expect(
      state().fieldError(PasswordResetFields.passwordConfirmation),
      isNotNull,
    );
    expect(state().fieldError(PasswordResetFields.password), isNull);
  });

  test('a successful reset emits the completion event and clears the secrets',
      () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.success('Password has been reset successfully.'));

    final events = <PasswordResetEvent>[];
    final sub = notifier().events.listen(events.add);

    await notifier().submitReset();
    await Future<void>.delayed(Duration.zero);

    expect(events, [isA<PasswordResetCompleted>()]);
    expect((events.single as PasswordResetCompleted).userName, email);
    final current = state();
    expect(current.isSubmitting, isFalse);
    expect(current.password, isEmpty);
    expect(current.confirmPassword, isEmpty);
    expect(current.otpCode, isEmpty);
    verify(() => resetPassword(
          userName: email,
          otpCode: '123456',
          password: newPassword,
          passwordConfirmation: newPassword,
        )).called(1);
    await sub.cancel();
  });

  test('an invalid OTP is shown as a banner and the step is kept', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    // The documented shape: 422 with a message and no `errors` map.
    stubReset(const ApiResult.error('The OTP is invalid or has expired.', 422));

    await notifier().submitReset();

    expect(state().errorMessage, 'The OTP is invalid or has expired.');
    expect(state().step, PasswordResetStep.enterCode);
    expect(state().isSubmitting, isFalse);
  });

  test('a 422 with an errors map lands on the fields it names', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.error('The given data was invalid.', 422, {
      'password': 'The password must be at least 10 characters.',
    }));

    await notifier().submitReset();

    expect(
      state().fieldError(PasswordResetFields.password),
      'The password must be at least 10 characters.',
    );
    expect(state().errorMessage, isNull);
  });

  test('a field error the client does not render still reaches the banner', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.error('The given data was invalid.', 422, {
      'captcha': 'The captcha is required.',
    }));

    await notifier().submitReset();

    expect(state().errorMessage, 'The captcha is required.');
  });

  test('being offline during the reset is reported and nothing is cleared', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.offline());

    await notifier().submitReset();

    expect(state().errorMessage, 'No internet connection available');
    // The user's typing survives the failure — retyping a password after a dropped
    // connection is the fastest way to lose someone mid-flow.
    expect(state().password, newPassword);
    expect(state().otpCode, '123456');
  });

  test('maintenance during the reset is reported', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.maintenance('Under maintenance', 503));

    await notifier().submitReset();

    expect(state().errorMessage, 'Under maintenance');
  });

  test('a 401 during the reset is shown inline, not routed on', () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);
    stubReset(const ApiResult.logout('Unauthenticated.', 401));

    await notifier().submitReset();

    expect(state().errorMessage, 'Unauthenticated.');
    expect(state().step, PasswordResetStep.enterCode);
  });

  test('submitReset does nothing on step 1', () async {
    notifier().onUserNameChange(email);

    await notifier().submitReset();

    verifyNever(() => resetPassword(
          userName: any(named: 'userName'),
          otpCode: any(named: 'otpCode'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        ));
  });

  // ---------------------------------------------------------------------------------
  // Navigation between the steps
  // ---------------------------------------------------------------------------------

  test('going back to the email step keeps the email and drops every secret',
      () async {
    await reachVerifyStep();
    notifier().onOtpChange('123456');
    notifier().onPasswordChange(newPassword);
    notifier().onConfirmPasswordChange(newPassword);

    notifier().backToEmailStep();

    final current = state();
    expect(current.step, PasswordResetStep.requestCode);
    expect(current.userName, email);
    expect(current.otpCode, isEmpty);
    expect(current.password, isEmpty);
    expect(current.confirmPassword, isEmpty);
    expect(current.expirySecondsLeft, 0);
  });

  // ---------------------------------------------------------------------------------
  // Countdowns
  // ---------------------------------------------------------------------------------

  test('the countdowns tick down together and the expiry flag flips at zero', () {
    fakeAsync((async) {
      stubSend(const ApiResult.success('Code sent.'));
      notifier().onUserNameChange(email);
      unawaited(notifier().sendCode());
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 1));
      expect(
        state().resendSecondsLeft,
        PasswordResetUiState.resendCooldownSeconds - 1,
      );
      expect(
        state().expirySecondsLeft,
        PasswordResetUiState.otpLifetimeSeconds - 1,
      );
      expect(state().isCodeExpired, isFalse);
      expect(state().expiryLabel, '9:59');

      async.elapse(
        const Duration(seconds: PasswordResetUiState.otpLifetimeSeconds),
      );
      expect(state().expirySecondsLeft, 0);
      expect(state().isCodeExpired, isTrue);
      // Advisory only: an expired estimate never disables the resend that fixes it.
      expect(state().canResend, isTrue);
    });
  });

  test('a disposed notifier stops counting instead of writing to dead state', () {
    // Its own container: disposal is the thing under test, so it must not also be the
    // shared one that tearDown disposes.
    final ownContainer = ProviderContainer(
      overrides: [
        requestPasswordResetUseCaseProvider.overrideWithValue(requestReset),
        resetPasswordUseCaseProvider.overrideWithValue(resetPassword),
      ],
    );
    final sub = ownContainer.listen(
      passwordResetNotifierProvider,
      (_, _) {},
      fireImmediately: true,
    );

    fakeAsync((async) {
      stubSend(const ApiResult.success('Code sent.'));
      final own = ownContainer.read(passwordResetNotifierProvider.notifier);
      own.onUserNameChange(email);
      unawaited(own.sendCode());
      async.flushMicrotasks();

      sub.close();
      ownContainer.dispose();

      // The ticker fires into a disposed notifier here. It must cancel itself rather
      // than throw an UnmountedRefException from a timer nobody is holding.
      async.elapse(const Duration(seconds: 5));
    });
  });
}

