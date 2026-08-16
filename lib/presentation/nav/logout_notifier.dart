import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_result.dart';
import '../../di/providers.dart';

/// Whether a sign-out is in flight, and the single entry point that starts one.
///
/// State rather than a local `setState` because the widget that owns the button — the
/// drawer's logout row — is disposed the moment the drawer closes. A flag living there
/// would reset the instant the user reopened the drawer, which is exactly when they
/// would tap Log Out again after nothing appeared to happen.
///
/// Deliberately **not** `isAutoDispose`: it has to outlive the drawer that reads it.
final logoutNotifierProvider =
    NotifierProvider<LogoutNotifier, bool>(LogoutNotifier.new);

class LogoutNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Signs out. Returns the server's verdict on the token revoke, or null when the
  /// call was ignored because one was already running — the caller must not report
  /// that as a failure, since a sign-out is genuinely in progress.
  ///
  /// The local session is cleared regardless of the result (see
  /// `AuthRepository.logout`), so the router redirects to Login either way.
  Future<ApiResult<void>?> logout() async {
    if (state) return null;
    state = true;
    try {
      return await ref.read(logoutUseCaseProvider)();
    } finally {
      // `ref.mounted`, because the successful path tears the shell down: the session
      // clears, the router swaps in Login, and the container that owns this notifier
      // can be gone before the finally runs. Writing state then throws.
      if (ref.mounted) state = false;
    }
  }
}
