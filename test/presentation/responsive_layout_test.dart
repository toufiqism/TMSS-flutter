import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracgo/core/api_result.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/employee.dart';
import 'package:tracgo/domain/model/requisition.dart';
import 'package:tracgo/domain/model/user.dart';
import 'package:tracgo/domain/usecase/cancel_requisition_use_case.dart';
import 'package:tracgo/domain/usecase/get_dashboard_summary_use_case.dart';
import 'package:tracgo/domain/usecase/get_requisition_use_case.dart';
import 'package:tracgo/domain/usecase/get_requisitions_use_case.dart';
import 'package:tracgo/domain/usecase/get_user_account_use_case.dart';
import 'package:tracgo/domain/usecase/search_employees_use_case.dart';
import 'package:tracgo/presentation/common/page_width.dart';
import 'package:tracgo/presentation/common/surface_card.dart';
import 'package:tracgo/presentation/dashboard/dashboard_screen.dart';
import 'package:tracgo/presentation/login/login_screen.dart';
import 'package:tracgo/presentation/nav/app_shell.dart';
import 'package:tracgo/presentation/password_reset/password_reset_notifier.dart';
import 'package:tracgo/presentation/password_reset/password_reset_screen.dart';
import 'package:tracgo/presentation/password_reset/password_reset_state.dart';
import 'package:tracgo/presentation/nav/route_paths.dart';
import 'package:tracgo/presentation/profile/profile_screen.dart';
import 'package:tracgo/presentation/requisition_create/requisition_create_screen.dart';
import 'package:tracgo/presentation/requisition_detail/requisition_detail_screen.dart';
import 'package:tracgo/presentation/requisition_list/requisition_list_screen.dart';

/// Every screen, at every surface the app now ships on.
///
/// The app was a portrait-phone design that shipped with `TARGETED_DEVICE_FAMILY = "1,2"`
/// and landscape enabled in `Info.plist` — so App Review runs it on an iPad, in landscape,
/// and in Split View, none of which anything had ever rendered at. The rest of the suite
/// is platform-agnostic and never varies surface size, so it proves none of this: a
/// notifier test passes identically whether the layout fits or overflows by 400px.
///
/// What these assert is narrow and mechanical — that no `RenderFlex` overflows and no
/// layout assertion fires. That is not the same as the result looking *good*, which only
/// a human on a device can judge. It is the part that can be automated, and it is the part
/// that regressed silently before.
///
/// Overflow surfaces as a `FlutterError` reported during paint, which the test binding
/// records; `tester.takeException()` is what turns it into a legible failure here.

/// Logical size of each surface, at a device pixel ratio of 1 so logical == physical.
class _Surface {
  const _Surface(this.name, this.size);

  final String name;
  final Size size;
}

const _surfaces = <_Surface>[
  // iPhone 15 Pro, both ways up.
  _Surface('iPhone portrait', Size(393, 852)),
  _Surface('iPhone landscape', Size(852, 393)),
  // iPad Pro 11", both ways up.
  _Surface('iPad portrait', Size(834, 1194)),
  _Surface('iPad landscape', Size(1194, 834)),
  // iPad multitasking. A 1/3 Split View is narrower than any phone this app supports,
  // which is exactly why it is here: the width helper widens gutters and must leave a
  // window this narrow completely alone.
  _Surface('iPad Split View 1/3', Size(320, 1194)),
  _Surface('iPad Slide Over', Size(375, 1133)),
];

/// The largest text scale iOS offers is roughly 3.1x. 2.0 is where these run by default:
/// far enough past 1.0 to catch a Row that was never going to wrap, close enough that a
/// failure is a real defect rather than a design that was never meant to survive it.
const _largeTextScale = 2.0;

const _session = Session(
  token: 'abc',
  user: User(
    id: 'tofiq.akbar@btracsl.com',
    name: 'Md. Tofiq Akbar',
    designation: 'Senior Engineer',
    email: 'tofiq.akbar@btracsl.com',
  ),
);

class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

class MockGetRequisitionsUseCase extends Mock implements GetRequisitionsUseCase {}

class MockGetRequisitionUseCase extends Mock implements GetRequisitionUseCase {}

class MockCancelRequisitionUseCase extends Mock
    implements CancelRequisitionUseCase {}

