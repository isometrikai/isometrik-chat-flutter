import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCommonViewModel {
  IsmChatCommonViewModel(this._repository);

  final IsmChatCommonRepository _repository;

  IsmChatConversationModel? chatPendingMessages;

  Future<int?> updatePresignedUrl({
    String? presignedUrl,
    Uint8List? bytes,
    bool isLoading = false,
  }) async {
    final respone = await _repository.updatePresignedUrl(
      presignedUrl: presignedUrl,
      bytes: bytes,
      isLoading: isLoading,
    );
    if (!(respone?.hasError == true)) {
      return respone?.errorCode;
    }
    return null;
  }

  Future<PresignedUrlModel?> getPresignedUrl({
    required bool isLoading,
    required String userIdentifier,
    required String mediaExtension,
    required Uint8List bytes,
  }) async {
    final responseGetPresigned = await _repository.getPresignedUrl(
      isLoading: isLoading,
      userIdentifier: userIdentifier,
      mediaExtension: mediaExtension,
    );
    if (responseGetPresigned != null) {
      final response = await updatePresignedUrl(
        bytes: bytes,
        isLoading: isLoading,
        presignedUrl: responseGetPresigned.presignedUrl,
      );
      if (response == 200) {
        return responseGetPresigned;
      }
    }
    return null;
  }

  Future<PresignedUrlModel?> postMediaUrl({
    required String conversationId,
    required String nameWithExtension,
    required int mediaType,
    required String mediaId,
    required bool isLoading,
    required Uint8List bytes,
    bool isUpdateThumbnail = false,
  }) async {
    final responseMedia = await _repository.postMediaUrl(
      conversationId: conversationId,
      nameWithExtension: nameWithExtension,
      mediaType: mediaType,
      mediaId: mediaId,
      isLoading: isLoading,
    );
    if (responseMedia != null) {
      final response = await updatePresignedUrl(
        bytes: bytes,
        isLoading: isLoading,
        presignedUrl: isUpdateThumbnail
            ? responseMedia.thumbnailPresignedUrl
            : responseMedia.mediaPresignedUrl,
      );
      if (response == 200) {
        return responseMedia;
      }
    }
    return null;
  }

  Future<bool> sendMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required int createdAt,
    required String notificationBody,
    required String notificationTitle,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
    List<String>? searchableTags,
    bool isBroadcast = false,
    bool isUpdateMesage = true,
  }) async {
    try {
      final response = await _repository.sendMessage(
        showInConversation: showInConversation,
        attachments: attachments,
        events: events,
        mentionedUsers: mentionedUsers,
        metaData: metaData,
        messageType: messageType,
        customType: customType,
        parentMessageId: parentMessageId,
        encrypted: encrypted,
        deviceId: deviceId,
        conversationId: conversationId,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        body: body,
      );
      if (response == null) return false;
      if (!isUpdateMesage) return false;
      if (isBroadcast) {
        final chatPageController = IsmChatUtility.chatPageController;
        for (var x = 0; x < chatPageController.messages.length; x++) {
          var messages = chatPageController.messages[x];
          if (messages.messageId?.isNotEmpty == true ||
              messages.sentAt != createdAt) {
            continue;
          }
          messages.messageId = response.messageId;
          messages.deliveredToAll = false;
          messages.readByAll = false;
          messages.isUploading = false;
          chatPageController.messages[x] = messages;
        }
      } else {
        final dbBox = IsmChatConfig.dbWrapper;
        final chatPendingMessagesData = await dbBox
            ?.getConversation(conversationId, dbBox: IsmChatDbBox.pending);
        if (chatPendingMessagesData != null) {
          chatPendingMessages = chatPendingMessagesData;
        }
        final pendingMessage = chatPendingMessages?.messages?['$createdAt'];
        if (pendingMessage != null &&
            [200, 403].contains(response.respone.errorCode)) {
          if (response.messageId.isNotEmpty) {
            pendingMessage.messageId = response.messageId;
            pendingMessage.deliveredToAll = false;
            pendingMessage.readByAll = false;
            pendingMessage.isUploading = false;
          } else if (response.respone.errorCode == 403) {
            pendingMessage.messageId = '';
            pendingMessage.isInvalidMessage = true;
          }
          chatPendingMessages?.messages
              ?.removeWhere((key, value) => key == '$createdAt');
          await dbBox?.saveConversation(
              conversation: chatPendingMessages!, dbBox: IsmChatDbBox.pending);
          if (chatPendingMessages?.messages?.isEmpty == true) {
            await dbBox?.pendingMessageBox
                .delete(chatPendingMessages?.conversationId ?? '');
          }
          var conversationModel = await dbBox?.getConversation(conversationId);
          if (conversationModel != null) {
            final messages = conversationModel.messages ?? {};
            messages.addEntries({'$createdAt': pendingMessage}.entries);
            conversationModel = conversationModel.copyWith(
              lastMessageDetails:
                  conversationModel.lastMessageDetails?.copyWith(
                reactionType: '',
                messageId: pendingMessage.messageId,
                action: '',
              ),
              messages: messages,
            );
          }
          await dbBox?.saveConversation(conversation: conversationModel!);
          return true;
        }
      }
      return false;
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return false;
    }
  }

  Future<(bool, IsmChatResponseModel?)> sendPaidWalletMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required String notificationBody,
    required String notificationTitle,
    required int createdAt,
    String? parentMessageId,
    Map<String, dynamic>? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final response = await _repository.sendPaidWalletMessage(
        showInConversation: showInConversation,
        messageType: messageType,
        encrypted: encrypted,
        deviceId: deviceId,
        conversationId: conversationId,
        body: body,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        attachments: attachments,
        customType: customType,
        events: events,
        mentionedUsers: mentionedUsers,
        parentMessageId: parentMessageId,
        metaData: metaData,
      );
      if (response == null) return (false, response?.$2);
      final dbBox = IsmChatConfig.dbWrapper;
      final chatPendingMessagesData = await dbBox
          ?.getConversation(conversationId, dbBox: IsmChatDbBox.pending);
      if (chatPendingMessagesData != null) {
        chatPendingMessages = chatPendingMessagesData;
      }

      final pendingMessage = chatPendingMessages?.messages?['$createdAt'];
      if (pendingMessage != null) {
        pendingMessage.messageId = response.$1;
        pendingMessage.deliveredToAll = false;
        pendingMessage.readByAll = false;
        pendingMessage.isUploading = false;
        chatPendingMessages?.messages
            ?.removeWhere((key, value) => key == '$createdAt');
        await dbBox?.saveConversation(
            conversation: chatPendingMessages!, dbBox: IsmChatDbBox.pending);
        if (chatPendingMessages?.messages?.isEmpty == true) {
          await dbBox?.pendingMessageBox
              .delete(chatPendingMessages?.conversationId ?? '');
        }
        var conversationModel = await dbBox?.getConversation(conversationId);
        if (conversationModel != null) {
          final messages = conversationModel.messages ?? {};
          messages.addEntries({'$createdAt': pendingMessage}.entries);
          conversationModel = conversationModel.copyWith(
            lastMessageDetails: conversationModel.lastMessageDetails?.copyWith(
              reactionType: '',
              messageId: pendingMessage.messageId,
            ),
            messages: messages,
          );
        }
        await dbBox?.saveConversation(conversation: conversationModel!);
      }
      return (true, response.$2);
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return (false, null);
    }
  }

  List<IsmChatMessageModel> sortMessages(List<IsmChatMessageModel> messages) {
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    return _parseMessagesWithDate(messages);
  }

  List<IsmChatMessageModel> _parseMessagesWithDate(
    List<IsmChatMessageModel> messages,
  ) {
    var result = <List<IsmChatMessageModel>>[];
    var list1 = <IsmChatMessageModel>[];
    var allMessages = <IsmChatMessageModel>[];
    var dummyList = <int>[];

    for (var x = 0; x < messages.length; x++) {
      if (!dummyList.contains(messages[x].sentAt)) {
        dummyList.add(messages[x].sentAt);
        if (x == 0) {
          list1.add(messages[x]);
        } else if (DateTime.fromMillisecondsSinceEpoch(messages[x - 1].sentAt)
            .isSameDay(
                DateTime.fromMillisecondsSinceEpoch(messages[x].sentAt))) {
          list1.add(messages[x]);
        } else {
          result.add([...list1]);
          list1.clear();
          list1.add(messages[x]);
        }
        if (x == messages.length - 1 && list1.isNotEmpty) {
          result.add([...list1]);
        }
      }
    }
    if (result.isEmpty && list1.isNotEmpty) {
      result.add([...list1]);
    }

    for (var message in result) {
      allMessages.add(
        IsmChatMessageModel.fromDate(
          message.first.sentAt,
        ),
      );
      allMessages.addAll(message);
    }
    return allMessages;
  }

  Future<IsmChatResponseModel?> createConversation({
    required bool typingEvents,
    required bool readEvents,
    required bool pushNotifications,
    required List<String> members,
    required bool isGroup,
    required int conversationType,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    String? conversationTitle,
    String? conversationImageUrl,
    String? customType,
    bool isLoading = false,
  }) async =>
      await _repository.createConversation(
        typingEvents: typingEvents,
        readEvents: readEvents,
        pushNotifications: pushNotifications,
        members: members,
        isGroup: isGroup,
        metaData: metaData,
        conversationType: conversationType,
        conversationImageUrl: conversationImageUrl,
        conversationTitle: conversationTitle,
        isLoading: isLoading,
        customType: customType,
        searchableTags: searchableTags,
      );

  Future<List<IsmChatMessageModel>> getChatMessages({
    required String conversationId,
    required int lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
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
    messages = sortMessages(messages);
    return messages;
  }
}
