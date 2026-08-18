import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/common/auth_form_controls.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/password_reset/password_reset_notifier.dart';
import 'package:tracgo/presentation/password_reset/password_reset_screen.dart';

/// The Profile entry point's two visible differences: the email arrives already filled
/// in, because the signed-in account's address is known, and it is locked there, because
/// that is the only account this flow may reset.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    // The notifier is auto-dispose; hold it the way the mounted screen does so reading
    // its state from the test does not create and discard a second instance.
    container.listen(passwordResetNotifierProvider, (_, _) {}, fireImmediately: true);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    String? initialEmail,
    bool lockEmail = false,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: PasswordResetScreen(
            onBack: () {},
            onCompleted: (_) {},
            initialEmail: initialEmail,
            lockEmail: lockEmail,
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

  testWidgets('the Profile flow renders the email as a locked row, not an input',
      (tester) async {
    await pumpScreen(
      tester,
      initialEmail: 'tofiq.akbar@btracsl.com',
      lockEmail: true,
    );

    expect(find.byType(AuthReadOnlyField), findsOneWidget);
    // Step 1 has exactly one field, so a locked row means no text input at all.
    expect(find.byType(AuthUnderlinedField), findsNothing);
    expect(find.text('tofiq.akbar@btracsl.com'), findsOneWidget);
    expect(find.text(TracGoStrings.resetEmailLockedNote), findsOneWidget);
  });

  testWidgets('a locked seed overrides an address already in the notifier',
      (tester) async {
    container
        .read(passwordResetNotifierProvider.notifier)
        .onUserNameChange('someone.else@btracsl.com');

    await pumpScreen(
      tester,
      initialEmail: 'tofiq.akbar@btracsl.com',
      lockEmail: true,
    );

    expect(
      container.read(passwordResetNotifierProvider).userName,
      'tofiq.akbar@btracsl.com',
    );
  });

  testWidgets('a lock with no address falls back to an editable field',
      (tester) async {
    // The session exists but carries a blank email. Locking an empty row would leave
    // the user with nothing to send a code to and no way to type one.
    await pumpScreen(tester, initialEmail: '   ', lockEmail: true);

    expect(find.byType(AuthReadOnlyField), findsNothing);
    expect(find.byType(AuthUnderlinedField), findsOneWidget);
  });
}
