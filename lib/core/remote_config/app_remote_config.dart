import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Server-controlled values, and the defaults that apply when the server has not been
/// heard from.
///
/// Every key here has a default that is safe to run on forever, because that is the
/// state the app is in on a first launch with no network, and on every launch where
/// the fetch fails. A key whose default is not safe is a key that turns a bad network
/// into an outage.
///
/// `api_base_url` is deliberately **not** a key. The base URL decides where the app
/// sends a bearer token and a password; making it remotely settable would mean a
/// compromised or misconfigured console entry could redirect credentials. It stays a
/// compile-time `--dart-define` (see `ApiConfig`).
class RemoteConfigDefaults {
  RemoteConfigDefaults._();

  /// Builds below this are asked to update. 0 disables the gate, which is what an
  /// unreachable server must mean — the alternative is locking every user out because
  /// a fetch failed.
  static const minimumSupportedBuildKey = 'minimum_supported_build';
  static const minimumSupportedBuildDefault = 0;

  /// Non-empty means "show this message"; empty means "nothing to say". Empty is the
  /// default so a failed fetch cannot invent a maintenance notice.
  static const maintenanceMessageKey = 'maintenance_message';
  static const maintenanceMessageDefault = '';

  static const values = <String, Object>{
    minimumSupportedBuildKey: minimumSupportedBuildDefault,
    maintenanceMessageKey: maintenanceMessageDefault,
  };
}

/// Reads the values in [RemoteConfigDefaults].
///
/// An interface rather than the Firebase class directly, for the same reason as
/// [CrashReporter]: it keeps the SDK out of the layers that consume the values, and it
/// lets a test hand a screen a fixed config without a Firebase binding.
abstract class AppRemoteConfig {
  int get minimumSupportedBuild;

  String get maintenanceMessage;

  /// Fetches and activates the latest values. Safe to call repeatedly; the underlying
  /// SDK throttles fetches itself.
  Future<void> refresh();
}

/// The config used when there is no backend: unit tests, and runtime when Firebase
/// failed to initialise. Always returns the defaults.
class StaticAppRemoteConfig implements AppRemoteConfig {
  const StaticAppRemoteConfig();

  @override
  int get minimumSupportedBuild => RemoteConfigDefaults.minimumSupportedBuildDefault;

  @override
  String get maintenanceMessage => RemoteConfigDefaults.maintenanceMessageDefault;

  @override
  Future<void> refresh() async {}
}

/// [AppRemoteConfig] backed by Firebase Remote Config.
class FirebaseAppRemoteConfig implements AppRemoteConfig {
  FirebaseAppRemoteConfig(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  /// Registers settings and defaults. Local work only — deliberately **not** a fetch.
  ///
  /// The network fetch is [refresh], which the bootstrap fires without awaiting. That
  /// split matters: this runs on the path to the first frame, and blocking startup for
  /// up to [_fetchTimeout] on a config nothing has read yet would be a self-inflicted
  /// cold-start regression on exactly the slow networks the timeout exists for.
  ///
  /// Returns normally even on failure — the app then runs on the compiled-in defaults,
  /// which is a supported state, not an error state.
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          // Zero in debug so a console change is visible on the next hot restart.
          // Release keeps the standard hour, because the SDK throttles server-side
          // anyway and a shorter interval only burns battery and quota.
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(RemoteConfigDefaults.values);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Remote Config initialise failed, using defaults: $error');
      }
    }
  }

  static const _fetchTimeout = Duration(seconds: 10);

  @override
  int get minimumSupportedBuild => _read(
        () => _remoteConfig.getInt(RemoteConfigDefaults.minimumSupportedBuildKey),
        RemoteConfigDefaults.minimumSupportedBuildDefault,
      );

  @override
  String get maintenanceMessage => _read(
        () => _remoteConfig.getString(RemoteConfigDefaults.maintenanceMessageKey),
        RemoteConfigDefaults.maintenanceMessageDefault,
      );

  @override
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (error) {
      // Keep whatever is already active. A failed refresh must leave the app on the
      // last known-good values, not blank them.
      if (kDebugMode) {
        debugPrint('Remote Config refresh failed: $error');
      }
    }
  }

  /// Getters are called from `build` methods, so they cannot be allowed to throw — a
  /// plugin that is not registered would otherwise take out the widget tree rather
  /// than fall back to the default it already has.
  T _read<T>(T Function() read, T fallback) {
    try {
      return read();
    } catch (_) {
      return fallback;
    }
  }
}
