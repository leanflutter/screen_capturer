import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'capture_mode.dart';
import 'captured_data.dart';
import 'system_screen_capturer_impl_linux.dart';
import 'system_screen_capturer_impl_macos.dart';
import 'system_screen_capturer_impl_windows.dart';
import 'system_screen_capturer.dart';

class ScreenCapturer {
  ScreenCapturer._() {
    if (Platform.isLinux) {
      _systemScreenCapturer = SystemScreenCapturerImplLinux();
    } else if (Platform.isMacOS) {
      _systemScreenCapturer = SystemScreenCapturerImplMacOS();
    } else if (Platform.isWindows) {
      _systemScreenCapturer = SystemScreenCapturerImplWindows(_channel);
    }
  }

  /// The shared instance of [ScreenCapturer].
  static final ScreenCapturer instance = ScreenCapturer._();

  final MethodChannel _channel = const MethodChannel('screen_capturer');

  late SystemScreenCapturer _systemScreenCapturer;

  Future<bool> isAccessAllowed() async {
    if (!kIsWeb && Platform.isMacOS) {
      return await _channel.invokeMethod('isAccessAllowed');
    }
    return true;
  }

  Future<void> requestAccess({
    bool onlyOpenPrefPane = false,
  }) async {
    if (!kIsWeb && Platform.isMacOS) {
      final Map<String, dynamic> arguments = {
        'onlyOpenPrefPane': onlyOpenPrefPane,
      };
      await _channel.invokeMethod('requestAccess', arguments);
    }
  }

  Future<CapturedData?> capture(
      {String? imagePath,
      CaptureMode mode = CaptureMode.region,
      bool silent = true,
      bool copyToClipboard = true}) async {
    File? imageFile;
    if (imagePath != null) {
      File imageFile = File(imagePath);
      if (!imageFile.parent.existsSync()) {
        imageFile.parent.create(recursive: true);
      }
    }
    var capturedData = CapturedData();

    await _systemScreenCapturer.capture(
        mode: mode,
        imagePath: imagePath,
        silent: silent,
        copyToClipboard: copyToClipboard,
        onCaptured: (buffer) {
          capturedData.pngBytes = buffer;
        });

    //need save to file
    if (imagePath != null && imageFile != null) {
      if (imageFile.existsSync()) {
        Uint8List imageBytes = imageFile.readAsBytesSync();
        final decodedImage = await decodeImageFromList(imageBytes);

        capturedData.imagePath = imagePath;
        capturedData.imageWidth = decodedImage.width;
        capturedData.imageHeight = decodedImage.height;
        capturedData.base64Image = base64Encode(imageBytes);
      }
    }

    return capturedData;
  }
}
