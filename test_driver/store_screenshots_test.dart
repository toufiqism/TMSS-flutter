// Driver half of the App Store screenshot capture.
//
// `integration_test`'s `takeScreenshot` hands the bytes back over the driver channel
// rather than writing them itself, so the file naming and destination live here. Run
// through tool/store/capture_ios_screenshots.sh, not directly.

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Native-resolution captures. The framing pass
/// (tool/store/generate_ios_store_screenshots.py) reads from here and writes the
/// upload-ready files one directory up, mirroring the Play layout.
const _rawDir = 'docs/appstore/graphics/screenshots/raw';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('$_rawDir/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      stdout.writeln('wrote ${file.path} (${(bytes.length / 1024).round()} KB)');
      return true;
    },
  );
}
