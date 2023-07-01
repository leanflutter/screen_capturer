import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:screen_capturer/src/capture_mode.dart';
import 'package:screen_capturer/src/screen_capturer_platform_interface.dart';
import 'package:screen_capturer/src/system_screen_capturer.dart';
import 'package:win32/win32.dart';

final Map<CaptureMode, String> _knownCaptureModeArgs = {
  CaptureMode.region: 'Rectangle',
  CaptureMode.screen: '',
  CaptureMode.window: 'Window',
};

bool _isScreenClipping() {
  final int hWnd = GetForegroundWindow();
  final lpdwProcessId = calloc<Uint32>();

  GetWindowThreadProcessId(hWnd, lpdwProcessId);
  // Get a handle to the process.
  final hProcess = OpenProcess(
    PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
    FALSE,
    lpdwProcessId.value,
  );

  if (hProcess == 0) {
    return false;
  }

  // Get a list of all the modules in this process.
  final hModules = calloc<HMODULE>(1024);
  final cbNeeded = calloc<DWORD>();

  try {
    int r = EnumProcessModules(
      hProcess,
      hModules,
      sizeOf<HMODULE>() * 1024,
      cbNeeded,
    );

    if (r == 1) {
      for (var i = 0; i < (cbNeeded.value ~/ sizeOf<HMODULE>()); i++) {
        final szModName = wsalloc(MAX_PATH);
        // Get the full path to the module's file.
        final hModule = hModules.elementAt(i).value;
        if (GetModuleFileNameEx(hProcess, hModule, szModName, MAX_PATH) != 0) {
          String moduleName = szModName.toDartString();
          if (moduleName.contains('ScreenClippingHost.exe')) {
            free(szModName);
            return true;
          }
        }
        free(szModName);
      }
    }
  } finally {
    free(hModules);
    free(cbNeeded);
    CloseHandle(hProcess);
  }

  return false;
}

class SystemScreenCapturerImplWindows extends SystemScreenCapturer {
  SystemScreenCapturerImplWindows();

  @override
  Future<void> capture({
    required CaptureMode mode,
    String? imagePath,
    bool copyToClipboard = true,
    bool silent = true,
  }) async {
    if (mode == CaptureMode.screen) {
      assert(imagePath != null);
      await ScreenCapturerPlatform.instance.captureScreen(
        imagePath: imagePath!,
      );
      return;
    }
    await Clipboard.setData(const ClipboardData(text: ''));
    ShellExecute(
      0,
      'open'.toNativeUtf16(),
      'ms-screenclip://?clippingMode=${_knownCaptureModeArgs[mode]}'
          .toNativeUtf16(),
      nullptr,
      nullptr,
      SW_SHOWNORMAL,
    );
    await Future.delayed(const Duration(seconds: 1));

    while (_isScreenClipping()) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (imagePath != null) {
      await ScreenCapturerPlatform.instance.saveClipboardImageAsPngFile(
        imagePath: imagePath,
      );
    }
  }
}
