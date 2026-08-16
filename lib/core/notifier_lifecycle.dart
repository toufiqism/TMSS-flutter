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
/// **`build()` can run more than once on the same object, and this used to be fatal.**
/// Riverpod reuses the `Notifier` instance across a rebuild — `ref.invalidate` disposes
/// the *element*, not the object, and calls `build()` again on the very same
/// `Notifier`. Verified on device: the same `hashCode` came back through `build()` with
/// `_disposed` already `true`. Nothing reset it, so from that moment on the notifier was
/// a zombie — it still ran its fetches, but every [setStateIfAlive] and [emitEvent] was
/// silently dropped.
///
/// The symptom was a dashboard that spun forever after signing out and back in: the
/// request returned 200, and the state write went nowhere. Restarting the app "fixed"
/// it only because that produced a genuinely new object.
///
/// So [registerLifecycle] now re-arms this state on every build. Prefer refreshing a
/// notifier by calling a method on it rather than `ref.invalidate` all the same: a
/// rebuild replaces the event controller, and a screen still holding the old stream
/// stops receiving events.
mixin NotifierLifecycle<StateT, EventT> on Notifier<StateT> {
  StreamController<EventT> _events = StreamController<EventT>.broadcast();
  bool _disposed = false;

  /// One-shot events (navigation, toasts, session-expired). Consumed with a
  /// `StreamSubscription` in the widget, never with `ref.watch`, so a rebuild
  /// cannot replay an event that already fired.
  Stream<EventT> get events => _events.stream;

  /// True once the provider has been torn down. Async continuations must check this
  /// before touching `state`, the event stream, or `ref`.
  bool get isDisposed => _disposed;

  /// Call first thing in `build()` — on **every** build, not just the first.
  ///
  /// Re-arms the guards before registering the next teardown hook. Without the reset a
  /// rebuilt notifier keeps the previous build's `_disposed` flag and closed controller,
  /// and can never write state or emit an event again.
  void registerLifecycle() {
    if (_disposed) {
      _disposed = false;
      // Closed by the previous build's dispose hook. A broadcast controller cannot be
      // reopened, so the only way back is a fresh one — which is why a screen must
      // resubscribe after a rebuild rather than cache `events`.
      if (_events.isClosed) _events = StreamController<EventT>.broadcast();
    }
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
