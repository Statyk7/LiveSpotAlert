import 'dart:developer' as developer;

import 'package:sentry_flutter/sentry_flutter.dart';


class AppLogger {
  static const String _name = 'LiveSpotAlert';

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );

    Sentry.logger.trace(
      message,
      attributes: _getSentryAttributes(error)
    );
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );

    Sentry.logger.info(
        message,
        attributes: _getSentryAttributes(error)
    );
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );

    Sentry.logger.warn(
        message,
        attributes: _getSentryAttributes(error)
    );
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );

    Sentry.logger.error(
        message,
        attributes: _getSentryAttributes(error)
    );
  }

  static Map<String, SentryLogAttribute>? _getSentryAttributes(Object? error) {
    if (error == null) return null;
    return { "error": SentryLogAttribute.string(error.toString()) };
  }
}
