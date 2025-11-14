import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String message) {
    if (kDebugMode) {
      // use debugPrint to avoid truncation
      debugPrint(message);
    }
  }

  static void i(String message) {
    if (kDebugMode) debugPrint('INFO: $message');
  }

  static void w(String message) {
    if (kDebugMode) debugPrint('WARN: $message');
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message${error != null ? ' - $error' : ''}');
      if (stack != null) debugPrint(stack.toString());
    } else {
      // In release you may want to send errors to a remote service
      // e.g. Sentry, Crashlytics. Keep this empty to avoid unexpected side effects.
    }
  }
}
