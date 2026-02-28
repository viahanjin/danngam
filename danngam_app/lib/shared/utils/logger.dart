/// Log Level Enum
enum LogLevel { debug, info, warning, error }

/// Application Logger
/// Provides centralized logging with different log levels
class AppLogger {
  AppLogger._();

  static const String _tag = '[DANNGAM]';

  /// Log debug message
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag);
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag);
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log error message
  static void error(String message, {String? tag, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, stackTrace: stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message,
    String? tag, {
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final levelString = level.toString().split('.').last.toUpperCase();

    final logMessage = '[$timestamp] [$levelString] $logTag: $message';

    // Print to console (only in debug mode)
    // ignore: avoid_print
    print(logMessage);

    // Log stack trace if provided
    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}
