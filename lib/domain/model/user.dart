import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String designation,
    required String email,
  }) = _User;
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
