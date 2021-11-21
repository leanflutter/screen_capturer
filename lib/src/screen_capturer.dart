import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<CapturedData?> capture({
    String? imagePath,
    bool silent = true,
  }) async {
    if (imagePath == null) throw ArgumentError.notNull('imagePath');
    File imageFile = File(imagePath);
    if (!imageFile.parent.existsSync()) {
      imageFile.parent.create(recursive: true);
    }
    await _systemScreenCapturer.capture(
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
        base64Image: base64Encode(imageBytes),
      );
    }
    return null;
  }
}