class MockGetUserAccountUseCase extends Mock implements GetUserAccountUseCase {}

class MockSearchEmployeesUseCase extends Mock implements SearchEmployeesUseCase {}

/// Deliberately verbose values. Short strings fit anywhere; the defects this is looking
/// for only appear when a label is long enough to need the space it does not have.
Requisition _requisition({String id = 'r1'}) => Requisition(
  id: id,
  pickupDateTime: DateTime(2026, 8, 20, 10, 30),
  pickupLocation: 'B-Trac Solutions Head Office, Tejgaon Industrial Area',
  dropLocation: 'Hazrat Shahjalal International Airport, Terminal 2',
  status: RequisitionStatus.pending,
  details: const RequisitionDetails.passenger(
    usedType: UsedType.pickupAndDrop,
    customerName: 'Md. Tofiq Akbar',
    numberOfPersons: 3,
    requiredFor: RequiredFor.ownUser,
    purpose: 'Client meeting and airport transfer for the visiting delegation',
  ),
  createdAt: DateTime(2026, 8, 14),
);

DashboardSummary _summary() => DashboardSummary(
  allCount: 128,
  approvedCount: 42,
  assignedCount: 17,
  pendingCount: 63,
  rejectedCount: 6,
  recentRequisitions: [
    _requisition(id: 'r1'),
    _requisition(id: 'r2'),
    _requisition(id: 'r3'),
  ],
);

/// Builds the provider graph every screen under test needs.
///
/// One list for all of them rather than a tailored set per screen: an override nothing
/// reads costs nothing, and a missing one fails as a confusing timeout inside a notifier
/// rather than as a clear message here.
///
/// A closure rather than a function declaration, and deliberately so.
///
/// Riverpod's `Override` is a sealed class in `riverpod/src/core/override.dart` and is not
/// exported, so it cannot be named in a signature. Omitting the return type does not help:
/// Dart infers return types for *closures*, but a function declaration with no return type
/// is `dynamic`, which compiles here and then fails at the call site with
/// `dynamic can't be assigned to List<Override>`. Binding a lambda to a `final` gets the
/// inference, so each mock gets a builder of its own below rather than a local inside.
///
/// The lint below asks for exactly the function declaration that cannot be written here.
// ignore: prefer_function_declarations_over_variables
final _overrides = () => [
  getDashboardSummaryUseCaseProvider.overrideWithValue(_dashboardUseCase()),
  getRequisitionsUseCaseProvider.overrideWithValue(_requisitionsUseCase()),
  getRequisitionUseCaseProvider.overrideWithValue(_requisitionUseCase()),
  cancelRequisitionUseCaseProvider.overrideWithValue(
    MockCancelRequisitionUseCase(),
  ),
  getUserAccountUseCaseProvider.overrideWithValue(_accountUseCase()),
  searchEmployeesUseCaseProvider.overrideWithValue(_employeesUseCase()),
  sessionStreamProvider.overrideWith((ref) => Stream.value(_session)),
];

MockGetDashboardSummaryUseCase _dashboardUseCase() {
  final mock = MockGetDashboardSummaryUseCase();
  when(mock.call).thenAnswer((_) async => ApiResult.success(_summary()));
  return mock;
}

MockGetRequisitionsUseCase _requisitionsUseCase() {
  final mock = MockGetRequisitionsUseCase();
  when(
    () => mock(any()),
  ).thenAnswer((_) async => ApiResult.success([_requisition()]));
  return mock;
}

MockGetRequisitionUseCase _requisitionUseCase() {
  final mock = MockGetRequisitionUseCase();
  when(
    () => mock(any()),
  ).thenAnswer((_) async => ApiResult.success(_requisition()));
  return mock;
}

MockGetUserAccountUseCase _accountUseCase() {
  final mock = MockGetUserAccountUseCase();
  when(mock.call).thenAnswer(
    (_) async => ApiResult.success(
      UserAccount(
        id: '1',
        email: 'tofiq.akbar@btracsl.com',
        employeeId: 'BTS-0001',
        memberSince: DateTime(2021, 3, 1),
      ),
    ),
  );
  return mock;
}

MockSearchEmployeesUseCase _employeesUseCase() {
  final mock = MockSearchEmployeesUseCase();
  when(
    () => mock(any()),
  ).thenAnswer((_) async => const ApiResult.success(<Employee>[]));
  return mock;
}

