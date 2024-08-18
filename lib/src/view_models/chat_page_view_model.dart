import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageViewModel {
  IsmChatPageViewModel(this._repository);

  final IsmChatPageRepository _repository;

  Future<List<IsmChatMessageModel>> getChatMessages({
    required String conversationId,
    required int lastMessageTimestamp,
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
        ].contains(e.action));
    if (searchText == null || searchText.isEmpty) {
      final controller = Get.find<IsmChatPageController>();
      if (controller.messages.isNotEmpty) {
        messages.removeWhere(
            (e) => e.messageId == controller.messages.last.messageId);
      }
      if (!isBroadcast) {
        var conversation = await IsmChatConfig.dbWrapper!
            .getConversation(conversationId: conversationId);

        if (conversation != null) {
          conversation.messages?.addAll(messages);
          await IsmChatConfig.dbWrapper!
              .saveConversation(conversation: conversation);
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
    int lastMessageTimestamp = 0,
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
      final controller = Get.find<IsmChatPageController>();
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
    var response = await _repository.blockUser(
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
  Future<List<UserDetails>?> getEligibleMembers(
          {required String conversationId,
          bool isLoading = false,
          int limit = 20,
          int skip = 0}) async =>
      await _repository.getEligibleMembers(
          conversationId: conversationId,
          isLoading: isLoading,
          limit: limit,
          skip: skip);

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

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async =>
      await _repository.readSingleMessage(
        conversationId: conversationId,
        messageId: messageId,
      );

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
    List<IsmChatMessageModel> messages,
  ) async {
    var conversationId = messages.first.conversationId!;
    messages.removeWhere((e) => e.messageId == '');
    if (messages.isEmpty) {
      return;
    }
    var myMessages = messages
        .where((m) =>
            m.sentByMe &&
            m.customType != IsmChatCustomMessageType.deletedForEveryone)
        .toList();
    if (myMessages.isNotEmpty) {
      var response = await _repository.deleteMessageForMe(
        conversationId: conversationId,
        messageIds: myMessages.map((e) => e.messageId).join(','),
      );
      if (response == null || response.hasError) {
        return;
      }
    }

    var allMessages = await IsmChatConfig.dbWrapper!.getMessage(conversationId);
    if (allMessages == null) {
      return;
    }

    for (var x in messages) {
      allMessages.removeWhere(
        (e) {
          if (e.messageId == x.messageId &&
              e.customType == IsmChatCustomMessageType.deletedForEveryone) {
            return true;
          }
          if (e.messageId == x.messageId &&
              e.customType != IsmChatCustomMessageType.deletedForEveryone) {
            return true;
          }
          return false;
        },
      );
    }
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);

      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
    }

    await Get.find<IsmChatPageController>().getMessagesFromDB(conversationId);
  }

  Future<void> deleteMessageForEveryone(
    List<IsmChatMessageModel> messages,
  ) async {
    messages.removeWhere((e) => e.messageId == '');
    if (messages.isEmpty) {
      return;
    }
    var conversationId = messages.first.conversationId!;
    var response = await _repository.deleteMessageForEveryone(
      conversationId: conversationId,
      messages: messages.map((e) => e.messageId).join(','),
    );
    if (response == null || response.hasError) {
      return;
    }

    var allMessages = await IsmChatConfig.dbWrapper!.getMessage(conversationId);
    if (allMessages == null) {
      return;
    }

    for (var x in messages) {
      var messageIndex =
          allMessages.indexWhere((e) => e.messageId == x.messageId);
      if (messageIndex != -1) {
        allMessages[messageIndex].customType =
            IsmChatCustomMessageType.deletedForEveryone;
        allMessages[messageIndex].reactions = [];
      }

      // allMessages.removeWhere((e) => e.messageId == x.messageId);
    }

    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
    }
    await Get.find<IsmChatPageController>().getMessagesFromDB(conversationId);
  }

  Future<void> clearAllMessages({
    required String conversationId,
    bool fromServer = true,
  }) async {
    var response = await _repository.clearAllMessages(
      conversationId: conversationId,
    );
    if (!response!.hasError) {
      await IsmChatConfig.dbWrapper!
          .clearAllMessage(conversationId: conversationId);
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
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
    var indexedMap = <String, int>{};
    var i = 0;
    for (var x in messages.reversed) {
      if (![
        IsmChatCustomMessageType.date,
        IsmChatCustomMessageType.block,
        IsmChatCustomMessageType.unblock,
        IsmChatCustomMessageType.conversationCreated,
      ].contains(x.customType)) {
        indexedMap[x.messageId!] = i;
      }
      i++;
    }
    return indexedMap;
  }

  Future<IsmChatResponseModel?> addReacton({required Reaction reaction}) async {
    var response = await _repository.addReacton(reaction: reaction);

    if (response == null || response.hasError) {
      return null;
    }

    var allMessages =
        await IsmChatConfig.dbWrapper!.getMessage(reaction.conversationId);
    if (allMessages == null) {
      return null;
    }

    var message =
        allMessages.where((e) => e.messageId == reaction.messageId).first;

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

    var messageIndex =
        allMessages.indexWhere((e) => e.messageId == reaction.messageId);

    allMessages[messageIndex] = message;
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: reaction.conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
    }
    var controller = Get.find<IsmChatPageController>();
    controller.didReactedLast = true;
    await controller.getMessagesFromDB(reaction.conversationId);
    return response;
  }

  Future<IsmChatResponseModel?> deleteReacton(
      {required Reaction reaction}) async {
    var response = await _repository.deleteReacton(reaction: reaction);
    if (response == null || response.hasError) {
      return null;
    }

    var allMessages =
        await IsmChatConfig.dbWrapper!.getMessage(reaction.conversationId);
    if (allMessages == null) {
      return null;
    }

    var message =
        allMessages.where((e) => e.messageId == reaction.messageId).first;
    var reactionMap = message.reactions;
    var isEmoji = false;
    for (var x in reactionMap ?? <MessageReactionModel>[]) {
      if (x.emojiKey == reaction.reactionType.value && x.userIds.length > 1) {
        x.userIds.remove(IsmChatConfig.communicationConfig.userConfig.userId);
        x.userIds.toSet().toList();
        isEmoji = true;
      }
    }
    if (isEmoji == false) {
      reactionMap
          ?.removeWhere((e) => e.emojiKey == reaction.reactionType.value);
    }

    message.reactions = reactionMap;
    var messageIndex =
        allMessages.indexWhere((e) => e.messageId == reaction.messageId);

    allMessages[messageIndex] = message;

    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: reaction.conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
    }
    var controller = Get.find<IsmChatPageController>();
    controller.didReactedLast = true;
    await controller.getMessagesFromDB(reaction.conversationId);
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
}
