import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class LocalMentionAndPhoneNumber {
  factory LocalMentionAndPhoneNumber.fromMap(Map<String, dynamic> map) =>
      LocalMentionAndPhoneNumber(
        text: map['text'] as String,
        isMentioned: map['isMentioned'] as bool,
        isPhoneNumber: map['isPhoneNumber'] as bool,
      );

  factory LocalMentionAndPhoneNumber.fromJson(String source) =>
      LocalMentionAndPhoneNumber.fromMap(
          json.decode(source) as Map<String, dynamic>);
  const LocalMentionAndPhoneNumber({
    required this.text,
    required this.isMentioned,
    required this.isPhoneNumber,
  });
  final String text;
  final bool isMentioned;
  final bool isPhoneNumber;

  LocalMentionAndPhoneNumber copyWith({
    String? text,
    bool? isMentioned,
    bool? isPhoneNumber,
  }) =>
      LocalMentionAndPhoneNumber(
        text: text ?? this.text,
        isMentioned: isMentioned ?? this.isMentioned,
        isPhoneNumber: isPhoneNumber ?? this.isPhoneNumber,
      );

  @override
  String toString() =>
      'LocalMentionAndPhoneNumber(text: $text, isMentioned: $isMentioned, isPhoneNumber: $isPhoneNumber)';

  Map<String, dynamic> toMap() => <String, dynamic>{
        'text': text,
        'isMentioned': isMentioned,
        'isPhoneNumber': isPhoneNumber,
      }.removeNullValues();

  String toJson() => json.encode(toMap());
}
