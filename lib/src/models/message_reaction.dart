// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MessageReactionModel {
  final String emojiKey;
  final List<String> userIds;
  MessageReactionModel({
    required this.emojiKey,
    required this.userIds,
  });

  MessageReactionModel copyWith({
    String? emojiKey,
    List<String>? userIds,
  }) =>
      MessageReactionModel(
        emojiKey: emojiKey ?? this.emojiKey,
        userIds: userIds ?? this.userIds,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'emojiKey': emojiKey,
        'userIds': userIds,
      }.removeNullValues();

  factory MessageReactionModel.fromMap(Map<String, dynamic> map) =>
      MessageReactionModel(
          emojiKey: map['emojiKey'] as String,
          userIds: List<String>.from(
            map['userIds'] as List<dynamic>,
          ));

  String toJson() => json.encode(toMap());

  factory MessageReactionModel.fromJson(String source) =>
      MessageReactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MessageReactionModel(emojiKey: $emojiKey, userIds: $userIds)';

  @override
  bool operator ==(covariant MessageReactionModel other) {
    if (identical(this, other)) return true;

    return other.emojiKey == emojiKey && listEquals(other.userIds, userIds);
  }

  @override
  int get hashCode => emojiKey.hashCode ^ userIds.hashCode;
}
