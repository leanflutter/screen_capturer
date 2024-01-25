import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:screen_capturer_example/pages/home.dart';
import 'package:screen_capturer_example/utils/default_shell_executor.dart';
import 'package:shell_executor/shell_executor.dart';

void main() {
  ShellExecutor.global = DefaultShellExecutor();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const HomePage(),
    );
  }
}
