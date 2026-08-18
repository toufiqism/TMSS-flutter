import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/domain/usecase/login_use_case.dart';
import 'package:tracgo/presentation/login/login_notifier.dart';
import 'package:tracgo/presentation/password_reset/password_reset_handoff.dart';
import 'package:tracgo/presentation/login/login_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late ProviderContainer container;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    container = ProviderContainer(overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)]);
    addTearDown(container.dispose);
    // isAutoDispose: hold a subscription so the notifier survives across awaits, the
    // same way the mounted LoginScreen does.
    container.listen(loginNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  const session = Session(
    token: 'abc',
    user: User(id: '1', name: 'Md. Tofiq Akbar', designation: 'Senior Engineer', email: 'tofiq.akbar@btracsl.com'),
  );

  test('submit with blank fields sets a validation error without calling the use case', () async {
    final notifier = container.read(loginNotifierProvider.notifier);

    await notifier.submit();

    expect(container.read(loginNotifierProvider).errorMessage, isNotNull);
    verifyNever(() => mockLoginUseCase(any(), any()));
  });

  test('submit with valid credentials succeeds and emits NavigateToDashboard', () async {
    when(() => mockLoginUseCase(any(), any())).thenAnswer((_) async => const ApiResult.success(session));
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    final events = <LoginEvent>[];
    final sub = notifier.events.listen(events.add);

    await notifier.submit();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(loginNotifierProvider).isLoading, isFalse);
    expect(container.read(loginNotifierProvider).errorMessage, isNull);
    expect(events, [isA<NavigateToDashboard>()]);
    await sub.cancel();
  });

  test('submit with invalid credentials surfaces the error message', () async {
    when(() => mockLoginUseCase(any(), any()))
        .thenAnswer((_) async => const ApiResult.error('Username/Password is invalid!'));
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('wrong@example.com');
    notifier.onPasswordChange('wrong');

    await notifier.submit();

    final state = container.read(loginNotifierProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, 'Username/Password is invalid!');
  });

  test('submit under maintenance surfaces the maintenance message', () async {
    when(() => mockLoginUseCase(any(), any()))
        .thenAnswer((_) async => const ApiResult.maintenance('Under maintenance', 503));
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    await notifier.submit();

    final state = container.read(loginNotifierProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, 'Under maintenance');
  });

  test('a logout result on login is shown inline, not swallowed', () async {
    when(() => mockLoginUseCase(any(), any()))
        .thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    await notifier.submit();

    expect(container.read(loginNotifierProvider).errorMessage, 'Session expired');
  });

  test('the password is dropped from state once login succeeds', () async {
    // It must not linger in memory, nor repopulate the field if the user is bounced
    // back to this screen.
    when(() => mockLoginUseCase(any(), any()))
        .thenAnswer((_) async => const ApiResult.success(session));
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    await notifier.submit();

    expect(container.read(loginNotifierProvider).password, isEmpty);
  });

  test('a second submit while one is in flight is ignored', () async {
    when(() => mockLoginUseCase(any(), any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const ApiResult.success(session);
    });
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    await Future.wait([notifier.submit(), notifier.submit()]);

    verify(() => mockLoginUseCase(any(), any())).called(1);
  });

  test('submit while offline surfaces the offline message', () async {
    when(() => mockLoginUseCase(any(), any())).thenAnswer((_) async => const ApiResult.offline());
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onUsernameChange('tofiq.akbar@btracsl.com');
    notifier.onPasswordChange('demo1234');

    await notifier.submit();

    expect(container.read(loginNotifierProvider).errorMessage, 'No internet connection available');
  });

  // ---------------------------------------------------------------------------------
  // Handoff from the password-reset flow
  // ---------------------------------------------------------------------------------

  test('a staged reset email prefills the username and the note on first build',
      () async {
    // Its own container: the shared one in setUp already built the notifier, which is
    // the very act being tested here.
    final ownContainer = ProviderContainer(
      overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
    );
    addTearDown(ownContainer.dispose);
    ownContainer
        .read(passwordResetHandoffProvider)
        .stage('tofiq.akbar@btracsl.com');
    ownContainer.listen(loginNotifierProvider, (_, _) {}, fireImmediately: true);

    final built = ownContainer.read(loginNotifierProvider);
    expect(built.username, 'tofiq.akbar@btracsl.com');
    expect(built.infoMessage, isNotNull);
    expect(built.password, isEmpty);
    // Delivered once: the slot is empty afterwards, so a later visit to Login is not
    // greeted by a stale "password updated" note.
    expect(ownContainer.read(passwordResetHandoffProvider).isStaged, isFalse);
  });

  test('an empty handoff leaves the login form untouched', () async {
    expect(container.read(loginNotifierProvider), const LoginUiState());
  });

  test('the reset note is cleared as soon as the user types', () async {
    final notifier = container.read(loginNotifierProvider.notifier);
    notifier.onPasswordResetComplete('tofiq.akbar@btracsl.com');
    expect(container.read(loginNotifierProvider).infoMessage, isNotNull);

    notifier.onPasswordChange('demo1234');

    expect(container.read(loginNotifierProvider).infoMessage, isNull);
    // The prefilled username survives; it is the part the user should not retype.
    expect(container.read(loginNotifierProvider).username, 'tofiq.akbar@btracsl.com');
  });
}
