import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/password_reset/password_reset_notifier.dart';
import 'package:tracgo/presentation/password_reset/password_reset_screen.dart';

/// The Profile entry point's one visible difference: the email arrives already filled
/// in, because the signed-in account's address is known.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    // The notifier is auto-dispose; hold it the way the mounted screen does so reading
    // its state from the test does not create and discard a second instance.
    container.listen(passwordResetNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  Future<void> pumpScreen(WidgetTester tester, {String? initialEmail}) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: PasswordResetScreen(
            onBack: () {},
            onCompleted: (_) {},
            initialEmail: initialEmail,
          ),
        ),
      ),
    );
    // The seed runs in a post-frame callback, alongside the event subscription.
    await tester.pump();
  }

  testWidgets('an initial email seeds the field, trimmed', (tester) async {
    await pumpScreen(tester, initialEmail: '  tofiq.akbar@btracsl.com  ');

    expect(
      container.read(passwordResetNotifierProvider).userName,
      'tofiq.akbar@btracsl.com',
    );
  });

  testWidgets('no initial email leaves the field empty', (tester) async {
    await pumpScreen(tester);

    expect(container.read(passwordResetNotifierProvider).userName, isEmpty);
  });

  testWidgets('a seed never overwrites an address the user already entered',
      (tester) async {
    container
        .read(passwordResetNotifierProvider.notifier)
        .onUserNameChange('someone.else@btracsl.com');

    await pumpScreen(tester, initialEmail: 'tofiq.akbar@btracsl.com');

    expect(
      container.read(passwordResetNotifierProvider).userName,
      'someone.else@btracsl.com',
    );
  });
}
