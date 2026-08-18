import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../core/network_messages.dart';
import '../../core/notifier_lifecycle.dart';
import '../../di/providers.dart';
import '../common/strings.dart';
import 'password_reset_state.dart';

/// `isAutoDispose: true` for the same reason [loginNotifierProvider] is, and more so:
/// this state holds a new password, its confirmation, and a live single-use OTP. None
/// of the three has any business outliving the screen that collected it.
final passwordResetNotifierProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetUiState>(
  PasswordResetNotifier.new,
  isAutoDispose: true,
);

/// Drives both steps of the reset flow against `/forgot-password` and `/reset-password`.
class PasswordResetNotifier extends Notifier<PasswordResetUiState>
    with NotifierLifecycle<PasswordResetUiState, PasswordResetEvent> {
  /// One second-tick drives both the resend cooldown and the expiry estimate. Two
  /// timers would be two things to cancel and two ways to leak.
  Timer? _ticker;

  @override
  PasswordResetUiState build() {
    registerLifecycle();
    // Registered after `registerLifecycle` so it runs alongside the lifecycle's own
    // teardown. A `Timer.periodic` outlives the provider otherwise, and every tick
    // afterwards is a write to a disposed notifier.
    ref.onDispose(_stopTicker);
    return const PasswordResetUiState();
  }

  // -----------------------------------------------------------------------------
  // Input
  // -----------------------------------------------------------------------------

  void onUserNameChange(String value) {
    state = state.copyWith(
      userName: value,
      errorMessage: null,
      fieldErrors: _without(PasswordResetFields.userName),
    );
  }

  /// Digits only, capped at [PasswordResetUiState.otpLength].
  ///
  /// Filtered here as well as at the keyboard: a paste from a mail client routinely
  /// brings a trailing space or a non-breaking one with it, and a 7-character "6-digit
  /// code" is a 422 the user cannot see the cause of.
  void onOtpChange(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = digits.length > PasswordResetUiState.otpLength
        ? digits.substring(0, PasswordResetUiState.otpLength)
        : digits;
    state = state.copyWith(
      otpCode: trimmed,
      errorMessage: null,
      fieldErrors: _without(PasswordResetFields.otpCode),
    );
  }

  void onPasswordChange(String value) {
    state = state.copyWith(
      password: value,
      errorMessage: null,
      // The confirmation's error is cleared too: it is a statement about the pair, and
      // leaving "both passwords must match" under a field the user has just changed the
      // other half of is stale by construction.
      fieldErrors: _without(
        PasswordResetFields.password,
        PasswordResetFields.passwordConfirmation,
      ),
    );
  }

  void onConfirmPasswordChange(String value) {
    state = state.copyWith(
      confirmPassword: value,
      errorMessage: null,
      fieldErrors: _without(PasswordResetFields.passwordConfirmation),
    );
  }

  /// Back from step 2 to step 1.
  ///
  /// Keeps the email — it is the thing the user came back to change or confirm — and
  /// drops the code and both passwords. The code belongs to the address that was just
  /// abandoned, and a password typed for one account must not be carried to another.
  void backToEmailStep() {
    if (state.isSubmitting) return;
    _stopTicker();
    state = state.copyWith(
      step: PasswordResetStep.requestCode,
      otpCode: '',
      password: '',
      confirmPassword: '',
      errorMessage: null,
      infoMessage: null,
      fieldErrors: const {},
      resendSecondsLeft: 0,
      expirySecondsLeft: 0,
    );
  }

  // -----------------------------------------------------------------------------
  // Step 1 — request the code
  // -----------------------------------------------------------------------------

  /// Requests an OTP for the current email. Used for both the first send and every
  /// resend, so the cooldown cannot be bypassed by whichever control fires it.
  Future<void> sendCode() async {
    if (state.isSubmitting) return;
    // Only meaningful on step 2 — `resendSecondsLeft` is 0 on step 1 — but checked
    // unconditionally so the guard cannot be lost if a caller ever fires this from
    // somewhere new.
    if (state.resendSecondsLeft > 0) return;

    final email = state.userName.trim();
    final emailError = _validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(
        errorMessage: null,
        infoMessage: null,
        fieldErrors: {PasswordResetFields.userName: emailError},
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      userName: email,
      errorMessage: null,
      infoMessage: null,
      fieldErrors: const {},
    );

    // Captured before the await: a failed *resend* still consumed one of the server's
    // five requests per minute, so the cooldown has to be armed either way. Without
    // this, a 429 leaves the resend link live and the next tap earns another one.
    final isResend = state.isEnteringCode;
    final requestReset = ref.read(requestPasswordResetUseCaseProvider);
    final result = await requestReset(email);
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<String>(:final response):
        setStateIfAlive(state.copyWith(
          isSubmitting: false,
          step: PasswordResetStep.enterCode,
          // A resend invalidates whatever was typed against the previous code, and
          // leaving those digits on screen invites the user to submit a code that can
          // no longer work.
          otpCode: '',
          infoMessage: response,
          resendSecondsLeft: PasswordResetUiState.resendCooldownSeconds,
          expirySecondsLeft: PasswordResetUiState.otpLifetimeSeconds,
        ));
        _startTicker();
      case ApiError<String>(:final message, :final fieldErrors):
        _sendFailed(message, fieldErrors, isResend);
      case ApiLogout<String>(:final message):
        // Unreachable in principle — the endpoint takes no token — but a 401 must never
        // route out of this screen: the user is here precisely because they cannot get
        // a session.
        _sendFailed(message, null, isResend);
      case ApiMaintenance<String>(:final message):
        _sendFailed(message, null, isResend);
      case ApiOffline<String>(:final message):
        _sendFailed(message, null, isResend);
    }
  }

  /// A failed request for a code. Shows the failure, and re-arms the resend cooldown
  /// when the attempt was a resend — see the note at its call site.
  void _sendFailed(String? message, Map<String, String>? fieldErrors, bool isResend) {
    _applyFailure(message, fieldErrors);
    if (!isResend || isDisposed) return;
    setStateIfAlive(state.copyWith(
      resendSecondsLeft: PasswordResetUiState.resendCooldownSeconds,
    ));
    // The ticker may have stopped once both counters hit zero; the cooldown above needs
    // it running again.
    _startTicker();
  }

  // -----------------------------------------------------------------------------
  // Step 2 — verify the code and set the password
  // -----------------------------------------------------------------------------

  Future<void> submitReset() async {
    if (state.isSubmitting) return;
    if (!state.isEnteringCode) return;

    final validation = _validateResetInput();
    if (validation.isNotEmpty) {
      state = state.copyWith(errorMessage: null, fieldErrors: validation);
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      fieldErrors: const {},
    );

    final resetPassword = ref.read(resetPasswordUseCaseProvider);
    final email = state.userName.trim();
    final result = await resetPassword(
      userName: email,
      otpCode: state.otpCode,
      password: state.password,
      passwordConfirmation: state.confirmPassword,
    );
    if (isDisposed) return;

    switch (result) {
      case ApiSuccess<String>():
        _stopTicker();
        // Cleared before the screen is popped, not left to auto-dispose: the password
        // is now the account's live credential and there is no reason for it to sit in
        // memory for even the frame it takes to navigate.
        setStateIfAlive(state.copyWith(
          isSubmitting: false,
          otpCode: '',
          password: '',
          confirmPassword: '',
          errorMessage: null,
          infoMessage: null,
          resendSecondsLeft: 0,
          expirySecondsLeft: 0,
        ));
        emitEvent(PasswordResetCompleted(email));
      case ApiError<String>(:final message, :final fieldErrors):
        _applyFailure(message, fieldErrors);
      case ApiLogout<String>(:final message):
        _applyFailure(message, null);
      case ApiMaintenance<String>(:final message):
        _applyFailure(message, null);
      case ApiOffline<String>(:final message):
        _applyFailure(message, null);
    }
  }

  // -----------------------------------------------------------------------------
  // Failure handling
  // -----------------------------------------------------------------------------

  /// Splits a failure into per-field messages and a banner.
  ///
  /// A 422 carries `errors` keyed by field name. Known keys are pinned to their input;
  /// anything else — a key this client does not render — is folded into the banner
  /// rather than dropped, because a validation message nobody shows is a form that
  /// fails with no visible reason. The generic "The given data was invalid." is
  /// suppressed once at least one field is speaking for itself.
  void _applyFailure(String? message, Map<String, String>? fieldErrors) {
    final known = <String, String>{};
    final leftovers = <String>[];
    for (final entry in (fieldErrors ?? const <String, String>{}).entries) {
      if (_renderedFields.contains(entry.key)) {
        known[entry.key] = entry.value;
      } else {
        leftovers.add(entry.value);
      }
    }

    final String? banner;
    if (leftovers.isNotEmpty) {
      banner = leftovers.join('\n');
    } else if (known.isNotEmpty) {
      banner = null;
    } else {
      banner = message ?? NetworkMessages.generic;
    }

    setStateIfAlive(state.copyWith(
      isSubmitting: false,
      errorMessage: banner,
      infoMessage: null,
      fieldErrors: known,
    ));
  }

  static const _renderedFields = {
    PasswordResetFields.userName,
    PasswordResetFields.otpCode,
    PasswordResetFields.password,
    PasswordResetFields.passwordConfirmation,
  };

  // -----------------------------------------------------------------------------
  // Validation
  // -----------------------------------------------------------------------------

  /// Deliberately loose: the contract says `user_name` is always an email in practice,
  /// but the server owns the real rule. This only catches the empty field and the
  /// obviously-not-an-address, which are the two mistakes worth catching before
  /// spending one of five requests per minute.
  String? _validateEmail(String email) {
    if (email.isEmpty) return TracGoStrings.resetErrorEmailRequired;
    final looksLikeEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return looksLikeEmail ? null : TracGoStrings.resetErrorEmailInvalid;
  }

  Map<String, String> _validateResetInput() {
    final errors = <String, String>{};
    if (state.otpCode.length != PasswordResetUiState.otpLength) {
      errors[PasswordResetFields.otpCode] = TracGoStrings.resetErrorCodeRequired;
    }
    if (state.password.isEmpty) {
      errors[PasswordResetFields.password] =
          TracGoStrings.resetErrorPasswordRequired;
    } else if (state.password.length < PasswordResetUiState.minPasswordLength) {
      errors[PasswordResetFields.password] =
          TracGoStrings.resetErrorPasswordTooShort;
    } else if (state.password != state.confirmPassword) {
      // Reported on the confirmation, not on the password: that is the field the user
      // is asked to fix, and flagging both reads as two separate problems.
      errors[PasswordResetFields.passwordConfirmation] =
          TracGoStrings.resetErrorConfirmMismatch;
    }
    return errors;
  }

  Map<String, String> _without(String field, [String? alsoField]) {
    if (state.fieldErrors.isEmpty) return state.fieldErrors;
    final next = Map<String, String>.from(state.fieldErrors)..remove(field);
    if (alsoField != null) next.remove(alsoField);
    return next;
  }

  // -----------------------------------------------------------------------------
  // Countdowns
  // -----------------------------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (isDisposed) {
      _stopTicker();
      return;
    }
    final resend = state.resendSecondsLeft > 0 ? state.resendSecondsLeft - 1 : 0;
    final expiry = state.expirySecondsLeft > 0 ? state.expirySecondsLeft - 1 : 0;
    if (resend == state.resendSecondsLeft && expiry == state.expirySecondsLeft) {
      // Nothing left to count. Stops the app rebuilding this screen once a second for
      // as long as the user sits on it.
      _stopTicker();
      return;
    }
    setStateIfAlive(
      state.copyWith(resendSecondsLeft: resend, expirySecondsLeft: expiry),
    );
    if (resend == 0 && expiry == 0) _stopTicker();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
