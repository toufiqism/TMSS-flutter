import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/colors.dart';
import '../../theme/shapes.dart';
import '../../theme/typography.dart';
import '../common/strings.dart';

/// Height of one box. Fixed rather than derived, so the row cannot change height as
/// digits are typed; the digit itself scales inside via [FittedBox].
const double _boxHeight = 58;

/// Gap between boxes. Kept small because six boxes plus five gaps have to fit inside a
/// 320dp screen's content column.
const double _boxGap = 8;

/// Six boxes that read as six inputs and behave as one.
///
/// Deliberately **not** six `TextField`s with six controllers and auto-advance. That
/// arrangement has to hand-implement backspace-into-the-previous-box, paste spread
/// across boxes, and IME composition, and gets at least one of them wrong on one
/// platform. Here a single transparent field spans the row and the boxes are painted
/// from its value, so the platform keeps doing the input work: paste of "123456" fills
/// all six, backspace clears the last, and iOS/Android SMS autofill drops the code
/// straight in via [AutofillHints.oneTimeCode].
///
/// The caret is not drawn; the active box's heavier border stands in for it.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
    this.length = 6,
    this.enabled = true,
    this.hasError = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final int length;
  final bool enabled;

  /// Draws every box in the destructive colour. The message itself belongs to the
  /// caller, next to the caption, so this widget never renders text of its own.
  final bool hasError;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // The active box is drawn from focus, so the row has to repaint when focus moves.
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(OtpCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Same two-way sync as `SyncedTextField`: the notifier clears the code on a resend
    // and after a successful reset, and without this the digits would stay on screen
    // while the state behind them was empty.
    if (widget.value == _controller.text) return;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    // The box the next digit lands in. Clamped so a full code leaves the last box
    // highlighted rather than pointing past the end of the row.
    final activeIndex = value.length.clamp(0, widget.length - 1);
    final hasFocus = _focusNode.hasFocus;

    return Semantics(
      textField: true,
      label: TracGoStrings.resetCodeSemanticLabel,
      value: value,
      excludeSemantics: true,
      child: SizedBox(
        height: _boxHeight,
        child: Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: _boxGap),
                  Expanded(
                    child: _OtpBox(
                      character: i < value.length ? value[i] : null,
                      isActive: hasFocus && widget.enabled && i == activeIndex,
                      hasError: widget.hasError,
                      enabled: widget.enabled,
                    ),
                  ),
                ],
              ],
            ),
            // On top of the boxes, invisible: it owns the keyboard, the selection and
            // the paste menu, and a tap anywhere along the row lands on it.
            Positioned.fill(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onSubmitted: (_) => widget.onSubmitted?.call(),
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                // Digits are painted by the boxes below. Drawing them here too would
                // show the code twice, offset by whatever the field's own padding is.
                style: const TextStyle(color: Colors.transparent, fontSize: 24),
                cursorColor: Colors.transparent,
                showCursor: false,
                cursorWidth: 0,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.character,
    required this.isActive,
    required this.hasError,
    required this.enabled,
  });

  final String? character;
  final bool isActive;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    if (hasError) {
      borderColor = tracGoDestructiveRed;
    } else if (isActive) {
      borderColor = tracGoGreen;
    } else if (character != null) {
      borderColor = tracGoRule;
    } else {
      borderColor = tracGoBorder;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled ? tracGoInputBackground : tracGoSurfaceSoft,
        borderRadius: tracGoBorderRadius(tracGoRadiusSmall),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1.5),
      ),
      child: Center(
        // The box height is fixed, so a user at 3x text scaling would otherwise push
        // the digit out of it. Scaling down keeps the code readable and the row intact.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              character ?? '',
              style: tracGoTextTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: hasError ? tracGoDestructiveRed : tracGoInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
