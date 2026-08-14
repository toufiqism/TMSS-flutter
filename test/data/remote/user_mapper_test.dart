import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/data/remote/dto/user_mapper.dart';

void main() {
  group('fromLoginData', () {
    test('captures the identity fields the login response actually carries', () {
      final user = UserMapper.fromLoginData(
        {
          'token': 'abc',
          'expires_at': '2027-08-14 00:32:59',
          'name': 'Md. Tofiq Akbar',
          'designation': 'Senior Engineer',
          'phone': '01700000000',
          'company_name': 'B-Trac Solutions Limited',
        },
        username: 'tofiq.akbar@btracsl.com',
      );

      expect(user.name, 'Md. Tofiq Akbar');
      expect(user.designation, 'Senior Engineer');
      expect(user.phone, '01700000000');
      expect(user.companyName, 'B-Trac Solutions Limited');
      expect(user.email, 'tofiq.akbar@btracsl.com');
    });

    test('missing optional identity fields stay null rather than becoming empty', () {
      final user = UserMapper.fromLoginData(
        {'token': 'abc'},
        username: 'tofiq.akbar@btracsl.com',
      );

      expect(user.phone, isNull);
      expect(user.companyName, isNull);
      // Falls back to a name derived from the email.
      expect(user.name, 'Tofiq Akbar');
    });
  });

  group('accountFromJson', () {
    /// The real `GET /user` body, captured live. Note it is a **bare object** — no
    /// {success, message, data} envelope, unlike every other endpoint.
    Map<String, dynamic> body() => {
          'id': 864,
          'user_name': 'tofiq.akbar@btracsl.com',
          'role_id': 1,
          'employee_id': 3035,
          'is_first_login': 'Yes',
          'last_pasword_updated_at': '2026-07-16 05:55:18',
          'active_status': 'Active',
          'remember_token': '39YxgqnJIWKbnYRqf9vbZHaEWrU9zmGRIeWhNwaR0qvRDqm6PG8VK5raB1VL',
          'api_token_expires_at': '2027-08-14 00:32:59',
          'created_at': '2025-10-12 12:26:42',
        };

    test('maps the account row, coercing numeric ids to strings', () {
      final account = UserMapper.accountFromJson(body());

      expect(account.id, '864');
      expect(account.employeeId, '3035');
      expect(account.roleId, '1');
      expect(account.activeStatus, 'Active');
      expect(account.email, 'tofiq.akbar@btracsl.com');
    });

    test('reads the server\'s misspelled last_pasword_updated_at', () {
      // The typo is the server's. Matching it exactly is required; the corrected
      // spelling is accepted too, in case it is ever fixed.
      final account = UserMapper.accountFromJson(body());

      expect(account.lastPasswordChangedAt, isNotNull);
      expect(
        UserMapper.accountFromJson({'last_password_updated_at': '2026-07-16 05:55:18'})
            .lastPasswordChangedAt,
        isNotNull,
      );
    });

    test('timestamps are read as UTC, matching the rest of this API', () {
      final account = UserMapper.accountFromJson(body());

      expect(account.memberSince!.toUtc(), DateTime.utc(2025, 10, 12, 12, 26, 42));
    });

    test('an empty body yields nulls rather than throwing', () {
      final account = UserMapper.accountFromJson({});

      expect(account.id, isNull);
      expect(account.employeeId, isNull);
      expect(account.memberSince, isNull);
    });

    test('the model has nowhere to put remember_token', () {
      // The response leaks it in plaintext; this client must never hold or render it.
      final account = UserMapper.accountFromJson(body());

      expect(
        account.toString(),
        isNot(contains('39Yxgq')),
        reason: 'remember_token must not reach the domain model',
      );
    });
  });
}
