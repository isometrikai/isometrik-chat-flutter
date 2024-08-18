import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMessageModel {
  IsmChatMessageModel({
    required this.body,
    required this.customType,
    required this.sentAt,
    required this.sentByMe,
    this.action,
    this.updatedAt,
    this.unreadMessagesCount,
    this.userId,
    this.userName,
    this.searchableTags,
    this.privateOneToOne,
    this.showInConversation,
    this.readByAll,
    this.senderInfo,
    this.metaData,
    this.messagingDisabled,
    this.membersCount,
    this.lastReadAt,
    this.attachments,
    this.lastMessageSentAt,
    this.isGroup,
    this.deliveredToAll,
    this.createdByUserName,
    this.createdByUserImageUrl,
    this.createdBy,
    this.conversationType,
    this.conversationTitle,
    this.conversationImageUrl,
    this.conversationId,
    this.parentMessageId,
    this.messageId,
    this.deviceId,
    this.adminCount,
    this.messageType,
    this.mentionedUsers,
    this.initiatorId,
    this.initiatorName,
    this.members,
    this.memberId,
    this.memberName,
    this.reactions,
    this.notificationBody,
    this.notificationTitle,
    this.readBy,
    this.deliveredTo,
    this.isUploading,
    this.conversationDetails,
    this.events,
    this.callDurations,
    this.meetingId,
    this.meetingType,
    this.audioOnly,
  });
  factory IsmChatMessageModel.fromJson(String source) =>
      IsmChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory IsmChatMessageModel.fromMap(Map<String, dynamic> map) {
    var model = IsmChatMessageModel(
      body: map['body'] != null && (map['body'] as String).isNotEmpty
          ? IsmChatUtility.decodeString(map['body'] as String)
          : '',
      action: map['action'] as String? ?? '',
      updatedAt: map['updatedAt'] as int? ?? 0,
      sentAt: map['sentAt'] as int? ?? 0,
      unreadMessagesCount: map['unreadMessagesCount'] as int? ?? 0,
      userId: map['userId'] as String? ?? map['initiatorId'] as String? ?? '',
      userName:
          map['userName'] as String? ?? map['initiatorName'] as String? ?? '',
      searchableTags: map['searchableTags'] != null
          ? List<String>.from(map['searchableTags'] as List<dynamic>)
          : [],
      privateOneToOne: map['privateOneToOne'] as bool? ?? false,
      showInConversation: map['showInConversation'] as bool? ?? true,
      readByAll: map['readByAll'] as bool? ?? false,
      senderInfo: map['senderInfo'] != null &&
              (map['senderInfo'] as Map<String, dynamic>).keys.isNotEmpty
          ? UserDetails.fromMap(map['senderInfo'] as Map<String, dynamic>)
          : map['senderId'] != null
              ? UserDetails(
                  userProfileImageUrl: map['senderProfileImageUrl'] as String,
                  userName: map['senderName'] as String,
                  userIdentifier: map['senderIdentifier'] as String,
                  userId: map['senderId'] as String,
                  online: false,
                  lastSeen: 0,
                  metaData: IsmChatMetaData(
                    firstName:
                        map['senderMetaData']['firstName'] as String? ?? '',
                    lastName:
                        map['senderMetaData']['lastName'] as String? ?? '',
                    profilePic:
                        map['senderMetaData']['profilePic'] as String? ?? '',
                  ),
                )
              : null,
      metaData: map['metaData'] != null
          ? IsmChatMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
          : null,
      messagingDisabled: map['messagingDisabled'] as bool? ?? false,
      membersCount: map['membersCount'] as int? ?? 0,
      lastReadAt: map['lastReadAt'].runtimeType == List
          ? List<IsmChatLastReadAt>.from(map['lastReadAt'] as List<dynamic>)
          : map['lastReadAt'].runtimeType == Map
              ? IsmChatLastReadAt.fromNetworkMap(
                  map['lastReadAt'] as Map<String, dynamic>? ??
                      <String, dynamic>{})
              : [],
      attachments: map['attachments'] != null
          ? (map['attachments'] as List<dynamic>)
              .map((e) => AttachmentModel.fromMap(e as Map<String, dynamic>))
              .toList()
          : null,
      lastMessageSentAt: map['lastMessageSentAt'] as int? ?? 0,
      isGroup: map['isGroup'] as bool? ?? false,
      deliveredToAll: map['deliveredToAll'] as bool? ?? false,
      customType: map['customType'] != null
          ? IsmChatCustomMessageType.fromMap(map['customType'] as String)
          : map['action'] != null
              ? IsmChatCustomMessageType.fromAction(map['action'] as String)
              : null,
      createdByUserName: map['createdByUserName'] as String? ?? '',
      createdByUserImageUrl: map['createdByUserImageUrl'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      conversationType: map['conversationType'] as int? ?? 0,
      conversationTitle: map['conversationTitle'] as String?,
      conversationImageUrl: map['conversationImageUrl'] as String?,
      conversationId: map['conversationId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      parentMessageId: map['parentMessageId'] as String? ?? '',
      adminCount: map['adminCount'] as int? ?? 0,
      messageType:
          IsmChatMessageType.fromValue(map['messageType'] as int? ?? 0),
      memberId: map['memberId'] as String?,
      memberName: map['memberName'] as String?,
      sentByMe: true,
      mentionedUsers: map['mentionedUsers'] == null
          ? []
          : (map['mentionedUsers'] as List)
              .map(
                (e) => UserDetails.fromMap(e as Map<String, dynamic>),
              )
              .toList(),
      initiatorId: map['initiatorId'] as String? ?? '',
      initiatorName: map['initiatorName'] as String? ?? '',
      callDurations: map['callDurations'] == null
          ? []
          : List<CallDuration>.from(
              (map['callDurations'] as List).map(
                (e) => CallDuration.fromMap(e as Map<String, dynamic>),
              ),
            ),
      members: map['members'] == null
          ? []
          : List<UserDetails>.from(
              (map['members'] as List).map(
                (e) => UserDetails.fromMap(e as Map<String, dynamic>),
              ),
            ),
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
      notificationTitle: map['notificationTitle'] as String? ?? '',
      notificationBody: map['notificationBody'] as String? ?? '',
      reactions: (map['reactions'] is List)
          ? (map['reactions'] as List)
              .map((e) => MessageReactionModel.fromJson(e as String))
              .toList()
          : (map['reactions'] is Map)
              ? (map['reactions'] as Map<String, dynamic>?)
                  ?.keys
                  .map(
                    (e) => MessageReactionModel(
                      emojiKey: e,
                      userIds:
                          (map['reactions'][e] as List<dynamic>).cast<String>(),
                    ),
                  )
                  .toList()
              : [],
      isUploading: map['isUploading'] as bool? ?? false,
      conversationDetails:
          map['conversationDetails'] as Map<String, dynamic>? ?? {},
      events: map['events'] != null
          ? map['events'].runtimeType == String
              ? IsmChatEvents.fromJson(map['events'])
              : IsmChatEvents.fromMap(map['events'])
          : null,
      meetingId: map['meetingId'] as String? ?? '',
      audioOnly: map['audioOnly'] as bool? ?? false,
      meetingType:
          map['meetingType'] == null ? null : map['meetingType'] as int? ?? 0,
    );

    if (IsmChatConfig.configInitilized) {
      try {
        model = model.copyWith(
          customType: model.customType != null &&
                  model.customType != IsmChatCustomMessageType.text
              ? model.customType
              : IsmChatCustomMessageType.withBody(model.body),
          sentByMe: model.senderInfo != null
              ? model.senderInfo?.userId ==
                  IsmChatConfig.communicationConfig.userConfig.userId
              : model.memberId != null
                  ? IsmChatConfig.communicationConfig.userConfig.userId ==
                      model.memberId
                  : model.initiatorId != null
                      ? model.initiatorId ==
                          IsmChatConfig.communicationConfig.userConfig.userId
                      : true,
          isGroup: model.conversationDetails?.isNotEmpty == true
              ? model.conversationDetails!['isGroup']
              : false,
          senderInfo: model.metaData?.senderInfo,
        );
      } catch (eroor, st) {
        IsmChatLog.error(eroor, st);
      }
    } else {
      IsmChatLog.error(
          'error from chat message model => IsmChatConfig.configInitilized');
    }

    return model;
  }

  factory IsmChatMessageModel.fromDate(int sentAt) => IsmChatMessageModel(
      body: sentAt.toMessageDateString(),
      action: '',
      updatedAt: 0,
      sentAt: sentAt,
      unreadMessagesCount: 0,
      searchableTags: [],
      privateOneToOne: false,
      showInConversation: true,
      readByAll: false,
      senderInfo: null,
      metaData: null,
      messagingDisabled: false,
      membersCount: 0,
      lastReadAt: [],
      attachments: null,
      lastMessageSentAt: 0,
      isGroup: false,
      deliveredToAll: false,
      customType: IsmChatCustomMessageType.date,
      createdByUserName: '',
      createdByUserImageUrl: '',
      createdBy: '',
      conversationType: 0,
      conversationTitle: null,
      conversationImageUrl: null,
      conversationId: '',
      messageId: '',
      deviceId: '',
      parentMessageId: '',
      adminCount: 0,
      messageType: IsmChatMessageType.normal,
      sentByMe: true,
      mentionedUsers: [],
      initiatorId: '',
      initiatorName: '',
      members: [],
      reactions: null,
      notificationBody: '',
      notificationTitle: '',
      deliveredTo: [],
      readBy: [],
      isUploading: false,
      conversationDetails: {},
      events: null,
      callDurations: [],
      meetingId: '',
      meetingType: null,
      audioOnly: null);

  factory IsmChatMessageModel.fromMonth(int sentAt) => IsmChatMessageModel(
        body: sentAt.toMessageMonthString(),
        action: '',
        updatedAt: 0,
        sentAt: sentAt,
        unreadMessagesCount: 0,
        searchableTags: [],
        privateOneToOne: false,
        showInConversation: true,
        readByAll: false,
        senderInfo: null,
        metaData: null,
        messagingDisabled: false,
        membersCount: 0,
        lastReadAt: [],
        attachments: null,
        lastMessageSentAt: 0,
        isGroup: false,
        deliveredToAll: false,
        customType: IsmChatCustomMessageType.date,
        createdByUserName: '',
        createdByUserImageUrl: '',
        createdBy: '',
        conversationType: 0,
        conversationTitle: null,
        conversationImageUrl: null,
        conversationId: '',
        messageId: '',
        deviceId: '',
        parentMessageId: '',
        adminCount: 0,
        messageType: IsmChatMessageType.normal,
        sentByMe: true,
        mentionedUsers: [],
        initiatorId: '',
        initiatorName: '',
        members: [],
        reactions: null,
        notificationBody: '',
        notificationTitle: '',
        readBy: [],
        deliveredTo: [],
        isUploading: false,
        conversationDetails: {},
        events: null,
        callDurations: [],
        meetingId: '',
        meetingType: null,
        audioOnly: null,
      );

  List<IsmChatContactMetaDatModel> get contacts {
    if (customType == IsmChatCustomMessageType.contact) {
      if (body == IsmChatStrings.contact) {
        return metaData?.contacts ?? [];
      }
      final number = body == IsmChatCustomMessageType.contact.value
          ? body
          : jsonDecode(body);
      if (number == List<dynamic>) {
        number.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
        return number
            .map(
              (e) => IsmChatContactMetaDatModel(
                contactId: e.id,
                contactIdentifier: e.phones.first.normalizedNumber,
                contactName: e.displayName,
                contactImageUrl: e.photo != null ? e.photo.toString() : '',
              ),
            )
            .toList();
      } else {
        return metaData?.contacts ?? [];
      }
    }

    return [];
  }

  Map<String, dynamic> toMap() => {
        'body': body,
        'action': action,
        'updatedAt': updatedAt,
        'sentAt': sentAt,
        'unreadMessagesCount': unreadMessagesCount,
        'userName': userName,
        'userId': userId,
        'searchableTags': searchableTags,
        'privateOneToOne': privateOneToOne,
        'showInConversation': showInConversation,
        'readByAll': readByAll,
        'senderInfo': senderInfo?.toMap(),
        'metaData': metaData?.toMap(),
        'messagingDisabled': messagingDisabled,
        'membersCount': membersCount,
        'lastReadAt': lastReadAt?.map((x) => x.toMap()).toList(),
        'attachments': attachments?.map((x) => x.toMap()).toList(),
        'lastMessageSentAt': lastMessageSentAt,
        'isGroup': isGroup,
        'deliveredToAll': deliveredToAll,
        'customType': customType?.value,
        'createdByUserName': createdByUserName,
        'createdByUserImageUrl': createdByUserImageUrl,
        'createdBy': createdBy,
        'conversationType': conversationType,
        'conversationTitle': conversationTitle,
        'conversationImageUrl': conversationImageUrl,
        'conversationId': conversationId,
        'parentMessageId': parentMessageId,
        'messageId': messageId,
        'deviceId': deviceId,
        'adminCount': adminCount,
        'messageType': messageType?.value,
        'sentByMe': sentByMe,
        'mentionedUsers': mentionedUsers?.map((e) => e.toMap()).toList(),
        'initiatorId': initiatorId,
        'initiatorName': initiatorName,
        'members': members?.map((e) => e.toMap()).toList(),
        'memberId': memberId,
        'memberName': memberName,
        'reactions': reactions,
        'notificationBody': notificationBody,
        'notificationTitle': notificationTitle,
        'readBy': readBy?.map((e) => e.toMap()).toList(),
        'deliveredTo': deliveredTo?.map((e) => e.toMap()).toList(),
        'isUploading': isUploading,
        'conversationDetails': conversationDetails,
        'events': events,
        'callDurations': callDurations?.map((e) => e.toMap()).toList(),
        'meetingId': meetingId,
        'meetingType': meetingType,
        'audioOnly': audioOnly,
      };

  String body;
  String? action;
  int sentAt;
  int? updatedAt;
  int? unreadMessagesCount;
  String? userId;
  String? userName;
  List<String>? searchableTags;
  bool? privateOneToOne;
  bool? showInConversation;
  bool? readByAll;
  UserDetails? senderInfo;
  IsmChatMetaData? metaData;
  bool? messagingDisabled;
  int? membersCount;
  List<IsmChatLastReadAt>? lastReadAt;
  List<AttachmentModel>? attachments;
  int? lastMessageSentAt;
  bool? isGroup;
  bool? deliveredToAll;
  String? createdByUserName;
  String? createdByUserImageUrl;
  String? createdBy;
  int? conversationType;
  String? conversationTitle;
  String? conversationImageUrl;
  String? conversationId;
  String? parentMessageId;
  String? initiatorId;
  String? messageId;
  String? deviceId;
  String? initiatorName;
  List<UserDetails>? members;
  int? adminCount;
  IsmChatMessageType? messageType;
  List<UserDetails>? mentionedUsers;
  IsmChatCustomMessageType? customType;
  bool sentByMe;
  String? memberId;
  String? memberName;
  List<MessageReactionModel>? reactions;
  String? notificationBody;
  String? notificationTitle;
  List<MessageStatus>? readBy;
  List<MessageStatus>? deliveredTo;
  bool? isUploading;
  Map<String, dynamic>? conversationDetails;
  IsmChatEvents? events;
  List<CallDuration>? callDurations;
  String? meetingId;
  int? meetingType;
  bool? audioOnly;

  String get chatName => conversationTitle ?? senderInfo?.userName ?? '';

  String get initiator =>
      userId == IsmChatConfig.communicationConfig.userConfig.userId
          ? 'You'
          : userName!;

  IsmChatMessageModel copyWith({
    String? body,
    String? action,
    int? sentAt,
    int? updatedAt,
    int? unreadMessagesCount,
    String? userId,
    String? userName,
    List<String>? searchableTags,
    bool? privateOneToOne,
    bool? showInConversation,
    bool? readByAll,
    UserDetails? senderInfo,
    IsmChatMetaData? metaData,
    bool? messagingDisabled,
    int? membersCount,
    List<IsmChatLastReadAt>? lastReadAt,
    List<AttachmentModel>? attachments,
    LastMessageDetails? lastMessageDetails,
    int? lastMessageSentAt,
    bool? isGroup,
    bool? deliveredToAll,
    IsmChatCustomMessageType? customType,
    String? createdByUserName,
    String? createdByUserImageUrl,
    String? createdBy,
    int? conversationType,
    String? conversationTitle,
    String? conversationImageUrl,
    String? conversationId,
    String? parentMessageId,
    String? initiatorId,
    String? messageId,
    String? initiatorName,
    String? deviceId,
    ConversationConfigModel? config,
    int? adminCount,
    IsmChatMessageType? messageType,
    bool? sentByMe,
    List<UserDetails>? mentionedUsers,
    List<UserDetails>? members,
    String? memberId,
    String? memberName,
    List<MessageReactionModel>? reactions,
    String? notificationBody,
    String? notificationTitle,
    List<MessageStatus>? readBy,
    List<MessageStatus>? deliveredTo,
    bool? isUploading,
    Map<String, dynamic>? conversationDetails,
    IsmChatEvents? events,
    List<CallDuration>? callDurations,
    String? meetingId,
    int? meetingType,
    bool? audioOnly,
  }) =>
      IsmChatMessageModel(
        body: body ?? this.body,
        action: action ?? this.action,
        updatedAt: updatedAt ?? this.updatedAt,
        sentAt: sentAt ?? this.sentAt,
        unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
        userName: userName ?? this.userName,
        userId: userId ?? this.userId,
        searchableTags: searchableTags ?? this.searchableTags,
        privateOneToOne: privateOneToOne ?? this.privateOneToOne,
        showInConversation: showInConversation ?? this.showInConversation,
        readByAll: readByAll ?? this.readByAll,
        senderInfo: senderInfo ?? this.senderInfo,
        metaData: metaData ?? this.metaData,
        messagingDisabled: messagingDisabled ?? this.messagingDisabled,
        membersCount: membersCount ?? this.membersCount,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        attachments: attachments ?? this.attachments,
        lastMessageSentAt: lastMessageSentAt ?? this.lastMessageSentAt,
        isGroup: isGroup ?? this.isGroup,
        deliveredToAll: deliveredToAll ?? this.deliveredToAll,
        customType: customType ?? this.customType,
        createdByUserName: createdByUserName ?? this.createdByUserName,
        createdByUserImageUrl:
            createdByUserImageUrl ?? this.createdByUserImageUrl,
        createdBy: createdBy ?? this.createdBy,
        conversationType: conversationType ?? this.conversationType,
        conversationTitle: conversationTitle ?? this.conversationTitle,
        conversationImageUrl: conversationImageUrl ?? this.conversationImageUrl,
        conversationId: conversationId ?? this.conversationId,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        initiatorId: initiatorId ?? this.initiatorId,
        messageId: messageId ?? this.messageId,
        deviceId: deviceId ?? this.deviceId,
        adminCount: adminCount ?? this.adminCount,
        messageType: messageType ?? this.messageType,
        sentByMe: sentByMe ?? this.sentByMe,
        mentionedUsers: mentionedUsers ?? this.mentionedUsers,
        initiatorName: initiatorId ?? this.initiatorName,
        members: members ?? this.members,
        memberId: memberId ?? this.memberId,
        memberName: memberName ?? this.memberName,
        reactions: reactions ?? this.reactions,
        notificationBody: notificationBody ?? this.notificationBody,
        notificationTitle: notificationTitle ?? this.notificationTitle,
        readBy: readBy ?? this.readBy,
        deliveredTo: deliveredTo ?? this.deliveredTo,
        isUploading: isUploading ?? this.isUploading,
        conversationDetails: conversationDetails ?? this.conversationDetails,
        events: events ?? this.events,
        callDurations: callDurations ?? this.callDurations,
        meetingId: meetingId ?? this.meetingId,
        meetingType: meetingType ?? this.meetingType,
        audioOnly: audioOnly ?? this.audioOnly,
      );

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatMessageModel(body: $body, action: $action, updatedAt: $updatedAt, sentAt: $sentAt, unreadMessagesCount: $unreadMessagesCount, userName: $userName, userId: $userId, searchableTags: $searchableTags, privateOneToOne: $privateOneToOne, showInConversation: $showInConversation, readByAll: $readByAll, senderInfo: $senderInfo, metaData: $metaData, messagingDisabled: $messagingDisabled, membersCount: $membersCount, lastReadAt: $lastReadAt, attachments: $attachments, lastMessageSentAt: $lastMessageSentAt, isGroup: $isGroup, deliveredToAll: $deliveredToAll, customType: $customType, createdByUserName: $createdByUserName, createdByUserImageUrl: $createdByUserImageUrl, createdBy: $createdBy, conversationType: $conversationType, conversationTitle: $conversationTitle, conversationImageUrl: $conversationImageUrl, conversationId: $conversationId, parentMessageId: $parentMessageId, initiatorId : $initiatorId  messageId: $messageId, deviceId: $deviceId, adminCount: $adminCount, messageType: $messageType, sentByMe: $sentByMe, mentionedUsers: $mentionedUsers, initiatorName : $initiatorName, members: $members, memberId: $memberId, memberName: $memberName, reactions : $reactions, readBy : $readBy, deliveredTo : $deliveredTo, isUploading : $isUploading, conversationDetails : $conversationDetails, events : $events, callDurations:$callDurations, meetingId :$meetingId, meetingType :$meetingType ,audioOnly:$audioOnly)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IsmChatMessageModel &&
        other.body == body &&
        other.action == action &&
        other.updatedAt == updatedAt &&
        other.sentAt == sentAt &&
        other.unreadMessagesCount == unreadMessagesCount &&
        other.userId == userId &&
        other.userName == userName &&
        listEquals(other.searchableTags, searchableTags) &&
        other.privateOneToOne == privateOneToOne &&
        other.showInConversation == showInConversation &&
        other.readByAll == readByAll &&
        other.senderInfo == senderInfo &&
        other.metaData == metaData &&
        other.messagingDisabled == messagingDisabled &&
        other.membersCount == membersCount &&
        listEquals(other.lastReadAt, lastReadAt) &&
        listEquals(other.attachments, attachments) &&
        listEquals(other.members, members) &&
        other.lastMessageSentAt == lastMessageSentAt &&
        other.isGroup == isGroup &&
        other.deliveredToAll == deliveredToAll &&
        other.customType == customType &&
        other.createdByUserName == createdByUserName &&
        other.createdByUserImageUrl == createdByUserImageUrl &&
        other.createdBy == createdBy &&
        other.conversationType == conversationType &&
        other.conversationTitle == conversationTitle &&
        other.conversationImageUrl == conversationImageUrl &&
        other.conversationId == conversationId &&
        other.parentMessageId == parentMessageId &&
        other.initiatorId == initiatorId &&
        other.messageId == messageId &&
        other.deviceId == deviceId &&
        other.messageType == messageType &&
        listEquals(other.mentionedUsers, mentionedUsers) &&
        other.sentByMe == sentByMe &&
        other.initiatorName == initiatorName &&
        other.memberId == memberId &&
        other.memberName == memberName &&
        other.conversationDetails == conversationDetails &&
        other.adminCount == adminCount &&
        other.reactions == reactions &&
        other.isUploading == isUploading &&
        listEquals(other.readBy, readBy) &&
        listEquals(other.deliveredTo, deliveredTo) &&
        other.events == events &&
        other.callDurations == callDurations &&
        other.meetingId == meetingId &&
        other.meetingType == meetingType &&
        other.audioOnly == audioOnly;
  }

  @override
  int get hashCode =>
      body.hashCode ^
      action.hashCode ^
      updatedAt.hashCode ^
      sentAt.hashCode ^
      unreadMessagesCount.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      searchableTags.hashCode ^
      privateOneToOne.hashCode ^
      showInConversation.hashCode ^
      readByAll.hashCode ^
      senderInfo.hashCode ^
      metaData.hashCode ^
      messagingDisabled.hashCode ^
      membersCount.hashCode ^
      lastReadAt.hashCode ^
      attachments.hashCode ^
      lastMessageSentAt.hashCode ^
      isGroup.hashCode ^
      deliveredToAll.hashCode ^
      customType.hashCode ^
      createdByUserName.hashCode ^
      createdByUserImageUrl.hashCode ^
      createdBy.hashCode ^
      conversationType.hashCode ^
      conversationTitle.hashCode ^
      conversationImageUrl.hashCode ^
      conversationId.hashCode ^
      parentMessageId.hashCode ^
      initiatorId.hashCode ^
      messageId.hashCode ^
      deviceId.hashCode ^
      messageType.hashCode ^
      mentionedUsers.hashCode ^
      sentByMe.hashCode ^
      initiatorName.hashCode ^
      members.hashCode ^
      memberId.hashCode ^
      memberName.hashCode ^
      adminCount.hashCode ^
      reactions.hashCode ^
      deliveredTo.hashCode ^
      isUploading.hashCode ^
      conversationDetails.hashCode ^
      readBy.hashCode ^
      events.hashCode ^
      callDurations.hashCode ^
      meetingId.hashCode ^
      meetingType.hashCode ^
      audioOnly.hashCode;
}

class MessageStatus {
  MessageStatus({
    this.userId,
    this.timestamp,
  });

  factory MessageStatus.fromMap(Map<String, dynamic> map) => MessageStatus(
        userId: map['userId'] != null ? map['userId'] as String : null,
        timestamp: map['timestamp'] != null ? map['timestamp'] as int : null,
      );

  factory MessageStatus.fromJson(String source) =>
      MessageStatus.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? userId;
  final int? timestamp;

  MessageStatus copyWith({
    String? userId,
    int? timestamp,
  }) =>
      MessageStatus(
        userId: userId ?? this.userId,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'timestamp': timestamp,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'MessageStatus(userId: $userId, timestamp: $timestamp)';

  @override
  bool operator ==(covariant MessageStatus other) {
    if (identical(this, other)) return true;

    return other.userId == userId && other.timestamp == timestamp;
  }

  @override
  int get hashCode => userId.hashCode ^ timestamp.hashCode;
}

class CallDuration {
  CallDuration({
    this.memberId,
    this.durationInMilliseconds,
  });

  factory CallDuration.fromMap(Map<String, dynamic> map) => CallDuration(
        memberId: map['memberId'] as String? ?? '',
        durationInMilliseconds: map['durationInMilliseconds'] as int? ?? 0,
      );

  factory CallDuration.fromJson(String source) =>
      CallDuration.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? memberId;
  final int? durationInMilliseconds;

  CallDuration copyWith({
    String? memberId,
    int? durationInMilliseconds,
  }) =>
      CallDuration(
        memberId: memberId ?? this.memberId,
        durationInMilliseconds:
            durationInMilliseconds ?? this.durationInMilliseconds,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'memberId': memberId,
        'durationInMilliseconds': durationInMilliseconds,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'CallDuration(memberId: $memberId, durationInMilliseconds: $durationInMilliseconds)';

  @override
  bool operator ==(covariant CallDuration other) {
    if (identical(this, other)) return true;

    return other.memberId == memberId &&
        other.durationInMilliseconds == durationInMilliseconds;
  }

  @override
  int get hashCode => memberId.hashCode ^ durationInMilliseconds.hashCode;
}
