// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/foundation.dart';

class IsmChatConversationModel {
  factory IsmChatConversationModel.fromJson(String source) =>
      IsmChatConversationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  factory IsmChatConversationModel.fromMap(Map<String, dynamic> map) {
    var model = IsmChatConversationModel(
        updatedAt: map['updatedAt'] as int? ?? 0,
        unreadMessagesCount: map['unreadMessagesCount'] as int? ?? 0,
        userIds: map['userIds'] == null
            ? []
            : List<String>.from(map['userIds'] as List),
        privateOneToOne: map['privateOneToOne'] as bool? ?? false,
        opponentDetails: map['opponentDetails'] == null
            ? null
            : UserDetails.fromMap(
                map['opponentDetails'] as Map<String, dynamic>),
        metaData: map['metaData'] == null
            ? IsmChatMetaData()
            : IsmChatMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        messagingDisabled: map['messagingDisabled'] as bool? ?? false,
        membersCount: map['membersCount'] as int? ?? 0,
        lastReadAt: map['lastReadAt'].runtimeType == List
            ? (map['lastReadAt'] as List)
                .map(
                    (e) => IsmChatLastReadAt.fromMap(e as Map<String, dynamic>))
                .toList()
            : map['lastReadAt'].runtimeType == Map
                ? IsmChatLastReadAt.fromNetworkMap(
                    map['lastReadAt'] as Map<String, dynamic>? ??
                        <String, dynamic>{})
                : [],
        lastMessageSentAt: map['lastMessageSentAt'] as int? ?? 0,
        lastMessageDetails: map['lastMessageDetails'] != null
            ? LastMessageDetails.fromMap(
                map['lastMessageDetails'] as Map<String, dynamic>)
            : null,
        isGroup: map['isGroup'] as bool? ?? false,
        createdAt: map['createdAt'] as int? ?? 0,
        createdBy: map['createdBy'] as String?,
        createdByUserName: map['createdByUserName'] as String? ?? '',
        conversationType: IsmChatConversationType.fromValue(
            map['conversationType'] as int? ?? 0),
        conversationTitle: map['conversationTitle'] as String? ?? '',
        conversationImageUrl: map['conversationImageUrl'] as String? ?? '',
        conversationId: map['conversationId'] as String? ?? '',
        config: map['config'] != null
            ? ConversationConfigModel.fromMap(
                map['config'] as Map<String, dynamic>)
            : ConversationConfigModel(
                typingEvents: false,
                readEvents: false,
                pushNotifications: false),
        members: map['members'] == null
            ? []
            : List<UserDetails>.from(
                (map['members'] as List).map(
                  (e) => UserDetails.fromMap(e as Map<String, dynamic>),
                ),
              ),
        usersOwnDetails: map['usersOwnDetails'] != null
            ? IsmChatUserOwnDetails.fromMap(
                map['usersOwnDetails'] as Map<String, dynamic>)
            : null,
        messages: map['messages'] != null
            ? (map['messages'] as List)
                .map(
                  (e) => IsmChatMessageModel.fromMap(e as Map<String, dynamic>),
                )
                .toList()
            : [],
        outSideMessage: map['outSideMessage'] != null
            ? OutSideMessage.fromMap(
                map['messageFromOutSide'] as Map<String, dynamic>)
            : null,
        isCreateGroupFromOutSide: map['isCreateGroupFromOutSide'] as bool? ?? false,
        customType: map['customType'] as String? ?? '',
        pushNotifications: map['pushNotifications'] as bool? ?? false);
    if (model.lastMessageDetails?.action ==
        IsmChatActionEvents.conversationCreated.name) {
      return model.copyWith(unreadMessagesCount: 0);
    }

    return model;
  }

  IsmChatConversationModel({
    this.updatedAt,
    this.unreadMessagesCount,
    this.privateOneToOne,
    this.opponentDetails,
    this.metaData,
    this.messagingDisabled,
    this.membersCount,
    this.lastReadAt,
    this.lastMessageSentAt,
    this.lastMessageDetails,
    this.isGroup,
    this.createdAt,
    this.conversationType,
    this.conversationTitle,
    this.conversationImageUrl,
    this.conversationId,
    this.config,
    this.userIds,
    this.members,
    this.usersOwnDetails,
    this.createdBy,
    this.createdByUserName,
    this.messages,
    this.outSideMessage,
    this.customType,
    this.pushNotifications,
    this.isCreateGroupFromOutSide,
  });

