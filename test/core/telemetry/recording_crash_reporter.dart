import 'package:flutter/foundation.dart';
import 'package:tracgo/core/telemetry/crash_reporter.dart';

/// A recorded call to [RecordingCrashReporter.recordError].
class RecordedError {
  RecordedError(this.error, this.stackTrace, this.reason, this.fatal, this.keys);

  final Object error;
  final StackTrace? stackTrace;
  final String? reason;
  final bool fatal;
  final Map<String, Object> keys;
}

/// A [CrashReporter] that keeps what it was told instead of sending it anywhere.
///
/// Hand-written rather than a `mocktail` mock: every assertion here is about *what*
/// was reported — the reason string, the custom keys, whether it was a non-fatal at
/// all — and a plain recorder reads better for that than a stack of `verify` calls.
class RecordingCrashReporter implements CrashReporter {
  final List<RecordedError> errors = [];
  final List<String> logs = [];
  final List<String?> userIds = [];
  final Map<String, Object> customKeys = {};

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, Object> keys = const <String, Object>{},
  }) async {
    errors.add(RecordedError(error, stackTrace, reason, fatal, keys));
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    errors.add(
      RecordedError(details.exception, details.stack, details.context?.toString(), fatal,
          const {}),
    );
  }

  @override
  Future<void> log(String message) async => logs.add(message);

  @override
  Future<void> setUserIdentifier(String? id) async => userIds.add(id);

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      customKeys[key] = value;
}
