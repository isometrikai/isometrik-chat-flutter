import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// View model for the chat page controller.
///
/// This view model provides business logic and coordinates between the
/// controller and repository layers. It handles data transformation and
/// business rules for message operations.
///
/// **Responsibilities:**
/// - Message retrieval and processing
/// - Message filtering (removes action messages)
/// - Message deduplication
/// - Database integration
/// - Business logic for message operations
///
/// **Architecture:**
/// - Part of MVVM pattern (Model-View-ViewModel)
/// - Coordinates between Controller and Repository
/// - Handles data transformation
///
/// **Usage:**
/// ```dart
/// final viewModel = IsmChatPageViewModel(repository);
/// final messages = await viewModel.getChatMessages(
///   conversationId: 'conv123',
///   lastMessageTimestamp: 0,
/// );
/// ```
///
/// **See Also:**
/// - [IsmChatPageController] - Controller that uses this view model
/// - [IsmChatPageRepository] - Repository for data access
/// - [ARCHITECTURE.md] - Architecture documentation
class IsmChatPageViewModel {
  /// Creates a new instance of [IsmChatPageViewModel].
  ///
  /// **Parameters:**
  /// - `_repository`: The repository instance for data access.
  IsmChatPageViewModel(this._repository);

  /// The repository instance for message operations.
  ///
  /// This repository provides access to the API and database for retrieving
  /// and managing messages.
  final IsmChatPageRepository _repository;

  Future<List<IsmChatMessageModel>> getChatMessages({
    required String conversationId,
    int? lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
    bool isBroadcast = false,
  }) async {
    var messages = await _repository.getChatMessages(
      conversationId: conversationId,
      lastMessageTimestamp: lastMessageTimestamp,
      limit: limit,
      skip: skip,
      searchText: searchText,
      isLoading: isLoading,
    );

    if (messages == null) {
      return [];
    }
    messages.removeWhere((e) => [
          IsmChatActionEvents.clearConversation.name,
          IsmChatActionEvents.deleteConversationLocally.name,
          IsmChatActionEvents.reactionAdd.name,
          IsmChatActionEvents.reactionRemove.name,
          IsmChatActionEvents.conversationDetailsUpdated.name,
          IsmChatActionEvents.messageDetailsUpdated.name,
        ].contains(e.action));
    // Block/unblock banners are managed locally (Option A), not merged from API.
    messages.removeWhere(IsmChatBlockUnblockCoordinator.isBannerMessage);
    final conversation =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    messages.removeWhere((m) => !m.isVisibleInGroupChat(conversation));
    if (searchText == null || searchText.isEmpty) {
      final controller = IsmChatUtility.chatPageController;
      if (controller.messages.isNotEmpty) {
        messages.removeWhere(
            (e) => e.messageId == controller.messages.last.messageId);
      }

      if (!isBroadcast) {
        if (conversation != null) {
          final data = <String, IsmChatMessageModel>{};
          for (var message in messages) {
            final entriesData = {message.key: message};
            data.addEntries(entriesData.entries);
          }
          conversation.messages?.addAll(data);
          await IsmChatConfig.dbWrapper
              ?.saveConversation(conversation: conversation);
        }
      } else {
        messages = messages;
      }
    } else {
      messages = messages;
    }

    return messages;
  }

