import 'dart:developer' as developer;

/// Simple logger utility
class Logger {
  static void log(String message, {String? name}) {
    developer.log(message, name: name ?? 'OminiChat');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'OminiChat',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message) {
    developer.log(message, name: 'OminiChat [DEBUG]');
  }
}

