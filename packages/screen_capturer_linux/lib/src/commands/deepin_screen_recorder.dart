import 'dart:io';

import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

final Map<CaptureMode, List<String>> _knownCaptureModeArgs = {
  CaptureMode.region: [''],
  CaptureMode.screen: ['-f'],
  CaptureMode.window: ['--dograb'],
};

class _Deepin extends Command with SystemScreenCapturer {
  @override
  String get executable {
    return 'deepin-screen-recorder';
  }

  @override
  Future<void> install() {
    throw UnimplementedError();
  }

  @override
  Future<ProcessResult> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) {
    return exec(
      [
        ..._knownCaptureModeArgs[mode]!,
        ...(imagePath != null ? ['-s', imagePath] : []),
        ...(silent ? ['-n'] : []),
      ],
    );
  }
}

final deepinScreenRecorder = _Deepin();
