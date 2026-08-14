import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/model/user.dart';

/// Session/token storage.
///
/// The session lives in flutter_secure_storage (Keychain on iOS, Keystore-backed
/// encrypted storage on Android) rather than plain prefs, because it is
/// credentials-adjacent. It is written as one JSON blob under [_sessionKey]: the token
/// plus the profile fields the drawer renders, plus the token's expiry.
///
/// Two platform behaviours drive the rest of this class:
///
/// - **Keychain items outlive the app on iOS.** Deleting the app does not delete them,
///   so a reinstall would otherwise resurrect a session whose token is long dead — the
///   app looks signed in, then 401s on its first request. [_clearIfFreshInstall] fixes
///   that using a marker in shared_preferences, which *is* wiped on uninstall.
/// - **A stated expiry is worth honouring.** The login response says when the token
///   dies; sending a token we know is dead just buys a guaranteed 401.
class SessionLocalDataSource {
  SessionLocalDataSource({
    FlutterSecureStorage? storage,
    Future<SharedPreferences> Function()? preferences,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                // first_unlock_this_device, not the default first_unlock:
                // `_this_device` keeps the token out of iCloud Keychain, so a corporate
                // session never syncs to the user's other hardware. Still readable after
                // a reboot once the device has been unlocked once, which `unlocked`
                // would not be — this app has no background work needing it earlier.
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              // Android needs no options here: flutter_secure_storage 11 already
              // defaults to AES-GCM data encryption under an RSA-OAEP Keystore key.
            ),
        _preferences = preferences ?? SharedPreferences.getInstance {
    unawaited(_hydrate());
  }

  static const _sessionKey = 'session_json';

  /// Non-sensitive marker recording that secure storage has been initialised by *this*
  /// installation. Deliberately in prefs, not the Keychain — its whole job is to
  /// disappear when the app is uninstalled.
  static const _installMarkerKey = 'session_storage_initialised';

  final FlutterSecureStorage _storage;
  final Future<SharedPreferences> Function() _preferences;
  final StreamController<Session?> _controller = StreamController<Session?>.broadcast();
  Session? _current;
  bool _hydrated = false;
  final List<Completer<void>> _hydrationWaiters = [];

  /// The token as of right now, for callers that cannot await — specifically the Dio
  /// auth interceptor, which has to decide synchronously whether to attach a header.
  ///
  /// Null before hydration, after logout, and once the stored token is past its stated
  /// expiry. In every case sending no Authorization header is correct: the request will
  /// come back 401 and the normal session-expired path will clear the session.
  String? get currentToken {
    final session = _current;
    if (session == null || session.isExpired) return null;
    return session.token;
  }

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
      if (await _clearIfFreshInstall()) {
        _current = null;
        return;
      }
      final raw = await _storage.read(key: _sessionKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        final stored = decoded is Map<String, dynamic> ? _sessionFromJson(decoded) : null;
        if (stored != null && stored.isExpired) {
          // Known-dead token. Drop it now so the app starts at login rather than
          // flashing a signed-in shell that immediately bounces on a 401.
          await _storage.delete(key: _sessionKey);
          _current = null;
        } else {
          _current = stored;
        }
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

  /// Wipes any session left behind by a previous installation.
  ///
  /// Returns true when this was a fresh install, meaning nothing should be hydrated.
  /// If prefs are unreadable this returns false — hydrating a possibly-stale session is
  /// recoverable (one 401), whereas signing a working user out on every launch is not.
  Future<bool> _clearIfFreshInstall() async {
    final SharedPreferences prefs;
    try {
      prefs = await _preferences();
      if (prefs.getBool(_installMarkerKey) ?? false) return false;
    } catch (_) {
      // Prefs unreadable. Hydrating a possibly-stale session is recoverable — one 401 —
      // whereas signing a working user out on every launch is not.
      return false;
    }

    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // Could not clear. Say so, so the caller hydrates rather than assuming an empty
      // store, and leave the marker unset so the next launch tries again.
      return false;
    }

    // Marker last: it records that the delete above actually happened. Writing it first
    // and then failing the delete would strand a stale session that nothing retries.
    // A failure here only costs one repeated (harmless) delete next launch.
    try {
      await prefs.setBool(_installMarkerKey, true);
    } catch (_) {
      // Intentionally ignored; the session is already gone, which is what matters.
    }
    return true;
  }

  /// Persists [session]. The in-memory copy and the stream are updated even if the
  /// secure write fails, so a Keystore hiccup degrades to a session that works for
  /// this launch but does not survive a restart — rather than a login that appears to
  /// fail after the server already authenticated the user.
  Future<void> save(Session session) async {
    _current = session;
    try {
      await _storage.write(key: _sessionKey, value: jsonEncode(_sessionToJson(session)));
      // A successful write implies storage is initialised for this install; make sure
      // the marker exists so the next launch does not mistake this for a fresh one.
      final prefs = await _preferences();
      await prefs.setBool(_installMarkerKey, true);
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
        // ISO-8601 UTC: this is our own persistence format, not the wire format, and it
        // round-trips unambiguously regardless of device timezone.
        'expiresAt': session.expiresAt?.toUtc().toIso8601String(),
      };

  /// Throws on a malformed payload, which [_hydrate] catches and treats as logged out.
  ///
  /// `expiresAt` is read leniently: sessions written before it existed simply lack the
  /// key, and an unparseable value is treated as "no known expiry" rather than
  /// invalidating an otherwise good session.
  Session _sessionFromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiresAt'];
    return Session(
      token: json['token'] as String,
      user: User(
        id: json['userId'] as String,
        name: json['userName'] as String,
        designation: json['userDesignation'] as String,
        email: json['userEmail'] as String,
      ),
      expiresAt: rawExpiry is String ? DateTime.tryParse(rawExpiry)?.toLocal() : null,
    );
  }
}
