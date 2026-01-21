/// String-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on String and String? types for common
/// string operations like URL validation, matching, color conversion, etc.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for nullable String to check if it's null or empty.
extension NullStringExtension on String? {
  /// Returns true if the string is null or empty (after trimming).
  bool get isNullOrEmpty => this == null || (this?.trim() ?? '').isEmpty;
}

/// Extension for String matching and validation operations.
extension MatchString on String {
  /// Checks if this string contains the other string (case-insensitive).
  bool didMatch(String other) => toLowerCase().contains(other.toLowerCase());

  /// Converts a string to a valid URL by ensuring it starts with 'https://'.
  String get convertToValidUrl =>
      'https://${replaceAll('http://', '').replaceAll('https://', '')}';

  /// Checks if the string contains a valid URL pattern.
  bool get isValidUrl =>
      toLowerCase().contains('https') ||
      toLowerCase().contains('http') ||
      toLowerCase().contains('www');

  /// Checks if the string starts with a valid URL pattern.
  bool get isForceValidUrl =>
      toLowerCase().startsWith('https') ||
      toLowerCase().startsWith('http') ||
      toLowerCase().startsWith('www');

  /// Checks if the string contains only alphabetic characters.
  bool get isAlphabet => RegExp(r'^[A-Za-z]+$').hasMatch(this);
}

/// Extension for String to get color from hex string.
extension ColorExtension on String {
  /// Converts a hex color string to a Color object.
  Color? get toColor {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Gets a Color from a hex string (alternative method).
  Color getColor() => Color(int.parse('0xff${replaceFirst('#', '')}'));
}

/// Extension for String to extract location coordinates from Google Maps URL.
extension GetLink on String {
  /// Extracts LatLng coordinates from a Google Maps URL.
  ///
  /// The URL format should be: <BaseUrl>?<Params>&query=`Lat`%2C`Lng`&<Rest Params>
  ///
  /// Throws [IsmChatInvalidMapUrlException] if the URL doesn't contain a map link.
  LatLng get position {
    if (!contains('map')) {
      throw const IsmChatInvalidMapUrlException(
          "Invalid url, link doesn't contains map link to extract position coordinates");
    }
    var position = split('query=')
        .last
        .split('&')
        .first
        .split('%2C')
        .map(double.parse)
        .toList();

    return LatLng(position.first, position.last);
  }
}

/// Extension for String to format last message type widget.
extension LastMessageWidget on String {
  /// Returns a widget representing the last message type.
  Widget lastMessageType(LastMessageDetails message) {
    switch (this) {
      case 'Image':
        return Row(
          children: [
            Icon(
              Icons.image,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Image',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Video':
        return Row(
          children: [
            Icon(
              Icons.video_call,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Video',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Audio':
        return Row(
          children: [
            Icon(
              Icons.audio_file,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Audio',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Document':
        return Row(
          children: [
            Icon(
              Icons.file_copy_outlined,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Document',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );
    }
    if (contains('https://www.google.com/maps/')) {
      return Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: IsmChatDimens.sixteen,
          ),
          IsmChatDimens.boxWidth2,
          Text(
            'Location',
            style: IsmChatStyles.w400Black12,
          )
        ],
      );
    }
    return Text(
      message.body,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: IsmChatStyles.w400Black12,
    );
  }
}

/// Extension for String to get reaction emoji string.
extension ReactionLastMessgae on String {
  /// Converts a reaction value to its emoji string representation.
  String get reactionString {
    var reactionValue = IsmChatEmoji.values.firstWhere((e) => e.value == this);
    var emoji = '';
    for (var x in IsmChatUtility.conversationController.reactions) {
      if (x.name == reactionValue.emojiKeyword) {
        emoji = x.emoji;
        break;
      }
    }

    return emoji;
  }
}

/// Extension for String to check media size and convert to Uint8List.
extension SizeOfMedia on String {
  /// Checks if the media size string is within the limit (default 100MB).
  ///
  /// Returns true if the size is in KB or if the numeric value is <= limit.
  bool size({double limit = 100.0}) {
    if (split(' ').last == 'KB') {
      return true;
    }
    if (double.parse(split(' ').first).round() <= limit.round()) {
      return true;
    }

    return false;
  }

  /// Converts a JSON string representation of a list to Uint8List.
  Uint8List get strigToUnit8List {
    if (isNotEmpty) {
      var list = Uint8List.fromList(
        List.from(jsonDecode(this) as List),
      );
      return list;
    }
    return Uint8List(0);
  }
}
