import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';

/// [CrashReporter] backed by Firebase Crashlytics.
///
/// The only file in the app that imports `firebase_crashlytics`; everything else talks
/// to the interface. It is constructed once during bootstrap and injected through the
/// provider graph, never reached for as a global.
///
/// Every method swallows its own failures. Crashlytics calls cross a platform channel
/// and can fail — most obviously before the native SDK has finished starting, or on a
/// platform where the plugin is not registered at all — and a telemetry write must
/// never be the thing that breaks a screen. Failures are surfaced with [debugPrint] in
/// debug builds only, so the developer wiring this up can see it while the user never
/// does.
class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, Object> keys = const <String, Object>{},
  }) async {
    await _guard('recordError', () async {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
        // Attached to this report only, rather than set as persistent custom keys:
        // the endpoint and status of *this* failure would otherwise leak onto the next
        // unrelated crash report and read as if they were part of it.
        information: keys.entries.map((e) => '${e.key}: ${e.value}').toList(),
      );
    });
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    await _guard('recordFlutterError', () async {
      if (fatal) {
        await _crashlytics.recordFlutterFatalError(details);
      } else {
        await _crashlytics.recordFlutterError(details);
      }
    });
  }

  @override
  Future<void> log(String message) => _guard('log', () => _crashlytics.log(message));

  @override
  Future<void> setUserIdentifier(String? id) {
    // Crashlytics has no "clear" call; the empty string is how the SDK expresses an
    // unidentified user, and it is what logout must write — otherwise every crash
    // after a sign-out stays attributed to the person who signed out.
    return _guard(
      'setUserIdentifier',
      () => _crashlytics.setUserIdentifier(id ?? ''),
    );
  }

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _guard('setCustomKey', () => _crashlytics.setCustomKey(key, value));

  Future<void> _guard(String operation, Future<void> Function() body) async {
    try {
      await body();
    } catch (error) {
      // Deliberately terminal. There is nobody to report a reporting failure to.
      if (kDebugMode) {
        debugPrint('Crashlytics $operation failed: $error');
      }
    }
  }
}
