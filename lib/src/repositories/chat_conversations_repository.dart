import 'dart:async';
import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationsRepository {
  final _apiWrapper = IsmChatApiWrapper();

  Future<IsmChatUserListModel?> getUserList({
    String? pageToken,
    int? count,
  }) async {
    try {
      String? url;
      if (pageToken?.isNotEmpty ?? false) {
        url = '${IsmChatAPI.allUsers}?pageToken=$pageToken&count=$count';
      } else {
        url = IsmChatAPI.allUsers;
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.commonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      var user = IsmChatUserListModel.fromMap(data);
      return user;
    } catch (e, st) {
      IsmChatLog.error('GetUserList error $e', st);
      return null;
    }
  }

  Future<IsmChatUserListModel?> getNonBlockUserList({
    int sort = 1,
    int skip = 0,
    int limit = 20,
    String searchTag = '',
    bool isLoading = false,
  }) async {
    try {
      String? url;
      if (searchTag.isNotEmpty) {
        url =
            '${IsmChatAPI.nonBlockUser}?sort=$sort&skip=$skip&limit=$limit&searchTag=$searchTag';
      } else {
        url = '${IsmChatAPI.nonBlockUser}?sort=$sort&skip=$skip&limit=$limit';
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      var user = IsmChatUserListModel.fromMap(data);

      return user;
    } catch (e, st) {
      IsmChatLog.error('Get non block UserList error $e', st);
      return null;
    }
  }

  Future<List<IsmChatConversationModel>?> getChatConversations({
    required int skip,
    required int limit,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async {
    try {
      String? url;
      if (searchTag != null && searchTag.isNotEmpty) {
        url =
            '${IsmChatAPI.getChatConversations}?searchTag=$searchTag&skip=$skip&limit=$limit';
      } else {
        url =
            '${IsmChatAPI.getChatConversations}?includeConversationStatusMessagesInUnreadMessagesCount=$includeConversationStatusMessagesInUnreadMessagesCount&skip=$skip&limit=$limit';
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);

      var listData = (data['conversations'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) {
        final c = IsmChatConversationModel.fromMap(e);
        final result = IsmChatConfig.conversationParser?.call(c, e);
        final conversation = result?.$1 ?? c;
        final updateServer = result?.$2 ?? false;
        if (updateServer) {
          if (conversation.metaData != null) {
            unawaited(updateConversation(
              conversationId: conversation.conversationId ?? '',
              metaData: conversation.metaData!,
            ));
          }
          // call update API unawaited
        }
        return conversation;
      }).toList();
      listData.sort(
        (a, b) => a.lastMessageDetails!.sentAt
            .compareTo(b.lastMessageDetails!.sentAt),
      );
      listData.removeWhere((e) =>
          e.opponentDetails?.userId.isEmpty == true &&
          e.opponentDetails?.userName.isEmpty == true &&
          e.isGroup == false);
      return listData;
    } catch (e, st) {
      IsmChatLog.error('GetChatConversations error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> unblockUser(
      {required String opponentId, required bool isLoading}) async {
    try {
      final payload = {'opponentId': opponentId};
      var response = await _apiWrapper.post(
        IsmChatAPI.unblockUser,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error(' UnBlock user error $e', st);
      return null;
    }
  }

  Future<UserDetails?> getUserData({bool isLoading = false}) async {
    try {
      var response = await _apiWrapper.get(
        IsmChatAPI.userDetails,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      var data = jsonDecode(response.data) as Map<String, dynamic>;

      var user = UserDetails.fromMap(data);

      return user;
    } catch (e, st) {
      IsmChatLog.error('GetUserDataError $e', st);
      return null;
    }
  }

  Future<UserDetails?> updateUserData({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    Map<String, dynamic>? metaData,
    bool isloading = false,
  }) async {
    try {
      var requestData = {
        if (userProfileImageUrl != null)
          'userProfileImageUrl': userProfileImageUrl,
        if (userName != null) 'userName': userName,
        if (userIdentifier != null) 'userIdentifier': userIdentifier,
        if (metaData != null) 'metaData': metaData,
      };
      var response = await _apiWrapper.patch(
        IsmChatAPI.updateUsers,
        payload: requestData,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      var user = UserDetails.fromMap(data);
      return user;
    } catch (e, st) {
      IsmChatLog.error('updateUserDataError $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> deleteChat(String conversationId) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.chatConversationDelete}?conversationId=$conversationId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Delete chat error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> clearAllMessages({
    required String conversationId,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.chatConversationClear}?conversationId=$conversationId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Clear chat error $e', st);
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

  Future<IsmChatUserListModel?> getBlockUser(
      {required int? skip, required int limit, required bool isLoading}) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.blockUser}?skip=$skip&limit=$limit',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );

      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;

      var user = IsmChatUserListModel.fromMap(data);
      return user;
    } catch (e, st) {
      IsmChatLog.error('GetChat Block users error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool isLoading = false,
  }) async {
    try {
      var response = await _apiWrapper.patch(
        IsmChatAPI.conversationDetails,
        payload: {
          'conversationId': conversationId,
          'metaData': metaData.toMap()
        },
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );

      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<IsmChatResponseModel?> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async {
    try {
      var payload = {
        'conversationId': conversationId,
      };
      var event = events.toMap();
      event
          .addAll(payload.map((key, value) => MapEntry(key, value as dynamic)));
      var response = await _apiWrapper.patch(
        IsmChatAPI.conversationSetting,
        payload: event,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );

      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<IsmChatResponseModel?> sendForwardMessage(
      {required List<String> userIds,
      required bool showInConversation,
      required int messageType,
      required bool encrypted,
      required String deviceId,
      required String body,
      required String notificationBody,
      required String notificationTitle,
      List<String>? searchableTags,
      IsmChatMetaData? metaData,
      Map<String, dynamic>? events,
      String? customType,
      List<Map<String, dynamic>>? attachments,
      bool isLoading = false}) async {
    try {
      final payload = {
        'userIds': userIds,
        'showInConversation': showInConversation,
        'messageType': messageType,
        'encrypted': encrypted,
        'deviceId': deviceId,
        'body': body,
        'metaData': metaData?.toMap(),
        'events': events,
        'customType': customType,
        'attachments': attachments,
        'notificationBody': notificationBody,
        'notificationTitle': notificationTitle,
        'searchableTags': searchableTags,
      }.removeNullValues();

      var response = await _apiWrapper.post(
        IsmChatAPI.sendForwardMessage,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      return response;
    } catch (e, st) {
      IsmChatLog.error('Send Forward Message $e', st);
      return null;
    }
  }

  Future<List<IsmChatConversationModel>?> getPublicAndOpenConversation({
    required int conversationType,
    String? searchTag,
    int sort = 1,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      String? url;
      if (searchTag?.isNotEmpty ?? false) {
        url =
            '${IsmChatAPI.getPublicAndOpenConversation}?conversationType=$conversationType&includeMembers=true&searchTag=$searchTag&sort=$sort&skip=$skip&limit=$limit';
      } else {
        url =
            '${IsmChatAPI.getPublicAndOpenConversation}?conversationType=$conversationType&includeMembers=true&sort=$sort&skip=$skip&limit=$limit';
      }

      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);

      var listData = (data['conversations'] as List)
          .map((e) =>
              IsmChatConversationModel.fromMap(e as Map<String, dynamic>))
          .toList();
      return listData;
    } catch (e, st) {
      IsmChatLog.error('GetUserList error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> joinConversation(
      {required String conversationId, bool isLoading = false}) async {
    try {
      var payload = {'conversationId': conversationId};
      var response = await _apiWrapper.put(IsmChatAPI.joinConversation,
          payload: payload,
          headers: IsmChatUtility.tokenCommonHeader(),
          showLoader: isLoading);
      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Join conversation error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> joinObserver({
    required String conversationId,
    bool isLoading = false,
  }) async {
    try {
      var payload = {'conversationId': conversationId};
      var response = await _apiWrapper.put(
        IsmChatAPI.joinObserver,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Join Observer error $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> leaveObserver(
      {required String conversationId, bool isLoading = false}) async {
    try {
      var payload = {'conversationId': conversationId};
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.leaveObserver}?conversationId=$conversationId',
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Leave Observer error $e', st);
      return null;
    }
  }

  Future<List<UserDetails>?> getObservationUser(
      {required String conversationId,
      int skip = 0,
      int limit = 20,
      bool isLoading = false,
      String? searchText}) async {
    try {
      String? url;
      if (searchText != null || searchText?.isNotEmpty == true) {
        url =
            '${IsmChatAPI.getObserver}?conversationId=$conversationId&searchTag=$searchText&sort=-1&limit=$limit&skip=$skip';
      } else {
        url =
            '${IsmChatAPI.getObserver}?conversationId=$conversationId&limit=$limit&skip=$skip';
      }
      var response = await _apiWrapper.get(url,
          headers: IsmChatUtility.tokenCommonHeader(), showLoader: isLoading);

      if (response.hasError) {
        return null;
      }

      var data = jsonDecode(response.data) as Map<String, dynamic>;

      return (data['conversationObservers'] as List)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('Get observer user $e, $st');
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

  /// to get the contacts..
  Future<ContactSync?> getContacts({
    required bool isLoading,
    required bool isRegisteredUser,
    required int skip,
    required int limit,
    required String searchTag,
  }) async {
    try {
      final res = await _apiWrapper.get(
        '${IsmChatAPI.contactGet}?q=$searchTag&skip=$skip&limit=$limit&isRegisteredUser=$isRegisteredUser',
        headers:
            IsmChatUtility.accessTokenCommonHeader(isDefaultContentType: true),
        showLoader: isLoading,
      );
      if (res.hasError) {
        return null;
      }
      return contactSyncFromJson(res.data);
    } catch (e, st) {
      IsmChatLog.error('Get user messages $e, $st');
      return null;
    }
  }

  /// For adding the contact..
  Future<IsmChatResponseModel?> addContact({
    required bool isLoading,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _apiWrapper.post(
        IsmChatAPI.contactSyncPost,
        payload: payload,
        headers:
            IsmChatUtility.accessTokenCommonHeader(isDefaultContentType: true),
        showLoader: isLoading,
      );
      if (res.hasError) {
        return null;
      }
      return res;
    } catch (e, st) {
      IsmChatLog.error('Get user messages $e, $st');
      return null;
    }
  }
}
