import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// A GetxController that provides common functionality for Isometrik Chat Flutter.
class IsmChatCommonController extends GetxController {
  IsmChatCommonController(this.viewModel);

  /// The underlying view model that provides the logic for the controller.
  final IsmChatCommonViewModel viewModel;

  /// Updates a presigned URL.
  ///
  /// * `presignedUrl`: The presigned URL to update.
  /// * `bytes`: The bytes to update.
  /// * `isLoading`: A boolean indicating whether the update is in progress.
  ///
  /// Returns a future that resolves to an integer value.
  Future<int?> updatePresignedUrl({
    String? presignedUrl,
    Uint8List? bytes,
    bool isLoading = false,
  }) async =>
      viewModel.updatePresignedUrl(
        bytes: bytes,
        presignedUrl: presignedUrl,
        isLoading: isLoading,
      );

  /// Retrieves a presigned URL.
  ///
  /// * `isLoading`: A boolean indicating whether the retrieval is in progress.
  /// * `userIdentifier`: The user identifier.
  /// * `mediaExtension`: The media extension.
  /// * `bytes`: The bytes to retrieve.
  ///
  /// Returns a future that resolves to a PresignedUrlModel instance.
  Future<PresignedUrlModel?> getPresignedUrl({
    required bool isLoading,
    required String userIdentifier,
    required String mediaExtension,
    required Uint8List bytes,
  }) async =>
      await viewModel.getPresignedUrl(
        isLoading: isLoading,
        userIdentifier: userIdentifier,
        mediaExtension: mediaExtension,
        bytes: bytes,
      );

  /// Posts a media URL.
  ///
  /// * `conversationId`: The conversation ID.
  /// * `nameWithExtension`: The name with extension.
  /// * `mediaType`: The media type.
  /// * `mediaId`: The media ID.
  /// * `bytes`: The bytes to post.
  /// * `isLoading`: A boolean indicating whether the post is in progress.
  /// * `isUpdateThumbnail`: A boolean indicating whether to update the thumbnail.
  ///
  /// Returns a future that resolves to a PresignedUrlModel instance.
  Future<PresignedUrlModel?> postMediaUrl({
    required String conversationId,
    required String nameWithExtension,
    required int mediaType,
    required String mediaId,
    required Uint8List bytes,
    required bool isLoading,
    bool isUpdateThumbnail = false,
  }) async =>
      await viewModel.postMediaUrl(
        conversationId: conversationId,
        nameWithExtension: nameWithExtension,
        mediaType: mediaType,
        mediaId: mediaId,
        isLoading: isLoading,
        bytes: bytes,
        isUpdateThumbnail: isUpdateThumbnail,
      );

  /// Sorts a list of messages.
  ///
  /// * `messages`: The list of messages to sort.
  ///
  /// Returns a sorted list of IsmChatMessageModel instances.
  List<IsmChatMessageModel> sortMessages(List<IsmChatMessageModel> messages) =>
      viewModel.sortMessages(messages);

