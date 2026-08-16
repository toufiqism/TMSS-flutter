import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracgo/core/notifier_lifecycle.dart';

/// Minimal notifier exercising the mixin directly, so the guarantees are pinned here
/// rather than inferred from whichever feature happens to depend on them.
class _Counter extends Notifier<int> with NotifierLifecycle<int, String> {
  int builds = 0;

  @override
  int build() {
    registerLifecycle();
    builds++;
    return 0;
  }

  void bump() => setStateIfAlive(state + 1);

  /// Writes without reading `state` first. Needed for the disposed case: reading
  /// `state` on a torn-down provider throws before any guard can run, so the argument
  /// has to be independent of it.
  void set(int value) => setStateIfAlive(value);
  void shout(String message) => emitEvent(message);
}

final _counterProvider = NotifierProvider<_Counter, int>(_Counter.new);

void main() {
  // Riverpod reuses the Notifier *object* across a rebuild — `ref.invalidate` disposes
  // the element and calls `build()` again on the same instance. Before this was
  // handled, `_disposed` stayed true from the previous build and the notifier became a
  // zombie: it ran its work, and every state write and event was silently dropped.
  // That is what left the dashboard spinning forever after a sign-out/sign-in cycle,
  // with a 200 in the log and nothing on screen.
  test('a rebuilt notifier can still write state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(_counterProvider, (_, _) {}, fireImmediately: true);

    final notifier = container.read(_counterProvider.notifier);
    notifier.bump();
    expect(container.read(_counterProvider), 1);

    container.invalidate(_counterProvider);
    // Same object, second build — the exact situation observed on device.
    final rebuilt = container.read(_counterProvider.notifier);
    expect(identical(rebuilt, notifier), isTrue,
        reason: 'the premise: Riverpod reuses the instance, so state must be re-armed');
    expect(rebuilt.builds, 2);
    expect(rebuilt.isDisposed, isFalse);

    rebuilt.bump();
    expect(container.read(_counterProvider), 1,
        reason: 'state resets to build()\'s value, then the write lands');
  });

  test('a rebuilt notifier gets a live event stream', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(_counterProvider, (_, _) {}, fireImmediately: true);
    container.read(_counterProvider.notifier);

    container.invalidate(_counterProvider);
    final rebuilt = container.read(_counterProvider.notifier);

    final received = <String>[];
    final sub = rebuilt.events.listen(received.add);
    rebuilt.shout('after rebuild');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['after rebuild']);
    await sub.cancel();
  });

  test('writes and events are still dropped once genuinely disposed', () async {
    final container = ProviderContainer();
    container.listen(_counterProvider, (_, _) {}, fireImmediately: true);
    final notifier = container.read(_counterProvider.notifier);

    container.dispose();

    expect(notifier.isDisposed, isTrue);
    // The guards still exist for their original purpose: a request that lands after the
    // screen is gone must not throw.
    expect(() => notifier.set(9), returnsNormally);
    expect(() => notifier.shout('gone'), returnsNormally);
  });
}
