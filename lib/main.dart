import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/common/strings.dart';
import 'presentation/nav/app_router.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: TmsApp()));
}

class TmsApp extends ConsumerWidget {
  const TmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: TmsStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTmsTheme(),
      routerConfig: router,
    );
  }
}
