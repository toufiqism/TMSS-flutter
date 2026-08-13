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
    unawaited(_hydrate());
  }

  static const _sessionKey = 'session_json';

  final FlutterSecureStorage _storage;
  final StreamController<Session?> _controller = StreamController<Session?>.broadcast();
  Session? _current;
  bool _hydrated = false;
  final List<Completer<void>> _hydrationWaiters = [];

  /// The token as of right now, for callers that cannot await — specifically the Dio
  /// auth interceptor, which has to decide synchronously whether to attach a header.
  /// Null before hydration finishes and after logout, and in both cases sending no
  /// Authorization header is the correct behaviour.
  String? get currentToken => _current?.token;

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
        final decoded = jsonDecode(raw);
        _current = decoded is Map<String, dynamic> ? _sessionFromJson(decoded) : null;
      }
    } catch (_) {
      // Corrupt/unreadable stored session — treat as logged out rather than crash on launch.
      _current = null;
    } finally {
      _hydrated = true;
      for (final waiter in _hydrationWaiters) {
        if (!waiter.isCompleted) waiter.complete();
      }
      _hydrationWaiters.clear();
    }
  }

  /// Persists [session]. The in-memory copy and the stream are updated even if the
  /// secure write fails, so a Keystore hiccup degrades to a session that works for
  /// this launch but does not survive a restart — rather than a login that appears to
  /// fail after the server already authenticated the user.
  Future<void> save(Session session) async {
    _current = session;
    try {
      await _storage.write(key: _sessionKey, value: jsonEncode(_sessionToJson(session)));
    } catch (_) {
      // Intentionally swallowed; see above.
    }
    if (!_controller.isClosed) _controller.add(session);
  }

  /// Clears the session. The in-memory copy is dropped first and unconditionally: if
  /// the secure delete fails, the user must still end up logged out for this process.
  Future<void> clear() async {
    _current = null;
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // Intentionally swallowed; see above.
    }
    if (!_controller.isClosed) _controller.add(null);
  }

  /// Releases the broadcast controller. Wired to the provider's `onDispose`; without
  /// it the controller outlived every rebuild of the provider graph.
  Future<void> dispose() async {
    for (final waiter in _hydrationWaiters) {
      if (!waiter.isCompleted) waiter.complete();
    }
    _hydrationWaiters.clear();
    await _controller.close();
  }

  Map<String, dynamic> _sessionToJson(Session session) => {
        'token': session.token,
        'userId': session.user.id,
        'userName': session.user.name,
        'userDesignation': session.user.designation,
        'userEmail': session.user.email,
      };

  /// Throws on a malformed payload, which [_hydrate] catches and treats as logged out.
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
