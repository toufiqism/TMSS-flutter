import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/common/tracgo_logo_mark.dart';
import 'package:tracgo/presentation/login/login_screen.dart';

/// A software keyboard covers roughly half a phone. At the resting logo size the sign-in
/// button lands under it, so the header compacts while the keyboard is up.
///
/// These tests drive that from `MediaQuery.viewInsets` rather than a real keyboard: the
/// screen's only input is the bottom inset, and a widget test is the one place both
/// states can be asserted deterministically. What they do *not* cover is the platform
/// keyboard actually raising that inset on device — that is Flutter's job, not this
/// screen's, but it does mean a green run here is not a substitute for a smoke test.
const double _keyboardInset = 320;

/// Mirrors the private constants in `login_screen.dart`. Duplicated on purpose: if
/// someone retunes them, this test should fail and be re-read, not silently follow.
const double _restingLogoSize = 108;
const double _compactLogoSize = 64;

/// Logo shrinkage (108 → 64) plus the gap under it (44 → 20).
const double _expectedLift = 68;

/// Injects [inset] as the keyboard's height.
///
/// Applied through MaterialApp's `builder`, *below* the app: wrapping MaterialApp from
/// the outside does not work, because it installs its own MediaQuery derived from the
/// test view and discards anything set above it.
Widget _withKeyboard(Widget child, {required double inset}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.only(bottom: inset),
      ),
      child: child!,
    ),
    home: child,
  );
}

Future<void> _pumpLogin(WidgetTester tester, {required double inset}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: _withKeyboard(
        LoginScreen(onLoginSuccess: () {}),
        inset: inset,
      ),
    ),
  );
  // Settles the header's 220ms compaction tween, which is otherwise mid-flight.
  await tester.pumpAndSettle();
}

double _logoSize(WidgetTester tester) =>
    tester.widget<TracGoLogoMark>(find.byType(TracGoLogoMark)).size;

double _headlineTop(WidgetTester tester) =>
    tester.getRect(find.text(TracGoStrings.loginHeading)).top;

void main() {
  testWidgets('the logo keeps its full size while the keyboard is closed',
      (tester) async {
    await _pumpLogin(tester, inset: 0);

    expect(_logoSize(tester), _restingLogoSize);
  });

  testWidgets('the logo shrinks while the keyboard is open', (tester) async {
    await _pumpLogin(tester, inset: _keyboardInset);

    expect(_logoSize(tester), _compactLogoSize);
  });

  testWidgets('opening the keyboard lifts the form and closing it restores the header',
      (tester) async {
    await _pumpLogin(tester, inset: 0);
    final restingHeadlineTop = _headlineTop(tester);

    // Re-pumped rather than rebuilt from scratch: the element tree survives, so the
    // header tweens from its resting size exactly as it does when the keyboard opens.
    await _pumpLogin(tester, inset: _keyboardInset);

    expect(_logoSize(tester), _compactLogoSize);
    expect(
      restingHeadlineTop - _headlineTop(tester),
      closeTo(_expectedLift, 0.5),
      reason: 'the fields below must gain the space the header gave up',
    );

    // The compaction is a response to the keyboard, not a one-way trip.
    await _pumpLogin(tester, inset: 0);

    expect(_logoSize(tester), _restingLogoSize);
    expect(_headlineTop(tester), closeTo(restingHeadlineTop, 0.5));
  });

  testWidgets('the sign-in button stays reachable above the keyboard', (tester) async {
    await _pumpLogin(tester, inset: _keyboardInset);

    final viewportBottom =
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
            _keyboardInset;
    final button = find.widgetWithText(
      ElevatedButton,
      TracGoStrings.loginSignInButton,
    );
    expect(button, findsOneWidget);

    // Scrolling to the end must actually reach it. The screen previously padded the
    // scroll view by the keyboard's height *on top of* the Scaffold already resizing for
    // it, which left a screenful of empty scrollable space below the form.
    final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();

    expect(tester.getRect(button).bottom, lessThanOrEqualTo(viewportBottom));
  });
}
