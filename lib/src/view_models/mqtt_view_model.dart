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

  Future<String> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    var response = await _repository.getChatConversationsUnreadCount(
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
    var response = await _repository.getChatConversationsCount(
      isLoading: isLoading,
    );
    if (response == null) {
      return '';
    }
    return response;
  }

  Future<String> getChatConversationsMessageCount({
    required isLoading,
    required String conversationId,
    required List<String> senderIds,
    required senderIdsExclusive,
    required lastMessageTimestamp,
  }) async {
    var response = await _repository.getChatConversationsMessageCount(
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
}
