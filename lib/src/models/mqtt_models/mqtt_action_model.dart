// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttActionModel {
  factory IsmChatMqttActionModel.fromJson(String source) =>
      IsmChatMqttActionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  factory IsmChatMqttActionModel.fromMap(Map<String, dynamic> map) =>
      IsmChatMqttActionModel(
        conversationId: map['conversationId'] as String? ?? '',
        messageId: map['messageId'] as String? ?? '',
        messageIds: map['messageIds'] != null
            ? List<String>.from((map['messageIds'] as List<dynamic>)
                .map<dynamic>((dynamic x) => x))
            : [],
        userDetails: map['userId'] != null
            ? IsmChatMqttUserModel(
                userId: map['userId'] as String? ?? '',
                userName: map['userName'] as String? ?? '',
                userIdentifier: map['userIdentifier'] as String? ?? '',
                profileImageUrl: map['userProfileImageUrl'] as String? ?? '',
              )
            : null,
        opponentDetails: map['opponentId'] != null
            ? IsmChatMqttUserModel(
                userId: map['opponentId'] as String? ?? '',
                userName: map['opponentName'] as String? ?? '',
                userIdentifier: map['opponentIdentifier'] as String? ?? '',
                profileImageUrl:
                    map['opponentProfileImageUrl'] as String? ?? '',
              )
            : null,
        initiatorDetails: map['initiatorId'] != null
            ? IsmChatMqttUserModel(
                userId: map['initiatorId'] as String? ?? '',
                userName: map['initiatorName'] as String? ?? '',
                userIdentifier: map['initiatorIdentifier'] as String? ?? '',
                profileImageUrl:
                    map['initiatorProfileImageUrl'] as String? ?? '',
              )
            : null,
        conversationDetails: map['conversationDetails'] != null
            ? IsmChatConversationModel.fromMap(
                map['conversationDetails'] as Map<String, dynamic>)
            : null,
        sentAt: map['sentAt'] as int? ?? 0,
        lastMessageSentAt: map['lastMessageSentAt'] as int? ?? 0,
        initiatorId: map['createdBy'] != null
            ? map['createdBy'] as String? ?? ''
            : map['initiatorId'] as String? ?? '',
        initiatorName: map['initiatorName'] as String? ?? '',
        memberId: map['memberId'] as String? ?? '',
        memberName: map['memberName'] as String? ?? '',
        action: IsmChatActionEvents.fromName(map['action'] as String? ?? ''),
        reactionType: map['reactionType'] as String? ?? '',
        reactionsCount: map['reactionsCount'] as int? ?? 0,
        senderId: map['senderId'] as String? ?? '',
        body: map['body'] != null && (map['body'] as String).isNotEmpty
            ? IsmChatUtility.decodeString(map['body'] as String)
            : '',
        messageType:
            IsmChatMessageType.fromValue(map['messageType'] as int? ?? 0),
        customType: map['customType'] != null
            ? IsmChatCustomMessageType.fromMap(map['customType'])
            : map['action'] != null
                ? IsmChatCustomMessageType.fromAction(map['action'] as String)
                : null,
        attachments: map['attachments'] != null
            ? (map['attachments'] as List<dynamic>)
                .map((e) => AttachmentModel.fromMap(e as Map<String, dynamic>))
                .toList()
            : null,
        metaData: map['metaData'] != null
            ? IsmChatMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        members: map['members'] != null
            ? List<UserDetails>.from(
                (map['members'] as List).map(
                  (dynamic x) => UserDetails.fromMap(x as Map<String, dynamic>),
                ),
              )
            : [],
      );

  final String? conversationId;
  final IsmChatMqttUserModel? userDetails;
  final IsmChatMqttUserModel? opponentDetails;
  final IsmChatMqttUserModel? initiatorDetails;
  final IsmChatConversationModel? conversationDetails;
  final int sentAt;
  final int? lastMessageSentAt;
  final String? messageId;
  final List<String>? messageIds;
  final IsmChatActionEvents action;
  final String? memberId;
  final String? memberName;
  final String? initiatorName;
  final String? initiatorId;
  final String? reactionType;
  final int? reactionsCount;
  final List<UserDetails>? members;
  final String? senderId;
  final String? senderName;
  final IsmChatMessageType? messageType;
  final IsmChatCustomMessageType? customType;
  final String? body;
  final List<AttachmentModel>? attachments;
  final IsmChatMetaData? metaData;

  IsmChatMqttActionModel({
    this.conversationId,
    this.userDetails,
    this.opponentDetails,
    this.initiatorDetails,
    this.conversationDetails,
    required this.sentAt,
    this.lastMessageSentAt,
    this.messageId,
    this.messageIds,
    required this.action,
    this.memberId,
    this.memberName,
    this.initiatorName,
    this.initiatorId,
    this.reactionType,
    this.reactionsCount,
    this.members,
    this.senderId,
    this.senderName,
    this.messageType,
    this.customType,
    this.body,
    this.attachments,
    this.metaData,
  });

  IsmChatMqttActionModel copyWith({
    String? conversationId,
    IsmChatMqttUserModel? userDetails,
    IsmChatMqttUserModel? opponentDetails,
    IsmChatMqttUserModel? initiatorDetails,
    IsmChatConversationModel? conversationDetails,
    int? sentAt,
    int? lastMessageSentAt,
    String? messageId,
    List<String>? messageIds,
    IsmChatActionEvents? action,
    String? memberId,
    String? memberName,
    String? initiatorName,
    String? initiatorId,
    String? reactionType,
    int? reactionsCount,
    List<UserDetails>? members,
    String? senderId,
    String? senderName,
    IsmChatMessageType? messageType,
    IsmChatCustomMessageType? customType,
    String? body,
    List<AttachmentModel>? attachments,
    IsmChatMetaData? metaData,
  }) =>
      IsmChatMqttActionModel(
        conversationId: conversationId ?? this.conversationId,
        userDetails: userDetails ?? this.userDetails,
        opponentDetails: opponentDetails ?? this.opponentDetails,
        initiatorDetails: initiatorDetails ?? this.initiatorDetails,
        conversationDetails: conversationDetails ?? this.conversationDetails,
        sentAt: sentAt ?? this.sentAt,
        lastMessageSentAt: lastMessageSentAt ?? this.lastMessageSentAt,
        messageId: messageId ?? this.messageId,
        messageIds: messageIds ?? this.messageIds,
        action: action ?? this.action,
        memberId: memberId ?? this.memberId,
        memberName: memberName ?? this.memberName,
        initiatorName: initiatorName ?? this.initiatorName,
        initiatorId: initiatorId ?? this.initiatorId,
        reactionType: reactionType ?? this.reactionType,
        reactionsCount: reactionsCount ?? this.reactionsCount,
        members: members ?? this.members,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        messageType: messageType ?? this.messageType,
        customType: customType ?? this.customType,
        body: body ?? this.body,
        attachments: attachments ?? this.attachments,
        metaData: metaData ?? this.metaData,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'conversationId': conversationId,
        'userDetails': userDetails?.toMap(),
        'opponentDetails': opponentDetails?.toMap(),
        'initiatorDetails': initiatorDetails?.toMap(),
        'conversationDetails': conversationDetails?.toMap(),
        'sentAt': sentAt,
        'lastMessageSentAt': lastMessageSentAt,
        'messageId': messageId,
        'messageIds': messageIds,
        'action': action,
        'memberId': memberId,
        'memberName': memberName,
        'initiatorName': initiatorName,
        'initiatorId': initiatorId,
        'reactionType': reactionType,
        'reactionsCount': reactionsCount,
        'members': members?.map((x) => x.toMap()).toList(),
        'senderId': senderId,
        'senderName': senderName,
        'messageType': messageType,
        'customType': customType,
        'body': body,
        'attachments': attachments?.map((x) => x.toMap()).toList(),
        'metaData': metaData?.toMap(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatMqttActionModel(conversationId: $conversationId, userDetails: $userDetails, opponentDetails: $opponentDetails, initiatorDetails: $initiatorDetails, conversationDetails: $conversationDetails, sentAt: $sentAt, lastMessageSentAt: $lastMessageSentAt, messageId: $messageId, messageIds: $messageIds, action: $action, memberId: $memberId, memberName: $memberName, initiatorName: $initiatorName, initiatorId: $initiatorId, reactionType: $reactionType, reactionsCount: $reactionsCount, members: $members, senderId: $senderId, senderName: $senderName, messageType: $messageType, customType: $customType, body: $body, attachments: $attachments, metaData: $metaData)';

  @override
  bool operator ==(covariant IsmChatMqttActionModel other) {
    if (identical(this, other)) return true;

    return other.conversationId == conversationId &&
        other.userDetails == userDetails &&
        other.opponentDetails == opponentDetails &&
        other.initiatorDetails == initiatorDetails &&
        other.conversationDetails == conversationDetails &&
        other.sentAt == sentAt &&
        other.lastMessageSentAt == lastMessageSentAt &&
        other.messageId == messageId &&
        listEquals(other.messageIds, messageIds) &&
        other.action == action &&
        other.memberId == memberId &&
        other.memberName == memberName &&
        other.initiatorName == initiatorName &&
        other.initiatorId == initiatorId &&
        other.reactionType == reactionType &&
        other.reactionsCount == reactionsCount &&
        listEquals(other.members, members) &&
        other.senderId == senderId &&
        other.senderName == senderName &&
        other.messageType == messageType &&
        other.customType == customType &&
        other.body == body &&
        listEquals(other.attachments, attachments) &&
        other.metaData == metaData;
  }

  @override
  int get hashCode =>
      conversationId.hashCode ^
      userDetails.hashCode ^
      opponentDetails.hashCode ^
      initiatorDetails.hashCode ^
      conversationDetails.hashCode ^
      sentAt.hashCode ^
      lastMessageSentAt.hashCode ^
      messageId.hashCode ^
      messageIds.hashCode ^
      action.hashCode ^
      memberId.hashCode ^
      memberName.hashCode ^
      initiatorName.hashCode ^
      initiatorId.hashCode ^
      reactionType.hashCode ^
      reactionsCount.hashCode ^
      members.hashCode ^
      senderId.hashCode ^
      senderName.hashCode ^
      messageType.hashCode ^
      customType.hashCode ^
      body.hashCode ^
      attachments.hashCode ^
      metaData.hashCode;
}

class Members {
  Members({
    this.memberProfileImageUrl,
    this.memberName,
    this.memberIdentifier,
    this.memberId,
  });

  factory Members.fromMap(Map<String, dynamic> map) => Members(
        memberProfileImageUrl: map['memberProfileImageUrl'] != null
            ? map['memberProfileImageUrl'] as String
            : null,
        memberName:
            map['memberName'] != null ? map['memberName'] as String : null,
        memberIdentifier: map['memberIdentifier'] != null
            ? map['memberIdentifier'] as String
            : null,
        memberId: map['memberId'] != null ? map['memberId'] as String : null,
      );

  factory Members.fromJson(String source) =>
      Members.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? memberProfileImageUrl;
  final String? memberName;
  final String? memberIdentifier;
  final String? memberId;

  Members copyWith({
    String? memberProfileImageUrl,
    String? memberName,
    String? memberIdentifier,
    String? memberId,
  }) =>
      Members(
        memberProfileImageUrl:
            memberProfileImageUrl ?? this.memberProfileImageUrl,
        memberName: memberName ?? this.memberName,
        memberIdentifier: memberIdentifier ?? this.memberIdentifier,
        memberId: memberId ?? this.memberId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'memberProfileImageUrl': memberProfileImageUrl,
        'memberName': memberName,
        'memberIdentifier': memberIdentifier,
        'memberId': memberId,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'Members(memberProfileImageUrl: $memberProfileImageUrl, memberName: $memberName, memberIdentifier: $memberIdentifier, memberId: $memberId)';

  @override
  bool operator ==(covariant Members other) {
    if (identical(this, other)) return true;

    return other.memberProfileImageUrl == memberProfileImageUrl &&
        other.memberName == memberName &&
        other.memberIdentifier == memberIdentifier &&
        other.memberId == memberId;
  }

  @override
  int get hashCode =>
      memberProfileImageUrl.hashCode ^
      memberName.hashCode ^
      memberIdentifier.hashCode ^
      memberId.hashCode;
}
