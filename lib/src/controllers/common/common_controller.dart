import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCommonController extends GetxController {
  IsmChatCommonController(this.viewModel);
  final IsmChatCommonViewModel viewModel;

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

  Future<PresignedUrlModel?> postMediaUrl({
    required String conversationId,
    required String nameWithExtension,
    required int mediaType,
    required String mediaId,
    required Uint8List bytes,
    required bool isLoading,
  }) async =>
      await viewModel.postMediaUrl(
        conversationId: conversationId,
        nameWithExtension: nameWithExtension,
        mediaType: mediaType,
        mediaId: mediaId,
        isLoading: isLoading,
        bytes: bytes,
      );

  List<IsmChatMessageModel> sortMessages(List<IsmChatMessageModel> messages) =>
      viewModel.sortMessages(messages);

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
          messages: [
            IsmChatMessageModel(
              body: '',
              customType: IsmChatCustomMessageType.conversationCreated,
              sentAt: DateTime.now().millisecondsSinceEpoch,
              sentByMe: false,
              conversationId: conversationId,
              action: 'conversationCreated',
            )
          ],
          opponentDetails: conversation.opponentDetails,
          lastMessageDetails:
              conversation.lastMessageDetails?.copyWith(deliverCount: 0),
          config: conversation.config,
          metaData: conversation.metaData,
          conversationType: conversation.conversationType);
      await IsmChatConfig.dbWrapper!
          .createAndUpdateConversation(dbConversationModel);
      unawaited(
          Get.find<IsmChatConversationsController>().getChatConversations());
      return conversation;
    }
    return null;
  }

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
}
