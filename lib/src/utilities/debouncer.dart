import 'dart:async';

import 'package:flutter/material.dart';

/// Debouncer utility for delaying function execution.
///
/// This class provides debouncing functionality to delay the execution of
/// a callback until a specified duration has passed since the last call.
/// Useful for search input, API calls, and other operations that should
/// not execute on every keystroke or event.
///
/// **How it works:**
/// - When `run()` is called, it cancels any pending timer
/// - Starts a new timer with the specified duration
/// - If `run()` is called again before the timer completes, the timer is reset
/// - The callback only executes after the duration passes without new calls
///
/// **Usage:**
/// ```dart
/// final debouncer = IsmChatDebounce();
///
/// // In search input handler
/// onChanged: (text) {
///   debouncer.run(
///     () => performSearch(text),
///     duration: Duration(milliseconds: 500),
///   );
/// }
/// ```
///
/// **Default Duration:** 750 milliseconds
///
/// **See Also:**
/// - [IsmChatActionDebounce] - Faster debouncer for actions
/// - [MODULE_UTILITIES.md] - Utilities documentation
class IsmChatDebounce {
  /// The action callback to execute after debounce delay.
  VoidCallback? action;

  /// Internal timer for debouncing.
  Timer? _timer;

  /// Runs the action after the specified duration.
  ///
  /// If called multiple times before the duration expires, the timer is reset
  /// and the duration starts over. This ensures the action only executes after
  /// a period of inactivity.
  ///
  /// **Parameters:**
  /// - `action`: The callback function to execute after the delay.
  /// - `duration`: The delay duration. Defaults to 750 milliseconds.
  ///
  /// **Example:**
  /// ```dart
  /// debouncer.run(
  ///   () => searchUsers(query),
  ///   duration: Duration(milliseconds: 500),
  /// );
  /// ```
  void run(VoidCallback action,
      {Duration duration = const Duration(milliseconds: 750)}) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}

/// Debouncer utility for action events (faster than [IsmChatDebounce]).
///
/// This class provides debouncing functionality similar to [IsmChatDebounce]
/// but with a shorter default duration, making it suitable for action events
/// like button clicks, typing indicators, etc.
///
/// **How it works:**
/// - Same mechanism as [IsmChatDebounce]
/// - Shorter default duration (500ms vs 750ms)
/// - Better for frequent, time-sensitive actions
///
/// **Usage:**
/// ```dart
/// final debouncer = IsmChatActionDebounce();
///
/// // For typing indicator
/// onTextChanged: (text) {
///   debouncer.run(
///     () => sendTypingIndicator(),
///   );
/// }
/// ```
///
/// **Default Duration:** 500 milliseconds
///
/// **See Also:**
/// - [IsmChatDebounce] - Standard debouncer with longer default duration
/// - [MODULE_UTILITIES.md] - Utilities documentation
class IsmChatActionDebounce {
  /// The action callback to execute after debounce delay.
  VoidCallback? action;

  /// Internal timer for debouncing.
  Timer? _timer;

  /// Runs the action after the specified duration.
  ///
  /// Similar to [IsmChatDebounce.run] but with a shorter default duration
  /// for faster response to action events.
  ///
  /// **Parameters:**
  /// - `action`: The callback function to execute after the delay.
  /// - `duration`: The delay duration. Defaults to 500 milliseconds.
  ///
  /// **Example:**
  /// ```dart
  /// actionDebouncer.run(
  ///   () => sendTypingIndicator(),
  /// );
  /// ```
  void run(VoidCallback action,
      {Duration duration = const Duration(milliseconds: 500)}) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}
