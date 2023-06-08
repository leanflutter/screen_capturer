import 'package:screen_capturer/src/capture_mode.dart';
import 'package:screen_capturer/src/system_screen_capturer.dart';
import 'package:shell_executor/shell_executor.dart';

final Map<CaptureMode, List<String>> _knownCaptureModeArgs = {
  CaptureMode.region: ['-i', '-r'],
  CaptureMode.screen: ['-C'],
  CaptureMode.window: ['-i', '-w'],
};

class SystemScreenCapturerImplMacOS extends SystemScreenCapturer {
  SystemScreenCapturerImplMacOS();

  @override
  Future<void> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    List<String> arguments = [
      ..._knownCaptureModeArgs[mode]!,
      ...(copyToClipboard ? ['-c'] : []),
      ...(silent ? ['-x'] : []),
      ...(imagePath != null ? [imagePath] : []),
    ];
    await $('/usr/sbin/screencapture', arguments);
  }
}
