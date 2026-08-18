import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/typography.dart';
import '../common/auth_form_controls.dart';
import '../common/motion.dart';
import '../common/page_width.dart';
import '../common/strings.dart';
import '../common/tracgo_logo_mark.dart';
import 'login_notifier.dart';
import 'login_state.dart';

// This screen's palette used to be seven private constants, kept out of
// `theme/colors.dart` because they were close cousins of the old forest-green tokens
// rather than replacements. The rest of the app has since adopted the same daylight
// language, so they are now the shared tokens — a second near-identical green in the
// palette is exactly what that note was written to avoid.

/// Edge length of the centred brand mark, at rest and with the keyboard open.
///
/// The mark is the first thing asked to give up space. A software keyboard eats roughly
/// half a phone's height, and at 108px the logo pushes the password field and the sign-in
/// button below the fold on a short device — the user has to scroll to reach the control
/// they just opened the keyboard to use. Shrinking the mark and the gap under it buys
/// back ~68px while keeping the headline, which is what says *which* screen this is.
const double _logoSize = 108;
const double _logoSizeCompact = 64;

/// Gap between the mark and the headline, at rest and compacted.
const double _logoGap = 44;
const double _logoGapCompact = 20;

/// Gap between the header block and the first field, at rest and compacted.
const double _headerGap = 40;
const double _headerGapCompact = 24;

/// Close enough to the platform keyboard's own slide-in that the two read as one
/// movement rather than two things happening at once.
const Duration _headerCompactDuration = Duration(milliseconds: 220);

/// Interpolates a resting measurement toward its compact counterpart.
double _compacted(double rest, double compact, double t) =>
    rest + (compact - rest) * t;

