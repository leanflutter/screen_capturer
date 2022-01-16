# screen_capturer

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/screen_capturer.svg
[pub-url]: https://pub.dev/packages/screen_capturer

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to take screenshots.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [screen_capturer](#screen_capturer)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

> ⚠️ macOS only supports non-sandbox mode.

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  screen_capturer: ^0.1.0
```

Or

```yaml
dependencies:
  screen_capturer:
    git:
      url: https://github.com/leanflutter/screen_capturer.git
      ref: main
```

### Usage

```dart
import 'package:screen_capturer/screen_capturer.dart';

CapturedData? capturedData = await ScreenCapturer.instance.capture(
  imagePath: '<path>',
);
```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## License

[MIT](./LICENSE)
