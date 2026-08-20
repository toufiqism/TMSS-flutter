import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_state.freezed.dart';

/// Which half of the flow the single `/forgot-password` route is showing.
///
/// One route, two steps, rather than two routes: the second step needs the email the
/// first one sent, and carrying it as a navigation payload buys a deep-link case
/// (`/reset-password` with no email) that has no sensible answer.
enum PasswordResetStep {
  /// Asking for the email to send an OTP to.
  requestCode,

  /// OTP has been requested; collecting the code and the new password.
  enterCode,
}

/// Field keys as the server names them in a 422 `errors` map. Errors are stored under
/// these rather than under widget-local names so a server message and a client-side
/// check land in exactly the same place.
class PasswordResetFields {
  PasswordResetFields._();

  static const userName = 'user_name';
  static const otpCode = 'otp_code';
  static const password = 'password';
  static const passwordConfirmation = 'password_confirmation';
}

@freezed
abstract class PasswordResetUiState with _$PasswordResetUiState {
  const factory PasswordResetUiState({
    @Default(PasswordResetStep.requestCode) PasswordResetStep step,
    @Default('') String userName,
    @Default('') String otpCode,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool isSubmitting,

    /// Failure text for the whole form. Field-specific messages go to [fieldErrors]
    /// instead, so the user is not asked to work out which input a banner refers to.
    String? errorMessage,

    /// The server's own success wording from `/forgot-password`, shown above step 2.
    String? infoMessage,
    @Default(<String, String>{}) Map<String, String> fieldErrors,

    /// Seconds until "Resend code" is available again. Client-side only, and set to
    /// [resendCooldownSeconds] after every send: the server throttles this endpoint at
    /// 5/min, and a resend button with no cooldown walks the user straight into a 429.
    @Default(0) int resendSecondsLeft,

    /// Seconds until the OTP is expected to expire, counted down from
    /// [otpLifetimeSeconds]. An estimate of the server's `OTP_EXPIRY_MINUTES`, not a
    /// fact — the server never sends the real deadline — so it never blocks a submit.
    @Default(0) int expirySecondsLeft,
  }) = _PasswordResetUiState;

  const PasswordResetUiState._();

  /// Length of the emailed code, per the contract.
  static const otpLength = 6;

  /// Minimum length the client insists on before spending a request.
  ///
  /// The contract documents no password policy at all — only a `NewPass123` example —
  /// so this is a floor the client applies, not a mirror of a server rule. A server
  /// that disagrees answers 422 and its message wins.
  static const minPasswordLength = 6;

  /// Kept under the server's own 5/min throttle with room to spare.
  static const resendCooldownSeconds = 60;

  /// The contract's default `OTP_EXPIRY_MINUTES` is 10.
  static const otpLifetimeSeconds = 10 * 60;

  bool get isEnteringCode => step == PasswordResetStep.enterCode;

  /// True once the local estimate of the OTP's lifetime has run out. Advisory: the
  /// submit button stays live, because only the server knows whether the code still
  /// works and a client clock that is slow would otherwise lock out a valid code.
  bool get isCodeExpired => isEnteringCode && expirySecondsLeft == 0;

  bool get canResend => isEnteringCode && !isSubmitting && resendSecondsLeft == 0;

  /// `mm:ss` for the expiry caption.
  String get expiryLabel {
    final minutes = expirySecondsLeft ~/ 60;
    final seconds = expirySecondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? fieldError(String field) => fieldErrors[field];
}

sealed class PasswordResetEvent {
  const PasswordResetEvent();
}

/// The password was changed. Carries the email so Login can prefill it — the account's
/// token is invalidated server-side, so the user has to sign in again either way.
class PasswordResetCompleted extends PasswordResetEvent {
  const PasswordResetCompleted(this.userName);

  final String userName;
}
