import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/motion.dart';
import '../../theme/typography.dart';
import '../common/motion.dart';
import '../common/strings.dart';
import '../common/synced_text_field.dart';
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

/// Minimum height of a field's input row, set by the tallest thing that can sit in one
/// — the reveal toggle, whose padding buys it a 44px tap target.
const double _fieldContentHeight = 44;

/// Ceiling on text scaling for the logo/headline block.
///
/// iOS accessibility sizes reach roughly 3.1x. The 40px headline at that scale is 124px
/// per line and pushes the form off-screen; the fields and button below stay fully
/// scalable, because those are the part the user actually has to operate.
const double _headerMaxTextScale = 1.4;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

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
            padding: const EdgeInsets.fromLTRB(30, 26, 30, 32),
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
                  // A failed sign-in opens its own height rather than shoving the fields
                  // down the page — the user's eyes are on the field they just typed in.
                  AnimatedSize(
                    duration: TracGoMotion.of(context).base,
                    curve: tracGoMotionCurve,
                    alignment: Alignment.topCenter,
                    child: MotionSwitcher(
                      child: uiState.errorMessage == null
                          ? const SizedBox(
                              key: ValueKey('no-error'),
                              width: double.infinity,
                            )
                          : Padding(
                              key: const ValueKey('error'),
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                uiState.errorMessage!,
                                textAlign: TextAlign.center,
                                style: tracGoTextTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
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
                    child: _UnderlinedField(
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
                    child: _UnderlinedField(
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
                    child: _SignInButton(
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
                      Text(
                        TracGoStrings.loginContactAdmin,
                        style: tracGoTextTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: tracGoGreen,
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

/// The pill sign-in button from the design: flat green, no Material elevation, with a
/// soft green-tinted drop shadow of its own.
class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: isLoading
            // The shadow reads as "raised, press me". Dropping it while the request is
            // in flight is the same signal as the disabled fill.
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x3D2E5C34), // rgba(46,92,52,0.24)
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tracGoGreen,
          disabledBackgroundColor: tracGoGreen.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          // minimumSize rather than a fixed height, so the label still fits when the
          // user scales text up. 20px of padding each side matches the design's 60px
          // resting height.
          minimumSize: const Size.fromHeight(60),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: isLoading ? null : onPressed,
        child: MotionSwitcher(
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  TracGoStrings.loginSignInButton,
                  key: const ValueKey('idle'),
                  style: tracGoTextTheme.labelLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// A field drawn as a baseline rule rather than a filled box, per the design: uppercase
/// caption, then the input, then a 1.5px underline.
///
/// When [obscureText] is set it also gains a reveal toggle, because a masked field with
/// no way to check what was typed is the usual cause of a login failure that is really a
/// typo.
class _UnderlinedField extends StatefulWidget {
  const _UnderlinedField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final VoidCallback? onSubmitted;
  final bool enabled;

  @override
  State<_UnderlinedField> createState() => _UnderlinedFieldState();
}

class _UnderlinedFieldState extends State<_UnderlinedField> {
  /// Starts masked, and is never persisted or lifted into [LoginUiState]: it is view
  /// state with no meaning outside this widget, and a revealed password surviving a
  /// rebuild — or worse, a navigation — is a shoulder-surfing hazard rather than a
  /// convenience.
  bool _revealed = false;

  /// Keeps the toggle out of the focus chain.
  ///
  /// A focusable button here takes focus when tapped, which closes the keyboard — so
  /// every peek at the password would cost the user a tap to get back to typing. Screen
  /// readers reach it by touch exploration regardless, and it carries a semantics label.
  final FocusNode _toggleFocusNode = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = tracGoTextTheme.bodyLarge?.copyWith(
      fontSize: 18,
      color: tracGoInk,
      letterSpacing: widget.obscureText ? 1.08 : null, // 0.06em at 18px
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: tracGoTextTheme.labelMedium?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1, // 0.1em at 11px
            color: tracGoTextMutedAlt,
          ),
        ),
        const SizedBox(height: 8),
        // A floor, not a fixed height, so the row still grows with text scaling. It
        // exists because the reveal toggle is taller than a bare input: without it the
        // password's rule sat ~20px lower than the username's, and the two fields the
        // design draws as a matched pair visibly disagreed.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _fieldContentHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SyncedTextField(
                  value: widget.value,
                  onChanged: widget.onChanged,
                  hintText: widget.hint,
                  obscureText: widget.obscureText && !_revealed,
                  // Explicit, and load-bearing: `obscureText` above goes false while the
                  // user is peeking, and this is what stops the keyboard learning the
                  // password in that window.
                  isSensitive: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onSubmitted,
                  enabled: widget.enabled,
                  style: inputStyle,
                  hintStyle: inputStyle?.copyWith(
                    color: tracGoPlaceholder,
                    letterSpacing: null,
                  ),
                  // The rule below is drawn by this widget, so the field itself must not
                  // add Material's own underline, fill or 48px content padding on top.
                  bare: true,
                ),
              ),
              if (widget.obscureText)
                _RevealToggle(
                  focusNode: _toggleFocusNode,
                  revealed: _revealed,
                  // Disabled alongside the field it belongs to: revealing the password
                  // during a sign-in attempt would toggle a field the user cannot edit.
                  onPressed: widget.enabled
                      ? () => setState(() => _revealed = !_revealed)
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const ColoredBox(
          color: tracGoRule,
          child: SizedBox(height: 1.5, width: double.infinity),
        ),
      ],
    );
  }
}

/// The design's uppercase SHOW / HIDE text button.
class _RevealToggle extends StatelessWidget {
  const _RevealToggle({
    required this.focusNode,
    required this.revealed,
    required this.onPressed,
  });

  final FocusNode focusNode;
  final bool revealed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // "SHOW" on its own describes nothing to a screen reader; this says what pressing
      // it does.
      label: revealed
          ? TracGoStrings.loginHidePassword
          : TracGoStrings.loginShowPassword,
      excludeSemantics: true,
      child: TextButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: tracGoGreen,
          // The design shows a bare word, but a 12px word is a 12px tap target. The
          // padding restores a 48px-tall hit area without moving the text.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: tracGoTextTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.72, // 0.06em at 12px
          ),
        ),
        child: Text(
          (revealed
                  ? TracGoStrings.loginHidePasswordShort
                  : TracGoStrings.loginShowPasswordShort)
              .toUpperCase(),
        ),
      ),
    );
  }
}
