import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/src/res/strings.dart';

/// Centralized logging utility for the Isometrik Chat SDK.
///
/// This class provides a consistent logging interface with different log levels
/// and colored output for better debugging. Logs are only shown in debug mode.
///
/// **Log Levels:**
/// - `error()` - Error logs (red color)
/// - `success()` - Success logs (green color)
/// - `info()` - Info logs (blue color)
/// - `debug()` - Debug logs (default color)
///
/// **Usage:**
/// ```dart
/// // Error log
/// IsmChatLog.error('Failed to send message', stackTrace);
///
/// // Success log
/// IsmChatLog.success('Message sent successfully');
///
/// // Info log
/// IsmChatLog.info('User connected');
///
/// // Debug log
/// IsmChatLog.debug('Processing message');
/// ```
///
/// **Platform Support:**
/// - **Web**: Uses `print()` with ANSI color codes
/// - **Mobile**: Uses `log()` from `dart:developer`
///
/// **Note:** Logs are only displayed in debug mode (`kDebugMode`).
/// In release builds, logging is disabled for performance.
///
/// **See Also:**
/// - [MODULE_UTILITIES.md] - Utilities documentation
class IsmChatLog {
  /// The log message.
  ///
  /// Can be any type (String, Object, etc.) that will be converted to string
  /// for display in the console.
  final dynamic message;

  /// Optional stack trace for error logs.
  ///
  /// Provides additional context about where the error occurred.
  final StackTrace? stackTrace;

  /// Creates an error log entry.
  ///
  /// Error logs are displayed in red color and include stack trace information
  /// if provided. Use this for logging errors, exceptions, and failures.
  ///
  /// **Parameters:**
  /// - `message`: The error message to log. Can be any type.
  /// - `stackTrace`: Optional stack trace for error context.
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await sendMessage();
  /// } catch (e, stack) {
  ///   IsmChatLog.error('Failed to send message: $e', stack);
  /// }
  /// ```
  IsmChatLog.error(this.message, [this.stackTrace]) {
    if (kDebugMode) {
      if (kIsWeb) {
        print('\x1B[31m[${IsmChatStrings.name}] - $message\x1B[0m');
      } else {
        log(
          '\x1B[31m[${IsmChatStrings.name}] - $message\x1B[0m',
          stackTrace: stackTrace,
          name: 'Error',
          level: 1200,
        );
      }
    }
  }

  /// Creates a success log entry.
  ///
  /// Success logs are displayed in green color. Use this for logging successful
  /// operations, completions, and positive outcomes.
  ///
  /// **Parameters:**
  /// - `message`: The success message to log. Can be any type.
  /// - `stackTrace`: Optional stack trace for additional context.
  ///
  /// **Example:**
  /// ```dart
  /// IsmChatLog.success('Message sent successfully');
  /// ```
  IsmChatLog.success(this.message, [this.stackTrace]) {
    if (kDebugMode) {
      if (kIsWeb) {
        print('\x1B[32m[${IsmChatStrings.name}] - $message\x1B[0m');
      } else {
        log(
          '\x1B[32m[${IsmChatStrings.name}] - $message\x1B[0m',
          stackTrace: stackTrace,
          name: 'Success',
          level: 800,
        );
      }
    }
  }

  /// Creates an info log entry.
  ///
  /// Info logs are displayed in blue color. Use this for logging informational
  /// messages, state changes, and general debugging information.
  ///
  /// **Parameters:**
  /// - `message`: The info message to log. Can be any type.
  /// - `stackTrace`: Optional stack trace for additional context.
  ///
  /// **Example:**
  /// ```dart
  /// IsmChatLog.info('User connected to MQTT');
  /// ```
  IsmChatLog.info(this.message, [this.stackTrace]) {
    if (kDebugMode) {
      if (kIsWeb) {
        print('\x1B[33m[${IsmChatStrings.name}] - $message\x1B[0m');
      } else {
        log(
          '\x1B[33m[${IsmChatStrings.name}] - $message\x1B[0m',
          stackTrace: stackTrace,
          name: 'Info',
          level: 900,
        );
      }
    }
  }

  /// Creates a debug log entry.
  ///
  /// Debug logs are displayed in default color (white). Use this for general
  /// debugging and development logs.
  ///
  /// **Parameters:**
  /// - `message`: The debug message to log. Can be any type.
  /// - `stackTrace`: Optional stack trace for additional context.
  ///
  /// **Example:**
  /// ```dart
  /// IsmChatLog('Processing message');
  /// ```
  IsmChatLog(this.message, [this.stackTrace]) {
    if (kDebugMode) {
      if (kIsWeb) {
        print('\x1B[37m[${IsmChatStrings.name}] - $message\x1B[0m');
      } else {
        log(
          '\x1B[37m[${IsmChatStrings.name}] - $message\x1B[0m',
          stackTrace: stackTrace,
          level: 700,
        );
      }
    }
  }
}
