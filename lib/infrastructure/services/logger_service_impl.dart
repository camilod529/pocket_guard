import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';

class LoggerServiceImpl implements LoggerService {
  final String context;
  final Logger _logger;

  LoggerServiceImpl(this.context)
    : _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  void debug(String message) {
    if (kDebugMode) {
      _logger.d('[$context] DEBUG: $message');
    }
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.e('[$context] $message', error: error, stackTrace: stackTrace);
    }
  }

  @override
  void info(String message) {
    if (kDebugMode) {
      _logger.i('[$context] $message');
    }
  }

  @override
  void warning(String message) {
    if (kDebugMode) {
      _logger.w('[$context] WARNING: $message');
    }
  }
}