  final int? updatedAt;
  final int? unreadMessagesCount;
  final List<String>? userIds;
  final bool? privateOneToOne;
  final UserDetails? opponentDetails;
  final IsmChatMetaData? metaData;
  final bool? messagingDisabled;
  final int? membersCount;
  final List<IsmChatLastReadAt>? lastReadAt;
  final int? lastMessageSentAt;
  final LastMessageDetails? lastMessageDetails;
  final bool? isGroup;
  final IsmChatConversationType? conversationType;
  final int? createdAt;
  final String? conversationTitle;
  final String? conversationImageUrl;
  final String? conversationId;
  final ConversationConfigModel? config;
  final List<UserDetails>? members;
  final IsmChatUserOwnDetails? usersOwnDetails;
  final String? createdBy;
  final String? createdByUserName;
  final List<IsmChatMessageModel>? messages;
  final OutSideMessage? outSideMessage;
  final bool? isCreateGroupFromOutSide;
  final String? customType;
  final bool? pushNotifications;

  String get replyName => opponentDetails?.userName ?? '';

  String get chatName {
    if (conversationTitle.isNullOrEmpty) {
      return opponentDetails?.userName ?? '';
    }
    return conversationTitle ?? '';
  }

  String get profileUrl {
    if (conversationImageUrl.isNullOrEmpty) {
      return opponentDetails?.profileUrl ?? '';
    }
    return conversationImageUrl ?? '';
  }

  IsmChatConversationModel copyWith({
    int? updatedAt,
    int? unreadMessagesCount,
    List<String>? searchableTags,
    bool? privateOneToOne,
    UserDetails? opponentDetails,
    IsmChatMetaData? metaData,
    bool? messagingDisabled,
    int? membersCount,
    List<IsmChatLastReadAt>? lastReadAt,
    LastMessageDetails? lastMessageDetails,
    int? lastMessageSentAt,
    bool? isGroup,
    String? customType,
    String? createdByUserName,
    String? createdByUserImageUrl,
    String? createdBy,
    int? createdAt,
    IsmChatConversationType? conversationType,
    String? conversationTitle,
    String? conversationImageUrl,
    String? conversationId,
    ConversationConfigModel? config,
    int? adminCount,
    List<UserDetails>? members,
    IsmChatUserOwnDetails? usersOwnDetails,
    List<IsmChatMessageModel>? messages,
    OutSideMessage? outSideMessage,
    bool? isCreateGroupFromOutSide,
    bool? pushNotifications,
    List<String>? userIds,
  }) =>
      IsmChatConversationModel(
          updatedAt: updatedAt ?? this.updatedAt,
          unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
          privateOneToOne: privateOneToOne ?? this.privateOneToOne,
          opponentDetails: opponentDetails ?? this.opponentDetails,
          metaData: metaData ?? this.metaData,
          messagingDisabled: messagingDisabled ?? this.messagingDisabled,
          membersCount: membersCount ?? this.membersCount,
          lastReadAt: lastReadAt ?? this.lastReadAt,
          lastMessageSentAt: lastMessageSentAt ?? this.lastMessageSentAt,
          lastMessageDetails: lastMessageDetails ?? this.lastMessageDetails,
          isGroup: isGroup ?? this.isGroup,
          conversationType: conversationType ?? this.conversationType,
          conversationTitle: conversationTitle ?? this.conversationTitle,
          conversationImageUrl:
              conversationImageUrl ?? this.conversationImageUrl,
          conversationId: conversationId ?? this.conversationId,
          createdAt: createdAt ?? this.createdAt,
          createdBy: createdBy ?? this.createdBy,
          createdByUserName: createdByUserName ?? this.createdByUserName,
          config: config ?? this.config,
          members: members ?? this.members,
          usersOwnDetails: usersOwnDetails ?? this.usersOwnDetails,
          messages: messages ?? this.messages,
          outSideMessage: outSideMessage ?? this.outSideMessage,
          customType: customType ?? this.customType,
          pushNotifications: pushNotifications ?? this.pushNotifications,
          isCreateGroupFromOutSide:
              isCreateGroupFromOutSide ?? this.isCreateGroupFromOutSide,
          userIds: userIds ?? this.userIds);

