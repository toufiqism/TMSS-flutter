import 'package:flutter/foundation.dart';

/// What the app tells its crash backend, expressed without naming one.
///
/// Everything above `di/` depends on this interface rather than on
/// `firebase_crashlytics` directly, for the same reason the repositories depend on
/// `domain/repository/` rather than on Dio: it keeps a vendor SDK out of the layers
/// that have no business knowing about it, and it means a test can assert "this
/// failure was reported" without a Firebase binding in the test harness.
///
/// Every method is fire-and-forget from the caller's point of view. Reporting must
/// never change program flow — an implementation that throws would turn a handled API
/// error into an unhandled one — so implementations swallow their own failures.
abstract class CrashReporter {
  /// Records a non-fatal (or, with [fatal] true, a fatal) error.
  ///
  /// [reason] is the short human label the Crashlytics console groups on; [keys] are
  /// searchable custom key/values attached to this report only.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, Object> keys = const <String, Object>{},
  });

  /// Records an error surfaced by the Flutter framework itself.
  Future<void> recordFlutterError(FlutterErrorDetails details, {bool fatal = false});

  /// Adds a breadcrumb. Breadcrumbs are not issues; they are the trail attached to
  /// whatever issue is reported next.
  Future<void> log(String message);

  /// Associates subsequent reports with a user. Pass null on logout.
  ///
  /// Callers must pass an opaque id, never an email or a name — crash reports are
  /// retained by a third party and read by whoever has console access.
  Future<void> setUserIdentifier(String? id);

  /// Sets a custom key that persists across reports until changed.
  Future<void> setCustomKey(String key, Object value);
}

/// The reporter used when there is no backend to report to: in unit tests, and at
/// runtime when Firebase failed to initialise.
///
/// It is deliberately silent rather than throwing or logging. A telemetry backend
/// being unavailable is not something the user can act on, and it must not be allowed
/// to take the app down with it.
class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, Object> keys = const <String, Object>{},
  }) async {}

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserIdentifier(String? id) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
