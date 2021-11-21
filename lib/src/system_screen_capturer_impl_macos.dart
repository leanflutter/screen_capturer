import 'dart:io';

import 'system_screen_capturer.dart';

class SystemScreenCapturerImplMacOS extends SystemScreenCapturer {
  SystemScreenCapturerImplMacOS();

  @override
  Future<void> capture({
    required String imagePath,
    bool silent = true,
  }) async {
    List<String> arguments = [
      '-i',
      '-r',
      silent ? '-x' : '',
      imagePath,
    ];
    arguments.removeWhere((e) => e.isEmpty);

    await Process.run(
      '/usr/sbin/screencapture',
      arguments,
    );
  }
}