/// Screens that live inside the shell chrome are pumped inside it, because the top bar and
/// the drawer are part of what has to fit — and because a Scaffold nested in a Scaffold is
/// how the router actually builds them.
Widget _inShell(Widget child, {required bool shell, required double textScale}) {
  final content = shell
      ? AppShell(
          currentPath: RoutePaths.dashboard,
          onNavigate: (_) {},
          onOpenProfile: () {},
          child: child,
        )
      : child;

  return MaterialApp(
    // Injected through `builder`, below the app: MaterialApp installs its own MediaQuery
    // from the test view, so a wrapper placed outside it is silently discarded.
    builder: (context, inner) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: inner!,
    ),
    home: content,
  );
}

/// Pumps [child] at [surface] and fails if the frame reported a layout error.
Future<void> _expectNoOverflow(
  WidgetTester tester,
  _Surface surface, {
  required Widget child,
  required bool shell,
  required double textScale,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface.size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(),
      child: _inShell(child, shell: shell, textScale: textScale),
    ),
  );
  // Not pumpAndSettle: the dashboard's count-up tween and the skeleton shimmer are
  // repeating animations, so settling never terminates. Two pumps take every screen past
  // its post-frame load and its entrance stagger.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  expect(
    tester.takeException(),
    isNull,
    reason:
        '${surface.name} (${surface.size.width.toInt()}x'
        '${surface.size.height.toInt()}) at ${textScale}x text reported a layout error',
  );
}

/// Puts the reset flow on its second step without a network round-trip.
///
/// The step is notifier state, so there is no constructor argument that reaches it. The
/// seeded values are the worst case for layout rather than the typical one: a long
/// address in the subtitle, a two-digit countdown beside the caption, and a field error
/// under the code — each of which adds a line the resting screen does not have.
class _SeededVerifyStepNotifier extends PasswordResetNotifier {
  @override
  PasswordResetUiState build() {
    return super.build().copyWith(
      step: PasswordResetStep.enterCode,
      userName: 'mohammad.tofiq.akbar@btracsolutions.example.com',
      otpCode: '1234',
      resendSecondsLeft: 45,
      expirySecondsLeft: 570,
      fieldErrors: const {
        'otp_code': 'The OTP is invalid or has expired.',
      },
    );
  }
}