/// Ceiling on text scaling for the logo/headline block.
///
/// iOS accessibility sizes reach roughly 3.1x. The 40px headline at that scale is 124px
/// per line and pushes the form off-screen; the fields and button below stay fully
/// scalable, because those are the part the user actually has to operate.
const double _headerMaxTextScale = 1.4;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onForgotPassword,
  });

  final VoidCallback onLoginSuccess;

  /// Opens the password-reset flow. Routed from here rather than pushed inline so the
  /// screen stays free of `go_router` — every other navigation on it is a callback too.
  final VoidCallback onForgotPassword;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  StreamSubscription<LoginEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    // Subscribe once, after the first frame, to the notifier's one-shot event stream —
    // the Dart equivalent of Kotlin's Channel/receiveAsFlow collected in a LaunchedEffect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _eventSub = ref.read(loginNotifierProvider.notifier).events.listen((
        event,
      ) {
        if (!mounted) return;
        if (event is NavigateToDashboard) widget.onLoginSuccess();
      });
    });
  }

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    // Deliberately read from *this* context, which sits above the Scaffold: the Scaffold
    // strips the bottom view inset out of the MediaQuery it hands its body
    // (`removeBottomInset`), so the identical call one level down always reports 0.
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final motion = TracGoMotion.of(context);
    // Error wins when both are somehow set: a stale success note over a fresh failure
    // would tell the user the opposite of what just happened.
    final bannerMessage = uiState.errorMessage ?? uiState.infoMessage;

    return Scaffold(
      backgroundColor: tracGoSignInBackground,
      // `resizeToAvoidBottomInset` is left at its default (true), so the Scaffold already
      // shortens the body by the keyboard's height and the scroll view below sees a
      // viewport that excludes it. This screen used to *also* pad the scroll view by
      // viewInsets.bottom, which double-counted the keyboard and left a screenful of dead
      // scrollable space under the form.
      // No AppBar on this screen, so the status bar is ours to clear — on both platforms.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            // 420 rather than the app-wide 600: a sign-in form is two fields and a
            // button, and stretched to the full content column on a tablet it reads as a
            // page with a hole in the middle. This keeps it near the width the design
            // drew it at, centred on whatever the window turns out to be.
            padding: const EdgeInsets.fromLTRB(
              30,
              26,
              30,
              32,
            ).constrainToContentWidth(context, maxContentWidth: 420),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Only the header rebuilds per animation frame; the fields and button
                  // sit outside the builder and are untouched by it, so a keyboard
                  // opening cannot disturb input state.
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: keyboardVisible ? 1 : 0,
                    ),
                    duration: _headerCompactDuration,
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MediaQuery.withClampedTextScaling(
                          maxScaleFactor: _headerMaxTextScale,
                          child: Column(
                            children: [
                              TracGoLogoMark(
                                size: _compacted(
                                  _logoSize,
                                  _logoSizeCompact,
                                  t,
                                ),
                              ),
                              SizedBox(
                                height: _compacted(
                                  _logoGap,
                                  _logoGapCompact,
                                  t,
                                ),
                              ),
                              Text(
                                TracGoStrings.loginHeading,
                                textAlign: TextAlign.center,
                                style: tracGoTextTheme.headlineSmall?.copyWith(
                                  fontSize: 40,
                                  height: 1.0,
                                  letterSpacing: -1.2, // -0.03em at 40px
                                  color: tracGoInk,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // The design caps the subtitle at 290px so it breaks into
                              // two balanced lines rather than one long one.
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 290,
                                ),
                                child: Text(
                                  TracGoStrings.loginSubheading,
                                  textAlign: TextAlign.center,
                                  style: tracGoTextTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: tracGoTextMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: _compacted(_headerGap, _headerGapCompact, t),
                        ),
                      ],
                    ),
                  ),
                  // One slot for both messages: a failed sign-in opens its own height
                  // rather than shoving the fields down the page, and the green
                  // "password reset, sign in again" note lands in the same place. They
                  // are mutually exclusive — any keystroke or submit clears both — so a
                  // second slot would only ever be an empty gap.
                  AnimatedSize(
                    duration: TracGoMotion.of(context).base,
                    curve: tracGoMotionCurve,
                    alignment: Alignment.topCenter,
                    child: MotionSwitcher(
                      child: bannerMessage == null
                          ? const SizedBox(
                              key: ValueKey('no-banner'),
                              width: double.infinity,
                            )
                          : Padding(
                              key: ValueKey(bannerMessage),
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                bannerMessage,
                                textAlign: TextAlign.center,
                                style: tracGoTextTheme.bodyMedium?.copyWith(
                                  color: uiState.errorMessage != null
                                      ? Theme.of(context).colorScheme.error
                                      : tracGoGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // The form enters a beat behind the header. Deliberately *not* wrapped
                  // around the whole column: the header owns the keyboard-compaction
                  // tween above, and nesting one animation inside another that resizes it
                  // makes both look like jitter.
                  FadeSlideIn(
                    delay: motion.staggerDelay(1),
                    child: AuthUnderlinedField(
                      label: TracGoStrings.loginUsernameLabel,
                      value: uiState.username,
                      onChanged: notifier.onUsernameChange,
                      hint: TracGoStrings.loginUsernamePlaceholder,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      enabled: !uiState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 26),
                  FadeSlideIn(
                    delay: motion.staggerDelay(2),
                    child: AuthUnderlinedField(
                      label: TracGoStrings.loginPasswordLabel,
                      value: uiState.password,
                      onChanged: notifier.onPasswordChange,
                      hint: TracGoStrings.loginPasswordPlaceholder,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !uiState.isLoading,
                      onSubmitted: () => unawaited(notifier.submit()),
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeSlideIn(
                    delay: motion.staggerDelay(3),
                    child: AuthPillButton(
                      label: TracGoStrings.loginSignInButton,
                      isLoading: uiState.isLoading,
                      onPressed: () => unawaited(notifier.submit()),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        TracGoStrings.loginForgotPassword,
                        style: tracGoTextTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          color: tracGoTextMuted,
                        ),
                      ),
                      // Was static "Contact admin" text, which was accurate only while
                      // there was no reset endpoint to send the user to.
                      TextButton(
                        onPressed: uiState.isLoading
                            // Not merely cosmetic: navigating away mid-request leaves
                            // the sign-in in flight with nothing to show its result.
                            ? null
                            : widget.onForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: tracGoGreen,
                          // The design draws a bare word; the padding restores a 48px
                          // tap target without moving it.
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        child: Text(
                          TracGoStrings.loginResetPassword,
                          style: tracGoTextTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: tracGoGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
