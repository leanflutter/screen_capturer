import 'dart:typed_data';
import 'capture_mode.dart';

typedef OnCapturedEventHandler = void Function(Uint8List buffer);

class SystemScreenCapturer {
  Future<void> capture({
    required CaptureMode mode,
    String? imagePath,
    OnCapturedEventHandler? onCaptured,
    bool copyToClipboard = true,
    bool silent = true,
  }) {
    throw UnimplementedError();
  }
}
