import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/requisition.dart';
import 'package:tracgo/domain/usecase/cancel_requisition_use_case.dart';
import 'package:tracgo/domain/usecase/get_requisition_use_case.dart';
import 'package:tracgo/domain/usecase/get_requisitions_use_case.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/presentation/common/strings.dart';
import 'package:tracgo/presentation/nav/app_shell.dart';
import 'package:tracgo/presentation/nav/route_paths.dart';
import 'package:tracgo/presentation/requisition_create/requisition_create_screen.dart';
import 'package:tracgo/presentation/requisition_detail/requisition_detail_screen.dart';
import 'package:tracgo/presentation/requisition_list/requisition_list_screen.dart';

/// Android 15+ enforces edge-to-edge for apps targeting API 35+, and this app targets
/// 36 — so the system navigation bar sits *over* the app unless its inset is honoured.
///
/// These tests pump each screen inside a MediaQuery carrying a bottom inset the size of
/// Android's navigation bar, then assert that the bottom-most content clears it. Written
/// after the requisition and detail screens shipped with their content underneath the
/// nav buttons: every screen passed an explicit `padding` to its scroll view, which
/// *replaces* the padding Flutter would otherwise derive from MediaQuery.
const _navBarInset = 48.0;

const _session = Session(
  token: 'abc',
  user: User(
    id: 'a@b.com',
    name: 'Md. Tofiq Akbar',
    designation: 'Senior Engineer',
    email: 'a@b.com',
  ),
);

class MockGetRequisitionsUseCase extends Mock implements GetRequisitionsUseCase {}

class MockCancelRequisitionUseCase extends Mock implements CancelRequisitionUseCase {}

class MockGetRequisitionUseCase extends Mock implements GetRequisitionUseCase {}

Requisition _requisition() => Requisition(
      id: 'r1',
      pickupDateTime: DateTime(2026, 8, 20, 10),
      pickupLocation: 'Head Office',
      dropLocation: 'Gulshan',
      status: RequisitionStatus.pending,
      details: const RequisitionDetails.passenger(
        usedType: UsedType.pickupAndDrop,
        customerName: 'Test',
        numberOfPersons: 1,
        requiredFor: RequiredFor.ownUser,
        purpose: 'Client meeting',
      ),
      createdAt: DateTime(2026, 8, 14),
    );

/// Wraps [child] in a viewport whose bottom [_navBarInset] is occupied by the system.
///
/// Overrides are applied by the caller: Riverpod's `Override` type lives under `src/`
/// and is not exported, so it cannot be named in a signature here.
Widget _withNavBar(Widget child) {
  // The MediaQuery must be injected via MaterialApp's `builder`, *below* the app.
  // Wrapping MaterialApp from the outside does not work: MaterialApp installs its own
  // MediaQuery derived from the test view, which discards any padding set above it —
  // so an outer wrapper silently simulates nothing.
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: const EdgeInsets.only(bottom: _navBarInset),
        viewPadding: const EdgeInsets.only(bottom: _navBarInset),
      ),
      child: child!,
    ),
    home: child,
  );
}

/// The y coordinate below which the system navigation bar is drawn.
double _navBarTop(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio - _navBarInset;

void main() {
  setUpAll(() => registerFallbackValue(const RequisitionListFilter()));

  testWidgets('the create screen submit button clears the navigation bar',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: _withNavBar(
          RequisitionCreateScreen(onBack: () {}, onSubmitted: () {}),
        ),
      ),
    );
    await tester.pump();

    final button = find.widgetWithText(
      ElevatedButton,
      TracGoStrings.newRequisitionSubmit,
    );
    expect(button, findsOneWidget);
    expect(
      tester.getRect(button).bottom,
      lessThanOrEqualTo(_navBarTop(tester)),
      reason: 'Submit must not render under the system navigation buttons',
    );
  });

  testWidgets('the requisition list bottom bar clears the navigation bar',
      (tester) async {
    final getRequisitions = MockGetRequisitionsUseCase();
    when(() => getRequisitions(any()))
        .thenAnswer((_) async => ApiResult.success([_requisition()]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getRequisitionsUseCaseProvider.overrideWithValue(getRequisitions),
          cancelRequisitionUseCaseProvider
              .overrideWithValue(MockCancelRequisitionUseCase()),
          sessionStreamProvider.overrideWith((ref) => Stream.value(_session)),
        ],
        // Nested inside AppShell exactly as the router builds it: a Scaffold inside a
        // Scaffold. Pumping the screen alone would not reproduce how MediaQuery padding
        // reaches the inner Scaffold's bottomNavigationBar.
        child: _withNavBar(
          AppShell(
            currentPath: RoutePaths.requisitionList,
            onNavigate: (_) {},
            onOpenProfile: () {},
            child: RequisitionListScreen(
              onNewRequisition: () {},
              onOpenRequisition: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final button = find.widgetWithText(
      ElevatedButton,
      TracGoStrings.requisitionListNewFab,
    );
    expect(button, findsOneWidget);
    expect(
      tester.getRect(button).bottom,
      lessThanOrEqualTo(_navBarTop(tester)),
      reason: 'the New requisition bar must sit above the navigation buttons',
    );
  });

  testWidgets('the detail screen actions clear the navigation bar', (tester) async {
    final getRequisition = MockGetRequisitionUseCase();
    when(() => getRequisition(any()))
        .thenAnswer((_) async => ApiResult.success(_requisition()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getRequisitionUseCaseProvider.overrideWithValue(getRequisition),
          cancelRequisitionUseCaseProvider
              .overrideWithValue(MockCancelRequisitionUseCase()),
        ],
        child: _withNavBar(
          RequisitionDetailScreen(
            requisitionId: 'r1',
            onBack: () {},
            onEdit: (_) {},
            onClosed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Scroll to the *end* of the list, not merely until the button appears. Any item in
    // a scrollable can be brought on screen by scrolling further; the real defect is
    // that at maximum extent the last content still sits beneath the nav bar, because
    // the scroll padding never accounted for the inset.
    final list = find.byType(Scrollable).last;
    final position = tester.state<ScrollableState>(list).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();

    expect(
      tester.getRect(find.text(TracGoStrings.requisitionDetailEdit)).bottom,
      lessThanOrEqualTo(_navBarTop(tester)),
      reason: 'Edit must be reachable, not hidden behind the navigation buttons',
    );
  });
}