  /// Sends a message.
  ///
  /// * `showInConversation`: A boolean indicating whether to show the message in the conversation.
  /// * `messageType`: The message type.
  /// * `encrypted`: A boolean indicating whether the message is encrypted.
  /// * `deviceId`: The device ID.
  /// * `conversationId`: The conversation ID.
  /// * `body`: The message body.
  /// * `createdAt`: The creation timestamp.
  /// * `notificationBody`: The notification body.
  /// * `notificationTitle`: The notification title.
  /// * `parentMessageId`: The parent message ID.
  /// * `metaData`: The metadata.
  /// * `mentionedUsers`: The mentioned users.
  /// * `events`: The events.
  /// * `customType`: The custom type.
  /// * `attachments`: The attachments.
  /// * `searchableTags`: The searchable tags.
  /// * `isBroadcast`: A boolean indicating whether the message is a broadcast.
  /// * `isUpdateMesage`: A boolean indicating whether to update the message.
  ///
  /// Returns a future that resolves to a boolean value.
  Future<bool> sendMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required int createdAt,
    required String notificationBody,
    required String notificationTitle,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
    List<String>? searchableTags,
    bool isBroadcast = false,
    bool isUpdateMesage = true,
  }) async =>
      await viewModel.sendMessage(
          showInConversation: showInConversation,
          messageType: messageType,
          encrypted: encrypted,
          deviceId: deviceId,
          conversationId: conversationId,
          body: body,
          createdAt: createdAt,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachments,
          customType: customType,
          events: events,
          isBroadcast: isBroadcast,
          mentionedUsers: mentionedUsers,
          metaData: metaData,
          parentMessageId: parentMessageId,
          searchableTags: searchableTags,
          isUpdateMesage: isUpdateMesage);

  // Sends a paid wallet message.
  ///
  /// * `showInConversation`: A boolean indicating whether to show the message in the conversation.
  /// * `messageType`: The message type.
  /// * `encrypted`: A boolean indicating whether the message is encrypted.
  /// * `deviceId`: The device ID.
  /// * `conversationId`: The conversation ID.
  /// * `body`: The message body.
  /// * `notificationBody`: The notification body.
  /// * `notificationTitle`: The notification title.
  /// * `createdAt`: The creation timestamp.
  /// * `parentMessageId`: The parent message ID.
  /// * `metaData`: The metadata.
  /// * `mentionedUsers`: The mentioned users.
  /// * `events`: The events.
  /// * `customType`: The custom type.
  /// * `attachments`: The attachments.
  ///
  /// Returns a future that resolves to a tuple containing a boolean value and an IsmChatResponseModel instance.
  Future<(bool, IsmChatResponseModel?)> sendPaidWalletMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required String notificationBody,
    required String notificationTitle,
    required int createdAt,
    String? parentMessageId,
    Map<String, dynamic>? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
  }) async =>
      await viewModel.sendPaidWalletMessage(
          showInConversation: showInConversation,
          messageType: messageType,
          encrypted: encrypted,
          deviceId: deviceId,
          conversationId: conversationId,
          body: body,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachments,
          customType: customType,
          events: events,
          mentionedUsers: mentionedUsers,
          parentMessageId: parentMessageId,
          metaData: metaData,
          createdAt: createdAt);

  /// Creates a conversation.
  ///
  /// * `userId`: The user ID.
  /// * `metaData`: The metadata.
  /// * `isGroup`: A boolean indicating whether the conversation is a group.
  /// * `isLoading`: A boolean indicating whether the creation is in progress.
  /// * `searchableTags`: The searchable tags.
  /// * `conversationType`: The conversation type.
  /// * `conversation`: The conversation model.
  /// * `pushNotifications`: A boolean indicating whether to enable push notifications.
  ///
  /// Returns a future that resolves to an IsmChatConversationModel instance.
  Future<IsmChatConversationModel?> createConversation({
    required List<String> userId,
    IsmChatMetaData? metaData,
    bool isGroup = false,
    bool isLoading = false,
    List<String> searchableTags = const [' '],
    IsmChatConversationType conversationType = IsmChatConversationType.private,
    required IsmChatConversationModel conversation,
    bool pushNotifications = true,
  }) async {
    if (isGroup) {
      userId = conversation.userIds ?? [];
    }
    var response = await viewModel.createConversation(
      isLoading: isLoading,
      typingEvents: true,
      readEvents: true,
      pushNotifications: pushNotifications,
      members: userId,
      isGroup: isGroup,
      conversationType: conversationType.value,
      searchableTags: searchableTags,
      metaData: metaData != null ? metaData.toMap() : {},
      conversationImageUrl:
          isGroup ? conversation.conversationImageUrl ?? '' : '',
      conversationTitle: isGroup ? conversation.conversationTitle ?? '' : '',
    );

    if (response != null) {
      var data = jsonDecode(response.data);
      var conversationId = data['conversationId'];
      conversation =
          conversation.copyWith(conversationId: conversationId ?? '');
      var dbConversationModel = IsmChatConversationModel(
          conversationId: conversationId ?? '',
          conversationImageUrl: conversation.conversationImageUrl,
          conversationTitle: conversation.conversationTitle,
          isGroup: isGroup,
          lastMessageSentAt: conversation.lastMessageSentAt ?? 0,
          messagingDisabled: conversation.messagingDisabled,
          membersCount: conversation.membersCount,
          unreadMessagesCount: conversation.unreadMessagesCount,
          messages: {
            '${DateTime.now().millisecondsSinceEpoch}': IsmChatMessageModel(
              body: '',
              customType: IsmChatCustomMessageType.conversationCreated,
              sentAt: DateTime.now().millisecondsSinceEpoch,
              sentByMe: false,
              conversationId: conversationId,
              action: 'conversationCreated',
            )
          },
          opponentDetails: conversation.opponentDetails,
          lastMessageDetails:
              conversation.lastMessageDetails?.copyWith(deliverCount: 0),
          config: conversation.config,
          metaData: conversation.metaData,
          conversationType: conversation.conversationType);
      await IsmChatConfig.dbWrapper
          ?.createAndUpdateConversation(dbConversationModel);
      await Get.find<IsmChatConversationsController>(
              tag: IsmChat.i.chatListPageTag)
          .getChatConversations();

      return conversation;
    }
    return null;
  }

  /// Retrieves chat messages.
  ///
  /// * `conversationId`: The conversation ID.
  /// * `lastMessageTimestamp`: The last message timestamp.
  /// * `limit`: The limit.
  /// * `skip`: The skip.
  /// * `searchText`: The search text.
  /// * `isLoading`: A boolean indicating whether the retrieval is in progress.
  ///
  /// Returns a future that resolves to a list of IsmChatMessageModel instances.
  Future<List<IsmChatMessageModel>> getChatMessages({
    required String conversationId,
    required int lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
  }) async =>
      await viewModel.getChatMessages(
        conversationId: conversationId,
        lastMessageTimestamp: lastMessageTimestamp,
        limit: limit,
        skip: skip,
        searchText: searchText,
        isLoading: isLoading,
      );

  /// Handles sorting and indexing of member list for UI display.
  ///
  /// * `list`: The list of selected members to process.
  void handleSorSelectedMembers(List<SelectedMembers> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      var tag = list[i].userDetails.userName[0].toUpperCase();
      var isLocal = list[i].localContacts ?? false;
      if (RegExp('[A-Z]').hasMatch(tag) && isLocal == false) {
        list[i].tagIndex = tag;
      } else {
        if (isLocal == true) {
          list[i].tagIndex = '#';
        }
      }
    }
    _suspensionFilter(list);
  }

  /// Handles sorting and indexing of contact list for UI display.
  ///
  /// * `list`: The list of selected contacts to process.
  void handleSorSelectedContact(List<SelectedContact> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      var tag = list[i].contact.displayName[0].toUpperCase();
      if (RegExp('[A-Z]').hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = '#';
      }
    }
    _suspensionFilter(list);
  }

  /// Filters the list of suspension beans.
  ///
  /// * `list`: The list of suspension beans to filter.
  void _suspensionFilter(List<ISuspensionBean>? list) {
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(list);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(list);
  }
}
