import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    CaptureMode mode = CaptureMode.region,
    String? imagePath,
    bool copyToClipboard = false,
    bool silent = true,
  }) async {
    File? imageFile;
    if (imagePath != null) {
      imageFile = File(imagePath);
      if (!imageFile.parent.existsSync()) {
        imageFile.parent.create(recursive: true);
      }
    }
    if (copyToClipboard) {
      // 如果是复制到剪切板，先清空剪切板，避免结果不正确
      Clipboard.setData(const ClipboardData(text: ''));
    }
    await _systemScreenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: copyToClipboard,
      silent: silent,
    );

    Uint8List? imageBytes;
    if (imageFile != null && imageFile.existsSync()) {
      imageBytes = imageFile.readAsBytesSync();
    }
    if (copyToClipboard) {
      imageBytes = await readImageFromClipboard();
    }

    if (imageBytes != null) {
      // 系统截图命令当传入复制到剪切板时，不会保存到文件，所以这里需要手动保存
      if (imageFile != null && !imageFile.existsSync()) {
        imageFile.writeAsBytesSync(imageBytes);
      }
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
