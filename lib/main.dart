import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/telemetry/telemetry_bootstrap.dart';
import 'di/providers.dart';
import 'presentation/common/strings.dart';
import 'presentation/nav/app_router.dart';
import 'theme/theme.dart';

Future<void> main() async {
  // Required before `bootstrapTelemetry`: Firebase.initializeApp talks over platform
  // channels, which do not exist until the binding is up.
  WidgetsFlutterBinding.ensureInitialized();

  // Never throws — a Firebase failure comes back as `Telemetry.disabled` rather than
  // stopping the app from starting. See bootstrapTelemetry.
  final telemetry = await bootstrapTelemetry();

  runApp(
    ProviderScope(
      // The graph's defaults are the no-op reporter and the static config, so these
      // overrides are what turn telemetry on. Injecting them rather than reaching for
      // `FirebaseCrashlytics.instance` inside the providers keeps the vendor SDK to
      // one file and keeps every test able to build the same graph.
      overrides: [
        crashReporterProvider.overrideWithValue(telemetry.crashReporter),
        appRemoteConfigProvider.overrideWithValue(telemetry.remoteConfig),
      ],
      child: const TracGoApp(),
    ),
  );
}

class TracGoApp extends ConsumerWidget {
  const TracGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Side-effecting and valueless: it keeps the crash reporter's user id in step with
    // the session. Watched here because this widget lives for the life of the app, so
    // the subscription does too.
    ref.watch(crashReporterIdentityProvider);

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: TracGoStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTracGoTheme(),
      routerConfig: router,
    );
  }
}
