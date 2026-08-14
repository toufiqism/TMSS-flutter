import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/user.dart';

part 'profile_state.freezed.dart';

/// The account half of the profile — `GET /user` and nothing else.
///
/// The person's identity (name, designation, email, phone, company) deliberately does
/// **not** live here. It comes from the session, which the screen watches directly, so
/// it renders on the first frame and survives a failed or offline account fetch. Mixing
/// the two into one state only created an ordering problem: the session stream resolves
/// asynchronously, so a notifier reading it at construction could see nothing.
@freezed
abstract class ProfileUiState with _$ProfileUiState {
  const factory ProfileUiState({
    UserAccount? account,
    @Default(true) bool isLoading,
    String? errorMessage,

    /// False for terminal failures such as 403, where retrying cannot help.
    @Default(true) bool canRetry,
  }) = _ProfileUiState;
}

sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileSessionExpired extends ProfileEvent {
  const ProfileSessionExpired(this.message);
  final String message;
}
