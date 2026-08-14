import '../../../domain/model/user.dart';
import 'json_reader.dart';
import 'wire_date_time.dart';

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
      phone: data.stringOrNull('phone'),
      companyName: data.stringOrNull('company_name'),
    );
  }

  /// Parses `GET /user`.
  ///
  /// **No envelope.** Every other endpoint answers `{success, message, data}`; this one
  /// returns the account row bare, so there is nothing to unwrap and looking for `data`
  /// would find nothing.
  ///
  /// `remember_token` is present in the response and is deliberately never read.
  ///
  /// Note `last_pasword_updated_at` — the typo is the server's, and matching it exactly
  /// is required. The correct spelling is also accepted in case it is ever fixed.
  static UserAccount accountFromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json.idOrNull('id'),
      email: json.stringFrom(['user_name', 'email']),
      employeeId: json.idOrNull('employee_id'),
      roleId: json.idOrNull('role_id'),
      activeStatus: json.stringOrNull('active_status'),
      // Server timestamps on this API are UTC, like `created_at` elsewhere.
      memberSince: WireDateTime.parseUtc(json.stringOrNull('created_at')),
      lastPasswordChangedAt: WireDateTime.parseUtc(
        json.stringFrom(['last_pasword_updated_at', 'last_password_updated_at']),
      ),
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
