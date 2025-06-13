import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMqttRepository {
  final _apiWrapper = IsmChatApiWrapper();

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var payload = {'messageId': messageId, 'conversationId': conversationId};
      var response = await _apiWrapper.put(
        IsmChatAPI.readIndicator,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Read message $e', st);
    }
  }

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

  Future<void> getChatConversationsUnreadCountBulk({
    required List<String> userIds,
    bool isLoading = false,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.conversationUnreadCountBulk}?includeConversationStatusMessagesInUnreadMessagesCount=false&hidden=false&userIds=${userIds.join(',')}',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Get Conversations unread error $e', st);
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

  Future<List<IsmChatConversationModel>?> getChatConversationApi({
    required int skip,
    required int limit,
    required String searchTag,
    required bool includeConversationStatusMessagesInUnreadMessagesCount,
  }) async {
    try {
      String? url;
      if (searchTag.isNotEmpty) {
        url =
            '${IsmChatAPI.getChatConversations}?searchTag=$searchTag&skip=$skip&limit=$limit';
      } else {
        url =
            '${IsmChatAPI.getChatConversations}?includeMembers=true&includeConversationStatusMessagesInUnreadMessagesCount=$includeConversationStatusMessagesInUnreadMessagesCount&skip=$skip&limit=$limit';
      }
      final response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      final data = jsonDecode(response.data);

      final listData = (data['conversations'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(IsmChatConversationModel.fromMap)
          .toList();
      listData.sort(
        (a, b) => (a.lastMessageDetails?.sentAt ?? 0)
            .compareTo(b.lastMessageDetails?.sentAt ?? 0),
      );
      return listData;
    } catch (e, st) {
      IsmChatLog.error('GetChatConversations error $e', st);
      return null;
    }
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
    try {
      var response = await _apiWrapper.get(
          '${IsmChatAPI.userchatMessages}?senderIdsExclusive=$senderIdsExclusive&deliveredToMe=$deliveredToMe&senderIds=${senderIds?.join(',')}&limit=$limit&skip=$skip&sort=$sort',
          headers: IsmChatUtility.tokenCommonHeader(),
          showLoader: isLoading);

      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);
      return (data['messages'] as List)
          .map((e) => IsmChatMessageModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('Get user messages $e, $st');
      return null;
    }
  }

  Future<void> pingMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var payload = {'messageId': messageId, 'conversationId': conversationId};
      var response = await _apiWrapper.put(
        IsmChatAPI.deliveredIndicator,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Delivery Message error $e', st);
    }
  }
}
