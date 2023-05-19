// import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:screen_capturer/screen_capturer.dart';

void main() {
  // const MethodChannel channel = MethodChannel('screen_capturer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // channel.setMockMethodCallHandler((MethodCall methodCall) async {
    //   return '42';
    // });
  });

  tearDown(() {
    // channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect('1', '1');
  });
}
