import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/common/strings.dart';

/// The drawer footer's version caption is a hand-kept constant.
///
/// Deliberately not `package_info_plus`: that caption is the only thing in the app that
/// would need it, and it would pull a platform channel into a screen that otherwise
/// renders entirely offline. The cost of the constant is that it drifts from
/// `pubspec.yaml` the first time someone bumps a release and forgets — silently, and on
/// exactly the screen a support call starts from.
///
/// This test is what makes the drift loud instead. It reads the pubspec the same way the
/// build does and asserts the two agree.
void main() {
  test('the drawer version caption matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml');
    expect(
      pubspec.existsSync(),
      isTrue,
      reason: 'tests are expected to run from the package root',
    );

    // `version: 1.0.0+1` — the caption shows the name only, not the build number, so the
    // `+N` suffix is captured separately and ignored.
    final match = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)(\+\d+)?\s*$',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());

    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml must declare a version line the build can read',
    );

    expect(
      TracGoStrings.appVersionLabel,
      'v${match!.group(1)}',
      reason:
          'TracGoStrings.appVersionLabel has drifted from pubspec.yaml — bump both, '
          'or the drawer will report the previous release to users and to support.',
    );
  });
}
