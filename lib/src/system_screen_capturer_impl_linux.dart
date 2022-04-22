import 'dart:io';

import 'capture_mode.dart';
import 'system_screen_capturer.dart';

class SystemScreenCapturerImplLinux extends SystemScreenCapturer {
  SystemScreenCapturerImplLinux();

  @override
  Future<void> capture({
    required String imagePath,
    CaptureMode mode = CaptureMode.region,
    bool silent = true,
  }) async {
    await Process.run(
      'gnome-screenshot',
      [
        '-a',
        '-f',
        imagePath,
      ],
    );
  }
}
