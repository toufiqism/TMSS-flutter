import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/model/user.dart';

/// Session/token storage — flutter_secure_storage (Keystore/Keychain-backed), not
/// shared_preferences, since this is credentials-adjacent data. Hand-rolls a small JSON
/// DTO (no freezed/codegen) the same way the Android app keeps a private StoredSession DTO
/// separate from the domain Session model in SessionLocalDataSource.kt.
class SessionLocalDataSource {
  SessionLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _hydrate();
  }

  static const _sessionKey = 'session_json';

  final FlutterSecureStorage _storage;
  final StreamController<Session?> _controller = StreamController<Session?>.broadcast();
  Session? _current;
  bool _hydrated = false;
  final List<Completer<void>> _hydrationWaiters = [];

  Stream<Session?> get session async* {
    if (!_hydrated) {
      final completer = Completer<void>();
      _hydrationWaiters.add(completer);
      await completer.future;
    }
    yield _current;
    yield* _controller.stream;
  }

  Future<void> _hydrate() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _current = _sessionFromJson(json);
      }
    } catch (_) {
      // Corrupt/unreadable stored session — treat as logged out rather than crash on launch.
      _current = null;
    } finally {
      _hydrated = true;
      for (final waiter in _hydrationWaiters) {
        waiter.complete();
      }
      _hydrationWaiters.clear();
    }
  }

  Future<void> save(Session session) async {
    _current = session;
    await _storage.write(key: _sessionKey, value: jsonEncode(_sessionToJson(session)));
    _controller.add(session);
  }

  Future<void> clear() async {
    _current = null;
    await _storage.delete(key: _sessionKey);
    _controller.add(null);
  }

  Map<String, dynamic> _sessionToJson(Session session) => {
        'token': session.token,
        'userId': session.user.id,
        'userName': session.user.name,
        'userDesignation': session.user.designation,
        'userEmail': session.user.email,
      };

  Session _sessionFromJson(Map<String, dynamic> json) => Session(
        token: json['token'] as String,
        user: User(
          id: json['userId'] as String,
          name: json['userName'] as String,
          designation: json['userDesignation'] as String,
          email: json['userEmail'] as String,
        ),
      );
}
