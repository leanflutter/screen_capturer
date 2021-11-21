import 'dart:io';

import 'system_screen_capturer.dart';

class SystemScreenCapturerImplLinux extends SystemScreenCapturer {
  SystemScreenCapturerImplLinux();

  @override
  Future<void> capture({
    required String imagePath,
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
