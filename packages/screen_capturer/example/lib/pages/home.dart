import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
    return ListView(
      children: <Widget>[
        if (_screenshotsDirectory != null)
          Column(
            children: [
              ListTile(
                title: const Text('Output Directory'),
                trailing: Text(_screenshotsDirectory!.path),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: _screenshotsDirectory!.path),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Copied')));
                },
              ),
            ],
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 32, bottom: 8, left: 16),
              child: const Text(
                'METHODS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            if (!kIsWeb && Platform.isMacOS) ...[
              ListTile(
                title: const Text('isAccessAllowed'),
                trailing: Text('$_isAccessAllowed'),
                onTap: () async {
                  bool allowed = await screenCapturer.isAccessAllowed();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('allowed: $allowed')),
                  );
                  setState(() {
                    _isAccessAllowed = allowed;
                  });
                },
              ),
              ListTile(
                title: const Text('requestAccess'),
                onTap: () async {
                  await screenCapturer.requestAccess();
                },
              ),
            ],
            ListTile(
              title: const Text('readImageFromClipboard'),
              onTap: () async {
                _imageBytesFromClipboard =
                    await screenCapturer.readImageFromClipboard();
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('capture'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _copyToClipboard,
                        onChanged: (value) {
                          _copyToClipboard = value!;
                          setState(() {});
                        },
                      ),
                      const Text('copyToClipboard'),
                    ],
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    child: const Text('region'),
                    onPressed: () {
                      _handleClickCapture(CaptureMode.region);
                    },
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    child: const Text('screen'),
                    onPressed: () {
                      _handleClickCapture(CaptureMode.screen);
                    },
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
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
        title: const Text('screen_capturer_example'),
      ),
      body: Container(
        child: _buildBody(context),
      ),
    );
  }
}
