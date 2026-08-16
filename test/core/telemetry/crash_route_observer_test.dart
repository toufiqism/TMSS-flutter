import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/core/telemetry/crash_route_observer.dart';

import 'recording_crash_reporter.dart';

Route<void> _route(String? name) => PageRouteBuilder<void>(
      settings: RouteSettings(name: name),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
    );

void main() {
  late RecordingCrashReporter reporter;
  late CrashRouteObserver observer;

  setUp(() {
    reporter = RecordingCrashReporter();
    observer = CrashRouteObserver(reporter);
  });

  test('a push is a breadcrumb naming both ends of the move', () {
    observer.didPush(_route('/requisitions'), _route('/dashboard'));

    expect(reporter.logs.single, 'nav push: /dashboard -> /requisitions');
  });

  test('a pop is recorded in the direction it happened', () {
    observer.didPop(_route('/requisitions/new'), _route('/requisitions'));

    expect(reporter.logs.single, 'nav pop: /requisitions -> /requisitions/new');
  });

  test('the first route has no previous, and says so rather than reading as a bug', () {
    observer.didPush(_route('/splash'), null);

    expect(reporter.logs.single, 'nav push: none -> /splash');
  });

  test('an unnamed route is labelled, not left blank', () {
    observer.didPush(_route(null), _route('/dashboard'));

    expect(reporter.logs.single, 'nav push: /dashboard -> unnamed');
  });

  test('breadcrumbs are never issues', () {
    observer.didPush(_route('/dashboard'), null);
    observer.didReplace(newRoute: _route('/login'), oldRoute: _route('/dashboard'));
    observer.didRemove(_route('/login'), null);

    expect(reporter.errors, isEmpty);
    expect(reporter.logs, hasLength(3));
  });
}
