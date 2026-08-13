import '../../../domain/model/user.dart';
import 'json_reader.dart';

/// Builds the domain [User] from what the server actually returns.
///
/// The contract said the login response confirmed only `data.token`, and that a second
/// `GET /user` call would be needed for the account. Neither held: `POST /login`
/// returns `name`, `designation`, `phone` and `company_name` alongside the token, so
/// one round-trip is enough.
///
/// `GET /user` is a different shape again — a **bare object**, no `data` envelope —
/// carrying `id`, `user_name` (the email) and `employee_id`, but *not* the name or
/// designation. So the two endpoints are complementary rather than redundant, and
/// [fromLoginData] is the one the login flow uses.
class UserMapper {
  UserMapper._();

  /// From `POST /login`'s `data` object.
  ///
  /// No user id is present there, and none is needed: the API resolves the acting user
  /// from the bearer token and takes no user id on any request. The email doubles as
  /// the local identifier.
  static User fromLoginData(Map<String, dynamic> data, {required String username}) {
    return User(
      id: username,
      name: data.stringOrNull('name') ?? _nameFromEmail(username),
      designation: data.stringOrNull('designation') ?? '',
      email: username,
    );
  }

  /// From `GET /user`'s bare object. Used to enrich an existing session with the real
  /// account id, not to build one from scratch — this response has no display name.
  static User mergeAccount(User base, Map<String, dynamic> json) {
    return base.copyWith(
      id: json.idOrNull('id') ?? json.idOrNull('employee_id') ?? base.id,
      email: json.stringFrom(['user_name', 'email']) ?? base.email,
    );
  }

  /// Last-resort display name: `tofiq.akbar@x.com` -> `Tofiq Akbar`. Only reached when
  /// the login response carries no `name`.
  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return email;
    return local
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