  Future<List<IsmChatMessageModel>> getBroadcastMessages({
    required String groupcastId,
    int? lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    int sort = -1,
    bool isLoading = false,
    List<String>? ids,
    String? searchText,
    String? messageTypes,
    String? customTypes,
    String? attachmentTypes,
    String? showInConversation,
    String? parentMessageId,
    bool isBroadcast = false,
  }) async {
    var messages = await _repository.getBroadcastMessages(
      groupcastId: groupcastId,
      hideNewConversationsForSender: false,
      sendPushForNewConversationCreated: true,
      notifyOnCompletion: true,
      executionFinished: false,
      attachmentTypes: attachmentTypes,
      customTypes: customTypes,
      ids: ids,
      isLoading: isLoading,
      lastMessageTimestamp: lastMessageTimestamp,
      limit: limit,
      messageTypes: messageTypes,
      parentMessageId: parentMessageId,
      searchText: searchText,
      showInConversation: showInConversation,
      skip: skip,
      sort: sort,
    );

    if (messages == null) {
      return [];
    }
    messages.removeWhere((e) => [
          IsmChatActionEvents.clearConversation.name,
          IsmChatActionEvents.deleteConversationLocally.name,
          IsmChatActionEvents.reactionAdd.name,
          IsmChatActionEvents.reactionRemove.name,
          IsmChatActionEvents.conversationDetailsUpdated.name,
        ].contains(e.action));
    if (searchText == null || searchText.isEmpty) {
      final controller = IsmChatUtility.chatPageController;
      if (controller.messages.isNotEmpty) {
        messages.removeWhere(
            (e) => e.messageId == controller.messages.last.messageId);
      }
      messages = messages;
    } else {
      messages = messages;
    }
    return messages;
  }

