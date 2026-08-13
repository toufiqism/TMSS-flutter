import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../common/strings.dart';
import '../common/synced_text_field.dart';
import '../common/tms_logo_mark.dart';
import 'login_notifier.dart';
import 'login_state.dart';

/// Header logo edge length. Shared between the logo itself and the padding that
/// reserves room for it, so the two cannot drift apart.
const double _logoSize = 32;

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
      backgroundColor: tmsSurfaceWhite,
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
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/login_bg.jpg',
                    fit: BoxFit.cover,
                    // A missing or corrupt asset must not take the login screen down.
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: tmsGreenLight),
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(color: tmsGreenLight.withValues(alpha: 0.4)),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 260.0 * media.textScaler.scale(1).clamp(1.0, 1.6),
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
                          Text(TmsStrings.loginTaglineTitle, style: tmsTextTheme.headlineSmall),
                          const SizedBox(height: 10),
                          Text(
                            TmsStrings.loginTaglineBody,
                            style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextSubtle),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: media.padding.top + 24,
                  left: 24,
                  child: const TmsLogoMark(
                    badgeColor: tmsGreenDark,
                    glyphColor: tmsLoginAccentGreen,
                    size: _logoSize,
                  ),
                ),
              ],
            ),
            const Divider(height: 1, indent: 28, endIndent: 28, color: tmsDivider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TmsStrings.loginHeading, style: tmsTextTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      TmsStrings.loginSubheading,
                      style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
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
                      label: TmsStrings.loginUsernameLabel,
                      value: uiState.username,
                      onChanged: notifier.onUsernameChange,
                      hint: TmsStrings.loginUsernamePlaceholder,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      enabled: !uiState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: TmsStrings.loginPasswordLabel,
                      value: uiState.password,
                      onChanged: notifier.onPasswordChange,
                      hint: TmsStrings.loginPasswordPlaceholder,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !uiState.isLoading,
                      onSubmitted: () => unawaited(notifier.submit()),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt),
                        children: [
                          TextSpan(text: '${TmsStrings.loginForgotPassword} '),
                          TextSpan(
                            text: TmsStrings.loginContactAdmin,
                            style: const TextStyle(color: tmsGreen, fontWeight: FontWeight.bold),
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
                                  color: tmsSurfaceWhite,
                                ),
                              )
                            : Text(
                                TmsStrings.loginSignInButton,
                                style: tmsTextTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  color: tmsSurfaceWhite,
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

class _LabeledField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: tmsTextTheme.labelMedium),
        const SizedBox(height: 6),
        SyncedTextField(
          value: value,
          onChanged: onChanged,
          hintText: hint,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          enabled: enabled,
        ),
      ],
    );
  }
}
