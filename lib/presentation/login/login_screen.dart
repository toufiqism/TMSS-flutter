import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../common/strings.dart';
import '../common/tms_logo_mark.dart';
import 'login_notifier.dart';
import 'login_state.dart';

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
      _eventSub = ref.read(loginNotifierProvider.notifier).events.listen((event) {
        if (event is NavigateToDashboard) widget.onLoginSuccess();
      });
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
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
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover),
                  Container(color: tmsGreenLight.withValues(alpha: 0.4)),
                  Padding(
                    padding: EdgeInsets.only(top: media.padding.top + 24, left: 24, right: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TmsLogoMark(badgeColor: tmsGreenDark, glyphColor: tmsLoginAccentGreen, size: 32),
                        const Spacer(),
                        Text(TmsStrings.loginTaglineTitle, style: tmsTextTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Text(
                          TmsStrings.loginTaglineBody,
                          style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextSubtle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 28, endIndent: 28, color: tmsDivider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(TmsStrings.loginHeading, style: tmsTextTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(TmsStrings.loginSubheading, style: tmsTextTheme.bodyMedium?.copyWith(color: tmsTextMutedAlt)),
                  const SizedBox(height: 24),
                  if (uiState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(uiState.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  _LabeledField(
                    label: TmsStrings.loginUsernameLabel,
                    value: uiState.username,
                    onChanged: notifier.onUsernameChange,
                    hint: TmsStrings.loginUsernamePlaceholder,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: TmsStrings.loginPasswordLabel,
                    value: uiState.password,
                    onChanged: notifier.onPasswordChange,
                    hint: TmsStrings.loginPasswordPlaceholder,
                    obscureText: true,
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: uiState.isLoading ? null : notifier.submit,
                      child: uiState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: tmsSurfaceWhite),
                            )
                          : Text(
                              TmsStrings.loginSignInButton,
                              style: tmsTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15.5, color: tmsSurfaceWhite),
                            ),
                    ),
                  ),
                ],
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
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: tmsTextTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
