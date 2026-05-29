import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttUserModel {
  factory IsmChatMqttUserModel.fromJson(String source) =>
      IsmChatMqttUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Parses [metaData] from a nested `metaData` map or top-level `firstName` / `lastName`.
  static IsmChatMetaData? metaDataFromMap(Map<String, dynamic> map) {
    if (map['metaData'] is Map<String, dynamic>) {
      return IsmChatMetaData.fromMap(map['metaData'] as Map<String, dynamic>);
    }
    final firstName = map['firstName'] as String?;
    final lastName = map['lastName'] as String?;
    if ((firstName?.isNotEmpty ?? false) || (lastName?.isNotEmpty ?? false)) {
      return IsmChatMetaData(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
      );
    }
    return null;
  }

  factory IsmChatMqttUserModel.fromMap(Map<String, dynamic> map) =>
      IsmChatMqttUserModel(
        userId: map['userId'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        profileImageUrl: map['userProfileImageUrl'] as String? ??
            map['profileImageUrl'] as String?,
        userIdentifier: map['userIdentifier'] as String?,
        metaData: metaDataFromMap(map),
      );

  const IsmChatMqttUserModel({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    this.userIdentifier,
    this.metaData,
  });

  final String userId;
  final String userName;
  final String? profileImageUrl;
  final String? userIdentifier;
  final IsmChatMetaData? metaData;

  /// Prefer "First Last" from [metaData]; fallback to [userName].
  String get displayName {
    final fullName =
        '${metaData?.firstName ?? ''} ${metaData?.lastName ?? ''}'.trim();
    return fullName.isNotEmpty ? fullName : userName;
  }

  IsmChatMqttUserModel copyWith({
    String? userId,
    String? userName,
    String? profileImageUrl,
    String? userIdentifier,
    IsmChatMetaData? metaData,
  }) =>
      IsmChatMqttUserModel(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        metaData: metaData ?? this.metaData,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'userName': userName,
        'profileImageUrl': profileImageUrl,
        'userIdentifier': userIdentifier,
        'metaData': metaData?.toMap(),
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MqttUserModel(id: $userId, name: $userName, profileImageUrl: $profileImageUrl, identifier: $userIdentifier, metaData: $metaData)';

  @override
  bool operator ==(covariant IsmChatMqttUserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.userName == userName &&
        other.profileImageUrl == profileImageUrl &&
        other.userIdentifier == userIdentifier &&
        other.metaData == metaData;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      userName.hashCode ^
      profileImageUrl.hashCode ^
      userIdentifier.hashCode ^
      metaData.hashCode;
}
