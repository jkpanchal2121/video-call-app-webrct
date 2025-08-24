import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // for kReleaseMode

final logger = kReleaseMode ? _NoOpLogger() : Logger();

class _NoOpLogger extends Logger {
  _NoOpLogger() : super(printer: PrettyPrinter(methodCount: 0));

  @override
  void log(
      Level level,
      dynamic message, {
        Object? error,
        StackTrace? stackTrace,
        DateTime? time,
      }) {
    // Do nothing in release mode
  }
}
