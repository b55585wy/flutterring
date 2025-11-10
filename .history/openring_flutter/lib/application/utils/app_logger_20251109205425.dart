import 'package:flutter/foundation.dart';

/// 统一日志工具，便于后续切换到不同的日志输出
class AppLogger {
  const AppLogger._();

  static void info(String tag, String message) {
    debugPrint('[INFO][$tag] $message');
  }

  static void warning(String tag, String message) {
    debugPrint('[WARN][$tag] $message');
  }

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    final buffer = StringBuffer('[ERROR][$tag] $message');
    if (error != null) {
      buffer.write(' error=$error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    debugPrint(buffer.toString());
  }
}

