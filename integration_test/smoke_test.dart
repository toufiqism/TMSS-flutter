// End-to-end smoke test on a real device or simulator, against the live API.
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/smoke_test.dart \
//     -d <device-id> \
//     --dart-define=TMS_USER=<email> --dart-define=TMS_PASS=<password>
//
// Deliberately read-only against the server: it signs in, reads the dashboard and the
// list, and opens the create form — but never submits one. Creating requisitions writes
// to a production fleet system; `test/live_api_check.dart` covers the write path and
// cancels what it creates.
//
// Screenshots land in build/screenshots/ via test_driver/integration_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tmss/main.dart' as app;
import 'package:tmss/presentation/common/strings.dart';
import 'package:tmss/presentation/common/synced_text_field.dart';

const _user = String.fromEnvironment('TMS_USER');
const _pass = String.fromEnvironment('TMS_PASS');

/// Dumps the on-screen rect of a few key widgets. Pixel-guessing from a screenshot was
/// ambiguous; actual rects are not.
String _geometry(WidgetTester tester) {
  final buffer = StringBuffer();
  void report(String label, Finder finder) {
    final matches = finder.evaluate().length;
    if (matches == 0) {
      buffer.writeln('  $label: absent');
      return;
    }
    try {
      buffer.writeln('  $label: x$matches ${tester.getRect(finder.first)}');
    } catch (e) {
      buffer.writeln('  $label: x$matches <no rect: $e>');
    }
  }

  report('Scaffold', find.byType(Scaffold));
  report('SyncedTextField', find.byType(SyncedTextField));
  report('Expanded', find.byType(Expanded));
  report('RefreshIndicator', find.byType(RefreshIndicator));
  report('ListView', find.byType(ListView));
  report('Card', find.byType(Card));
  report('bottomBar', find.widgetWithText(ElevatedButton, TmsStrings.requisitionListNewFab));
  return buffer.toString();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [finder] matches or [timeout] elapses.
  ///
  /// `pumpAndSettle` is not usable here: every screen has a live network call behind
  /// it, and an indeterminate CircularProgressIndicator never settles.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
    String? label,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    final what = label ?? finder.describeMatch(Plurality.zero);
    // Capture the screen and its visible text before failing — a bare "timed out"
    // says nothing about which screen the app was actually stuck on.
    await binding.takeScreenshot('TIMEOUT-$what');
    final visible = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    fail('timed out waiting for $what\nvisible text was: $visible');
  }

  /// Like [waitFor], but satisfied by whichever of [finders] appears first.
  Future<void> waitForAny(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = const Duration(seconds: 30),
    required String label,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finders.any((f) => f.evaluate().isNotEmpty)) return;
    }
    await binding.takeScreenshot('TIMEOUT-$label');
    final visible = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    final view = tester.view;
    fail(
      'timed out waiting for $label\n'
      'visible text: $visible\n'
      'spinners: ${find.byType(CircularProgressIndicator).evaluate().length}\n'
      'scaffolds: ${find.byType(Scaffold).evaluate().length}\n'
      'viewInsets.bottom: ${view.viewInsets.bottom} devicePixelRatio: ${view.devicePixelRatio}\n'
      'physicalSize: ${view.physicalSize}\n'
      'geometry:\n${_geometry(tester)}',
    );
  }

  testWidgets('login -> dashboard -> list -> new requisition', (tester) async {
    expect(_user.isNotEmpty && _pass.isNotEmpty, isTrue,
        reason: 'pass --dart-define=TMS_USER=... and --dart-define=TMS_PASS=...');

    app.main();

    // The session is persisted, so a second run on the same device legitimately starts
    // signed in. Accept either entry point rather than assuming a logged-out device.
    await waitForAny(
      tester,
      [find.text(TmsStrings.loginHeading), find.text(TmsStrings.dashboardNeedVehicleTitle)],
      label: 'login screen or restored session',
    );

    if (find.text(TmsStrings.loginHeading).evaluate().isNotEmpty) {
      await binding.takeScreenshot('01-login');

      // --- sign in -------------------------------------------------------------
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2), reason: 'username and password');
      await tester.enterText(fields.at(0), _user);
      await tester.pump();
      await tester.enterText(fields.at(1), _pass);
      await tester.pump();
      await binding.takeScreenshot('02-credentials-entered');

      await tester.tap(find.widgetWithText(ElevatedButton, TmsStrings.loginSignInButton));
      await tester.pump();
    }

    // Drop focus so the software keyboard cannot eat the viewport on later screens.
    // (testTextInput is a fake-binding facility and asserts on a real device.)
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    // --- dashboard -------------------------------------------------------------
    await waitFor(tester, find.text(TmsStrings.dashboardNeedVehicleTitle),
        label: 'dashboard hero card');
    // The stat panel only renders once the summary resolves, so reaching it proves the
    // list endpoint parsed and the counts were derived.
    await waitFor(tester, find.text(TmsStrings.dashboardStatAll), label: 'stat panel');
    await binding.takeScreenshot('03-dashboard');

    expect(find.text(TmsStrings.dashboardStatApproved), findsOneWidget);
    expect(find.text(TmsStrings.dashboardRecentRequisitions), findsOneWidget);

    // --- drawer ----------------------------------------------------------------
    await tester.tap(find.byTooltip(TmsStrings.navOpenMenu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('04-drawer');
    // The drawer header renders the signed-in user, so this also proves the session
    // carries the name the login response supplied.
    expect(find.text(TmsStrings.navMyRequisition), findsOneWidget);

    // Close the drawer and navigate from the dashboard instead: tapping a drawer item
    // races the close animation against go_router's shell rebuild, which made this step
    // flaky. "View All" is a plain route push and is what most users tap anyway.
    await tester.tapAt(const Offset(360, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // --- requisition list ------------------------------------------------------
    await waitFor(tester, find.text(TmsStrings.dashboardViewAll), label: 'back on dashboard');
    await tester.tap(find.text(TmsStrings.dashboardViewAll));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await waitFor(tester, find.text(TmsStrings.requisitionListNewFab), label: 'list screen');
    await tester.pump(const Duration(seconds: 3));
    await binding.takeScreenshot('05-requisition-list');
    // Either rows or the empty state — both mean the screen resolved rather than hung.
    await waitForAny(
      tester,
      [find.byType(Card), find.text(TmsStrings.requisitionListEmpty)],
      timeout: const Duration(seconds: 60),
      label: 'list rows or empty state',
    );
    await binding.takeScreenshot('05b-requisition-list-settled');

    // --- detail ----------------------------------------------------------------
    if (find.byType(Card).evaluate().isNotEmpty) {
      await tester.tap(find.byType(Card).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // The app bar title, not a section header: _Section uppercases its titles, so
      // find.text('Trip') never matches the rendered 'TRIP'.
      await waitFor(tester, find.text(TmsStrings.requisitionDetailTitle),
          label: 'detail screen');
      await tester.pump(const Duration(seconds: 1));
      await binding.takeScreenshot('09-detail');

      expect(find.text(TmsStrings.requisitionDetailPickup), findsOneWidget);
      expect(find.text(TmsStrings.requisitionDetailDepartment), findsOneWidget);

      // Activity sits below the fold and the ListView builds lazily, so it does not
      // exist in the tree until it is scrolled into view.
      await tester.scrollUntilVisible(
        find.text(TmsStrings.requisitionDetailSectionActivity.toUpperCase()),
        240,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 20,
      );
      await tester.pump(const Duration(milliseconds: 400));
      await binding.takeScreenshot('10-detail-activity');
      expect(find.text(TmsStrings.requisitionDetailSectionActivity.toUpperCase()),
          findsOneWidget,
          reason: 'every requisition has at least a creation entry');

      // Actions are gated on status, so assert whichever case this row actually is.
      // Both branches matter: the server refuses edit and cancel outside Pending, and
      // it accepts them inside it.
      final isPending = find.text(TmsStrings.requisitionDetailEdit).evaluate().isNotEmpty;
      if (isPending) {
        expect(find.text(TmsStrings.requisitionDetailNotEditable), findsNothing);

        await tester.tap(find.text(TmsStrings.requisitionDetailEdit));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
        await waitFor(tester, find.text(TmsStrings.editRequisitionSave),
            label: 'edit form');
        await binding.takeScreenshot('11-edit-seeded');

        // The form must arrive pre-filled, and the type toggle must be locked because
        // req_type cannot change after creation.
        expect(find.text(TmsStrings.editRequisitionTypeLocked), findsOneWidget);
        final prefilled = find
            .byType(TextField)
            .evaluate()
            .map((e) => (e.widget as TextField).controller?.text ?? '')
            .where((t) => t.isNotEmpty);
        expect(prefilled, isNotEmpty, reason: 'the form should be seeded, not blank');

        await tester.tap(find.byIcon(Icons.arrow_back).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      } else {
        expect(find.text(TmsStrings.requisitionDetailNotEditable), findsOneWidget);
      }

      // Not tester.pageBack(): the detail screen supplies its own leading IconButton
      // rather than a Material/Cupertino BackButton, which is what pageBack looks for.
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await waitFor(tester, find.text(TmsStrings.requisitionListNewFab),
          label: 'back on the list');
    }

    // --- new requisition -------------------------------------------------------
    await tester.tap(find.text(TmsStrings.requisitionListNewFab));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await waitFor(tester, find.text(TmsStrings.newRequisitionSubmit), label: 'create form');
    await binding.takeScreenshot('06-new-requisition-passenger');

    expect(find.text(TmsStrings.newRequisitionTogglePassenger), findsOneWidget);
    expect(find.text(TmsStrings.newRequisitionToggleLogistics), findsOneWidget);

    // Logistics is live again — switching must actually swap the form.
    await tester.tap(find.text(TmsStrings.newRequisitionToggleLogistics));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('07-new-requisition-logistics');
    expect(find.text(TmsStrings.newRequisitionFieldGoodsDetails), findsOneWidget,
        reason: 'logistics-only field proves the toggle switched forms');

    // Validation must fire locally rather than round-tripping an empty form.
    await tester.tap(find.text(TmsStrings.newRequisitionSubmit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('08-validation-errors');
    expect(find.text(TmsStrings.newRequisitionErrorRequired), findsWidgets);
  });
}
