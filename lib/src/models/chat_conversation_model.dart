import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Data model representing a chat conversation.
///
/// This model contains all information about a conversation including metadata,
/// members, messages, and conversation settings.
///
/// **Key Properties:**
/// - `conversationId` - Unique conversation identifier
/// - `conversationTitle` - Display title of the conversation
/// - `conversationType` - Type (private, group, broadcast)
/// - `members` - List of conversation members
/// - `messages` - Map of messages in the conversation
/// - `lastMessageDetails` - Details of the last message
/// - `unreadMessagesCount` - Count of unread messages
/// - `metaData` - Custom metadata
///
/// **Serialization:**
/// - `fromMap()` - Create from Map (JSON)
/// - `fromJson()` - Create from JSON string
/// - `toMap()` - Convert to Map
/// - `toJson()` - Convert to JSON string
///
/// **Usage:**
/// ```dart
/// // From API response
/// final conversation = IsmChatConversationModel.fromMap(jsonMap);
///
/// // Access properties
/// print(conversation.conversationTitle);
/// print(conversation.unreadMessagesCount);
///
/// // Convert to JSON
/// final json = conversation.toJson();
/// ```
///
/// **See Also:**
/// - [IsmChatMessageModel] - Message model
/// - [UserDetails] - User information model
/// - [MODULE_MODELS.md] - Models documentation
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
            ? map['messages'] is List
                ? {}
                : (map['messages'] as Map).messageMap
            : {},
        outSideMessage: map['outSideMessage'] != null
            ? OutSideMessage.fromMap(
                map['messageFromOutSide'] as Map<String, dynamic>)
            : null,
        customType: map['customType'] as String? ?? '',
        searchableTags: map['searchableTags'] != null ? List<String>.from(map['searchableTags'] as List<dynamic>) : [],
        pushNotifications: map['pushNotifications'] as bool? ?? false);
    if (model.lastMessageDetails?.action ==
        IsmChatActionEvents.conversationCreated.name) {
      return model.copyWith(unreadMessagesCount: 0);
    }
    if (model.messages?.isNotEmpty == true &&
        model.lastMessageDetails?.action ==
            IsmChatActionEvents.conversationDetailsUpdated.name) {
      IsmChatMessageModel? message;
      if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context) &&
          IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (controller.messages.isNotEmpty) {
          message = IsmChatUtility.chatPageController.messages.last;
        }
      } else {
        message = model.messages?.values.toList().first;
      }

      model = model.copyWith(
        lastMessageDetails: model.lastMessageDetails?.copyWith(
          body: message?.body,
          audioOnly: message?.audioOnly,
          meetingId: message?.meetingId,
          meetingType: message?.meetingType,
          callDurations: message?.callDurations,
          sentByMe: message?.sentByMe,
          showInConversation: true,
          senderId: message?.senderInfo?.userId ?? '',
          sentAt: message?.sentAt,
          senderName: [
            IsmChatCustomMessageType.removeAdmin,
            IsmChatCustomMessageType.addAdmin,
            IsmChatCustomMessageType.memberJoin,
            IsmChatCustomMessageType.memberLeave,
          ].contains(message?.customType)
              ? message?.userName?.isNotEmpty == true
                  ? message?.userName
                  : message?.initiatorName ?? ''
              : model.isGroup ?? false
                  ? message?.senderInfo?.userName
                  : message?.chatName,
          messageType: message?.messageType?.value ?? 0,
          messageId: message?.messageId ?? '',
          conversationId: message?.conversationId ?? '',
          action: message?.action,
          customType: message?.customType,
          readCount: message?.messageId?.isNotEmpty == true
              ? model.isGroup ?? false
                  ? message?.readByAll ?? false
                      ? model.membersCount
                      : message?.lastReadAt?.length
                  : message?.readByAll ?? false
                      ? 1
                      : 0
              : 0,
          deliveredTo: message?.messageId?.isNotEmpty == true
              ? message?.deliveredTo
              : [],
          readBy: message?.messageId?.isNotEmpty == true ? message?.readBy : [],
          deliverCount: message?.messageId?.isNotEmpty == true
              ? model.isGroup ?? false
                  ? message?.deliveredToAll ?? false
                      ? model.membersCount
                      : 0
                  : message?.deliveredToAll ?? false
                      ? 1
                      : 0
              : 0,
          members:
              message?.members?.map((e) => e.memberName ?? '').toList() ?? [],
          initiatorId: message?.initiatorId,
          metaData: message?.metaData,
        ),
      );
      return model;
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
    this.searchableTags,
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
  final Map<String, IsmChatMessageModel>? messages;
  final OutSideMessage? outSideMessage;
  final String? customType;
  final bool? pushNotifications;
  final List<String>? searchableTags;

  String get replyName => opponentDetails?.userName ?? '';

  String get chatName {
    if (conversationTitle.isNullOrEmpty) {
      if (isOpponentDetailsEmpty) {
        return IsmChatStrings.deletedUser;
      }
      return opponentDetails?.userName ?? '';
    }
    return conversationTitle ?? '';
  }

  String get profileUrl {
    if (conversationImageUrl.isNullOrEmpty) {
      if (isOpponentDetailsEmpty) {
        return IsmChatConstants.profileUrl;
      }
      return opponentDetails?.profileUrl ?? '';
    }
    return conversationImageUrl ?? '';
  }

  bool get isOpponentDetailsEmpty =>
      isGroup == false &&
      (opponentDetails?.userId ?? '').isEmpty &&
      ((opponentDetails?.userName ?? '').isEmpty ||
          (opponentDetails?.profileUrl ?? '').isEmpty);

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
    Map<String, IsmChatMessageModel>? messages,
    OutSideMessage? outSideMessage,
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
        conversationImageUrl: conversationImageUrl ?? this.conversationImageUrl,
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
        userIds: userIds ?? this.userIds,
        searchableTags: searchableTags ?? this.searchableTags,
      );

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
        'messages': messages != null
            ? {
                for (var entry in messages!.entries)
                  entry.key: entry.value.toMap()
              }
            : {},
        'updatedAt': updatedAt,
        'unreadMessagesCount': unreadMessagesCount,
        'userIds': userIds,
        'searchableTags': searchableTags,
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
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatConversationModel(updatedAt: $updatedAt, unreadMessagesCount: $unreadMessagesCount, userIds: $userIds, privateOneToOne: $privateOneToOne, opponentDetails: $opponentDetails, metaData: $metaData, messagingDisabled: $messagingDisabled, membersCount: $membersCount, lastReadAt: $lastReadAt, lastMessageSentAt: $lastMessageSentAt, lastMessageDetails: $lastMessageDetails, isGroup: $isGroup, conversationType: $conversationType, createdAt: $createdAt, conversationTitle: $conversationTitle, conversationImageUrl: $conversationImageUrl, conversationId: $conversationId, config: $config, members: $members, usersOwnDetails: $usersOwnDetails, createdBy: $createdBy, createdByUserName: $createdByUserName, messages: $messages, outSideMessage : $outSideMessage ,customType: $customType, pushNotifications : $pushNotifications, searchableTags : $searchableTags)';

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
        listEquals(other.searchableTags, searchableTags) &&
        listEquals(other.userIds, userIds) &&
        other.usersOwnDetails == usersOwnDetails &&
        other.createdBy == createdBy &&
        other.outSideMessage == outSideMessage &&
        other.createdByUserName == createdByUserName &&
        other.customType == customType &&
        other.pushNotifications == pushNotifications &&
        other.messages == messages;
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
      customType.hashCode ^
      pushNotifications.hashCode ^
      userIds.hashCode ^
      messages.hashCode;
}

