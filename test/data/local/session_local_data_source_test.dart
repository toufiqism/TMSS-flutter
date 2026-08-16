import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracgo/data/local/session_local_data_source.dart';
import 'package:tracgo/domain/model/user.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _user = User(
  id: 'tofiq.akbar@btracsl.com',
  name: 'Md. Tofiq Akbar',
  designation: 'Senior Engineer',
  email: 'tofiq.akbar@btracsl.com',
);

String _storedJson({String? expiresAt}) => jsonEncode({
      'token': 'abc123',
      'userId': _user.id,
      'userName': _user.name,
      'userDesignation': _user.designation,
      'userEmail': _user.email,
      'expiresAt': ?expiresAt,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterSecureStorage storage;

  setUp(() {
    storage = MockFlutterSecureStorage();
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  /// [installed] mirrors whether a previous run of *this installation* left its marker.
  SessionLocalDataSource build({required bool installed}) {
    SharedPreferences.setMockInitialValues(
      installed ? {'session_storage_initialised': true} : {},
    );
    final dataSource = SessionLocalDataSource(
      storage: storage,
      preferences: SharedPreferences.getInstance,
    );
    addTearDown(dataSource.dispose);
    return dataSource;
  }

  group('fresh install', () {
    test('discards a session the Keychain kept across an uninstall', () async {
      // iOS does not delete Keychain items when the app is deleted, so a reinstall
      // would otherwise come up "signed in" holding a long-dead token.
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => _storedJson());

      final dataSource = build(installed: false);

      expect(await dataSource.session.first, isNull);
      verify(() => storage.delete(key: 'session_json')).called(1);
    });

    test('sets the marker so the next launch hydrates normally', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

      final dataSource = build(installed: false);
      await dataSource.session.first;

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('session_storage_initialised'), isTrue);
    });

    test('an already-marked install hydrates its stored session', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => _storedJson());

      final dataSource = build(installed: true);

      final session = await dataSource.session.first;
      expect(session?.token, 'abc123');
      expect(session?.user.name, 'Md. Tofiq Akbar');
      verifyNever(() => storage.delete(key: any(named: 'key')));
    });
  });

  group('expiry', () {
    test('an expired stored token is dropped rather than hydrated', () async {
      // Otherwise the app renders a signed-in shell that 401s on its first request.
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (_) async => _storedJson(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ),
      );

      final dataSource = build(installed: true);

      expect(await dataSource.session.first, isNull);
      expect(dataSource.currentToken, isNull);
      verify(() => storage.delete(key: 'session_json')).called(1);
    });

    test('an unexpired token hydrates and is offered to the interceptor', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (_) async => _storedJson(
          expiresAt: DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        ),
      );

      final dataSource = build(installed: true);
      await dataSource.session.first;

      expect(dataSource.currentToken, 'abc123');
    });

    test('a session written before expiry existed is not treated as expired', () async {
      // Backward compatibility: the key is simply absent, which means "unknown", and
      // guessing "dead" would sign out a working user on upgrade.
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => _storedJson());

      final dataSource = build(installed: true);
      await dataSource.session.first;

      expect(dataSource.currentToken, 'abc123');
    });

    test('an unparseable expiry is treated as unknown, not as expired', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => _storedJson(expiresAt: 'not a date'));

      final dataSource = build(installed: true);
      await dataSource.session.first;

      expect(dataSource.currentToken, 'abc123');
    });

    test('expiry round-trips through save and is persisted as UTC ISO-8601', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
      final dataSource = build(installed: true);
      await dataSource.session.first;
      final expiry = DateTime.now().add(const Duration(days: 365));

      await dataSource.save(Session(token: 'abc123', user: _user, expiresAt: expiry));

      final written = verify(
        () => storage.write(key: 'session_json', value: captureAny(named: 'value')),
      ).captured.single as String;
      final decoded = jsonDecode(written) as Map<String, dynamic>;
      expect(DateTime.parse(decoded['expiresAt'] as String).isUtc, isTrue);
      expect(
        DateTime.parse(decoded['expiresAt'] as String)
            .difference(expiry.toUtc())
            .inSeconds,
        0,
      );
    });
  });

  group('resilience', () {
    test('corrupt JSON reads as logged out instead of crashing at launch', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'not json at all');

      final dataSource = build(installed: true);

      expect(await dataSource.session.first, isNull);
    });

    test('a storage read failure reads as logged out', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenThrow(Exception('keychain unavailable'));

      final dataSource = build(installed: true);

      expect(await dataSource.session.first, isNull);
    });

    test('a failed secure write still yields a usable in-memory session', () async {
      // The server has already authenticated the user; failing the login because the
      // Keystore hiccuped would be the wrong trade.
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenThrow(Exception('write failed'));
      final dataSource = build(installed: true);
      await dataSource.session.first;

      await dataSource.save(const Session(token: 'abc123', user: _user));

      expect(dataSource.currentToken, 'abc123');
    });

    test('clear drops the session even if the secure delete fails', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => _storedJson());
      final dataSource = build(installed: true);
      await dataSource.session.first;
      when(() => storage.delete(key: any(named: 'key')))
          .thenThrow(Exception('delete failed'));

      await dataSource.clear();

      expect(dataSource.currentToken, isNull);
    });

    test('emits every session change to listeners', () async {
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
      final dataSource = build(installed: true);
      final seen = <Session?>[];
      final sub = dataSource.session.listen(seen.add);
      await Future<void>.delayed(Duration.zero);

      await dataSource.save(const Session(token: 'abc123', user: _user));
      await dataSource.clear();
      await Future<void>.delayed(Duration.zero);

      expect(seen.map((s) => s?.token), [null, 'abc123', null]);
      await sub.cancel();
    });
  });
}
