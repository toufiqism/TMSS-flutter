import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/di/providers.dart';
import 'package:tracgo/domain/model/user.dart';

import '../core/telemetry/recording_crash_reporter.dart';

Session _session(String id) => Session(
      token: 'token',
      user: User(
        id: id,
        name: 'Synthetic Person',
        designation: 'Officer',
        email: 'synthetic@example.com',
      ),
    );

void main() {
  late RecordingCrashReporter reporter;
  late StreamController<Session?> sessions;
  late ProviderContainer container;

  setUp(() {
    reporter = RecordingCrashReporter();
    sessions = StreamController<Session?>();
    container = ProviderContainer(
      overrides: [
        crashReporterProvider.overrideWithValue(reporter),
        sessionStreamProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    addTearDown(() {
      container.dispose();
      // `unawaited`, and only after the container is gone: awaiting `close()` hangs
      // forever here. The done event is delivered to Riverpod's internal stream
      // subscription, which never completes the future `close()` returns, so a plain
      // `addTearDown(sessions.close)` times the test out at 30s rather than failing.
      unawaited(sessions.close());
    });
  });

  /// Instantiates the binder and keeps it alive for the duration of the test.
  ///
  /// `listen`, not `read`: providers are auto-dispose by default in Riverpod 3, so a
  /// bare `read` builds the provider and then throws it away the moment the call
  /// returns, taking its session subscription with it. In the app the equivalent hold
  /// is `TracGoApp` watching it, which lasts as long as the app does.
  void startBinder() {
    container.listen<void>(crashReporterIdentityProvider, (previous, next) {});
  }

  /// Lets a stream event reach the provider and the listener run.
  ///
  /// Two turns, not one: the event has to cross the controller into Riverpod's
  /// internal subscription, which then republishes it as an `AsyncData` — a single
  /// `Duration.zero` delay lands between those two steps and the listener has not run
  /// yet.
  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('starts unidentified, so a pre-login crash is attributed to nobody', () async {
    startBinder();
    await settle();

    expect(reporter.userIds, [null]);
  });

  test('a session identifies the user by opaque id', () async {
    startBinder();
    sessions.add(_session('emp-42'));
    await settle();

    expect(reporter.userIds.last, 'emp-42');
  });

  test('logout clears the identity rather than leaving the last user attached', () async {
    startBinder();
    sessions.add(_session('emp-42'));
    await settle();
    sessions.add(null);
    await settle();

    expect(reporter.userIds.last, isNull);
  });

  test('no name or email is ever sent', () async {
    startBinder();
    sessions.add(_session('emp-42'));
    await settle();

    for (final id in reporter.userIds) {
      expect(id, anyOf(isNull, 'emp-42'));
    }
  });
}
