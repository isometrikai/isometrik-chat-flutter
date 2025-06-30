import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttViewModel {
  IsmChatMqttViewModel(this._repository);

  final IsmChatMqttRepository _repository;

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.readSingleMessage(
        conversationId: conversationId,
        messageId: messageId,
      );
  Future<void> pingMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.pingMessageDelivered(
        conversationId: conversationId,
        messageId: messageId,
      );

  Future<String> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    final response = await _repository.getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
    if (response == null) {
      return '';
    }
    return response;
  }

  Future<void> getChatConversationsUnreadCountBulk({
    required List<String> userIds,
    bool isLoading = false,
  }) async {
    await _repository.getChatConversationsUnreadCountBulk(
      isLoading: isLoading,
      userIds: userIds,
    );
  }

  Future<String> getChatConversationsCount({
    bool isLoading = false,
  }) async {
    final response = await _repository.getChatConversationsCount(
      isLoading: isLoading,
    );
    if (response == null) {
      return '';
    }
    return response;
  }

  Future<String> getChatConversationsMessageCount({
    required bool isLoading,
    required String conversationId,
    required List<String> senderIds,
    required senderIdsExclusive,
    required lastMessageTimestamp,
  }) async {
    final response = await _repository.getChatConversationsMessageCount(
      isLoading: isLoading,
      conversationId: conversationId,
      senderIds: senderIds,
      lastMessageTimestamp: lastMessageTimestamp,
      senderIdsExclusive: senderIdsExclusive,
    );
    if (response == null) {
      return '';
    }
    return response;
  }

  Future<List<IsmChatConversationModel>> getChatConversationApi({
    required int skip,
    required int limit,
    required String searchTag,
    required bool includeConversationStatusMessagesInUnreadMessagesCount,
  }) async {
    final response = await _repository.getChatConversationApi(
      skip: skip,
      limit: limit,
      searchTag: searchTag,
      includeConversationStatusMessagesInUnreadMessagesCount:
          includeConversationStatusMessagesInUnreadMessagesCount,
    );
    if (response == null) return [];
    return response;
  }

  Future<List<IsmChatMessageModel>?> getUserMessges({
    List<String>? ids,
    List<String>? messageTypes,
    List<String>? customTypes,
    List<String>? attachmentTypes,
    String? showInConversation,
    List<String>? senderIds,
    String? parentMessageId,
    int? lastMessageTimestamp,
    bool? conversationStatusMessage,
    String? searchTag,
    String? fetchConversationDetails,
    bool deliveredToMe = false,
    bool senderIdsExclusive = true,
    int limit = 20,
    int? skip = 0,
    int? sort = -1,
    bool isLoading = false,
  }) async {
    final messages = await _repository.getUserMessges(
      attachmentTypes: attachmentTypes,
      conversationStatusMessage: conversationStatusMessage,
      customTypes: customTypes,
      deliveredToMe: deliveredToMe,
      fetchConversationDetails: fetchConversationDetails,
      ids: ids,
      lastMessageTimestamp: lastMessageTimestamp,
      limit: limit,
      messageTypes: messageTypes,
      parentMessageId: parentMessageId,
      searchTag: searchTag,
      senderIds: senderIds,
      senderIdsExclusive: senderIdsExclusive,
      showInConversation: showInConversation,
      skip: skip,
      sort: sort,
      isLoading: isLoading,
    );
    if (messages == null) {
      return null;
    }
    messages.removeWhere(
      (e) => [
        IsmChatActionEvents.clearConversation.name,
        IsmChatActionEvents.conversationCreated.name,
        IsmChatActionEvents.deleteConversationLocally.name,
        IsmChatActionEvents.reactionAdd.name,
        IsmChatActionEvents.reactionRemove.name,
        IsmChatActionEvents.conversationDetailsUpdated.name,
        IsmChatActionEvents.userUpdate.name,
        IsmChatActionEvents.memberLeave.name,
        IsmChatActionEvents.memberJoin.name,
        IsmChatActionEvents.membersRemove.name,
        IsmChatActionEvents.userUnblock.name,
        IsmChatActionEvents.userUnblockConversation.name,
        IsmChatActionEvents.userBlock.name,
        IsmChatActionEvents.userBlockConversation.name,
        IsmChatActionEvents.userBlockConversation.name,
        IsmChatActionEvents.observerJoin.name,
        IsmChatActionEvents.observerLeave.name,
        IsmChatActionEvents.removeAdmin.name,
        IsmChatActionEvents.addAdmin.name,
        IsmChatActionEvents.meetingCreated.name,
        IsmChatActionEvents.meetingEndedByHost.name,
        IsmChatActionEvents.meetingEndedDueToRejectionByAll.name,
      ].contains(e.action),
    );
    return messages;
  }
}