  Map<String, dynamic> toMap() => {
        'isGroup': isGroup,
        'createdBy': createdBy,
        'createdByUserName': createdByUserName,
        'conversationType': conversationType?.value,
        'conversationTitle': conversationTitle,
        'conversationImageUrl': conversationImageUrl,
        'conversationId': conversationId,
        'config': config?.toMap(),
        'createdAt': createdAt,
        'members': members?.map((e) => e.toMap()).toList(),
        'usersOwnDetails': usersOwnDetails?.toMap(),
        'messages': messages?.map((e) => e.toMap()).toList(),
        'updatedAt': updatedAt,
        'unreadMessagesCount': unreadMessagesCount,
        'userIds': userIds,
        'privateOneToOne': privateOneToOne,
        'opponentDetails': opponentDetails?.toMap(),
        'metaData': metaData?.toMap(),
        'messagingDisabled': messagingDisabled,
        'membersCount': membersCount,
        'lastReadAt': lastReadAt?.map((x) => x.toMap()).toList(),
        'lastMessageSentAt': lastMessageSentAt,
        'lastMessageDetails': lastMessageDetails?.toMap(),
        'outSideMessage': outSideMessage?.toMap(),
        'customType': customType,
        'pushNotifications': pushNotifications,
        'isCreateGroupFromOutSide': isCreateGroupFromOutSide,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatConversationModel(updatedAt: $updatedAt, unreadMessagesCount: $unreadMessagesCount, userIds: $userIds, privateOneToOne: $privateOneToOne, opponentDetails: $opponentDetails, metaData: $metaData, messagingDisabled: $messagingDisabled, membersCount: $membersCount, lastReadAt: $lastReadAt, lastMessageSentAt: $lastMessageSentAt, lastMessageDetails: $lastMessageDetails, isGroup: $isGroup, conversationType: $conversationType, createdAt: $createdAt, conversationTitle: $conversationTitle, conversationImageUrl: $conversationImageUrl, conversationId: $conversationId, config: $config, members: $members, usersOwnDetails: $usersOwnDetails, createdBy: $createdBy, createdByUserName: $createdByUserName, messages: $messages, outSideMessage : $outSideMessage ,customType: $customType, pushNotifications : $pushNotifications, isCreateGroupFromOutSide : $isCreateGroupFromOutSide)';

  @override
  bool operator ==(covariant IsmChatConversationModel other) {
    if (identical(this, other)) return true;

    return other.updatedAt == updatedAt &&
        other.unreadMessagesCount == unreadMessagesCount &&
        listEquals(other.userIds, userIds) &&
        other.privateOneToOne == privateOneToOne &&
        other.opponentDetails == opponentDetails &&
        other.metaData == metaData &&
        other.messagingDisabled == messagingDisabled &&
        other.membersCount == membersCount &&
        listEquals(other.lastReadAt, lastReadAt) &&
        other.lastMessageSentAt == lastMessageSentAt &&
        other.lastMessageDetails == lastMessageDetails &&
        other.isGroup == isGroup &&
        other.conversationType == conversationType &&
        other.createdAt == createdAt &&
        other.conversationTitle == conversationTitle &&
        other.conversationImageUrl == conversationImageUrl &&
        other.conversationId == conversationId &&
        other.config == config &&
        listEquals(other.members, members) &&
        other.usersOwnDetails == usersOwnDetails &&
        other.createdBy == createdBy &&
        other.outSideMessage == outSideMessage &&
        other.isCreateGroupFromOutSide == isCreateGroupFromOutSide &&
        other.createdByUserName == createdByUserName &&
        other.customType == customType &&
        other.pushNotifications == pushNotifications &&
        listEquals(other.messages, messages);
  }

  @override
  int get hashCode =>
      updatedAt.hashCode ^
      unreadMessagesCount.hashCode ^
      userIds.hashCode ^
      privateOneToOne.hashCode ^
      opponentDetails.hashCode ^
      metaData.hashCode ^
      messagingDisabled.hashCode ^
      membersCount.hashCode ^
      lastReadAt.hashCode ^
      lastMessageSentAt.hashCode ^
      lastMessageDetails.hashCode ^
      isGroup.hashCode ^
      conversationType.hashCode ^
      createdAt.hashCode ^
      conversationTitle.hashCode ^
      conversationImageUrl.hashCode ^
      conversationId.hashCode ^
      config.hashCode ^
      members.hashCode ^
      usersOwnDetails.hashCode ^
      createdBy.hashCode ^
      createdByUserName.hashCode ^
      outSideMessage.hashCode ^
      isCreateGroupFromOutSide.hashCode ^
      customType.hashCode ^
      pushNotifications.hashCode ^
      messages.hashCode;
}

class OutSideMessage {
  final String? imageUrl;
  final String? messageFromOutSide;
  final String? caption;
  final AboutTextModel? aboutText;
  OutSideMessage({
    this.imageUrl,
    this.messageFromOutSide,
    this.caption,
    this.aboutText,
  });

