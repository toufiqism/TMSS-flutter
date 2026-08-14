import 'package:flutter/material.dart';

/// Re-adds the system's bottom inset — Android's gesture bar or navigation buttons, and
/// the iOS home indicator — to padding that was written as a literal.
///
/// Android 15 (API 35) made edge-to-edge mandatory for apps targeting it, and this app
/// targets 36. Content therefore draws *underneath* the navigation bar by default.
/// Flutter would normally derive a scroll view's padding from `MediaQuery` and handle
/// this, but passing an explicit `padding` **replaces** that derivation rather than
/// adding to it. Every screen here passes an explicit padding, which is exactly how the
/// bottom of the requisition list and the detail screen's actions ended up sitting under
/// the nav buttons.
///
/// Uses `padding`, not `viewPadding`: when the keyboard is open the system bar inset is
/// already subsumed by `viewInsets`, and `padding.bottom` correctly collapses to zero so
/// the content is not pushed twice.
extension BottomSystemInset on EdgeInsets {
  EdgeInsets addBottomSystemInset(BuildContext context) =>
      copyWith(bottom: bottom + MediaQuery.paddingOf(context).bottom);
}
