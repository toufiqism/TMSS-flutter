import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// The signed-in person, as the *login* response describes them.
///
/// Deliberately not the same thing as [UserAccount]: everything here comes from
/// `POST /login` and is persisted with the session, because the drawer renders it on
/// every screen and must not need a network call to do so.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String designation,
    required String email,
    String? phone,
    String? companyName,
  }) = _User;
}

/// The account row behind the token, from `GET /user`.
///
/// Kept separate from [User] and **not** persisted: it is account metadata rather than
/// identity, it is only needed on the profile screen, and staleness matters more here
/// (an account can be deactivated between launches).
///
/// `GET /user` also returns `remember_token` in plaintext. It is deliberately not
/// modelled — there is no reason for this client to hold it, let alone display it.
@freezed
abstract class UserAccount with _$UserAccount {
  const factory UserAccount({
    String? id,
    String? email,
    String? employeeId,
    String? roleId,
    String? activeStatus,
    DateTime? memberSince,
    DateTime? lastPasswordChangedAt,
  }) = _UserAccount;
}

@freezed
abstract class Session with _$Session {
  const Session._();

  const factory Session({
    required String token,
    required User user,

    /// When the bearer token stops being accepted.
    ///
    /// The login response carries `expires_at` (roughly a year out). Null means the
    /// server did not say — treated as "no known expiry" rather than "expired", because
    /// guessing the token is dead would sign a working user out for no reason.
    DateTime? expiresAt,
  }) = _Session;

  /// Whether the token is known to be past its stated lifetime.
  ///
  /// A false here is not a promise the token still works — it can be revoked server-side
  /// at any time, which surfaces as a 401. This only catches the case the client *can*
  /// know about without a round-trip.
  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && !expiry.isAfter(DateTime.now());
  }
}
