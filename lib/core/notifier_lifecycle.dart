import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-shot event channel plus post-dispose write guards, shared by every notifier.
///
/// Two things throw once a provider is torn down, and every notifier here does both
/// after awaiting a repository call:
///
/// - writing `state` throws `UnmountedRefException` (riverpod `ref.dart`, `_throwIfInvalidUsage`),
/// - `StreamController.add` throws `StateError` once the controller is closed.
///
/// A user who backs out of a screen mid-request hits exactly that window, so both
/// writes go through [emitEvent] / [setStateIfAlive] instead of touching the raw
/// members.
///
/// **Invariant this relies on:** the notifiers mixing this in declare no provider
/// dependencies, so `build()` runs exactly once per instance and the controller
/// created below outlives every legitimate write. Refresh a notifier by calling a
/// method on it — never `ref.invalidate`, which would re-run `build()`, close this
/// controller via [registerLifecycle]'s dispose hook, and silently strand any screen
/// still listening to the old stream.
mixin NotifierLifecycle<StateT, EventT> on Notifier<StateT> {
  final StreamController<EventT> _events = StreamController<EventT>.broadcast();
  bool _disposed = false;

  /// One-shot events (navigation, toasts, session-expired). Consumed with a
  /// `StreamSubscription` in the widget, never with `ref.watch`, so a rebuild
  /// cannot replay an event that already fired.
  Stream<EventT> get events => _events.stream;

  /// True once the provider has been torn down. Async continuations must check this
  /// before touching `state`, the event stream, or `ref`.
  bool get isDisposed => _disposed;

  /// Call once, first thing in `build()`.
  void registerLifecycle() {
    ref.onDispose(() {
      _disposed = true;
      _events.close();
    });
  }

  /// Emits [event] if the notifier is still alive; drops it otherwise. Dropping is
  /// correct here: every event targets a screen that is, by definition, already gone.
  void emitEvent(EventT event) {
    if (_disposed || _events.isClosed) return;
    _events.add(event);
  }

  /// Writes [next] if the notifier is still alive; no-ops otherwise.
  void setStateIfAlive(StateT next) {
    if (_disposed) return;
    state = next;
  }
}
