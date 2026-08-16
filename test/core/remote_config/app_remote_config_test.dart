import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/core/remote_config/app_remote_config.dart';

void main() {
  group('defaults are the safe-to-run-forever state', () {
    const config = StaticAppRemoteConfig();

    test('the update gate is off, so a failed fetch cannot lock anyone out', () {
      expect(config.minimumSupportedBuild, 0);
    });

    test('no maintenance message, so a failed fetch cannot invent an outage', () {
      expect(config.maintenanceMessage, isEmpty);
    });

    test('refresh is a no-op that does not throw', () async {
      await expectLater(config.refresh(), completes);
    });
  });

  test('every declared key has a compiled-in default', () {
    expect(
      RemoteConfigDefaults.values.keys,
      containsAll(<String>[
        RemoteConfigDefaults.minimumSupportedBuildKey,
        RemoteConfigDefaults.maintenanceMessageKey,
      ]),
    );
    expect(
      RemoteConfigDefaults.values[RemoteConfigDefaults.minimumSupportedBuildKey],
      RemoteConfigDefaults.minimumSupportedBuildDefault,
    );
    expect(
      RemoteConfigDefaults.values[RemoteConfigDefaults.maintenanceMessageKey],
      RemoteConfigDefaults.maintenanceMessageDefault,
    );
  });

  test('the base URL is not remotely settable — it would redirect credentials', () {
    expect(RemoteConfigDefaults.values.keys, isNot(contains('api_base_url')));
  });
}
