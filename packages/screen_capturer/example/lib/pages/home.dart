import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preference_list/preference_list.dart';
import 'package:screen_capturer/screen_capturer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory? _screenshotsDirectory;

  bool _isAccessAllowed = false;
  bool _copyToClipboard = false;

  CapturedData? _lastCapturedData;
  Uint8List? _imageBytesFromClipboard;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _screenshotsDirectory = await getApplicationDocumentsDirectory();
    _isAccessAllowed = await screenCapturer.isAccessAllowed();

    setState(() {});
  }

  Future<void> _handleClickCapture(CaptureMode mode) async {
    Directory directory =
        _screenshotsDirectory ?? await getApplicationDocumentsDirectory();

    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath =
        '${directory.path}/screen_capturer_example/Screenshots/$imageName';
    _lastCapturedData = await screenCapturer.capture(
      mode: mode,
      imagePath: imagePath,
      copyToClipboard: _copyToClipboard,
      silent: true,
    );
    if (_lastCapturedData != null) {
      // ignore: avoid_print
      // print(_lastCapturedData!.toJson());
    } else {
      // ignore: avoid_print
      print('User canceled capture');
    }
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        if (_screenshotsDirectory != null)
          PreferenceListSection(
            children: [
              PreferenceListItem(
                title: const Text('Output Directory'),
                accessoryView: Text(_screenshotsDirectory!.path),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: _screenshotsDirectory!.path),
                  );
                  BotToast.showText(text: 'Copied to clipboard');
                },
              ),
            ],
          ),
        PreferenceListSection(
          title: const Text('METHODS'),
          children: [
            if (!kIsWeb && Platform.isMacOS) ...[
              PreferenceListItem(
                title: const Text('isAccessAllowed'),
                accessoryView: Text('$_isAccessAllowed'),
                onTap: () async {
                  bool allowed = await screenCapturer.isAccessAllowed();
                  BotToast.showText(text: 'allowed: $allowed');
                  setState(() {
                    _isAccessAllowed = allowed;
                  });
                },
              ),
              PreferenceListItem(
                title: const Text('requestAccess'),
                onTap: () async {
                  await screenCapturer.requestAccess();
                },
              ),
            ],
            PreferenceListItem(
              title: const Text('readImageFromClipboard'),
              onTap: () async {
                _imageBytesFromClipboard =
                    await screenCapturer.readImageFromClipboard();
                setState(() {});
              },
            ),
            PreferenceListItem(
              title: const Text('capture'),
              accessoryView: Row(
                children: [
                  Row(
                    children: [
                      CupertinoCheckbox(
                        value: _copyToClipboard,
                        onChanged: (value) {
                          _copyToClipboard = value!;
                          setState(() {});
                        },
                      ),
                      const Text('copyToClipboard'),
                      const SizedBox(width: 10),
                    ],
                  ),
                  CupertinoButton(
                    child: const Text('region'),
                    onPressed: () {
                      _handleClickCapture(CaptureMode.region);
                    },
                  ),
                  CupertinoButton(
                    child: const Text('screen'),
                    onPressed: () {
                      _handleClickCapture(CaptureMode.screen);
                    },
                  ),
                  CupertinoButton(
                    child: const Text('window'),
                    onPressed: () {
                      _handleClickCapture(CaptureMode.window);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_lastCapturedData != null && _lastCapturedData?.imagePath != null)
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 400,
            height: 400,
            child: Image.file(
              File(_lastCapturedData!.imagePath!),
            ),
          ),
        if (_imageBytesFromClipboard != null)
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 400,
            height: 400,
            child: Image.memory(
              _imageBytesFromClipboard!,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }
}
