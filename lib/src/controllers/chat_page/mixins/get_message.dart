part of '../chat_page_controller.dart';

mixin IsmChatPageGetMessageMixin on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  Future<void> getMessagesFromDB(String conversationId,
      [IsmChatDbBox dbBox = IsmChatDbBox.main]) async {
    _controller.closeOverlay();

    var messages =
        await IsmChatConfig.dbWrapper?.getMessage(conversationId, dbBox);
    if (messages == null) {
      _controller.messages.clear();
      return;
    }
    if (IsmChatConfig.shouldPendingMessageSend) {
      var pendingmessages = await IsmChatConfig.dbWrapper
          ?.getMessage(conversationId, IsmChatDbBox.pending);
      if (pendingmessages != null) {
        messages.addAll(pendingmessages);
      }
    } else {
      await IsmChatConfig.dbWrapper
          ?.removeConversation(conversationId, IsmChatDbBox.pending);
    }
    _controller.messages = _controller.commonController
        .sortMessages(filterMessages(messages.values.toList()));

    if (_controller.messages.isEmpty) {
      return;
    }
    _controller.isMessagesLoading = false;
    _controller._generateIndexedMessageList();
  }

  List<IsmChatMessageModel> filterMessages(List<IsmChatMessageModel> messages) {
    var filterMessage = IsmChatMessageModel(
        body: '', sentAt: 0, customType: null, sentByMe: false);
    var dummymessages = List<IsmChatMessageModel>.from(messages);
    for (var x in dummymessages) {
      if (x.customType != IsmChatCustomMessageType.oneToOneCall) {
        continue;
      }
      if (x.meetingId != filterMessage.meetingId) {
        filterMessage = x;
        continue;
      }
      if (x.action == IsmChatActionEvents.meetingCreated.name) {
        filterMessage = filterMessage.copyWith(meetingType: x.meetingType);
      } else {
        filterMessage = x.copyWith(
          meetingType: filterMessage.meetingType,
        );
      }
      messages.removeWhere((e) =>
          e.action == IsmChatActionEvents.meetingCreated.name &&
          e.meetingId == x.meetingId);

      var fliterIndex = messages.indexWhere((e) => e.meetingId == x.meetingId);
      if (fliterIndex != -1) {
        messages[fliterIndex] = filterMessage;
      }
    }
    return messages;
  }

  Future<void> getMessagesFromAPI({
    bool forPagination = false,
    int? lastMessageTimestamp,
    bool isBroadcast = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      if (_controller.canCallCurrentApi) return;
      _controller.canCallCurrentApi = true;

      if (_controller.messages.isEmpty) {
        _controller.isMessagesLoading = true;
      }
      var timeStamp = lastMessageTimestamp ??
          (_controller.messages.isEmpty
              ? 0
              : _controller.messages.last.sentAt + 7000);
      var messagesList = List<IsmChatMessageModel>.from(_controller.messages);
      messagesList.removeWhere(
          (element) => element.customType == IsmChatCustomMessageType.date);
      var conversationID = _controller.conversation?.conversationId ?? '';

      var data = await _controller.viewModel.getChatMessages(
        skip: forPagination ? messagesList.length.pagination() : 0,
        conversationId: conversationID,
        lastMessageTimestamp: timeStamp,
        isBroadcast: isBroadcast,
      );

      if (_controller.messages.isEmpty) {
        _controller.isMessagesLoading = false;
      }

      if (data.isNotEmpty && !_controller.isBroadcast) {
        await getMessagesFromDB(conversationID);
      } else {
        _controller.messages.addAll(data);
      }
      _controller.canCallCurrentApi = false;
    }
  }

  Future<void> getBroadcastMessages({
    String groupcastId = '',
    int? lastMessageTimestamp,
    bool isLoading = false,
    String? searchText,
    bool isBroadcast = false,
    bool forPagination = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      if (_controller.canCallCurrentApi) return;
      _controller.canCallCurrentApi = true;
      if (_controller.messages.isEmpty) {
        _controller.isMessagesLoading = true;
      }
      var timeStamp = lastMessageTimestamp ??
          (_controller.messages.isEmpty
              ? 0
              : _controller.messages.last.sentAt + 7000);
      var messagesList = List<IsmChatMessageModel>.from(_controller.messages);
      messagesList.removeWhere(
          (element) => element.customType == IsmChatCustomMessageType.date);
      var groupcastID = groupcastId.isNotEmpty
          ? groupcastId
          : _controller.conversation?.conversationId ?? '';
      var data = await _controller.viewModel.getBroadcastMessages(
        skip: forPagination ? messagesList.length.pagination() : 0,
        groupcastId: groupcastID,
        lastMessageTimestamp: timeStamp,
        isBroadcast: isBroadcast,
      );
      if (_controller.messages.isEmpty) {
        _controller.isMessagesLoading = false;
      }
      _controller.messages.addAll(data);
      _controller.canCallCurrentApi = false;
    }
  }

  void searchedMessages(String query, {bool fromScrolling = false}) async {
    if (query.trim().isEmpty) {
      _controller.searchMessages.clear();
      return;
    }
    if (_controller.canCallCurrentApi) return;
    _controller.canCallCurrentApi = true;

    var messages = await _controller.viewModel.getChatMessages(
      skip: !fromScrolling ? 0 : _controller.searchMessages.length.pagination(),
      conversationId: _controller.conversation?.conversationId ?? '',
      lastMessageTimestamp: 0,
      searchText: query,
      isLoading: true,
    );

    if (messages.isNotEmpty) {
      if (fromScrolling) {
        _controller.searchMessages.addAll(messages);
      } else {
        _controller.searchMessages = messages;
      }
    } else if (!fromScrolling) {
      _controller.searchMessages.clear();
    }
    _controller.canCallCurrentApi = false;
  }

  Future<void> getMessageDeliverTime(IsmChatMessageModel message) async {
    _controller.deliverdMessageMembers.clear();
    var response = await _controller.viewModel.getMessageDeliverTime(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );

    if (response == null || response.isEmpty) {
      return;
    }
    _controller.deliverdMessageMembers = response;
  }

  Future<void> getMessageReadTime(IsmChatMessageModel message) async {
    _controller.readMessageMembers.clear();
    var response = await _controller.viewModel.getMessageReadTime(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );

    if (response == null || response.isEmpty) {
      return;
    }
    _controller.readMessageMembers = response;
  }

  Future<IsmChatConversationModel?> getConverstaionDetails(
      {bool? isLoading}) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      if (!_controller.isCoverationApiDetails) {
        return null;
      }
      _controller.isCoverationApiDetails = false;
      final conversationId = _controller.conversation?.conversationId ?? '';
      var data = await _controller.viewModel.getConverstaionDetails(
        conversationId: conversationId,
        includeMembers:
            _controller.conversation?.isGroup == true ? true : false,
        isLoading: isLoading,
      );

      if (data.data != null &&
          (_controller.conversation?.conversationId == conversationId)) {
        final responeData = data.data as IsmChatConversationModel;
        _controller.conversation = responeData.copyWith(
          conversationId: conversationId,
          metaData: _controller.conversation?.metaData,
          outSideMessage: _controller.conversation?.outSideMessage,
          messages: {
            for (var message in _controller.messages)
              '${message.sentAt}': message
          },
        );
        IsmChatProperties.chatPageProperties.onCoverstaionStatus
            ?.call(Get.context!, _controller.conversation!);

        // controller.medialist is storing media i.e. Image, Video and Audio. //
        _controller.conversationController.mediaList = _controller.messages
            .where((e) => [
                  IsmChatCustomMessageType.image,
                  IsmChatCustomMessageType.video,
                  IsmChatCustomMessageType.audio,
                ].contains(e.customType))
            .toList();

        // controller.mediaListLinks is storing links //
        _controller.conversationController.mediaListLinks = _controller.messages
            .where((e) => [
                  IsmChatCustomMessageType.link,
                ].contains(e.customType))
            .toList();

        // controller.mediaListDocs is storing docs //
        _controller.conversationController.mediaListDocs = _controller.messages
            .where((e) => [
                  IsmChatCustomMessageType.file,
                ].contains(e.customType))
            .toList();

        if (responeData.members != null) {
          _controller.groupMembers = responeData.members ?? [];
          _controller.groupMembers.sort((a, b) =>
              a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));
          _controller.groupMembers.removeWhere((e) => e.userId.isEmpty);
        }

        IsmChatLog.success('Updated conversation');
        if (_controller.conversation?.messagingDisabled ?? false) {
          unawaited(_controller.conversationController.getBlockUser());
        }
      }
      if (data.statusCode == 400 && conversationId.isNotEmpty) {
        _controller.isActionAllowed = true;
      }
      _controller.isCoverationApiDetails = true;
      _controller.conversationController.currentConversation =
          _controller.conversation;
      return _controller.conversation;
    }
    return null;
  }

  Future<void> getReacton({required Reaction reaction}) async {
    var response = await _controller.viewModel.getReacton(reaction: reaction);
    _controller.userReactionList = response ?? [];
  }

  void updateLastMessagOnCurrentTime(IsmChatMessageModel message) async {
    var conversationController = Get.find<IsmChatConversationsController>();
    var conversation = await IsmChatConfig.dbWrapper
        ?.getConversation(conversationId: message.conversationId);

    if (conversation == null) {
      return;
    }

    if (!_controller.didReactedLast) {
      if (message.customType != IsmChatCustomMessageType.removeMember) {
        conversation = conversation.copyWith(
          lastMessageDetails: conversation.lastMessageDetails?.copyWith(
            sentByMe: message.sentByMe,
            showInConversation: true,
            sentAt: conversation.lastMessageDetails?.reactionType?.isNotEmpty ==
                    true
                ? conversation.lastMessageDetails?.sentAt
                : message.sentAt,
            senderName: [
              IsmChatCustomMessageType.removeAdmin,
              IsmChatCustomMessageType.addAdmin
            ].contains(message.customType)
                ? message.initiatorName ?? ''
                : message.chatName,
            messageType: message.messageType?.value ?? 0,
            messageId: message.messageId ?? '',
            conversationId: message.conversationId ?? '',
            body: message.body,
            senderId: message.senderInfo?.userId,
            customType: message.customType,
            readBy: [],
            deliveredTo: [],
            readCount: conversation.isGroup == true
                ? message.readByAll == true
                    ? conversation.membersCount ?? 0
                    : message.lastReadAt?.length
                : message.readByAll == true
                    ? 1
                    : 0,
            deliverCount: conversation.isGroup == true
                ? message.deliveredToAll == true
                    ? conversation.membersCount ?? 0
                    : 0
                : message.deliveredToAll == true
                    ? 1
                    : 0,
            members:
                message.members?.map((e) => e.memberName ?? '').toList() ?? [],
            action: '',
          ),
          unreadMessagesCount: 0,
        );
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
        await conversationController.getConversationsFromDB();
      }
    } else {
      await conversationController.getChatConversations();
    }
  }

  UserDetails getUser() => UserDetails(
        userProfileImageUrl:
            IsmChatProperties.chatPageProperties.header?.profileImageUrl?.call(
                    Get.context!,
                    _controller.conversation!,
                    _controller.conversation?.profileUrl ?? '') ??
                _controller.conversation?.profileUrl ??
                '',
        userName: IsmChatProperties.chatPageProperties.header?.title?.call(
                Get.context!,
                _controller.conversation!,
                _controller.conversation?.chatName ?? '') ??
            _controller.conversation?.chatName ??
            '',
        userIdentifier:
            _controller.conversation?.opponentDetails?.userIdentifier ?? '',
        userId: _controller.conversation?.opponentDetails?.userId ?? '',
      );

  Future<void> updateMessage({
    required String messageId,
    required String conversationId,
    bool isOpponentMessage = false,
    IsmChatMetaData? metaData,
  }) async {
    if (!isOpponentMessage) {
      final response = await _controller.viewModel.updateMessage(
        metaData: {'isDownloaded': true},
        messageId: messageId,
        conversationId: conversationId,
        isLoading: true,
      );
      if (response) {
        await _controller.getMessagesFromDB(conversationId);
      }
    } else {
      var allMessages =
          await IsmChatConfig.dbWrapper?.getMessage(conversationId);
      if (allMessages == null) return;
      var message = allMessages.values
          .cast<IsmChatMessageModel?>()
          .firstWhere((e) => e?.messageId == messageId, orElse: () => null);
      if (message != null) {
        if (metaData != null) {
          message.metaData = metaData;
        } else {
          message.metaData = message.metaData?.copyWith(
            isDownloaded: true,
          );
        }
        allMessages[message.key] = message;
        var conversation = await IsmChatConfig.dbWrapper
            ?.getConversation(conversationId: conversationId);
        if (conversation != null) {
          conversation = conversation.copyWith(messages: allMessages);
          await IsmChatConfig.dbWrapper
              ?.saveConversation(conversation: conversation);
        }
        await getMessagesFromDB(conversationId);
      }
    }
  }

  Future<void> getMessageForStatus() async {
    var messageIds = <String>[];
    final conversationId = _controller.conversation?.conversationId ?? '';
    for (var message in _controller.messages) {
      if (((message.deliveredToAll == false) || (message.readByAll == false)) &&
          !message.messageId.isNullOrEmpty) {
        messageIds.add(message.messageId ?? '');
      }
    }
    if (messageIds.isNotEmpty) {
      messageIds.removeWhere((e) => e.isNullOrEmpty);
      final response = await _controller.viewModel.getMessageForStatus(
        conversationId: conversationId,
        messageIds: messageIds,
        isLoading: false,
      );
      if (response != null) {
        var conversation = await IsmChatConfig.dbWrapper
            ?.getConversation(conversationId: conversationId);

        final dbMessages = conversation?.messages?.values.toList() ?? [];
        for (var dbmessage in dbMessages) {
          final messageStatus = response.cast<MessageStatusModel?>().firstWhere(
                (e) => e?.messageId == dbmessage.messageId,
                orElse: () => null,
              );
          if (dbmessage.messageId == messageStatus?.messageId) {
            if (messageStatus?.deliveredToAll ?? false) {
              dbmessage.deliveredTo?.add(
                MessageStatus(
                  userId: conversation?.opponentDetails?.userId ?? '',
                  timestamp: int.tryParse(dbmessage.key),
                ),
              );
            }
            if (messageStatus?.readByAll ?? false) {
              dbmessage.readBy?.add(
                MessageStatus(
                  userId: conversation?.opponentDetails?.userId ?? '',
                  timestamp: int.tryParse(dbmessage.key),
                ),
              );
            }
            dbmessage.deliveredToAll = messageStatus?.deliveredToAll ?? false;
            dbmessage.readByAll = messageStatus?.readByAll ?? false;
            conversation?.messages?[dbmessage.key] = dbmessage;
          }
        }
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation!);
        await getMessagesFromDB(conversationId);
      }
    }
  }
}
