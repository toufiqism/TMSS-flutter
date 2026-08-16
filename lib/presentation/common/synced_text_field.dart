import 'package:flutter/material.dart';

/// A text field whose visible text tracks notifier state in both directions.
///
/// `TextFormField(initialValue: x)` seeds its controller once, in `initState`, and
/// ignores every later change to `x`. That is fine while the user is the only thing
/// writing the field, and wrong the moment state is reset from elsewhere: tapping
/// "Reset" on the requisition list cleared `searchQuery` in the notifier but left the
/// typed text sitting on screen, so the list showed unfiltered results under a search
/// box that still displayed a query.
///
/// This owns the controller and pushes external changes into it. Changes that
/// originated from the user's own keystrokes are already reflected in the controller,
/// so they compare equal and the cursor is left untouched.
class SyncedTextField extends StatefulWidget {
  const SyncedTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.isSensitive,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.autofillHints,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final String? errorText;
  final bool obscureText;

  /// Whether the content must be kept out of the keyboard's learning dictionary,
  /// autocorrect and smart punctuation, independently of whether it is currently
  /// masked.
  ///
  /// Defaults to [obscureText], which is right for a field that is always masked. A
  /// field with a reveal toggle **must** pass `true` explicitly: otherwise the moment
  /// the user unmasks their password, suggestions and autocorrect switch back on and
  /// the keyboard starts learning it — a leak that outlives the app, and one that is
  /// completely invisible while it happens.
  final bool? isSensitive;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final int maxLines;

  /// Hard character limit, matching the server's own `max:` rule for the field.
  ///
  /// Enforced at the keyboard so the limit is unreachable by typing, rather than only
  /// reported after a failed submit. The counter is suppressed in [build]: this app's
  /// inputs are fixed-height pills, and Material's counter line would push the layout
  /// around on every field that has one.
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final List<String>? autofillHints;
  final bool enabled;

  @override
  State<SyncedTextField> createState() => _SyncedTextFieldState();
}

class _SyncedTextFieldState extends State<SyncedTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(SyncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _controller.text) return;
    // State changed from outside this field (a reset, a cleared form). Adopt it and
    // park the caret at the end — there is no meaningful old caret position to keep
    // when the text was replaced wholesale.
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSensitive = widget.isSensitive ?? widget.obscureText;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
      // Keyed off sensitivity, not masking: a revealed password is still one line.
      maxLines: isSensitive ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      // Passwords must never be logged to a keyboard's learning dictionary — including
      // while the user has them on screen.
      enableSuggestions: !isSensitive,
      autocorrect: !isSensitive,
      smartDashesType: isSensitive ? SmartDashesType.disabled : SmartDashesType.enabled,
      smartQuotesType: isSensitive ? SmartQuotesType.disabled : SmartQuotesType.enabled,
      decoration: InputDecoration(
        // Empty, not null: null restores Material's default "12/200" counter, which is
        // what the fixed-height pill design cannot absorb.
        counterText: '',
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        fillColor: widget.fillColor,
      ),
    );
  }
}
