part of '../isometrik_chat_flutter.dart';

/// Conversation management mixin for IsmChatDelegate.
///
/// This mixin contains methods related to conversation CRUD operations,
/// conversation queries, and conversation state management.
mixin IsmChatDelegateConversationMixin {
  /// Gets all conversations from the local database.
  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      return await Get.find<IsmChatMqttController>().getAllConversationFromDB();
    }
    return null;
  }

  /// Gets the list of non-blocked users.
  Future<List<SelectedMembers>?> getNonBlockUserList() async {
    if (IsmChatUtility.conversationControllerRegistered) {
      return await IsmChatUtility.conversationController.getNonBlockUserList();
    }
    return null;
  }

  /// Gets user conversations filtered by the conversation predicate.
  Future<List<IsmChatConversationModel>> get userConversations =>
      getAllConversationFromDB().then((conversations) => (conversations ?? [])
          .where(
              IsmChatProperties.conversationProperties.conversationPredicate ??
                  (_) => true)
          .toList());

  /// Gets the unread conversation count.
  Future<int> get unreadCount =>
      userConversations.then((value) => value.unreadCount);

  /// Updates a conversation's metadata.
  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
  }) async =>
      await IsmChatUtility.conversationController.updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  /// Updates conversation settings (events, loading state).
  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    required bool isLoading,
  }) async =>
      await IsmChatUtility.conversationController.updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  /// Gets chat conversations from the API.
  Future<void> getChatConversation() async {
    if (IsmChatUtility.conversationControllerRegistered) {
      await IsmChatUtility.conversationController.getChatConversations();
    }
  }

  /// Gets chat conversations from local database.
  Future<void> getChatConversationFromLocal({
    String? searchTag,
  }) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      await IsmChatUtility.conversationController
          .getConversationsFromDB(searchTag: searchTag);
    }
  }

  /// Gets chat conversations from the API with pagination.
  Future<List<IsmChatConversationModel>> getChatConversationApi({
    int skip = 0,
    int limit = 20,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return [];
    return await Get.find<IsmChatMqttController>().getChatConversationApi(
      skip: skip,
      limit: limit,
      searchTag: searchTag,
      includeConversationStatusMessagesInUnreadMessagesCount:
          includeConversationStatusMessagesInUnreadMessagesCount,
    );
  }

  /// Gets the total count of chat conversations.
  Future<int> getChatConversationsCount({
    required bool isLoading,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return 0;
    final count = await Get.find<IsmChatMqttController>()
        .getChatConversationsCount(isLoading: isLoading);
    return int.tryParse(count) ?? 0;
  }

  /// Gets the unread count for chat conversations.
  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return;
    await Get.find<IsmChatMqttController>().getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
  }

  /// Gets the message count for a specific conversation.
  Future<int> getChatConversationsMessageCount({
    required bool isLoading,
    required String converationId,
    required List<String> senderIds,
    required bool senderIdsExclusive,
    required int lastMessageTimestamp,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return 0;
    final count = await Get.find<IsmChatMqttController>()
        .getChatConversationsMessageCount(
      isLoading: isLoading,
      converationId: converationId,
      senderIds: senderIds,
      lastMessageTimestamp: lastMessageTimestamp,
      senderIdsExclusive: senderIdsExclusive,
    );
    return int.tryParse(count) ?? 0;
  }

  /// Gets conversation details.
  Future<IsmChatConversationModel?> getConverstaionDetails({
    required bool isLoading,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      return await IsmChatUtility.chatPageController.getConverstaionDetails(
        isLoading: isLoading,
      );
    }
    return null;
  }

  /// Gets a conversation by its ID.
  Future<IsmChatConversationModel?> getConversation({
    required String conversationId,
  }) async {
    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
      await Future.delayed(const Duration(seconds: 2));
    }
    var controller = IsmChatUtility.conversationController;
    final conversation = controller.getConversation(conversationId);
    if (conversation != null) {
      controller.updateLocalConversation(conversation);
    }
    return conversation;
  }
}