  OutSideMessage copyWith({
    String? imageUrl,
    String? messageFromOutSide,
    String? caption,
    AboutTextModel? aboutText,
  }) =>
      OutSideMessage(
        imageUrl: imageUrl ?? this.imageUrl,
        messageFromOutSide: messageFromOutSide ?? this.messageFromOutSide,
        caption: caption ?? this.caption,
        aboutText: aboutText ?? this.aboutText,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'imageUrl': imageUrl,
        'messageFromOutSide': messageFromOutSide,
        'caption': caption,
        'aboutText': aboutText?.toMap(),
      };

  factory OutSideMessage.fromMap(Map<String, dynamic> map) => OutSideMessage(
        imageUrl: map['imageUrl'] as String? ?? '',
        messageFromOutSide: map['messageFromOutSide'] as String? ?? '',
        caption: map['caption'] as String? ?? '',
        aboutText: map['aboutText'] != null
            ? AboutTextModel.fromMap(map['aboutText'] as Map<String, dynamic>)
            : null,
      );

  String toJson() => json.encode(toMap());

  factory OutSideMessage.fromJson(String source) =>
      OutSideMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'OutSideMessage(imageUrl: $imageUrl, messageFromOutSide: $messageFromOutSide, caption: $caption, aboutText: $aboutText)';

  @override
  bool operator ==(covariant OutSideMessage other) {
    if (identical(this, other)) return true;

    return other.imageUrl == imageUrl &&
        other.messageFromOutSide == messageFromOutSide &&
        other.caption == caption &&
        other.aboutText == aboutText;
  }

  @override
  int get hashCode =>
      imageUrl.hashCode ^
      messageFromOutSide.hashCode ^
      caption.hashCode ^
      aboutText.hashCode;
}

class AboutTextModel {
  final String? title;
  final String? subTitle;
  AboutTextModel({
    this.title,
    this.subTitle,
  });

  AboutTextModel copyWith({
    String? title,
    String? subTitle,
  }) =>
      AboutTextModel(
        title: title ?? this.title,
        subTitle: subTitle ?? this.subTitle,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'subTitle': subTitle,
      };

  factory AboutTextModel.fromMap(Map<String, dynamic> map) => AboutTextModel(
        title: map['title'] as String? ?? '',
        subTitle: map['subTitle'] as String? ?? '',
      );

  String toJson() => json.encode(toMap());

  factory AboutTextModel.fromJson(String source) =>
      AboutTextModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AboutTextModel(title: $title, subTitle: $subTitle)';

  @override
  bool operator ==(covariant AboutTextModel other) {
    if (identical(this, other)) return true;

    return other.title == title && other.subTitle == subTitle;
  }

  @override
  int get hashCode => title.hashCode ^ subTitle.hashCode;
}
