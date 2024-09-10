import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttUserModel {
  factory IsmChatMqttUserModel.fromJson(String source) =>
      IsmChatMqttUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory IsmChatMqttUserModel.fromMap(Map<String, dynamic> map) =>
      IsmChatMqttUserModel(
        userId: (map['userId']) as String,
        userName: map['userName'] as String,
        profileImageUrl: map['userProfileImageUrl'] != null
            ? map['userProfileImageUrl'] as String
            : null,
        userIdentifier: map['userIdentifier'] != null
            ? map['userIdentifier'] as String
            : null,
      );

  const IsmChatMqttUserModel({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    this.userIdentifier,
  });
  final String userId;
  final String userName;
  final String? profileImageUrl;
  final String? userIdentifier;

  IsmChatMqttUserModel copyWith({
    String? userId,
    String? userName,
    String? profileImageUrl,
    String? userIdentifier,
  }) =>
      IsmChatMqttUserModel(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        userIdentifier: userIdentifier ?? this.userIdentifier,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'userName': userName,
        'profileImageUrl': profileImageUrl,
        'userIdentifier': userIdentifier,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MqttUserModel(id: $userId, name: $userName, profileImageUrl: $profileImageUrl, identifier: $userIdentifier)';

  @override
  bool operator ==(covariant IsmChatMqttUserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.userName == userName &&
        other.profileImageUrl == profileImageUrl &&
        other.userIdentifier == userIdentifier;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      userName.hashCode ^
      profileImageUrl.hashCode ^
      userIdentifier.hashCode;
}