class OutSideMessage {
  OutSideMessage({
    this.imageUrl,
    this.messageFromOutSide,
    this.caption,
    this.aboutText,
  });

  factory OutSideMessage.fromMap(Map<String, dynamic> map) => OutSideMessage(
        imageUrl: map['imageUrl'] as String? ?? '',
        messageFromOutSide: map['messageFromOutSide'] as String? ?? '',
        caption: map['caption'] as String? ?? '',
        aboutText: map['aboutText'] != null
            ? AboutTextModel.fromMap(map['aboutText'] as Map<String, dynamic>)
            : null,
      );

  factory OutSideMessage.fromJson(String source) =>
      OutSideMessage.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? imageUrl;
  final String? messageFromOutSide;
  final String? caption;
  final AboutTextModel? aboutText;

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
      }.removeNullValues();

  String toJson() => json.encode(toMap());

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
  AboutTextModel({
    this.title,
    this.subTitle,
  });

  factory AboutTextModel.fromMap(Map<String, dynamic> map) => AboutTextModel(
        title: map['title'] as String? ?? '',
        subTitle: map['subTitle'] as String? ?? '',
      );

  factory AboutTextModel.fromJson(String source) =>
      AboutTextModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? title;
  final String? subTitle;

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
      }.removeNullValues();

  String toJson() => json.encode(toMap());

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