void main() {
  setUpAll(() => registerFallbackValue(const RequisitionListFilter()));

  final screens = <String, ({Widget widget, bool shell})>{
    'Sign In': (
      widget: LoginScreen(onLoginSuccess: () {}, onForgotPassword: () {}),
      // No shell: Login sits outside it, and is the one screen with no AppBar to supply
      // a top inset.
      shell: false,
    ),
    'Dashboard': (
      widget: DashboardScreen(
        onViewAllRequisitions: () {},
        onRequisitionNow: () {},
        onOpenRequisition: (_) {},
      ),
      shell: true,
    ),
    'Requisition list': (
      widget: RequisitionListScreen(
        onNewRequisition: () {},
        onOpenRequisition: (_) {},
      ),
      shell: true,
    ),
    'Requisition detail': (
      widget: RequisitionDetailScreen(
        requisitionId: 'r1',
        onBack: () {},
        onEdit: (_) {},
        onClosed: () {},
      ),
      shell: false,
    ),
    'New requisition': (
      widget: RequisitionCreateScreen(onBack: () {}, onSubmitted: () {}),
      shell: false,
    ),
    'Reset password': (
      widget: PasswordResetScreen(onBack: () {}, onCompleted: (_) {}),
      // Outside the shell for the same reason Sign In is: it is reachable while signed
      // out, and draws its own back control.
      shell: false,
    ),
    'Reset password locked email': (
      // The Profile entry point: a fixed address rendered as a read-only row. Its own
      // entry because it is a different widget in that slot, and a long email beside a
      // lock glyph is exactly the pair that can run out of width on a narrow window.
      widget: PasswordResetScreen(
        onBack: () {},
        onCompleted: (_) {},
        initialEmail: 'tofiq.akbar@btracsl.com',
        lockEmail: true,
      ),
      shell: false,
    ),
    'Reset password code step': (
      // A nested ProviderScope so only this entry gets the seeded notifier; the entry
      // above still exercises the first step.
      widget: ProviderScope(
        overrides: [
          passwordResetNotifierProvider.overrideWith(_SeededVerifyStepNotifier.new),
        ],
        child: PasswordResetScreen(onBack: () {}, onCompleted: (_) {}),
      ),
      shell: false,
    ),
    'Profile': (widget: ProfileScreen(onBack: () {}, onChangePassword: () {}), shell: false),
  };

  for (final entry in screens.entries) {
    group(entry.key, () {
      for (final surface in _surfaces) {
        testWidgets('${surface.name} lays out without overflow', (tester) async {
          await _expectNoOverflow(
            tester,
            surface,
            child: entry.value.widget,
            shell: entry.value.shell,
            textScale: 1.0,
          );
        });

        testWidgets('${surface.name} survives ${_largeTextScale}x text', (
          tester,
        ) async {
          await _expectNoOverflow(
            tester,
            surface,
            child: entry.value.widget,
            shell: entry.value.shell,
            textScale: _largeTextScale,
          );
        });
      }
    });
  }

  // The overflow tests above cannot see any of this.
  //
  // Verified by neutralising `constrainToContentWidth` and re-running: all 72 of them
  // stayed green. A column stretched to 1194pt does not overflow anything — it is merely
  // unreadable — so "no exception" is the wrong instrument for the iPad work entirely.
  // These measure the rendered result instead.
  group('content is centred on a tablet, not stretched', () {
    for (final screen in [
      (
        name: 'Dashboard',
        widget: DashboardScreen(
          onViewAllRequisitions: () {},
          onRequisitionNow: () {},
          onOpenRequisition: (_) {},
        ),
        shell: true,
      ),
      (
        name: 'Requisition list',
        widget: RequisitionListScreen(
          onNewRequisition: () {},
          onOpenRequisition: (_) {},
        ),
        shell: true,
      ),
      (
        name: 'Profile',
        widget: ProfileScreen(onBack: () {}, onChangePassword: () {}),
        shell: false,
      ),
    ]) {
      testWidgets('${screen.name} caps its card width on iPad landscape', (
        tester,
      ) async {
        const viewport = Size(1194, 834);
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _overrides(),
            child: _inShell(
              screen.widget,
              shell: screen.shell,
              textScale: 1.0,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        final cards = find.byType(SurfaceCard);
        expect(
          cards,
          findsWidgets,
          reason: 'the screen should have rendered its content cards',
        );

        // The column the content is supposed to occupy, centred in the window.
        final gutter = (viewport.width - tracGoMaxContentWidth) / 2;
        // Every card, not just the first: on the dashboard the first one is a quarter-width
        // stat tile, which is correctly *not* centred on its own — what has to hold is that
        // no card escapes the column's bounds.
        for (var i = 0; i < tester.widgetList(cards).length; i++) {
          final rect = tester.getRect(cards.at(i));
          expect(
            rect.left,
            greaterThanOrEqualTo(gutter - 1.0),
            reason:
                '${screen.name} card $i starts at ${rect.left.toInt()}pt, left of the '
                '${gutter.toInt()}pt gutter — the content column is not capped',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(viewport.width - gutter + 1.0),
            reason:
                '${screen.name} card $i ends at ${rect.right.toInt()}pt across a '
                '${viewport.width.toInt()}pt window — the content column is not capped',
          );
        }
      });
    }
  });

  // The width helper's contract, asserted directly rather than inferred from a screen:
  // it may only ever *widen* a gutter, so every window narrower than the content column
  // keeps the phone padding it was designed with.
  group('content width', () {
    testWidgets('a phone-width window keeps its original padding', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(tester.view.reset);

      late EdgeInsets resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                20,
              ).constrainToContentWidth(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, const EdgeInsets.fromLTRB(20, 22, 20, 20));
    });

    testWidgets('a tablet-width window centres the column', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1194, 834);
      addTearDown(tester.view.reset);

      late EdgeInsets resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                20,
              ).constrainToContentWidth(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // (1194 - 600) / 2 = 297 a side, leaving exactly the 600pt column.
      expect(resolved.left, 297);
      expect(resolved.right, 297);
      expect(1194 - resolved.left - resolved.right, tracGoMaxContentWidth);
      // Vertical padding is never touched.
      expect(resolved.top, 22);
      expect(resolved.bottom, 20);
    });
  });
}
