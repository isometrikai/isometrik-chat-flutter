/// DateTime and date-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on DateTime and int (timestamp) types for
/// date formatting, comparison, and conversion operations.
library;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Applies the SDK's configured timezone (if any) to a [DateTime].
///
/// **Priority:**
/// 1. If [IsmChatConfig.userTimeZoneOffset] callback is set and [userId] is provided:
///    - Uses the callback to get user-specific timezone
/// 2. If [IsmChatConfig.timeZoneOffset] is set:
///    - Uses the global timezone offset
/// 3. Otherwise:
///    - Falls back to device local timezone
///
/// **Parameters:**
/// - `dateTime`: The DateTime to convert
/// - `userId`: Optional user ID for per-user timezone lookup
/// - `conversationId`: Optional conversation ID for context
DateTime _applyChatTimeZone(
  DateTime dateTime, {
  String? userId,
  String? conversationId,
}) {
  // Try per-user timezone first (for agent/admin interfaces)
  if (userId != null && IsmChatConfig.userTimeZoneOffset != null) {
    final userOffset =
        IsmChatConfig.userTimeZoneOffset!(userId, conversationId);
    if (userOffset != null) {
      final utc = dateTime.toUtc();
      return utc.add(userOffset);
    }
  }

  // Fall back to global timezone offset
  final offset = IsmChatConfig.timeZoneOffset;
  if (offset == null) {
    // Default behavior: device local timezone
    return dateTime.toLocal();
  }

  // Normalize to UTC then apply the configured offset so that all timestamps
  // are shown according to the desired region, independent of the device.
  final utc = dateTime.toUtc();
  return utc.add(offset);
}

/// Extension for int (timestamp) to convert to DateTime and format dates.
extension DateConvertor on int {
  /// Converts a timestamp (milliseconds since epoch) to a DateTime object.
  ///
  /// Optionally accepts [userId] and [conversationId] for per-user timezone support.
  DateTime toDate({String? userId, String? conversationId}) =>
      _applyChatTimeZone(
        DateTime.fromMillisecondsSinceEpoch(this),
        userId: userId,
        conversationId: conversationId,
      );

  /// Converts a timestamp to a time string (e.g., "3:45 PM").
  ///
  /// This getter uses the device timezone by default.
  /// For per-user timezone support, use [toTimeStringForUser] method instead.
  String get toTimeString => DateFormat.jm().format(
        _applyChatTimeZone(DateTime.fromMillisecondsSinceEpoch(this)),
      );

  /// Converts a timestamp to a time string with per-user timezone support.
  ///
  /// Accepts [userId] and [conversationId] for per-user timezone support.
  /// Use this method when you need to display times according to a specific user's timezone.
  String toTimeStringForUser({String? userId, String? conversationId}) =>
      DateFormat.jm().format(
        _applyChatTimeZone(
          DateTime.fromMillisecondsSinceEpoch(this),
          userId: userId,
          conversationId: conversationId,
        ),
      );

  /// Converts a timestamp to a current time string with "Last seen" prefix.
  ///
  /// Optionally accepts [userId] and [conversationId] for per-user timezone support.
  String toCurrentTimeStirng({String? userId, String? conversationId}) {
    if (this == 0 || this == -1) {
      return IsmChatStrings.tapInfo;
    }
    final timeStamp =
        toDate(userId: userId, conversationId: conversationId).removeTime();
    final now = _applyChatTimeZone(
      DateTime.now(),
      userId: userId,
      conversationId: conversationId,
    ).removeTime();

    if (now.day == timeStamp.day) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.today} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate(userId: userId, conversationId: conversationId))}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.yestarday} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate(userId: userId, conversationId: conversationId))}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 7)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.at} ${DateFormat('E h:mm a').format(toDate(userId: userId, conversationId: conversationId))}';
    }
    return '${IsmChatStrings.lastSeen} ${IsmChatStrings.on} ${DateFormat('MMM d, yyyy h:mm a').format(toDate(userId: userId, conversationId: conversationId))}';
  }

  /// Converts a timestamp to a last message time string.
  ///
  /// This getter uses the device timezone by default.
  /// For per-user timezone support, use [toLastMessageTimeStringForUser] method instead.
  String get toLastMessageTimeString {
    if (this == 0 || this == -1) {
      return '';
    }
    final timeStamp = toDate().removeTime();
    final now = _applyChatTimeZone(DateTime.now()).removeTime();
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

  /// Converts a timestamp to a last message time string with per-user timezone support.
  ///
  /// Accepts [userId] and [conversationId] for per-user timezone support.
  /// Use this method when you need to display times according to a specific user's timezone.
  String toLastMessageTimeStringForUser({
    String? userId,
    String? conversationId,
  }) {
    if (this == 0 || this == -1) {
      return '';
    }
    final timeStamp =
        toDate(userId: userId, conversationId: conversationId).removeTime();
    final now = _applyChatTimeZone(
      DateTime.now(),
      userId: userId,
      conversationId: conversationId,
    ).removeTime();
    if (now.day == timeStamp.day) {
      return DateFormat.jm()
          .format(toDate(userId: userId, conversationId: conversationId));
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return IsmChatStrings.yestarday.capitalizeFirst!;
    }
    return IsmChatConfig.isMonthFirst == true
        ? DateFormat('MM/dd/yyyy')
            .format(toDate(userId: userId, conversationId: conversationId))
        : DateFormat('dd/MM/yyyy')
            .format(toDate(userId: userId, conversationId: conversationId));
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
    var now = _applyChatTimeZone(DateTime.now());
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
    var now = _applyChatTimeZone(DateTime.now());
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
    var now = _applyChatTimeZone(DateTime.now());
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
    final timeStamp =
        _applyChatTimeZone(DateTime.fromMillisecondsSinceEpoch(this));
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
