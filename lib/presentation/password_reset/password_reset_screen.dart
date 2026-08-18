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
import 'otp_code_field.dart';
import 'password_reset_notifier.dart';
import 'password_reset_state.dart';

/// Edge length of the brand mark. Smaller than Sign In's 108: this screen carries a
/// two-line subtitle and, on step 2, four controls under it, and the mark is the first
/// thing that can give up space without costing the user anything.
const double _logoSize = 72;

/// Ceiling on text scaling for the logo/headline block, matching Sign In: iOS
/// accessibility sizes reach ~3.1x, at which a 34px headline alone fills the screen.
/// Everything the user has to operate below stays fully scalable.
const double _headerMaxTextScale = 1.4;

/// Both halves of the password reset flow, on one route.
///
/// The step is notifier state rather than a second route: step 2 is meaningless without
/// the email step 1 sent, and a `/reset-password` route would have to answer for the
/// deep link that arrives without one.
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({
    super.key,
    required this.onBack,
    required this.onCompleted,
    this.initialEmail,
    this.lockEmail = false,
  });

  /// Leaves the flow entirely — from step 1, or from the app bar arrow on either step
  /// once the step-2 arrow has done its own job of going back to step 1.
  final VoidCallback onBack;

  /// The password was changed. Carries the email so Login can prefill it.
  final ValueChanged<String> onCompleted;

  /// Seeds the email field. Supplied when the flow is opened from Profile, where the
  /// signed-in account's address is already known; null from the Login screen, where
  /// the whole point is that nobody is signed in.
  final String? initialEmail;

  /// Fixes [initialEmail] in place instead of merely seeding it.
  ///
  /// Set on the Profile entry point. That flow is "change *my* password": the code goes
  /// to the account this device is signed in as, and finishing it invalidates that
  /// account's token and drops the session — none of which makes sense for an address
  /// the user typed over the top. From Login the field stays editable, because there is
  /// no account in context to fix it to.
  ///
  /// Ignored when [initialEmail] is null or blank; a lock with nothing to lock would
  /// leave the user staring at an empty row and no way to fill it.
  final bool lockEmail;

  /// The trimmed address, or null when there is nothing usable to show.
  String? get _seedEmail {
    final seed = initialEmail?.trim() ?? '';
    return seed.isEmpty ? null : seed;
  }

  /// Whether step 1 renders the address as a locked row rather than an input.
  bool get isEmailLocked => lockEmail && _seedEmail != null;

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  StreamSubscription<PasswordResetEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    // Same one-shot event subscription as Login: `ref.listen` on state would replay the
    // completion on any rebuild and pop the screen twice.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(passwordResetNotifierProvider.notifier);
      _eventSub = notifier.events.listen((event) {
        if (!mounted) return;
        if (event is PasswordResetCompleted) widget.onCompleted(event.userName);
      });

      // Seeded here rather than in `build`: writing to a notifier while the widget
      // tree is building is what Riverpod asserts against.
      final seed = widget._seedEmail;
      if (seed == null) return;
      final current = ref.read(passwordResetNotifierProvider).userName;
      // Locked: the seed is the only address this flow may use, so it wins outright.
      // Unlocked: it only ever fills an untouched field. The notifier lives for the
      // length of the flow, so a rebuild — a keyboard opening, a rotation — must not
      // overwrite what the user has since typed.
      if (widget.isEmailLocked ? current != seed : current.isEmpty) {
        notifier.onUserNameChange(seed);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_eventSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(passwordResetNotifierProvider);
    final notifier = ref.read(passwordResetNotifierProvider.notifier);
    // Error wins over the "code sent" note: a stale success line above a fresh failure
    // says the opposite of what just happened.
    final bannerMessage = uiState.errorMessage ?? uiState.infoMessage;
    final isError = uiState.errorMessage != null;

    return PopScope(
      // On step 2, back means "back to the email", not "out of the flow" — the same
      // thing the arrow does, so the gesture and the button cannot disagree. Blocked
      // outright while a request is in flight: popping then would leave the reset
      // running with nowhere to report its result.
      canPop: !uiState.isEnteringCode && !uiState.isSubmitting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (uiState.isSubmitting) return;
        if (uiState.isEnteringCode) notifier.backToEmailStep();
      },
      child: Scaffold(
        backgroundColor: tracGoSignInBackground,
        // No AppBar, so the status bar is this screen's to clear — on both platforms.
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              // 420, matching Sign In: the same narrow form column rather than the
              // app-wide 600, which would leave a hole in the middle of a tablet.
              padding: const EdgeInsets.fromLTRB(
                30,
                8,
                30,
                32,
              ).constrainToContentWidth(context, maxContentWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: uiState.isSubmitting
                            ? null
                            : () {
                                if (uiState.isEnteringCode) {
                                  notifier.backToEmailStep();
                                } else {
                                  widget.onBack();
                                }
                              },
                        tooltip: TracGoStrings.resetBackSemanticLabel,
                        icon: const Icon(Icons.arrow_back, color: tracGoInk),
                      ),
                    ),
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: _headerMaxTextScale,
                      child: Column(
                        children: [
                          const TracGoLogoMark(size: _logoSize),
                          const SizedBox(height: 24),
                          Text(
                            TracGoStrings.resetHeading,
                            textAlign: TextAlign.center,
                            style: tracGoTextTheme.headlineSmall?.copyWith(
                              fontSize: 34,
                              height: 1.0,
                              letterSpacing: -1.0, // -0.03em at 34px
                              color: tracGoInk,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: _Subtitle(
                              state: uiState,
                              isEmailLocked: widget.isEmailLocked,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
                                    color: isError
                                        ? Theme.of(context).colorScheme.error
                                        : tracGoGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    AnimatedSize(
                      duration: TracGoMotion.of(context).base,
                      curve: tracGoMotionCurve,
                      alignment: Alignment.topCenter,
                      child: MotionSwitcher(
                        child: uiState.isEnteringCode
                            ? _VerifyStep(
                                key: const ValueKey('verify'),
                                state: uiState,
                                notifier: notifier,
                                isEmailLocked: widget.isEmailLocked,
                              )
                            : _RequestStep(
                                key: const ValueKey('request'),
                                state: uiState,
                                notifier: notifier,
                                lockedEmail: widget.isEmailLocked
                                    ? widget._seedEmail
                                    : null,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step-dependent subtitle. On step 2 it names the address the code went to, because
/// the commonest reason a code never arrives is that it was sent to a typo.
class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.state, required this.isEmailLocked});

  final PasswordResetUiState state;
  final bool isEmailLocked;

  @override
  Widget build(BuildContext context) {
    final base = tracGoTextTheme.bodyLarge?.copyWith(
      height: 1.5,
      color: tracGoTextMuted,
    );
    if (!state.isEnteringCode) {
      return Text(
        // "Enter your work email" is an instruction the locked flow does not give.
        isEmailLocked
            ? TracGoStrings.resetRequestSubheadingLocked
            : TracGoStrings.resetRequestSubheading,
        textAlign: TextAlign.center,
        style: base,
      );
    }
    return Text.rich(
      TextSpan(
        text: '${TracGoStrings.resetVerifySubheading} ',
        children: [
          TextSpan(
            text: state.userName,
            style: base?.copyWith(color: tracGoInk, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: base,
    );
  }
}

/// Step 1 — the email that the OTP is sent to.
class _RequestStep extends StatelessWidget {
  const _RequestStep({
    super.key,
    required this.state,
    required this.notifier,
    this.lockedEmail,
  });

  final PasswordResetUiState state;
  final PasswordResetNotifier notifier;

  /// Non-null on the Profile entry point: the one address this flow may use. The field
  /// is then a read-only row rather than an input, and nothing on this step can change
  /// `state.userName`.
  final String? lockedEmail;

  @override
  Widget build(BuildContext context) {
    final locked = lockedEmail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (locked != null)
          AuthReadOnlyField(
            label: TracGoStrings.resetEmailLabel,
            value: locked,
            note: TracGoStrings.resetEmailLockedNote,
            errorText: state.fieldError(PasswordResetFields.userName),
          )
        else
          AuthUnderlinedField(
            label: TracGoStrings.resetEmailLabel,
            value: state.userName,
            onChanged: notifier.onUserNameChange,
            hint: TracGoStrings.resetEmailPlaceholder,
            errorText: state.fieldError(PasswordResetFields.userName),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.username],
            enabled: !state.isSubmitting,
            onSubmitted: () => unawaited(notifier.sendCode()),
          ),
        const SizedBox(height: 32),
        AuthPillButton(
          label: TracGoStrings.resetSendCodeButton,
          isLoading: state.isSubmitting,
          onPressed: () => _send(locked),
        ),
      ],
    );
  }

  /// Sends against the locked address, restoring it first if the notifier has not been
  /// seeded yet.
  ///
  /// The seed lands in a post-frame callback, so there is one frame in which the button
  /// is on screen and `state.userName` is still empty; without this, a tap in that frame
  /// would fail validation with "Enter your work email" under a field the user cannot
  /// type into. Cheap, and it also means the locked value is the one that is sent even
  /// if some future code path writes over the notifier's copy.
  void _send(String? locked) {
    if (locked != null && state.userName != locked) {
      notifier.onUserNameChange(locked);
    }
    unawaited(notifier.sendCode());
  }
}

/// Step 2 — the code, the new password, and its confirmation.
class _VerifyStep extends StatelessWidget {
  const _VerifyStep({
    super.key,
    required this.state,
    required this.notifier,
    required this.isEmailLocked,
  });

  final PasswordResetUiState state;
  final PasswordResetNotifier notifier;

  /// Only changes the wording of the "back to step 1" link — the step itself still
  /// goes back, because that is where a fresh send is started from.
  final bool isEmailLocked;

  @override
  Widget build(BuildContext context) {
    final otpError = state.fieldError(PasswordResetFields.otpCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A Wrap, not a Row: the caption and the countdown are a matched pair at 1.0x
        // and do not both fit on one line by ~2.0x text scaling, where a Row overflows
        // by 65px on a phone-width column. This drops the countdown onto its own line
        // instead.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              TracGoStrings.resetCodeLabel.toUpperCase(),
              style: tracGoTextTheme.labelMedium?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1, // 0.1em at 11px
                color: otpError != null
                    ? tracGoDestructiveRed
                    : tracGoTextMutedAlt,
              ),
            ),
            // The expiry estimate. Advisory only — the code is still submitted after it
            // reaches zero, because the server owns the real deadline and a client clock
            // that runs fast must not refuse a code that still works.
            Text(
              state.isCodeExpired
                  ? TracGoStrings.resetCodeExpired
                  : TracGoStrings.resetCodeExpiresIn(state.expiryLabel),
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: state.isCodeExpired ? tracGoDestructiveRed : tracGoTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OtpCodeField(
          value: state.otpCode,
          onChanged: notifier.onOtpChange,
          length: PasswordResetUiState.otpLength,
          enabled: !state.isSubmitting,
          hasError: otpError != null,
        ),
        if (otpError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              otpError,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: tracGoDestructiveRed,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            // Disabled for the cooldown window rather than firing a request the server
            // will throttle: the endpoint allows 5/min and answers 429 above that.
            onPressed: state.canResend ? () => unawaited(notifier.sendCode()) : null,
            style: TextButton.styleFrom(
              foregroundColor: tracGoGreen,
              disabledForegroundColor: tracGoTextMuted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: Text(
              state.resendSecondsLeft > 0
                  ? TracGoStrings.resetResendIn(state.resendSecondsLeft)
                  : TracGoStrings.resetResendButton,
              style: tracGoTextTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AuthUnderlinedField(
          label: TracGoStrings.resetNewPasswordLabel,
          value: state.password,
          onChanged: notifier.onPasswordChange,
          hint: TracGoStrings.resetPasswordPlaceholder,
          errorText: state.fieldError(PasswordResetFields.password),
          obscureText: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !state.isSubmitting,
        ),
        const SizedBox(height: 26),
        AuthUnderlinedField(
          label: TracGoStrings.resetConfirmPasswordLabel,
          value: state.confirmPassword,
          onChanged: notifier.onConfirmPasswordChange,
          hint: TracGoStrings.resetPasswordPlaceholder,
          errorText: state.fieldError(PasswordResetFields.passwordConfirmation),
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !state.isSubmitting,
          onSubmitted: () => unawaited(notifier.submitReset()),
        ),
        const SizedBox(height: 32),
        AuthPillButton(
          label: TracGoStrings.resetSubmitButton,
          isLoading: state.isSubmitting,
          onPressed: () => unawaited(notifier.submitReset()),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed:
                state.isSubmitting ? null : () => notifier.backToEmailStep(),
            style: TextButton.styleFrom(
              foregroundColor: tracGoTextMuted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: Text(
              isEmailLocked
                  ? TracGoStrings.resetBackToEmailLocked
                  : TracGoStrings.resetBackToEmail,
              style: tracGoTextTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
