import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/common/tracgo_logo_mark.dart';
import 'package:tracgo/presentation/password_reset/password_reset_screen.dart';

/// The reset screen drops its header entirely while the keyboard is up, rather than
/// compacting it the way Sign In does: step 2 stacks a code row, two password fields, a
/// resend link and a button under it, and a merely-smaller header still leaves the
/// submit button under the keyboard.
///
/// Driven from `MediaQuery.viewInsets` rather than a real keyboard: the bottom inset is
/// the screen's only input, and a widget test is the one place both states can be
/// asserted deterministically. It does not cover the platform actually raising that
/// inset on device — that is Flutter's job, not this screen's — so a green run here is
/// not a substitute for a smoke test.
const double _keyboardInset = 320;

/// Injects [inset] as the keyboard's height.
///
/// Applied through MaterialApp's `builder`, *below* the app: wrapping MaterialApp from
/// the outside does not work, because it installs its own MediaQuery derived from the
/// test view and discards anything set above it.
Widget _withKeyboard(Widget child, {required double inset}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(viewInsets: EdgeInsets.only(bottom: inset)),
      child: child!,
    ),
    home: child,
  );
}

Future<void> _pumpReset(WidgetTester tester, {required double inset}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: _withKeyboard(
        PasswordResetScreen(onBack: () {}, onCompleted: (_) {}),
        inset: inset,
      ),
    ),
  );
  // Settles the 220ms fold, which is otherwise mid-flight.
  await tester.pumpAndSettle();
}

void main() {
  final logo = find.byType(TracGoLogoMark);
  final heading = find.text(TracGoStrings.resetHeading);
  final subtitle = find.text(TracGoStrings.resetRequestSubheading);

  testWidgets('the header is on screen while the keyboard is closed', (tester) async {
    await _pumpReset(tester, inset: 0);

    expect(logo, findsOneWidget);
    expect(heading, findsOneWidget);
    expect(subtitle, findsOneWidget);
  });

  testWidgets('the header is gone while the keyboard is open', (tester) async {
    await _pumpReset(tester, inset: _keyboardInset);

    expect(logo, findsNothing);
    expect(heading, findsNothing);
    expect(subtitle, findsNothing);
  });

  testWidgets('the back control survives the fold', (tester) async {
    // Everything else in the header goes; this one cannot, or a user who opened the
    // keyboard has no way out of the flow but the system gesture.
    await _pumpReset(tester, inset: _keyboardInset);

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('the header comes back when the keyboard closes', (tester) async {
    await _pumpReset(tester, inset: _keyboardInset);
    expect(logo, findsNothing);

    await _pumpReset(tester, inset: 0);

    expect(logo, findsOneWidget);
    expect(heading, findsOneWidget);
  });

  testWidgets('the fold is animated, not a jump', (tester) async {
    // Measured on the button rather than the header itself. The header is clipped from
    // the bottom while staying anchored at the top, so its own coordinates never move —
    // what the fold does is lift everything underneath it, and that is the effect worth
    // asserting anyway.
    final button = find.text(TracGoStrings.resetSendCodeButton);

    await _pumpReset(tester, inset: 0);
    final restingHeight = tester.getSize(find.byType(TracGoLogoMark)).height;
    final restingTop = tester.getTopLeft(button).dy;

    // Raise the keyboard and stop partway through the 220ms fold.
    await tester.pumpWidget(
      ProviderScope(
        child: _withKeyboard(
          PasswordResetScreen(onBack: () {}, onCompleted: (_) {}),
          inset: _keyboardInset,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));

    // Mid-flight: the mark is still mounted at full size — the block clips it away
    // rather than resizing it, so the artwork never distorts — and the form has already
    // begun rising.
    expect(logo, findsOneWidget);
    expect(tester.getSize(find.byType(TracGoLogoMark)).height, restingHeight);
    final midTop = tester.getTopLeft(button).dy;
    expect(midTop, lessThan(restingTop));

    await tester.pumpAndSettle();
    expect(logo, findsNothing);
    // And kept rising to the end, rather than snapping there on the first frame.
    expect(tester.getTopLeft(button).dy, lessThan(midTop));
  });
}
