import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for `integration_test/smoke_test.dart`. Its only job beyond the default is
/// writing the screenshots the test requests to disk, so a run can be reviewed after
/// the fact rather than only passing or failing.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('build/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
