import 'package:screen_capturer/src/capture_mode.dart';
import 'package:screen_capturer/src/system_screen_capturer.dart';
import 'package:shell_executor/shell_executor.dart';

final Map<String, Map<CaptureMode, List<String>>> _knownCaptureModeArgs = {
  'gnome-screenshot': {
    CaptureMode.region: ['-a'],
    CaptureMode.screen: [],
    CaptureMode.window: ['-w'],
  },
  'spectacle': {
    CaptureMode.region: ['-r'],
    CaptureMode.screen: ['-f'],
    CaptureMode.window: ['-a'],
  }
};

class SystemScreenCapturerImplLinux extends SystemScreenCapturer {
  SystemScreenCapturerImplLinux();

  @override
  Future<void> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    try {
      List<String> arguments = [
        ..._knownCaptureModeArgs['gnome-screenshot']![mode]!,
        ...(copyToClipboard ? ['-c'] : []),
        ...(imagePath != null ? ['-f', imagePath] : []),
      ];
      await $('gnome-screenshot', arguments);
    } catch (e) {
      try {
        List<String> arguments = [
          '-b',
          '-n',
          ..._knownCaptureModeArgs['spectacle']![mode]!,
          ...(copyToClipboard ? ['-c'] : []),
          ...(imagePath != null ? ['-o', imagePath] : []),
        ];
        await $('spectacle', arguments);
      } catch (e) {
        rethrow;
      }
    }
  }
}
