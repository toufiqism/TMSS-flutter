import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/di/providers.dart';
import 'package:tmss/domain/model/user.dart';
import 'package:tmss/presentation/common/strings.dart';
import 'package:tmss/presentation/nav/app_shell.dart';
import 'package:tmss/presentation/nav/route_paths.dart';

/// Widget tests for the shell chrome, added for one specific reason: the profile icon
/// shipped wired to `onPressed: () {}`.
///
/// The callback was declared on the widget, passed in by the router, and never invoked —
/// so tapping Profile did nothing. `flutter analyze` cannot catch that; an unused final
/// field on a public widget is legal Dart. Only pressing the button finds it.
const _session = Session(
  token: 'abc',
  user: User(
    id: 'tofiq.akbar@btracsl.com',
    name: 'Md. Tofiq Akbar',
    designation: 'Senior Engineer',
    email: 'tofiq.akbar@btracsl.com',
  ),
);

Widget _shell({
  required VoidCallback onOpenProfile,
  ValueChanged<String>? onNavigate,
}) {
  return ProviderScope(
    overrides: [
      sessionStreamProvider.overrideWith((ref) => Stream.value(_session)),
    ],
    child: MaterialApp(
      home: AppShell(
        currentPath: RoutePaths.dashboard,
        onNavigate: onNavigate ?? (_) {},
        onOpenProfile: onOpenProfile,
        child: const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping the profile icon invokes onOpenProfile', (tester) async {
    var opened = 0;
    await tester.pumpWidget(_shell(onOpenProfile: () => opened++));
    await tester.pump();

    await tester.tap(find.byTooltip(TmsStrings.navProfile));
    await tester.pump();

    expect(opened, 1, reason: 'the icon must actually call its callback');
  });

  testWidgets('the drawer routes to the requisition list', (tester) async {
    final navigated = <String>[];
    await tester.pumpWidget(
      _shell(onOpenProfile: () {}, onNavigate: navigated.add),
    );
    await tester.pump();

    await tester.tap(find.byTooltip(TmsStrings.navOpenMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TmsStrings.navMyRequisition));
    await tester.pumpAndSettle();

    expect(navigated, [RoutePaths.requisitionList]);
  });

  testWidgets('the drawer header renders the signed-in user', (tester) async {
    await tester.pumpWidget(_shell(onOpenProfile: () {}));
    await tester.pump();

    await tester.tap(find.byTooltip(TmsStrings.navOpenMenu));
    await tester.pumpAndSettle();

    expect(find.text('Md. Tofiq Akbar'), findsOneWidget);
    expect(find.text('Senior Engineer'), findsOneWidget);
    // Initials skip the honorific: "Md. Tofiq Akbar" is TA, not MT.
    expect(find.text('TA'), findsOneWidget);
  });
}
