import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_capturer/src/capture_mode.dart';
import 'package:screen_capturer/src/captured_data.dart';
import 'package:screen_capturer/src/screen_capturer_platform_interface.dart';
import 'package:screen_capturer/src/system_screen_capturer.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_linux.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_macos.dart';
import 'package:screen_capturer/src/system_screen_capturer_impl_windows.dart'
    if (dart.library.html) 'system_screen_capturer_impl_windows_noop.dart';

class ScreenCapturer {
  ScreenCapturer._() {
    if (!kIsWeb && Platform.isLinux) {
      _systemScreenCapturer = SystemScreenCapturerImplLinux();
    } else if (!kIsWeb && Platform.isMacOS) {
      _systemScreenCapturer = SystemScreenCapturerImplMacOS();
    } else if (!kIsWeb && Platform.isWindows) {
      _systemScreenCapturer = SystemScreenCapturerImplWindows();
    }
  }

  /// The shared instance of [ScreenCapturer].
  static final ScreenCapturer instance = ScreenCapturer._();

  late SystemScreenCapturer _systemScreenCapturer;

  /// Checks whether the current process already has screen capture access
  ///
  /// macOS only
  Future<bool> isAccessAllowed() {
    return ScreenCapturerPlatform.instance.isAccessAllowed();
  }

  /// Requests screen capture access
  ///
  /// macOS only
  Future<void> requestAccess({bool onlyOpenPrefPane = false}) {
    return ScreenCapturerPlatform.instance.requestAccess(
      onlyOpenPrefPane: onlyOpenPrefPane,
    );
  }

  /// Reads an image from the clipboard
  ///
  /// Returns a [Uint8List] object
  Future<Uint8List?> readImageFromClipboard() {
    return ScreenCapturerPlatform.instance.readImageFromClipboard();
  }

  /// Captures the screen and saves it to the specified [imagePath]
  ///
  /// Returns a [CapturedData] object with the image path, width, height and base64 encoded image
  Future<CapturedData?> capture({
    String? imagePath,
    CaptureMode mode = CaptureMode.region,
    bool silent = true,
  }) async {
    if (imagePath == null) throw ArgumentError.notNull('imagePath');
    File imageFile = File(imagePath);
    if (!imageFile.parent.existsSync()) {
      imageFile.parent.create(recursive: true);
    }
    await _systemScreenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      silent: silent,
    );
    if (imageFile.existsSync()) {
      Uint8List imageBytes = imageFile.readAsBytesSync();
      final decodedImage = await decodeImageFromList(imageBytes);

      return CapturedData(
        imagePath: imagePath,
        imageWidth: decodedImage.width,
        imageHeight: decodedImage.height,
        imageBytes: imageBytes,
      );
    }
    return null;
  }
}

/// The shared instance of [ScreenCapturer].
final screenCapturer = ScreenCapturer.instance;
