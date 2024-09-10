part of '../chat_page_controller.dart';

mixin IsmChatPageGetMessageMixin on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  Future<void> getMessagesFromDB(String conversationId,
      [IsmChatDbBox dbBox = IsmChatDbBox.main]) async {
    _controller.closeOverlay();

    var messages =
        await IsmChatConfig.dbWrapper?.getMessage(conversationId, dbBox);
    if (messages == null || (messages.isEmpty)) {
      _controller.messages.clear();
      return;
    }

    var pendingmessages = await IsmChatConfig.dbWrapper!
        .getMessage(conversationId, IsmChatDbBox.pending);
    if (pendingmessages != null || (pendingmessages?.isNotEmpty == true)) {
      messages.addAll(pendingmessages ?? []);
    }

    _controller.messages =
        _controller.commonController.sortMessages(filterMessages(messages));

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
    String conversationId = '',
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
      var conversationID = conversationId.isNotEmpty
          ? conversationId
          : _controller.conversation?.conversationId ?? '';

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

  Future<void> updateConversationMessage() async {
    var chatConersationController = Get.find<IsmChatConversationsController>();
    var converstionIndex = chatConersationController.conversations.indexWhere(
        (e) => e.conversationId == _controller.conversation?.conversationId);
    chatConersationController.conversations[converstionIndex] =
        chatConersationController.conversations[converstionIndex]
            .copyWith(messages: _controller.messages);
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

  Future<IsmChatConversationModel?> getConverstaionDetails({
    required String conversationId,
    bool? includeMembers,
    // String? ids,
    // int? membersSkip,
    // int? membersLimit,
    bool? isLoading,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      if (!_controller.isCoverationApiDetails) {
        return null;
      }
      _controller.isCoverationApiDetails = false;
      var data = await _controller.viewModel.getConverstaionDetails(
        conversationId: conversationId,
        includeMembers: includeMembers,
        isLoading: isLoading,
      );

      if (data.data != null &&
          (_controller.conversation?.conversationId == conversationId)) {
        _controller.conversation = data.data.copyWith(
          conversationId: conversationId,
          metaData: _controller.conversation?.metaData,
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

        if (data.data.members != null) {
          _controller.groupMembers = data.data.members!;
          _controller.groupMembers.sort((a, b) =>
              a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));
        }

        IsmChatLog.success('Updated conversation');
      }
      if (data.statusCode == 400 && conversationId.isNotEmpty) {
        _controller.isActionAllowed = true;
      }
      _controller.isCoverationApiDetails = true;
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
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: message.conversationId);

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
        await IsmChatConfig.dbWrapper!
            .saveConversation(conversation: conversation);
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
}
