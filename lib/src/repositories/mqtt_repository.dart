import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttRepository {
  final _apiWrapper = IsmChatApiWrapper();

  Future<String?> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    try {
      var response = await _apiWrapper.get(
        IsmChatAPI.conversationUnreadCount,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      var unReadCount = jsonDecode(response.data);
      var count = unReadCount['count'].toString();
      return count;
    } catch (e, st) {
      IsmChatLog.error('Get Conversations unread error $e', st);
      return null;
    }
  }

  Future<String?> getChatConversationsCount({
    bool isLoading = false,
  }) async {
    try {
      var response = await _apiWrapper.get(
        IsmChatAPI.conversationCount,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      var getCount = jsonDecode(response.data);
      var count = getCount['conversationsCount'].toString();
      return count;
    } catch (e, st) {
      IsmChatLog.error('Get Conversations count error $e', st);
      return null;
    }
  }

  Future<String?> getChatConversationsMessageCount({
    required isLoading,
    required String conversationId,
    required List<String> senderIds,
    required senderIdsExclusive,
    required lastMessageTimestamp,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.chatMessagesCount}?conversationId=$conversationId&senderIds=${senderIds.join(',')}&senderIdsExclusive=$senderIdsExclusive&lastMessageTimestamp=$lastMessageTimestamp',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      var getCount = jsonDecode(response.data);
      var count = getCount['messagesCount'].toString();
      return count;
    } catch (e, st) {
      IsmChatLog.error('Get Conversations count error $e', st);
      return null;
    }
  }
}
