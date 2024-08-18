import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class LastMessageDetails {
  factory LastMessageDetails.fromJson(String source) =>
      LastMessageDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  factory LastMessageDetails.fromMap(Map<String, dynamic> map) {
    var details = LastMessageDetails(
      metaData: map['metaData'] != null
          ? IsmChatMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
          : null,
      showInConversation: map['showInConversation'] as bool? ?? false,
      sentAt: map['sentAt'] as int? ?? 0,
      senderName: map['senderName'] as String? ??
          map['userName'] as String? ??
          map['initiatorName'] as String? ??
          '',
      senderId: map['senderId'] as String? ??
          map['userId'] as String? ??
          map['initiatorId'] as String? ??
          '',
      messageType: map['messageType'] as int? ?? 0,
      messageId: map['messageId'] as String? ?? map['userId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      body: IsmChatUtility.decodeString(map['body'] as String? ?? ''),
      deliverCount:
          map['deliveredTo'] != null ? (map['deliveredTo'] as List).length : 0,
      readCount: map['readBy'] != null ? (map['readBy'] as List).length : 0,
      customType: map['customType'] != null
          ? map['customType'].runtimeType == String
              ? IsmChatCustomMessageType.fromString(map['customType'] as String)
              : IsmChatCustomMessageType.fromValue(map['customType'] as int)
          : map['action'] != null
              ? IsmChatCustomMessageType.fromAction(map['action'] as String)
              : null,
      sentByMe: true,
      members: map['members'] != null
          ? (map['members'] as List).map((e) {
              if (e.runtimeType == Map<String, dynamic>) {
                return e['memberName'] as String? ?? '';
              } else if (e.runtimeType == String) {
                return e as String? ?? '';
              }
              return e['memberName'] as String? ?? '';
            }).toList()
          : <String>[],
      reactionType: map['reactionType'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      action: map['action'] as String? ?? '',
      initiatorId: map['initiatorId'] as String? ?? '',
      deliveredTo: map['deliveredTo'] == null
          ? []
          : List<MessageStatus>.from(
              (map['deliveredTo'] as List).map(
                (e) {
                  if (e.runtimeType == String) {
                    return MessageStatus.fromJson(e as String);
                  }
                  return MessageStatus.fromMap(e as Map<String, dynamic>);
                },
              ),
            ),
      readBy: map['readBy'] == null
          ? []
          : List<MessageStatus>.from(
              (map['readBy'] as List).map(
                (e) {
                  if (e.runtimeType == String) {
                    return MessageStatus.fromJson(e as String);
                  }
                  return MessageStatus.fromMap(e as Map<String, dynamic>);
                },
              ),
            ),
      memberName: map['memberName'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      audioOnly: map['audioOnly'] as bool? ?? false,
      callDurations: map['callDurations'] == null
          ? []
          : List<CallDuration>.from(
              (map['callDurations'] as List).map(
                (e) => CallDuration.fromMap(e as Map<String, dynamic>),
              ),
            ),
      meetingId: map['meetingId'] as String? ?? '',
      meetingType:
          map['meetingType'] != null ? map['meetingType'] as int? ?? 0 : null,
    );
    details = details.copyWith(
      body: details.metaData?.replyMessage?.parentMessageMessageType ==
              IsmChatCustomMessageType.contact
          ? IsmChatStrings.contact
          : details.body,
      sentByMe: details.senderId.isNotEmpty
          ? details.senderId ==
              IsmChatConfig.communicationConfig.userConfig.userId
          : details.initiatorId?.isNotEmpty == true
              ? details.initiatorId ==
                  IsmChatConfig.communicationConfig.userConfig.userId
              : true,
    );

    return details;
  }

  LastMessageDetails({
    required this.showInConversation,
    required this.sentAt,
    required this.senderName,
    this.senderId = '',
    required this.messageType,
    required this.messageId,
    required this.conversationId,
    required this.body,
    this.deliverCount = 0,
    this.readCount = 0,
    required this.sentByMe,
    this.customType,
    this.members,
    this.reactionType,
    this.userId,
    this.action,
    this.deliveredTo,
    this.readBy,
    this.initiatorId,
    this.memberName,
    this.memberId,
    this.metaData,
    this.audioOnly,
    this.callDurations,
    this.meetingId,
    this.meetingType,
  });

  final bool showInConversation;
  final int sentAt;
  final String senderName;
  final String senderId;
  final int messageType;
  final String messageId;
  final String conversationId;
  final String body;
  final int deliverCount;
  final int readCount;
  final bool sentByMe;
  final List<String>? members;
  final String? reactionType;
  final String? action;
  final String? userId;
  final IsmChatCustomMessageType? customType;
  final List<MessageStatus>? readBy;
  final List<MessageStatus>? deliveredTo;
  final String? initiatorId;
  final String? memberName;
  final String? memberId;
  final IsmChatMetaData? metaData;
  final List<CallDuration>? callDurations;
  final String? meetingId;
  final int? meetingType;
  final bool? audioOnly;

  String get adminOpponentName =>
      memberId == IsmChatConfig.communicationConfig.userConfig.userId
          ? 'You'
          : memberName ?? '';

  LastMessageDetails copyWith({
    bool? showInConversation,
    int? sentAt,
    String? senderName,
    String? senderId,
    int? messageType,
    String? messageId,
    String? conversationId,
    String? body,
    int? deliverCount,
    int? readCount,
    bool? sentByMe,
    IsmChatCustomMessageType? customType,
    List<String>? members,
    String? reactionType,
    String? action,
    String? userId,
    List<MessageStatus>? readBy,
    List<MessageStatus>? deliveredTo,
    String? initiatorId,
    String? memberName,
    String? memberId,
    IsmChatMetaData? metaData,
    List<CallDuration>? callDurations,
    String? meetingId,
    int? meetingType,
    bool? audioOnly,
  }) =>
      LastMessageDetails(
        showInConversation: showInConversation ?? this.showInConversation,
        sentAt: sentAt ?? this.sentAt,
        senderName: senderName ?? this.senderName,
        senderId: senderId ?? this.senderId,
        messageType: messageType ?? this.messageType,
        messageId: messageId ?? this.messageId,
        conversationId: conversationId ?? this.conversationId,
        body: body ?? this.body,
        customType: customType ?? this.customType,
        deliverCount: deliverCount ?? this.deliverCount,
        readCount: readCount ?? this.readCount,
        sentByMe: sentByMe ?? this.sentByMe,
        members: members ?? this.members,
        reactionType: reactionType ?? this.reactionType,
        action: action ?? this.action,
        readBy: readBy ?? this.readBy,
        deliveredTo: deliveredTo ?? this.deliveredTo,
        initiatorId: initiatorId ?? this.initiatorId,
        memberName: memberName ?? this.memberName,
        memberId: memberId ?? this.memberId,
        metaData: metaData ?? this.metaData,
        callDurations: callDurations ?? this.callDurations,
        meetingId: meetingId ?? this.meetingId,
        meetingType: meetingType ?? this.meetingType,
        audioOnly: audioOnly ?? this.audioOnly,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'showInConversation': showInConversation,
        'sentAt': sentAt,
        'senderName': senderName,
        'senderId': senderId,
        'messageType': messageType,
        'messageId': messageId,
        'conversationId': conversationId,
        'body': body,
        'customType': customType?.value,
        'deliverCount': deliverCount,
        'readCount': readCount,
        'sentByMe': sentByMe,
        'members': members,
        'reactionType': reactionType,
        'action': action,
        'readBy': readBy,
        'deliveredTo': deliveredTo,
        'initiatorId': initiatorId,
        'memberName': memberName,
        'memberId': memberId,
        'metaData': metaData?.toMap(),
        'callDurations': callDurations?.map((e) => e.toMap()).toList(),
        'meetingId': meetingId,
        'meetingType': meetingType,
        'audioOnly': audioOnly
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'LastMessageDetails(showInConversation: $showInConversation, sentAt: $sentAt, senderName: $senderName, senderId: $senderId, messageType: $messageType, messageId: $messageId, conversationId: $conversationId, body: $body, customType: $customType, deliverCount: $deliverCount, readCount: $readCount, sentByMe: $sentByMe, members: $members,  reactionType : $reactionType, action : $action, deliveredTo :$deliveredTo, readBy : $readBy, initiatorId : $initiatorId, memberName : $memberName, memberId : $memberId, metaData : $metaData, callDurations:$callDurations, meetingId:$meetingId, meetingType:$meetingType, audioOnly:$audioOnly)';

  @override
  bool operator ==(covariant LastMessageDetails other) {
    if (identical(this, other)) return true;

    return other.showInConversation == showInConversation &&
        other.sentAt == sentAt &&
        other.senderName == senderName &&
        other.senderId == senderId &&
        other.messageType == messageType &&
        other.messageId == messageId &&
        other.conversationId == conversationId &&
        other.body == body &&
        other.readCount == readCount &&
        other.deliverCount == deliverCount &&
        other.sentByMe == sentByMe &&
        other.members == members &&
        other.customType == customType &&
        other.reactionType == reactionType &&
        other.action == action &&
        other.readBy == readBy &&
        other.deliveredTo == deliveredTo &&
        other.initiatorId == initiatorId &&
        other.memberName == memberName &&
        other.memberId == messageId &&
        other.metaData == metaData &&
        other.callDurations == callDurations &&
        other.meetingId == meetingId &&
        other.meetingType == meetingType &&
        other.audioOnly == audioOnly;
  }

  @override
  int get hashCode =>
      showInConversation.hashCode ^
      sentAt.hashCode ^
      senderName.hashCode ^
      senderId.hashCode ^
      messageType.hashCode ^
      messageId.hashCode ^
      conversationId.hashCode ^
      body.hashCode ^
      deliverCount.hashCode ^
      readCount.hashCode ^
      sentByMe.hashCode ^
      members.hashCode ^
      customType.hashCode ^
      reactionType.hashCode ^
      action.hashCode ^
      readBy.hashCode ^
      deliveredTo.hashCode ^
      initiatorId.hashCode ^
      memberName.hashCode ^
      memberId.hashCode ^
      metaData.hashCode ^
      callDurations.hashCode ^
      meetingId.hashCode ^
      meetingType.hashCode ^
      audioOnly.hashCode;
}
