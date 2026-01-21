/// Number-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on int and double types for pagination,
/// time formatting, and other numeric operations.
library;

/// Extension for int to handle message pagination.
extension MessagePagination on int {
  /// Calculates pagination value recursively.
  ///
  /// [endValue] - The initial end value (default: 20)
  /// [notEqualPagination] - Whether to use not equal pagination (default: false)
  /// [increaseValue] - The value to increase by each iteration (default: 20)
  int pagination(
      {int endValue = 20,
      bool notEqualPagination = false,
      int increaseValue = 20}) {
    if (this == 0) {
      return this;
    }

    if (this <= endValue && notEqualPagination == false) {
      return endValue;
    }
    endValue = endValue + increaseValue;
    return pagination(endValue: endValue, increaseValue: increaseValue);
  }
}

/// Extension for int to format timer record time.
extension IntToTimeLeft on int {
  /// Converts seconds to a timer format string (e.g., "05:30").
  String get getTimerRecord {
    int h, m, s;
    h = this ~/ 3600;
    m = (this - h * 3600) ~/ 60;
    s = this - (h * 3600) - (m * 60);
    var minuteLeft = m.toString().length < 2 ? '0$m' : m.toString();
    var secondsLeft = s.toString().length < 2 ? '0$s' : s.toString();
    var result = '$minuteLeft:$secondsLeft';
    return result;
  }
}

/// Extension for double to format timer in seconds.
extension TimerSecond on double {
  /// Converts milliseconds to seconds format (e.g., "5.3 s").
  String get inSecTimer {
    final data = (this / 1000).toStringAsFixed(1);
    return '$data s';
  }
}