  Future<void> readMessage({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.readMessage(
        conversationId: conversationId,
        messageId: messageId,
      );

  Future<void> notifyTyping({required String conversationId}) async =>
      await _repository.notifyTyping(
        conversationId: conversationId,
      );

  Future<ModelWrapper> getConverstaionDetails(
          {required String conversationId,
          String? ids,
          bool? includeMembers,
          int? membersSkip,
          int? membersLimit,
          bool? isLoading}) async =>
      await _repository.getConverstaionDetails(
          conversationId: conversationId,
          includeMembers: includeMembers,
          isLoading: isLoading);

  Future<bool> blockUser(
      {required String opponentId,
      required String conversationId,
      bool isLoading = false}) async {
    final response = await _repository.blockUser(
        opponentId: opponentId, isLoading: isLoading);

    if (response?.hasError ?? true) {
      return false;
    }

    return true;
  }

  /// Add members to a conversation
  Future<IsmChatResponseModel?> addMembers(
          {required List<String> memberList,
          required String conversationId,
          bool isLoading = false}) async =>
      await _repository.addMembers(
          memberList: memberList,
          conversationId: conversationId,
          isLoading: isLoading);

  /// change group title
  Future<IsmChatResponseModel?> changeGroupTitle({
    required String conversationTitle,
    required String conversationId,
    required bool isLoading,
  }) async =>
      await _repository.changeGroupTitle(
        conversationTitle: conversationTitle,
        conversationId: conversationId,
        isLoading: isLoading,
      );

  /// change group title
  Future<IsmChatResponseModel?> changeGroupProfile({
    required String conversationImageUrl,
    required String conversationId,
    required bool isLoading,
  }) async =>
      await _repository.changeGroupProfile(
          conversationImageUrl: conversationImageUrl,
          conversationId: conversationId,
          isLoading: isLoading);

  /// Remove members from conversation
  Future<IsmChatResponseModel?> removeMember({
    required String conversationId,
    required String userId,
    bool isLoading = false,
  }) async =>
      await _repository.removeMembers(conversationId, userId, isLoading);

  /// Get eligible members to add to a conversation
  Future<List<UserDetails>?> getEligibleMembers({
    required String conversationId,
    bool isLoading = false,
    int limit = 20,
    int skip = 0,
    String? searchTag,
  }) async =>
      await _repository.getEligibleMembers(
        conversationId: conversationId,
        isLoading: isLoading,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );

  /// Leave conversation
  Future<IsmChatResponseModel?> leaveConversation(
          String conversationId, bool isLoading) async =>
      await _repository.leaveConversation(conversationId, isLoading);

  /// make admin api
  Future<IsmChatResponseModel?> makeAdmin({
    required String memberId,
    required String conversationId,
    bool isLoading = false,
  }) async =>
      await _repository.makeAdmin(memberId, conversationId, isLoading);

  /// Remove member as admin from conversation
  Future<IsmChatResponseModel?> removeAdmin({
    required String conversationId,
    required String memberId,
    bool isLoading = false,
  }) async =>
      await _repository.removeAdmin(conversationId, memberId, isLoading);

  Future<List<UserDetails>?> getMessageDeliverTime({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.getMessageDeliverTime(
        conversationId: conversationId,
        messageId: messageId,
      );

  Future<List<UserDetails>?> getMessageReadTime({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.getMessageReadTime(
        conversationId: conversationId,
        messageId: messageId,
      );

  Future<void> deleteMessageForMe(
    IsmChatMessages messages,
  ) async {
    final conversationId = messages.values.first.conversationId ?? '';
    messages.removeWhere((key, value) => value.messageId == '');
    if (messages.isEmpty) {
      return;
    }
    final myMessages = messages.entries
        .where((m) =>
            m.value.sentByMe &&
            m.value.customType != IsmChatCustomMessageType.deletedForEveryone)
        .toList();
    if (myMessages.isNotEmpty) {
      var response = await _repository.deleteMessageForMe(
        conversationId: conversationId,
        messageIds: myMessages.map((e) => e.value.messageId).join(','),
      );
      if (response == null || response.hasError) {
        return;
      }
    }

    var conversation =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);

    final allMessages = conversation?.messages;
    if (allMessages == null) {
      return;
    }

    for (var x in messages.values) {
      allMessages.removeWhere(
        (key, value) {
          if (value.messageId == x.messageId &&
              value.customType == IsmChatCustomMessageType.deletedForEveryone) {
            return true;
          }
          if (value.messageId == x.messageId &&
              value.customType != IsmChatCustomMessageType.deletedForEveryone) {
            return true;
          }

          return false;
        },
      );
    }

    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
    }

    await IsmChatUtility.chatPageController.getMessagesFromDB(conversationId);
  }

  Future<void> deleteMessageForEveryone(
    IsmChatMessages messages,
  ) async {
    messages.removeWhere(
      (key, value) => (value.messageId ?? '').trim().isEmpty,
    );
    if (messages.isEmpty) {
      return;
    }
    final conversationId = messages.values.first.conversationId ?? '';
    final messageIds = messages.values
        .map((e) => (e.messageId ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (messageIds.isEmpty) {
      return;
    }

    // Delete each message ID individually for compatibility with servers
    // that only honor the first ID from a comma-separated query param.
    for (final messageId in messageIds) {
      final response = await _repository.deleteMessageForEveryone(
        conversationId: conversationId,
        messages: messageId,
      );
      if (response == null || response.hasError) {
        return;
      }
    }
    var conversation =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    final allMessages = conversation?.messages;
    if (allMessages == null) {
      return;
    }

    for (var message in messages.entries) {
      final gotMessage =
          allMessages.values.toList().cast<IsmChatMessageModel?>().firstWhere(
                (e) => e?.messageId == message.value.messageId,
                orElse: () => null,
              );
      if (gotMessage != null) {
        allMessages[gotMessage.key] = gotMessage.copyWith(
          customType: IsmChatCustomMessageType.deletedForEveryone,
          reactions: [],
        );
      }
    }

    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
    }
    await IsmChatUtility.chatPageController.getMessagesFromDB(conversationId);
  }

  Future<bool> clearAllMessages({
    required String conversationId,
    bool fromServer = true,
  }) async {
    if (fromServer) {
      final response = await _repository.clearAllMessages(
        conversationId: conversationId,
      );
      if (response?.hasError != false) {
        return false;
      }
    }
    await IsmChatConfig.dbWrapper
        ?.clearAllMessage(conversationId: conversationId);
    await IsmChatUtility.conversationController.getChatConversations();
    return true;
  }

  Future<void> readAllMessages({
    required String conversationId,
    required int timestamp,
  }) async =>
      await _repository.readAllMessages(
        conversationId: conversationId,
        timestamp: timestamp,
      );

  Future<List<IsmChatPrediction>?> getLocation({
    required String latitude,
    required String longitude,
    required String searchKeyword,
  }) async =>
      await _repository.getLocation(
        latitude: latitude,
        longitude: longitude,
        query: searchKeyword,
      );

  Map<String, int> generateIndexedMessageList(
      List<IsmChatMessageModel> messages) {
    final indexedMap = <String, int>{};
    for (var i = 0; i < messages.length; i++) {
      final x = messages[messages.length - 1 - i];
      if ([
        IsmChatCustomMessageType.date,
        IsmChatCustomMessageType.block,
        IsmChatCustomMessageType.unblock,
        IsmChatCustomMessageType.conversationCreated,
      ].contains(x.customType)) {
        continue;
      }
      final id = x.messageId;
      if (id == null || id.isEmpty) {
        continue;
      }
      indexedMap[id] = i;
    }
    return indexedMap;
  }

  /// ListView is `reverse: true`, so index 0 is the newest row (including date
  /// separators). Used at tap time so quote-jump does not depend on a stale map.
  static int? reversedScrollIndexForMessageId(
    List<IsmChatMessageModel> messages, {
    required String messageId,
  }) {
    if (messageId.isEmpty || messages.isEmpty) {
      return null;
    }

    IsmChatMessageModel? target;
    for (final msg in messages) {
      if (msg.messageId == messageId) {
        target = msg;
        break;
      }
    }
    if (target == null) {
      return null;
    }

    var scrollId = messageId;
    if (target.isGridDisplayableMedia) {
      final chronological = messages
          .where((msg) => msg.customType != IsmChatCustomMessageType.date)
          .toList();
      final group = IsmChatMediaGridGrouping.collect(chronological, target);
      if (IsmChatMediaGridGrouping.shouldHide(group, target)) {
        final hostId = group.first.messageId;
        if (hostId != null && hostId.isNotEmpty) {
          scrollId = hostId;
        }
      }
    }

    for (var i = 0; i < messages.length; i++) {
      if (messages[messages.length - 1 - i].messageId == scrollId) {
        return i;
      }
    }
    return null;
  }

  Future<IsmChatResponseModel?> addReacton({required Reaction reaction}) async {
    final response = await _repository.addReacton(reaction: reaction);

    if (response == null) {
      return null;
    }
    if (response.hasError) {
      return response;
    }
    var conversation =
        await IsmChatConfig.dbWrapper?.getConversation(reaction.conversationId);
    final allMessages = conversation?.messages;
    if (allMessages == null) {
      return null;
    }
    var message = allMessages.values.cast<IsmChatMessageModel?>().firstWhere(
          (e) => e?.messageId == reaction.messageId,
          orElse: () => null,
        );

    if (message != null) {
      var isEmoji = false;
      for (var x in message.reactions ?? <MessageReactionModel>[]) {
        if (x.emojiKey == reaction.reactionType.value) {
          x.userIds.add(IsmChatConfig.communicationConfig.userConfig.userId);
          isEmoji = true;
          break;
        }
      }
      if (isEmoji == false) {
        message.reactions ??= [];
        message.reactions?.add(
          MessageReactionModel(
            emojiKey: reaction.reactionType.value,
            userIds: [IsmChatConfig.communicationConfig.userConfig.userId],
          ),
        );
      }
      allMessages[message.key] = message;

      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }
      final controller = IsmChatUtility.chatPageController
        ..didReactedLast = true;
      await controller.getMessagesFromDB(reaction.conversationId);
    }

    return response;
  }

  Future<IsmChatResponseModel?> deleteReacton(
      {required Reaction reaction}) async {
    var response = await _repository.deleteReacton(reaction: reaction);
    if (response == null || response.hasError) {
      return null;
    }

    var conversation =
        await IsmChatConfig.dbWrapper?.getConversation(reaction.conversationId);

    final allMessages = conversation?.messages;
    if (allMessages == null) {
      return null;
    }

    final message = allMessages.values.cast<IsmChatMessageModel?>().firstWhere(
          (e) => e?.messageId == reaction.messageId,
          orElse: () => null,
        );

    if (message != null) {
      var reactionMap = message.reactions ?? [];
      var isEmoji = false;
      for (var x in reactionMap) {
        if (x.emojiKey == reaction.reactionType.value && x.userIds.length > 1) {
          x.userIds.remove(IsmChatConfig.communicationConfig.userConfig.userId);
          x.userIds.toSet().toList();
          isEmoji = true;
        }
      }
      if (isEmoji == false) {
        reactionMap
            .removeWhere((e) => e.emojiKey == reaction.reactionType.value);
      }
      message.reactions = reactionMap;
      allMessages[message.key] = message;

      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);
        await IsmChatConfig.dbWrapper!
            .saveConversation(conversation: conversation);
      }
      final controller = IsmChatUtility.chatPageController
        ..didReactedLast = true;
      await controller.getMessagesFromDB(reaction.conversationId);
    }

    return response;
  }

  Future<List<UserDetails>?> getReacton({required Reaction reaction}) async =>
      await _repository.getReacton(reaction: reaction);

  Future<IsmChatResponseModel?> sendBroadcastMessage(
          {required bool showInConversation,
          required bool sendPushForNewConversationCreated,
          required bool notifyOnCompletion,
          required bool hideNewConversationsForSender,
          required String groupcastId,
          required int messageType,
          required bool encrypted,
          required String deviceId,
          required String body,
          required String notificationBody,
          required String notificationTitle,
          List<String>? searchableTags,
          String? parentMessageId,
          IsmChatMetaData? metaData,
          Map<String, dynamic>? events,
          String? customType,
          List<Map<String, dynamic>>? attachments,
          List<Map<String, dynamic>>? mentionedUsers,
          bool isLoading = false}) async =>
      await _repository.sendBroadcastMessage(
        showInConversation: showInConversation,
        sendPushForNewConversationCreated: sendPushForNewConversationCreated,
        notifyOnCompletion: notifyOnCompletion,
        hideNewConversationsForSender: hideNewConversationsForSender,
        groupcastId: groupcastId,
        messageType: messageType,
        encrypted: encrypted,
        deviceId: deviceId,
        body: body,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        attachments: attachments,
        customType: customType,
        events: events,
        isLoading: isLoading,
        mentionedUsers: mentionedUsers,
        metaData: metaData,
        parentMessageId: parentMessageId,
        searchableTags: searchableTags,
      );

  Future<String?> createBroadcastConversation({
    bool isLoading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    required String groupcastTitle,
    required String groupcastImageUrl,
    String? customType,
    required List<String> membersId,
  }) async =>
      _repository.createBroadcastConversation(
        groupcastTitle: groupcastTitle,
        groupcastImageUrl: groupcastImageUrl,
        membersId: membersId,
        customType: customType,
        isLoading: isLoading,
        metaData: metaData,
        searchableTags: searchableTags,
      );

  Future<bool> updateMessage({
    required Map<String, dynamic> metaData,
    required bool isLoading,
    required String messageId,
    required String conversationId,
  }) async =>
      await _repository.updateMessage(
          metaData: metaData,
          isLoading: isLoading,
          messageId: messageId,
          conversationId: conversationId);

  Future<List<MessageStatusModel>?> getMessageForStatus({
    required String conversationId,
    required List<String> messageIds,
    required bool isLoading,
  }) async =>
      await _repository.getMessageForStatus(
        conversationId: conversationId,
        messageIds: messageIds,
        isLoading: isLoading,
      );
}
