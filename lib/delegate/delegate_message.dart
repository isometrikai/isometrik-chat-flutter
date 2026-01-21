part of '../isometrik_chat_flutter.dart';

/// Message management mixin for IsmChatDelegate.
///
/// This mixin contains methods related to message operations such as fetching,
/// updating, and managing messages.
mixin IsmChatDelegateMessageMixin {
  /// Gets messages from the API.
  Future<List<IsmChatMessageModel>?> getMessagesFromApi({
    required String conversationId,
    required int lastMessageTimestamp,
    required int limit,
    required int skip,
    String? searchText,
    required bool isLoading,
  }) async {
    if (Get.isRegistered<IsmChatCommonController>()) {
      return await Get.find<IsmChatCommonController>().getChatMessages(
        conversationId: conversationId,
        lastMessageTimestamp: lastMessageTimestamp,
        limit: limit,
        skip: skip,
        searchText: searchText,
        isLoading: isLoading,
      );
    }
    return null;
  }

  /// Gets messages on the chat page.
  Future<void> getMessageOnChatPage({
    bool isBroadcast = false,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      await controller.getMessagesFromAPI(
        isBroadcast: isBroadcast,
        lastMessageTimestamp: controller.messages.isNotEmpty
            ? controller.messages.last.sentAt
            : 0,
      );
    }
  }

  /// Updates the chat page with latest conversation details and messages.
  Future<void> updateChatPage() async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      await controller.getConverstaionDetails();
      await controller.getMessagesFromAPI();
    }
  }

  /// Gets the current conversation messages.
  List<IsmChatMessageModel> currentConversatonMessages() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      return controller.messages;
    }
    return [];
  }

  /// Gets messages from the local database.
  Future<void> getMessagesFromDB({required String conversationId}) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.getMessagesFromDB(conversationId);
    }
  }

  /// Updates a message in the database and refreshes the chat page.
  Future<void> updateMessage({
    required IsmChatMessageModel message,
  }) async {
    final converations = await IsmChat.i.getAllConversationFromDB() ?? [];
    IsmChatConversationModel? conversation;
    for (var i in converations) {
      if (i.conversationId != message.conversationId) continue;
      conversation = i;
      break;
    }
    if (conversation != null) {
      final messages = conversation.messages ?? {};
      messages[message.key] = message;
      var dbConversations = await IsmChatConfig.dbWrapper
          ?.getConversation(message.conversationId ?? '');
      if (dbConversations != null) {
        dbConversations = dbConversations.copyWith(messages: messages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }
    }
    await getMessagesFromDB(conversationId: message.conversationId ?? '');
  }

  /// Updates message metadata.
  Future<void> updateMessageMetaData({
    required String messageId,
    required String conversationId,
    bool isOpponentMessage = false,
    IsmChatMetaData? metaData,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.updateMessage(
        messageId: messageId,
        conversationId: conversationId,
        isOpponentMessage: isOpponentMessage,
        metaData: metaData,
      );
    }
  }
}
