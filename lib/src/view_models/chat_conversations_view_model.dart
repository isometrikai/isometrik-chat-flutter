import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationsViewModel {
  IsmChatConversationsViewModel(this._repository);

  final IsmChatConversationsRepository _repository;

  Future<List<IsmChatConversationModel>> getChatConversations({
    int skip = 0,
    int chatLimit = 20,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async {
    var conversations = await _repository.getChatConversations(
      skip: skip,
      limit: chatLimit,
      searchTag: searchTag ?? '',
      includeConversationStatusMessagesInUnreadMessagesCount:
          includeConversationStatusMessagesInUnreadMessagesCount,
    );

    if (conversations == null || conversations.isEmpty) {
      return [];
    }
    if (searchTag == null) {
      final dbConversations =
          await IsmChatConfig.dbWrapper?.getAllConversations() ?? [];

      for (var conversation in conversations) {
        IsmChatConversationModel? dbConversation;
        if (dbConversations.isNotEmpty) {
          dbConversation = dbConversations.firstWhere(
            (e) => e.conversationId == conversation.conversationId,
            orElse: () => IsmChatConversationModel(messages: {}),
          );
        }
        conversation = conversation.copyWith(
          messages: dbConversation?.messages,
          opponentDetails: conversation.opponentDetails,
          lastMessageDetails: conversation.lastMessageDetails,
          config: conversation.config,
          metaData: conversation.metaData,
          customType: conversation.customType,
          conversationImageUrl: conversation.conversationImageUrl,
          conversationTitle: conversation.conversationTitle,
          conversationType: conversation.conversationType,
          members: conversation.members,
          membersCount: conversation.membersCount,
        );

        await IsmChatConfig.dbWrapper
            ?.createAndUpdateConversation(conversation);
      }
    }
    return conversations;
  }

  Future<UserDetails?> getUserData({bool isLoading = false}) async =>
      await _repository.getUserData(isLoading: isLoading);

  Future<UserDetails?> updateUserData({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    Map<String, dynamic>? metaData,
    bool isloading = false,
  }) async =>
      await _repository.updateUserData(
        userIdentifier: userIdentifier,
        userName: userName,
        userProfileImageUrl: userProfileImageUrl,
        metaData: metaData,
        isloading: isloading,
      );

  Future<IsmChatUserListModel?> getUserList({
    String? pageToken,
    int? count,
    String? opponentId,
  }) async {
    final response =
        await _repository.getUserList(count: count, pageToken: pageToken);

    if (response == null) {
      return null;
    }
    final data = [...response.users];
    data.removeWhere(
        (e) => e.userId == IsmChatConfig.communicationConfig.userConfig.userId);

    if (opponentId != null) {
      data.removeWhere((e) => e.userId == opponentId);
    }
    return IsmChatUserListModel(users: data, pageToken: response.pageToken);
  }

  Future<IsmChatUserListModel?> getNonBlockUserList({
    int sort = 1,
    int skip = 0,
    int limit = 20,
    String searchTag = '',
    bool isLoading = false,
  }) async {
    final response = await _repository.getNonBlockUserList(
      sort: sort,
      skip: skip,
      limit: limit,
      searchTag: searchTag,
      isLoading: isLoading,
    );

    if (response == null) {
      return null;
    }
    final data = [...response.users];
    data.removeWhere(
        (e) => e.userId == IsmChatConfig.communicationConfig.userConfig.userId);
    return IsmChatUserListModel(users: data, pageToken: response.pageToken);
  }

  Future<IsmChatResponseModel?> deleteChat(String conversationId) async =>
      await _repository.deleteChat(conversationId);

  Future<void> clearAllMessages(String conversationId,
      {bool fromServer = true}) async {
    final response = await _repository.clearAllMessages(
      conversationId: conversationId,
    );
    if (!response!.hasError) {
      await IsmChatConfig.dbWrapper!
          .clearAllMessage(conversationId: conversationId);
      await IsmChatUtility.conversationController.getChatConversations();
    }
  }

  Future<IsmChatResponseModel?> unblockUser({
    required String opponentId,
    required bool isLoading,
  }) async {
    final response = await _repository.unblockUser(
      opponentId: opponentId,
      isLoading: isLoading,
    );
    return response;
  }

  Future<IsmChatUserListModel?> getBlockUser({
    required int? skip,
    required int limit,
    required bool isLoading,
  }) async =>
      await _repository.getBlockUser(
        skip: skip,
        limit: limit,
        isLoading: isLoading,
      );

  Future<IsmChatResponseModel?> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool isLoading = false,
  }) async =>
      await _repository.updateConversation(
        conversationId: conversationId,
        metaData: metaData,
        isLoading: isLoading,
      );

  Future<IsmChatResponseModel?> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async =>
      await _repository.updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  Future<IsmChatResponseModel?> sendForwardMessage({
    required List<String> userIds,
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
    bool isLoading = false,
  }) async =>
      await _repository.sendForwardMessage(
        userIds: userIds,
        showInConversation: showInConversation,
        messageType: messageType,
        encrypted: encrypted,
        deviceId: deviceId,
        body: body,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        attachments: attachments,
        customType: customType,
        events: events,
        metaData: metaData,
        searchableTags: searchableTags,
        isLoading: isLoading,
      );

  Future<List<IsmChatConversationModel>?> getPublicAndOpenConversation({
    required int conversationType,
    String? searchTag,
    int sort = 1,
    int skip = 0,
    int limit = 20,
  }) async =>
      _repository.getPublicAndOpenConversation(
          limit: limit,
          searchTag: searchTag,
          skip: skip,
          sort: sort,
          conversationType: conversationType);

  Future<IsmChatResponseModel?> joinConversation(
          {required String conversationId, bool isLoading = false}) async =>
      _repository.joinConversation(
          conversationId: conversationId, isLoading: isLoading);
  Future<IsmChatResponseModel?> joinObserver(
          {required String conversationId, bool isLoading = false}) async =>
      _repository.joinObserver(
          conversationId: conversationId, isLoading: isLoading);

  Future<IsmChatResponseModel?> leaveObserver(
          {required String conversationId, bool isLoading = false}) async =>
      _repository.leaveObserver(
          conversationId: conversationId, isLoading: isLoading);

  Future<List<UserDetails>?> getObservationUser(
          {required String conversationId,
          int skip = 0,
          int limit = 20,
          bool isLoading = false,
          String? searchText}) async =>
      _repository.getObservationUser(
        conversationId: conversationId,
        isLoading: isLoading,
        skip: skip,
        limit: limit,
        searchText: searchText,
      );

  /// upload the contacts
  Future<IsmChatResponseModel?> addContact({
    required bool isLoading,
    required Map<String, dynamic> payload,
  }) async =>
      await _repository.addContact(
        isLoading: isLoading,
        payload: payload,
      );

  /// to get the contacts..
  Future<ContactSync?> getContacts({
    required bool isLoading,
    required bool isRegisteredUser,
    required int skip,
    required int limit,
    required String searchTag,
  }) async =>
      await _repository.getContacts(
          isLoading: isLoading,
          isRegisteredUser: isRegisteredUser,
          skip: skip,
          limit: limit,
          searchTag: searchTag);

  Future<IsmChatResponseModel?> updateMyStatusToAllUsers({
    required List<String> userIds,
    required Map<String, dynamic> payload,
    bool isLoading = false,
  }) async =>
      await _repository.updateMyStatusToAllUsers(
        userIds: userIds,
        payload: payload,
        isLoading: isLoading,
      );
}
