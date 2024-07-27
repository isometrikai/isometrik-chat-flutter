import 'dart:developer';

import '/res/strings.dart';

class AppLog {
  ///This Constructor of `ChatLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `yellow` color.
  ///
  ///It can be used for error logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `ChatLog()` - for basic log
  ///- `ChatLog.info()` - for info log
  ///- `ChatLog.success()` - for success log
  AppLog.error(this.message, [this.stackTrace]) {
    log(
      '\x1B[31m[${Strings.name}] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Error',
      level: 1200,
    );
  }

  ///This Constructor of `ChatLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `yellow` color.
  ///
  ///It can be used for success logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `ChatLog()` - for basic log
  ///- `ChatLog.info()` - for info log
  ///- `ChatLog.error()` - for error log
  AppLog.success(this.message, [this.stackTrace]) {
    log(
      '\x1B[32m[${Strings.name}] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Success',
      level: 800,
    );
  }

  ///This Constructor of `ChatLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `yellow` color.
  ///
  ///It can be used for information logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `ChatLog()` - for basic log
  ///- `ChatLog.success()` - for success log
  ///- `ChatLog.error()` - for error log
  AppLog.info(this.message, [this.stackTrace]) {
    log(
      '\x1B[33m[${Strings.name}] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Info',
      level: 900,
    );
  }

  ///This Constructor of `ChatLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `yellow` color.
  ///
  ///It can be used for basic logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `ChatLog.info()` - for information log
  ///- `ChatLog.success()` - for success log
  ///- `ChatLog.error()` - for error log
  AppLog(this.message, [this.stackTrace]) {
    log(
      '\x1B[37m[${Strings.name}] - $message\x1B[0m',
      // '[${ChatStrings.name}] - $message',
      stackTrace: stackTrace,
      level: 700,
    );
  }
  final dynamic message;
  final StackTrace? stackTrace;
}
