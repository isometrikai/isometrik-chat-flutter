/// Duration-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on Duration type for formatting
/// duration strings and generating wave samples for audio visualization.
library;

import 'dart:math';

/// Extension for Duration to format duration strings.
extension DurationExtensions on Duration {
  /// Formats duration as "MM:SS" or "HH:MM:SS" if hours > 0.
  String get formatDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    var twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    var hour = num.parse(twoDigits(inHours));
    if (hour > 0) {
      return '${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  /// Generates wave samples for audio visualization.
  ///
  /// Returns a list of random double values between 30 and 160,
  /// with the number of samples based on duration (clamped between 100-150).
  List<double> get waveSamples {
    var number = (inMilliseconds ~/ 30).clamp(100, 150).toInt();
    var random = Random();
    return List.generate(number, (i) => (random.nextInt(130) + 30).toDouble());
  }

  /// Formats duration as a full string with hours, minutes, and seconds.
  ///
  /// Example: "2 Hours 30 Mins 15 Secs" or "30 Mins 15 Secs"
  String get formatFullDuration {
    var h = inHours.toString().padLeft(2, '0');
    var m = (inMinutes % 60).toString().padLeft(2, '0');
    var s = (inSeconds % 60).toString().padLeft(2, '0');
    if (h != '00') {
      h = '$h Hours';
    }
    if (m != '00') {
      m = '$m Mins';
    }
    if (s != '00') {
      s = '$s Secs';
    }
    return [h, m, s].where((e) => e != '00').join(' ');
  }
}
