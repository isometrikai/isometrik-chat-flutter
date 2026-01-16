/// DateTime and date-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on DateTime and int (timestamp) types for
/// date formatting, comparison, and conversion operations.
library;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for int (timestamp) to convert to DateTime and format dates.
extension DateConvertor on int {
  /// Converts a timestamp (milliseconds since epoch) to a DateTime object.
  DateTime toDate() => DateTime.fromMillisecondsSinceEpoch(this).toLocal();

  /// Converts a timestamp to a time string (e.g., "3:45 PM").
  String get toTimeString => DateFormat.jm()
      .format(DateTime.fromMillisecondsSinceEpoch(this).toLocal());

  /// Converts a timestamp to a current time string with "Last seen" prefix.
  String toCurrentTimeStirng() {
    if (this == 0 || this == -1) {
      return IsmChatStrings.tapInfo;
    }
    final timeStamp = toDate().removeTime();
    final now = DateTime.now().toLocal().removeTime();

    if (now.day == timeStamp.day) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.today} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate())}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.yestarday} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate())}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 7)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.at} ${DateFormat('E h:mm a').format(toDate())}';
    }
    return '${IsmChatStrings.lastSeen} ${IsmChatStrings.on} ${DateFormat('MMM d, yyyy h:mm a').format(toDate())}';
  }

  /// Converts a timestamp to a last message time string.
  String get toLastMessageTimeString {
    if (this == 0 || this == -1) {
      return '';
    }
    final timeStamp = toDate().removeTime();
    final now = DateTime.now().removeTime();
    if (now.day == timeStamp.day) {
      return DateFormat.jm().format(toDate());
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return IsmChatStrings.yestarday.capitalizeFirst!;
    }
    return IsmChatConfig.isMonthFirst == true
        ? DateFormat('MM/dd/yyyy').format(toDate())
        : DateFormat('dd/MM/yyyy').format(toDate());
  }

  /// Converts a weekday number (1-7) to its string representation.
  String get weekDayString {
    if (this > 7 || this < 1) {
      throw const IsmChatInvalidWeekdayNumber('Value should be between 1 & 7');
    }
    var weekDays = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return weekDays[this]!;
  }

  /// Converts a timestamp to a message date string.
  String toMessageDateString() {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now().toLocal();
    var date = toDate();
    if (now.isSameDay(date)) {
      return 'Today';
    }
    if (now.isSameMonth(date)) {
      if (now.day - date.day == 1) {
        return 'Yesterday';
      }
      if (now.difference(date) < const Duration(days: 8)) {
        return date.weekday.weekDayString;
      }
      return date.toDateString();
    }
    return date.toDateString();
  }

  /// Converts a timestamp to a message month string.
  String toMessageMonthString() {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now().toLocal();
    var date = toDate();

    if (now.isSameDay(date)) {
      return 'Today';
    } else if (now.difference(date) < const Duration(days: 8)) {
      return date.weekday.weekDayString;
    }
    return date.toDateString();
  }

  /// Converts a timestamp to a delivery time string.
  String get deliverTime {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now().toLocal();
    var timestamp = toDate();
    late DateFormat dateFormat;
    if (now.difference(timestamp) > const Duration(days: 365)) {
      dateFormat = DateFormat('EEEE, MMM d, yyyy');
    } else if (now.difference(timestamp) > const Duration(days: 7)) {
      dateFormat = DateFormat('E, d MMM yyyy, hh:mm:ss aa');
    } else {
      dateFormat = DateFormat('EEEE  hh:mm:ss aa');
    }

    return dateFormat.format(timestamp);
  }

  /// Converts a timestamp to a formatted time string with month and day.
  String get getTime {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(this).toLocal();
    final time = DateFormat.jm().format(timeStamp);
    final monthDay = DateFormat.MMMd().format(timeStamp);
    return '$monthDay, $time';
  }
}

/// Extension for DateTime to format dates and compare dates.
extension DateFormats on DateTime {
  /// Converts a DateTime to a time string (e.g., "3:45 PM").
  String toTimeString() => DateFormat.jm().format(this);

  /// Checks if this DateTime is on the same day as another DateTime.
  bool isSameDay(DateTime other) => isSameMonth(other) && day == other.day;

  /// Checks if this DateTime is in the same month as another DateTime.
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Converts a DateTime to a date string (e.g., "15 Jan 2024").
  String toDateString() => DateFormat('dd MMM yyyy').format(this);

  /// Removes the time component from a DateTime, keeping only the date.
  DateTime removeTime() => DateTime(year, month, day).toLocal();
}
