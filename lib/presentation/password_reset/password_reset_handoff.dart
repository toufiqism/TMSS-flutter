import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A one-shot handoff of the reset flow's email to the Login screen.
///
/// The reset started from Login can simply call a method on the login notifier, because
/// that screen is still mounted underneath the pushed route. The one started from
/// Profile cannot: finishing it clears the session, and the router tears the whole
/// signed-in stack down and *builds Login for the first time*. There is no notifier to
/// call at the moment the reset completes, and the one that exists a frame later was
/// created after the fact.
///
/// So the email is parked here instead, and `LoginNotifier.build` takes it on the way
/// in. [take] empties the slot, so a value is delivered exactly once — a later visit to
/// Login must not be greeted by a "password updated" note from twenty minutes ago.
///
/// A plain mutable object behind a `Provider`, deliberately, rather than a
/// `Notifier<String?>`: Riverpod asserts that a provider may not modify another
/// provider while building, and taking the value *is* a write. Nothing watches this —
/// it is a mailbox, not state — so provider-state semantics would buy nothing and cost
/// the one call site that matters.
final passwordResetHandoffProvider = Provider<PasswordResetHandoff>(
  (ref) => PasswordResetHandoff(),
);

class PasswordResetHandoff {
  String? _staged;

  /// Whether an email is waiting to be collected. For tests and assertions; the Login
  /// screen uses [take].
  bool get isStaged => _staged != null;

  void stage(String userName) => _staged = userName;

  String? take() {
    final staged = _staged;
    _staged = null;
    return staged;
  }
}
