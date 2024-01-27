import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shell_executor/shell_executor.dart';

class DefaultShellExecutor extends ShellExecutor {
  @override
  Future<ProcessResult> exec(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: true,
    );

    if (kDebugMode) {
      print('\$ $executable ${arguments.join(' ')}');
    }

    String? stdoutStr;
    String? stderrStr;

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}$msg';
      stdout.write(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}$msg';
      stderr.write(msg);
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
