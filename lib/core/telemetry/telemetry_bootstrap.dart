import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../remote_config/app_remote_config.dart';
import 'crash_reporter.dart';
import 'firebase_crash_reporter.dart';

/// What bootstrap hands back to `main` for injection into the provider graph.
class Telemetry {
  const Telemetry({required this.crashReporter, required this.remoteConfig});

  /// The no-backend pairing: what the app runs on when Firebase is unavailable.
  const Telemetry.disabled()
      : crashReporter = const NoOpCrashReporter(),
        remoteConfig = const StaticAppRemoteConfig();

  final CrashReporter crashReporter;
  final AppRemoteConfig remoteConfig;
}

/// Starts Firebase, wires the global error handlers, and returns the telemetry
/// services.
///
/// Must be called after `WidgetsFlutterBinding.ensureInitialized()` and before
/// `runApp`, because `Firebase.initializeApp` needs the platform channels up.
///
/// **This never throws.** Firebase initialisation fails for reasons that have nothing
/// to do with the app being broken — a missing `google-services.json` on a fresh
/// checkout, an unregistered plugin on a platform nobody has configured yet, a device
/// with no Play Services. None of those are a reason for the user to be unable to file
/// a requisition, so a failure downgrades to [Telemetry.disabled] and the app carries
/// on with no reporting.
///
/// Note that the error handlers are only installed when Firebase came up. On the
/// failure path Flutter's own defaults are deliberately left in place, so errors still
/// reach the console instead of disappearing into a no-op reporter.
Future<Telemetry> bootstrapTelemetry() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    final crashlytics = FirebaseCrashlytics.instance;
    // Collection is on in every build, debug included — a deliberate choice while the
    // integration is being verified. Flip this to `!kDebugMode` to keep development
    // crashes out of the production dashboard.
    await crashlytics.setCrashlyticsCollectionEnabled(true);

    final reporter = FirebaseCrashReporter(crashlytics);
    _installErrorHandlers(reporter);

    final remoteConfig = FirebaseAppRemoteConfig(FirebaseRemoteConfig.instance);
    await remoteConfig.initialize();
    // Unawaited on purpose: see FirebaseAppRemoteConfig.initialize. The fetch must not
    // sit between the user and the first frame. `refresh` swallows its own failures,
    // so this cannot surface as an unhandled async error.
    unawaited(remoteConfig.refresh());

    return Telemetry(crashReporter: reporter, remoteConfig: remoteConfig);
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Firebase initialisation failed; telemetry disabled: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    return const Telemetry.disabled();
  }
}

/// Routes both classes of uncaught error to [reporter].
///
/// Each handler chains to whatever was installed before it rather than replacing it.
/// Replacing outright would silence the console dump and the red error box that make
/// a debug session usable — reporting an error is supposed to be additive to seeing
/// it, not a substitute.
///
/// Not covered: errors raised inside a background `Isolate`. The app spawns none; if
/// one is ever added it needs its own `Isolate.current.addErrorListener` here.
void _installErrorHandlers(CrashReporter reporter) {
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    previousFlutterOnError?.call(details);
    unawaited(reporter.recordFlutterError(details, fatal: true));
  };

  final previousPlatformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(
      reporter.recordError(
        error,
        stackTrace,
        reason: 'Uncaught asynchronous error',
        fatal: true,
      ),
    );
    // `false` when nothing was chained: it means "not handled", which leaves the
    // framework free to print the error as it normally would. Returning `true` here
    // would report the error to Crashlytics and hide it from the developer at the
    // same time.
    return previousPlatformOnError?.call(error, stackTrace) ?? false;
  };
}
