import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatLastReadAt {
  factory IsmChatLastReadAt.fromJson(String source) =>
      IsmChatLastReadAt.fromMap(json.decode(source) as Map<String, dynamic>);

  factory IsmChatLastReadAt.fromMap(Map<String, dynamic> map) =>
      IsmChatLastReadAt(
        userId: map['userId'] as String? ?? '',
        readAt: map['readAt'] as int? ?? 0,
      );

  const IsmChatLastReadAt({
    required this.userId,
    required this.readAt,
  });
  final String userId;
  final int readAt;

  IsmChatLastReadAt copyWith({
    String? userId,
    int? readAt,
  }) =>
      IsmChatLastReadAt(
        userId: userId ?? this.userId,
        readAt: readAt ?? this.readAt,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'readAt': readAt,
      }.removeNullValues();

  static List<IsmChatLastReadAt> fromNetworkMap(Map<String, dynamic> map) {
    var data = <IsmChatLastReadAt>[];
    for (MapEntry map in map.entries) {
      data.add(
        IsmChatLastReadAt(
          userId: map.key as String,
          readAt: map.value as int,
        ),
      );
    }
    return data;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'LastReadAt(userId: $userId, readAt: $readAt)';

  @override
  bool operator ==(covariant IsmChatLastReadAt other) {
    if (identical(this, other)) return true;

    return other.userId == userId && other.readAt == readAt;
  }

  @override
  int get hashCode => userId.hashCode ^ readAt.hashCode;
}
