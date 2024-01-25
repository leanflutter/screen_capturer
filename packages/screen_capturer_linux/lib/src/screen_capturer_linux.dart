import 'package:screen_capturer_linux/src/commands/gnome_screenshot.dart';
import 'package:screen_capturer_platform_interface/screen_capturer_platform_interface.dart';

class ScreenCapturerLinux extends MethodChannelScreenCapturer {
  /// The [ScreenCapturerLinux] constructor.
  ScreenCapturerLinux() : super();

  /// Registers this class as the default instance of [ScreenCapturerLinux].
  static void registerWith() {
    ScreenCapturerPlatform.instance = ScreenCapturerLinux();
  }

  @override
  SystemScreenCapturer get systemScreenCapturer => gnomeScreenshot;
}
