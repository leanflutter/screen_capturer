import 'package:screen_capturer_linux/src/commands/deepin_screen_recorder.dart';
import 'package:screen_capturer_linux/src/commands/gnome_screenshot.dart';
import 'package:screen_capturer_linux/src/commands/spectacle.dart';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';
import 'package:shell_executor/shell_executor.dart';

class ScreenCapturerLinux extends MethodChannelScreenCapturer {
  /// The [ScreenCapturerLinux] constructor.
  ScreenCapturerLinux() : super();

  /// Registers this class as the default instance of [ScreenCapturerLinux].
  static void registerWith() {
    ScreenCapturerPlatform.instance = ScreenCapturerLinux();
  }

  bool? _isKdeDesktop;

  bool get isKdeDesktop {
    if (_isKdeDesktop == null) {
      try {
        final result = ShellExecutor.global.execSync('pgrep', ['plasmashell']);
        _isKdeDesktop = result.exitCode == 0;
      } catch (_) {
        _isKdeDesktop = false;
      }
    }
    return _isKdeDesktop!;
  }

  bool? _isDeepinDesktop;

  bool get isDeepinDesktop {
    if (_isDeepinDesktop == null) {
      try {
        final result =
            ShellExecutor.global.execSync('deepin-screen-recorder', ['-v']);
        _isDeepinDesktop = result.exitCode == 0;
      } catch (_) {
        _isDeepinDesktop = false;
      }
    }
    return _isDeepinDesktop!;
  }

  @override
  SystemScreenCapturer get systemScreenCapturer {
    if (isKdeDesktop) {
      return spectacle;
    }

    if (isDeepinDesktop) {
      return deepinScreenRecorder;
    }
    return gnomeScreenshot;
  }
}
