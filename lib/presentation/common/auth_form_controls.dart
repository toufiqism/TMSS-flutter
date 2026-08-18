import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'motion.dart';
import 'strings.dart';
import 'synced_text_field.dart';

/// The controls the signed-out screens are built from.
///
/// Both started life private to `login_screen.dart`. The password-reset flow needs the
/// identical field and the identical button — same underline, same pill, same disabled
/// treatment — and a second copy of either is exactly the drift that turned
/// `RequisitionRecentRow` into a second requisition row. So they moved here and Login
/// uses them too; there is one definition of what a signed-out field looks like.

/// Minimum height of a field's input row, set by the tallest thing that can sit in one
/// — the reveal toggle, whose padding buys it a 44px tap target.
const double _fieldContentHeight = 44;

/// A field drawn as a baseline rule rather than a filled box, per the design: uppercase
/// caption, then the input, then a 1.5px underline.
///
/// When [obscureText] is set it also gains a reveal toggle, because a masked field with
/// no way to check what was typed is the usual cause of a sign-in failure that is really
/// a typo.
///
/// [errorText] draws the rule in the destructive colour and prints the message beneath
/// it. That is where the server's 422 `errors` map lands, one entry per field, so a
/// rejected password says so at the password rather than in a banner the user has to
/// map back onto a field themselves.
class AuthUnderlinedField extends StatefulWidget {
  const AuthUnderlinedField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.errorText,
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
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final VoidCallback? onSubmitted;
  final bool enabled;

  @override
  State<AuthUnderlinedField> createState() => _AuthUnderlinedFieldState();
}

class _AuthUnderlinedFieldState extends State<AuthUnderlinedField> {
  /// Starts masked, and is never persisted or lifted into notifier state: it is view
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
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: tracGoTextTheme.labelMedium?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1, // 0.1em at 11px
            color: hasError ? tracGoDestructiveRed : tracGoTextMutedAlt,
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
                  // during a request would toggle a field the user cannot edit.
                  onPressed: widget.enabled
                      ? () => setState(() => _revealed = !_revealed)
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ColoredBox(
          color: hasError ? tracGoDestructiveRed : tracGoRule,
          child: const SizedBox(height: 1.5, width: double.infinity),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText!,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: tracGoDestructiveRed,
              ),
            ),
          ),
      ],
    );
  }
}

/// A field-shaped row whose value the user is not allowed to change.
///
/// Same caption, same 1.5px rule and the same vertical rhythm as [AuthUnderlinedField],
/// so it sits in a form beside one without breaking the column — but it is not a text
/// field at all: no cursor, no keyboard, no autofill, nothing for a tap to focus. That
/// is deliberate. A disabled `TextField` reads as *temporarily* unavailable, the way
/// every other field on these screens looks while a request is in flight; this value is
/// fixed for the life of the screen, and the lock glyph plus [note] say why.
///
/// [errorText] still applies: the server can reject a value this client did not let the
/// user choose, and that message has to land somewhere the user can see it.
class AuthReadOnlyField extends StatelessWidget {
  const AuthReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.errorText,
  });

  final String label;
  final String value;

  /// One line under the rule explaining why the value cannot be edited.
  final String? note;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: tracGoTextTheme.labelMedium?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1, // 0.1em at 11px
            color: hasError ? tracGoDestructiveRed : tracGoTextMutedAlt,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          // The same floor as an editable field's input row, so a locked field and a
          // typed one are the same height at the same text scale.
          constraints: const BoxConstraints(minHeight: _fieldContentHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  // Wraps rather than ellipsises: this is the address the code is being
                  // sent to, and a truncated one is exactly the detail the user is here
                  // to check.
                  style: tracGoTextTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: tracGoInk,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.lock_outline,
                size: 18,
                color: tracGoTextMutedAlt,
                semanticLabel: TracGoStrings.resetEmailLockedSemanticLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ColoredBox(
          color: hasError ? tracGoDestructiveRed : tracGoRule,
          child: const SizedBox(height: 1.5, width: double.infinity),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: tracGoDestructiveRed,
              ),
            ),
          )
        else if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              note!,
              style: tracGoTextTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: tracGoTextMuted,
              ),
            ),
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

/// The pill primary button from the design: flat green, no Material elevation, with a
/// soft green-tinted drop shadow of its own.
///
/// [isLoading] both disables the button and swaps the label for a spinner, so a
/// double-tap cannot fire a second request while the first is in flight — the notifier
/// guards that too, but the control should not invite the tap in the first place.
class AuthPillButton extends StatelessWidget {
  const AuthPillButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
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
          // The key must sit on the switcher's own child, not inside it: without one
          // that changes, `MotionSwitcher` sees the same widget type either side of the
          // swap and cross-fades nothing.
          child: _AuthPillButtonLabel(
            key: ValueKey(isLoading),
            label: label,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }
}

/// The button's label/spinner swap.
class _AuthPillButtonLabel extends StatelessWidget {
  const _AuthPillButtonLabel({
    super.key,
    required this.label,
    required this.isLoading,
  });

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Text(
      label,
      style: tracGoTextTheme.labelLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
