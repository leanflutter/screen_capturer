# screen_capturer

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/screen_capturer.svg
[pub-url]: https://pub.dev/packages/screen_capturer
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter 桌面应用程序进行屏幕截图。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [screen_capturer](#screen_capturer)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
      - [Windows requirements](#windows-requirements)
    - [用法](#用法)
    - [macOS](#macos)
  - [平台差异](#平台差异)
    - [CaptureMode](#capturemode)
  - [谁在用使用它？](#谁在用使用它)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  screen_capturer: ^0.1.7
```

或

```yaml
dependencies:
  screen_capturer:
    git:
      url: https://github.com/leanflutter/screen_capturer.git
      ref: main
```

#### Windows requirements

请务必修改你的 Visual Studio 安装，并确保 **"C++ ATL for latest v142 build tools (x86 & x64)"** 已安装

### 用法

### macOS

更改文件 `macos/Runner/DebugProfile.entitlements` 或 `macos/Runner/Release.entitlements` 如下：

> 仅在沙盒模式下需要。

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
+	<key>com.apple.security.temporary-exception.mach-register.global-name</key>
+	<string>com.apple.screencapture.interactive</string>
</dict>
</plist>
```

```dart
import 'package:screen_capturer/screen_capturer.dart';

CapturedData? capturedData = await screenCapturer.capture(
  mode: CaptureMode.region, // screen, window
  imagePath: '<path>',
  copyToClipboard: true,
);
```

> 请看这个插件的示例应用，以了解完整的例子。

## 平台差异

### CaptureMode

| Name     | Description                                | Linux | macOS | Windows |
| -------- | ------------------------------------------ | ----- | ----- | ------- |
| `region` | 在对象周围拖动光标以形成一个矩形。         | ✔️    | ✔️    | ✔️      |
| `screen` | 捕获整个屏幕。                             | ✔️    | ✔️    | ✔️      |
| `window` | 选择要捕获的窗口。（linux 只捕获当前窗口） | ➖    | ✔️    | ✔️      |

## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。

## 许可证

[MIT](./LICENSE)
