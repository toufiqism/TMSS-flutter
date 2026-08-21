// Captures the App Store screenshots by driving the real app on a real simulator.
//
//     python3 tool/store/mock_api_server.py 8099          # terminal 1
//     ./tool/store/capture_ios_screenshots.sh             # terminal 2
//
// Not a test of anything — it asserts only enough to fail loudly when a screen it wants
// never arrives, because a green run that silently captured six copies of a spinner is
// worse than a red one.
//
// Why the app drives itself instead of being tapped from outside: this Mac has no way to
// inject input into the iOS Simulator (no `idb`, no assistive access for `osascript`,
// and `xcrun simctl` offers only `io`/`ui`/`keychain`). The Android pipeline in
// docs/play/graphics/README.md uses `adb shell input tap`; there is no iOS equivalent,
// so navigation happens through the app's own GoRouter.
//
// Every name, plate and record in the captures comes from tool/store/mock_api_server.py.
// The live account may not be used: it holds a real employee's name, ID and phone plus
// real business records, none of which may be published to a store listing.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/main.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/nav/app_router.dart';
import 'package:tracgo/presentation/nav/route_paths.dart';

/// The mock's employee directory, not a real address. The mock accepts any credentials —
/// this pair exists so the Sign In capture shows a filled, plausible form.
const _username = 'nusrat.jahan@btracsolutions.com';
const _password = 'demo1234';

/// `Vehicle Assigned` in the mock's fixture set, so its detail screen carries the
/// vehicle and driver block that the list never shows. See mock_api_server.py:110.
const _assignedRequisitionId = '4817';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots', (tester) async {
    // Android needs the Flutter surface converted before it can be read back; iOS
    // neither needs nor supports it, and calling it there throws.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TracGoApp(),
      ),
    );

    // A session survives between runs — the Keychain outlives an app *launch*, and on
    // iOS it outlives an uninstall too. Clear it so the run always starts at Sign In
    // rather than skipping that capture on every run after the first.
    await container.read(logoutUseCaseProvider).call();
    await _settle(tester);

    await _capture(binding, tester, '06-login', marker: TracGoStrings.loginSignInButton);

    // -- sign in ------------------------------------------------------------------
    final fields = find.byType(TextField);
    expect(
      fields,
      findsNWidgets(2),
      reason: 'Sign In should have exactly a username and a password field',
    );
    await tester.enterText(fields.at(0), _username);
    await _settle(tester);
    await tester.enterText(fields.at(1), _password);
    await _settle(tester);

    await tester.tap(find.text(TracGoStrings.loginSignInButton));
    await _settle(tester, rounds: 40);

    await _capture(
      binding,
      tester,
      '01-dashboard',
      marker: TracGoStrings.dashboardRecentRequisitions,
    );

    // -- the rest, by route rather than by tap ------------------------------------
    // Tapping would work, but every added tap is another coordinate that a layout
    // change silently invalidates. `go` lands on the same screens with the same data.
    final router = container.read(goRouterProvider);

    router.go(RoutePaths.requisitionList);
    await _settle(tester, rounds: 40);
    await _capture(binding, tester, '04-list');

    router.go(RoutePaths.detailFor(_assignedRequisitionId));
    await _settle(tester, rounds: 40);
    await _capture(binding, tester, '03-detail-assigned');

    router.go(RoutePaths.newRequisition);
    await _settle(tester, rounds: 40);
    await _capture(
      binding,
      tester,
      '02-new-passenger',
      marker: TracGoStrings.newRequisitionSectionTripDetails,
    );

    // The Logistics variant is the same route with the type toggle flipped, so this one
    // genuinely does need a tap.
    final logistics = _text(TracGoStrings.newRequisitionToggleLogistics);
    expect(logistics, findsWidgets, reason: 'type toggle missing from the create form');
    await tester.tap(logistics.first);
    await _settle(tester, rounds: 20);
    await _capture(
      binding,
      tester,
      '05-logistics',
      marker: TracGoStrings.newRequisitionSectionVehicleDetails,
    );
  });
}

/// Pumps in slices instead of `pumpAndSettle`.
///
/// `pumpAndSettle` throws the moment the tree never reaches a quiet frame, and several
/// of these screens are legitimately never quiet: a loading spinner and the pill
/// toggle's ripple both animate indefinitely. Real network calls to the mock also need
/// wall-clock time to come back, which a settle loop does not grant.
Future<void> _settle(WidgetTester tester, {int rounds = 12}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Writes one screenshot, after asserting the screen actually arrived.
///
/// The assertion is the point: without it a slow mock or a renamed route yields a
/// perfectly valid PNG of the previous screen, and the mistake is only caught by eye at
/// upload time.
Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name, {
  String? marker,
}) async {
  if (marker != null) {
    if (_text(marker).evaluate().isEmpty) {
      // Give a slow response one more chance before failing — the first dashboard fetch
      // after sign-in is the slowest thing in the run.
      await _settle(tester, rounds: 40);
    }
    await expectLater(
      _text(marker),
      findsWidgets,
      reason: '$name: expected "$marker" on screen before capturing',
    );
  }
  await binding.takeScreenshot(name);
}

/// Finds visible text, allowing for the uppercasing that `SectionLabel` applies.
///
/// The section captions are passed in sentence case and rendered `toUpperCase()`, with
/// the readable string kept as the semantics label — so `find.text('Trip Details')`
/// matches nothing on a screen that plainly shows "TRIP DETAILS".
Finder _text(String value) {
  final asWritten = find.text(value);
  return asWritten.evaluate().isNotEmpty ? asWritten : find.text(value.toUpperCase());
}
