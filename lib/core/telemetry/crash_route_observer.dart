import 'dart:async';

import 'package:flutter/widgets.dart';

import 'crash_reporter.dart';

/// Leaves a Crashlytics breadcrumb for every navigation, so a crash report shows the
/// path the user took to reach it instead of just the screen they landed on.
///
/// Attached to both navigators go_router creates: the root one, and the nested one
/// inside the `ShellRoute`. Only registering the root would silently miss every move
/// between Dashboard and Requisition List, which is most of the app's navigation.
///
/// Breadcrumbs, not reports: none of this creates an issue in the console on its own.
class CrashRouteObserver extends NavigatorObserver {
  CrashRouteObserver(this._reporter);

  final CrashReporter _reporter;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _record('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('remove', route, previousRoute);
  }

  /// `unawaited`, never awaited: a navigator callback is synchronous, and blocking a
  /// route transition on a platform-channel round-trip would make navigation as slow
  /// and as failure-prone as the telemetry channel.
  void _record(String action, Route<dynamic>? route, Route<dynamic>? previous) {
    final to = _nameOf(route);
    final from = _nameOf(previous);
    unawaited(_reporter.log('nav $action: $from -> $to'));
  }

  /// Routes built by go_router carry their location in `settings.name`; anonymous
  /// routes (dialogs, the transient bounce page) carry nothing, and are reported as
  /// `unnamed` rather than as a null that reads like a bug in the breadcrumb trail.
  String _nameOf(Route<dynamic>? route) {
    if (route == null) return 'none';
    final name = route.settings.name;
    if (name == null || name.isEmpty) return 'unnamed';
    return name;
  }
}
