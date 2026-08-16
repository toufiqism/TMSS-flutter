import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/employee.dart';
import 'package:tracgo/domain/usecase/search_employees_use_case.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/requisition_create/requisition_create_screen.dart';

/// The create form is long and every field on it opens a keyboard. Two things have to
/// hold while that keyboard is up: the pinned Submit button must stop spending ~86px of
/// a halved viewport on a control nobody is reaching for mid-typing, and the rider
/// dropdown — which opens *below* its search field, the one thing Flutter scrolls into
/// view on focus — must not render into the covered strip.
///
/// Driven from `MediaQuery.viewInsets` rather than a real keyboard, so this proves the
/// screen's response to the inset and not the platform raising it.
const double _keyboardInset = 320;

/// Synthetic, matching the rule that no real directory data goes in source.
const _employees = [
  Employee(
    id: '1',
    name: 'Tofiq Akbar',
    employeeCode: 'E-1',
    designation: 'Senior Engineer',
    department: 'Engineering',
    company: 'BTracSL',
  ),
  Employee(
    id: '2',
    name: 'Tanvir Hasan',
    employeeCode: 'E-2',
    designation: 'Analyst',
    department: 'Operations',
    company: 'BTracSL',
  ),
];

class MockSearchEmployeesUseCase extends Mock implements SearchEmployeesUseCase {}

/// Injects [inset] as the keyboard's height, below the app — see the note in
/// `login_keyboard_test.dart` for why an outer wrapper silently simulates nothing.
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

Future<void> _pumpCreate(
  WidgetTester tester, {
  required double inset,
  SearchEmployeesUseCase? searchEmployees,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (searchEmployees != null)
          searchEmployeesUseCaseProvider.overrideWithValue(searchEmployees),
      ],
      child: _withKeyboard(
        RequisitionCreateScreen(onBack: () {}, onSubmitted: () {}),
        inset: inset,
      ),
    ),
  );
  // The screen seeds itself from a post-frame callback, so one pump is not enough.
  await tester.pump();
  await tester.pump();
}

Finder get _submitButton => find.widgetWithText(
      ElevatedButton,
      TracGoStrings.newRequisitionSubmit,
    );

double _viewportBottom(WidgetTester tester, double inset) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio - inset;

void main() {
  testWidgets('submit stays pinned below the form while the keyboard is closed',
      (tester) async {
    await _pumpCreate(tester, inset: 0);

    expect(_submitButton, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: _submitButton,
      ),
      findsNothing,
      reason: 'with room to spare Submit is a fixed footer, not form content',
    );
    // Pinned means pinned: it sits at the bottom of the screen, not wherever the form
    // happens to end.
    expect(
      tester.getRect(_submitButton).bottom,
      closeTo(_viewportBottom(tester, 0), 20),
    );
  });

  testWidgets('submit moves into the form while the keyboard is open', (tester) async {
    await _pumpCreate(tester, inset: _keyboardInset);

    expect(
      _submitButton,
      findsOneWidget,
      reason: 'exactly one Submit — the two placements must never both be mounted',
    );
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: _submitButton,
      ),
      findsOneWidget,
    );
  });

  testWidgets('the form gets the pinned footer\'s height back when the keyboard opens',
      (tester) async {
    await _pumpCreate(tester, inset: 0);
    final restingScrollBottom =
        tester.getRect(find.byType(SingleChildScrollView)).bottom;
    // The footer's own height: the gap between where the form stops and the screen ends.
    final footerHeight = _viewportBottom(tester, 0) - restingScrollBottom;
    expect(footerHeight, greaterThan(0));

    await _pumpCreate(tester, inset: _keyboardInset);

    expect(
      tester.getRect(find.byType(SingleChildScrollView)).bottom,
      closeTo(_viewportBottom(tester, _keyboardInset), 0.5),
      reason: 'nothing may sit between the form and the keyboard any more',
    );
  });

  testWidgets('the rider dropdown is scrolled above the keyboard when results land',
      (tester) async {
    final searchEmployees = MockSearchEmployeesUseCase();
    when(() => searchEmployees(any()))
        .thenAnswer((_) async => const ApiResult.success(_employees));

    await _pumpCreate(
      tester,
      inset: _keyboardInset,
      searchEmployees: searchEmployees,
    );

    final searchField = find.widgetWithText(
      TextField,
      TracGoStrings.newRequisitionHintEmployeeSearch,
    );
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'ta');
    // Past the notifier's 300ms search debounce, then through the reveal's own 220ms
    // scroll animation.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    final match = find.text(_employees.first.name);
    expect(match, findsOneWidget, reason: 'the dropdown must be open at all');
    expect(
      tester.getRect(match).bottom,
      lessThanOrEqualTo(_viewportBottom(tester, _keyboardInset)),
      reason: 'matches rendered under the keyboard read as "the search did nothing"',
    );
  });
}
