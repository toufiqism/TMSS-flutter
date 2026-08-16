import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/core/session_expiration_handler.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/domain/usecase/get_user_account_use_case.dart';
import 'package:tracgo/presentation/profile/profile_notifier.dart';
import 'package:tracgo/presentation/profile/profile_state.dart';

class MockGetUserAccountUseCase extends Mock implements GetUserAccountUseCase {}

class MockSessionExpirationHandler extends Mock implements SessionExpirationHandler {}

const _account = UserAccount(
  id: '864',
  email: 'tofiq.akbar@btracsl.com',
  employeeId: '3035',
  roleId: '1',
  activeStatus: 'Active',
);

void main() {
  late MockGetUserAccountUseCase mockGetAccount;
  late MockSessionExpirationHandler mockSessionExpiration;
  late ProviderContainer container;

  setUp(() {
    mockGetAccount = MockGetUserAccountUseCase();
    mockSessionExpiration = MockSessionExpirationHandler();
    when(() => mockSessionExpiration.handle()).thenAnswer((_) async {});
    container = ProviderContainer(overrides: [
      getUserAccountUseCaseProvider.overrideWithValue(mockGetAccount),
      sessionExpirationHandlerProvider.overrideWithValue(mockSessionExpiration),
    ]);
    addTearDown(container.dispose);
    container.listen(profileNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  test('starts loading and exposes nothing until /user answers', () async {
    final accountCall = Completer<ApiResult<UserAccount>>();
    when(() => mockGetAccount()).thenAnswer((_) => accountCall.future);

    final loading = container.read(profileNotifierProvider.notifier).load();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(profileNotifierProvider);
    expect(state.isLoading, isTrue);
    expect(state.account, isNull);

    accountCall.complete(const ApiResult.success(_account));
    await loading;
  });

  test('a successful load exposes the account', () async {
    when(() => mockGetAccount()).thenAnswer((_) async => const ApiResult.success(_account));

    await container.read(profileNotifierProvider.notifier).load();

    final state = container.read(profileNotifierProvider);
    expect(state.isLoading, isFalse);
    expect(state.account?.employeeId, '3035');
    expect(state.account?.activeStatus, 'Active');
    expect(state.errorMessage, isNull);
  });

  test('a failed fetch reports itself without inventing an account', () async {
    // Identity is rendered from the session by the screen, so a failure here degrades
    // only the account block.
    when(() => mockGetAccount()).thenAnswer((_) async => const ApiResult.offline());

    await container.read(profileNotifierProvider.notifier).load();

    final state = container.read(profileNotifierProvider);
    expect(state.account, isNull);
    expect(state.errorMessage, 'No internet connection available');
    expect(state.isLoading, isFalse);
  });

  test('a 403 is terminal, so Retry is withheld', () async {
    when(() => mockGetAccount())
        .thenAnswer((_) async => const ApiResult.error('Forbidden', 403));

    await container.read(profileNotifierProvider.notifier).load();

    expect(container.read(profileNotifierProvider).canRetry, isFalse);
  });

  test('a generic error keeps Retry available', () async {
    when(() => mockGetAccount())
        .thenAnswer((_) async => const ApiResult.error('boom', 500));

    await container.read(profileNotifierProvider.notifier).load();

    final state = container.read(profileNotifierProvider);
    expect(state.canRetry, isTrue);
    expect(state.errorMessage, 'boom');
  });

  test('maintenance surfaces its message', () async {
    when(() => mockGetAccount())
        .thenAnswer((_) async => const ApiResult.maintenance('Under maintenance', 503));

    await container.read(profileNotifierProvider.notifier).load();

    expect(container.read(profileNotifierProvider).errorMessage, 'Under maintenance');
  });

  test('logout triggers the session handler and emits SessionExpired', () async {
    when(() => mockGetAccount())
        .thenAnswer((_) async => const ApiResult.logout('Session expired', 401));
    final notifier = container.read(profileNotifierProvider.notifier);
    final events = <ProfileEvent>[];
    final sub = notifier.events.listen(events.add);

    await notifier.load();
    await Future<void>.delayed(Duration.zero);

    verify(() => mockSessionExpiration.handle()).called(1);
    expect(events, [isA<ProfileSessionExpired>()]);
    await sub.cancel();
  });

  test('retrying clears the previous error before re-fetching', () async {
    when(() => mockGetAccount()).thenAnswer((_) async => const ApiResult.error('boom'));
    final notifier = container.read(profileNotifierProvider.notifier);
    await notifier.load();
    expect(container.read(profileNotifierProvider).errorMessage, isNotNull);

    when(() => mockGetAccount()).thenAnswer((_) async => const ApiResult.success(_account));
    await notifier.load();

    final state = container.read(profileNotifierProvider);
    expect(state.errorMessage, isNull);
    expect(state.account?.employeeId, '3035');
  });
}
