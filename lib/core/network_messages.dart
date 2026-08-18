/// Default user-facing text for network failures.
///
/// These live in `core/` rather than `presentation/common/strings.dart` because the
/// data layer produces them: `data → presentation` would invert the dependency
/// direction the rest of the app maintains.
///
/// Each is a *fallback*. When the server sends a `message` in its error envelope that
/// wins, since it can say something specific ("Pickup date must be in the future")
/// that a generic client string never could.
class NetworkMessages {
  NetworkMessages._();

  static const generic = 'Something went wrong. Please try again.';
  static const offline = 'No internet connection available';
  static const timeout = 'The server took too long to respond. Please try again.';
  static const secureConnection = 'Could not establish a secure connection.';
  static const unexpectedResponse = 'The server sent an unexpected response.';
  static const validation = 'Please check the highlighted fields.';
  static const maintenance = 'The system is under maintenance. Please try again later.';
  static const sessionExpired = 'Your session expired. Please sign in again.';
  static const notPermitted = "You don't have permission to do that.";
  static const notFound = 'That requisition no longer exists.';

  /// 409 from update/cancel. The contract is explicit that this is an expected path
  /// rather than a fault: the requisition left `Pending` while the client held a stale
  /// copy, so the wording points at the refresh that follows rather than blaming the
  /// user.
  static const stale = 'This requisition just changed. The list has been refreshed.';

  /// 429. Both `/login` and `/forgot-password` carry their own scoped throttle, and
  /// the framework's own wording ("Too Many Attempts.") says nothing about what to do
  /// next, so this is used whenever the server sends no message of its own.
  static const tooManyRequests =
      'Too many attempts. Please wait a minute and try again.';

  /// Fallbacks for the two password-reset endpoints, used only when the server answers
  /// 200 with no `message`. Both are worded to match the contract's own: the first
  /// deliberately does not confirm that the account exists.
  static const passwordResetCodeSent =
      'If an account matches, a password reset code has been sent.';
  static const passwordResetComplete = 'Password has been reset successfully.';

  /// Operations the contract does not define. Surfaced if one is somehow reached
  /// despite the `ApiCapabilities` gates in the UI.
  static const unsupportedOperation =
      'That is not available yet in this version of the app.';
}
