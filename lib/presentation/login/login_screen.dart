import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../common/strings.dart';
import '../common/synced_text_field.dart';
import '../common/tracgo_logo_mark.dart';
import 'login_notifier.dart';
import 'login_state.dart';

/// Header logo edge length. Shared between the logo itself and the padding that
/// reserves room for it, so the two cannot drift apart.
const double _logoSize = 32;

/// Ceiling on the header's text scaling. iOS accessibility sizes reach roughly 3.1x,
/// at which the tagline alone is taller than the screen.
const double _headerMaxTextScale = 1.3;

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
      _eventSub = ref.read(loginNotifierProvider.notifier).events.listen((event) {
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
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: tracGoSurfaceWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // The header was a hard SizedBox(height: 260), which overflowed once the
            // tagline wrapped to more lines at large accessibility text scales. It is
            // now a *minimum* that grows with its content instead.
            //
            // Nothing here uses Spacer or Expanded, and that is deliberate rather than
            // stylistic: this Stack sits inside a SingleChildScrollView, so the incoming
            // maxHeight is infinite. `minHeight` constrains the floor, not the ceiling —
            // a flex child would be asked to divide infinite free space, which throws
            // "RenderFlex children have non-zero flex but incoming height constraints
            // are unbounded" and fails layout for the entire screen, painting nothing.
            //
            // So the tagline is bottom-pinned with Align (which adopts the incoming
            // minHeight without needing a bounded max) and the logo is absolutely
            // positioned at the top. The tagline's top padding reserves the logo's
            // space so the two cannot collide as text scales up.
            // The header's text scale is clamped, the form's is not. At the largest
            // accessibility sizes the unclamped tagline grew past the full viewport and
            // pushed the username, password and Sign In button entirely off-screen —
            // the form was still there, but unreachable without a long scroll. Clamping
            // only this decorative block keeps branding bounded while leaving the part
            // the user actually needs fully scalable.
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: _headerMaxTextScale,
              child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/login_bg.jpg',
                    fit: BoxFit.cover,
                    // A missing or corrupt asset must not take the login screen down.
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: tracGoGreenLight),
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(color: tracGoGreenLight.withValues(alpha: 0.4)),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 260.0 *
                        media.textScaler.scale(1).clamp(1.0, _headerMaxTextScale),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: media.padding.top + 24 + _logoSize + 16,
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(TracGoStrings.loginTaglineTitle, style: tracGoTextTheme.headlineSmall),
                          const SizedBox(height: 10),
                          Text(
                            TracGoStrings.loginTaglineBody,
                            style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextSubtle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: media.padding.top + 24,
                  left: 24,
                  child: const TracGoLogoMark(
                    badgeColor: tracGoGreenDark,
                    glyphColor: tracGoLoginAccentGreen,
                    size: _logoSize,
                  ),
                ),
              ],
              ),
            ),
            const Divider(height: 1, indent: 28, endIndent: 28, color: tracGoDivider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TracGoStrings.loginHeading, style: tracGoTextTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      TracGoStrings.loginSubheading,
                      style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextMutedAlt),
                    ),
                    const SizedBox(height: 24),
                    if (uiState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          uiState.errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    _LabeledField(
                      label: TracGoStrings.loginUsernameLabel,
                      value: uiState.username,
                      onChanged: notifier.onUsernameChange,
                      hint: TracGoStrings.loginUsernamePlaceholder,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      enabled: !uiState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
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
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: tracGoTextTheme.bodyMedium?.copyWith(color: tracGoTextMutedAlt),
                        children: [
                          TextSpan(text: '${TracGoStrings.loginForgotPassword} '),
                          TextSpan(
                            text: TracGoStrings.loginContactAdmin,
                            style: const TextStyle(color: tracGoGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // minimumSize rather than a fixed height, so the label still
                        // fits when the user scales text up.
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: uiState.isLoading ? null : () => unawaited(notifier.submit()),
                        child: uiState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tracGoSurfaceWhite,
                                ),
                              )
                            : Text(
                                TracGoStrings.loginSignInButton,
                                style: tracGoTextTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  color: tracGoSurfaceWhite,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled input. When [obscureText] is set it also gains a reveal toggle, because
/// a masked field with no way to check what was typed is the usual cause of a login
/// failure that is really a typo.
class _LabeledField extends StatefulWidget {
  const _LabeledField({
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
  State<_LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<_LabeledField> {
  /// Starts masked, and is never persisted or lifted into [LoginUiState]: it is view
  /// state with no meaning outside this widget, and a revealed password surviving a
  /// rebuild — or worse, a navigation — is a shoulder-surfing hazard rather than a
  /// convenience.
  bool _revealed = false;

  /// Keeps the toggle out of the focus chain.
  ///
  /// A plain [IconButton] in a `suffixIcon` takes focus when tapped, which closes the
  /// keyboard — so every peek at the password would cost the user a tap to get back to
  /// typing. Screen readers reach the button by touch exploration regardless, and it
  /// carries a tooltip, so nothing is lost by making it unfocusable.
  final FocusNode _toggleFocusNode = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.obscureText;
    final tooltip = _revealed
        ? TracGoStrings.loginHidePassword
        : TracGoStrings.loginShowPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: tracGoTextTheme.labelMedium),
        const SizedBox(height: 6),
        SyncedTextField(
          value: widget.value,
          onChanged: widget.onChanged,
          hintText: widget.hint,
          obscureText: widget.obscureText && !_revealed,
          // Explicit, and load-bearing: `obscureText` above goes false while the user
          // is peeking, and this is what stops the keyboard learning the password in
          // that window.
          isSensitive: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          suffixIcon: !showToggle
              ? null
              : IconButton(
                  focusNode: _toggleFocusNode,
                  // Disabled alongside the field it belongs to: revealing the password
                  // during a sign-in attempt would toggle a field the user cannot edit.
                  onPressed: widget.enabled
                      ? () => setState(() => _revealed = !_revealed)
                      : null,
                  tooltip: tooltip,
                  icon: Icon(
                    _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: tracGoTextMutedAlt,
                  ),
                ),
        ),
      ],
    );
  }
}
