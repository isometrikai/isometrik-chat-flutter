part of '../chat_page_controller.dart';

/// Message management mixin for IsmChatPageController.
///
/// This mixin handles message reading, deletion, updates, and typing notifications.
mixin IsmChatPageMessageManagementMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Reads a specific message.
  Future<void> readMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _controller.viewModel.readMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// Reads all messages in the conversation.
  Future<void> readAllMessages() async {
    await _controller.viewModel.readAllMessages(
      conversationId: _controller.conversation?.conversationId ?? '',
      timestamp: _controller.messages.isNotEmpty
          ? DateTime.now().millisecondsSinceEpoch
          : _controller.conversation?.lastMessageSentAt ?? 0,
    );
  }

  /// Notifies typing status to other users.
  void notifyTyping() {
    if (_controller.isTyping) {
      _controller.isTyping = false;
      var tickTick = 0;
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (tickTick == 0) {
          await _controller.viewModel.notifyTyping(
            conversationId: _controller.conversation?.conversationId ?? '',
          );
        }
        if (tickTick == 2) {
          _controller.isTyping = true;
          timer.cancel();
        }
        tickTick++;
      });
    }
  }

  /// Updates the last message in the conversation.
  Future<bool> updateLastMessage() async {
    if (!_controller.didReactedLast) {
      var chatConversation = await IsmChatConfig.dbWrapper
          ?.getConversation(_controller.conversation?.conversationId ?? '');
      if (chatConversation != null &&
          chatConversation.messages?.isNotEmpty == true) {
        if (_controller.messages.isNotEmpty &&
            _controller.messages.last.customType !=
                IsmChatCustomMessageType.removeMember) {
          final lastMessage = _controller.messages.last;
          chatConversation = chatConversation.copyWith(
            lastMessageDetails: chatConversation.lastMessageDetails?.copyWith(
              audioOnly: lastMessage.audioOnly,
              meetingId: lastMessage.meetingId,
              meetingType: lastMessage.meetingType,
              callDurations: lastMessage.callDurations,
              sentByMe: lastMessage.sentByMe,
              showInConversation: true,
              senderId: lastMessage.senderInfo?.userId ?? '',
              sentAt: chatConversation
                          .lastMessageDetails?.reactionType?.isNotEmpty ==
                      true
                  ? chatConversation.lastMessageDetails?.sentAt
                  : lastMessage.sentAt,
              senderName: [
                IsmChatCustomMessageType.removeAdmin,
                IsmChatCustomMessageType.addAdmin,
                IsmChatCustomMessageType.memberJoin,
                IsmChatCustomMessageType.memberLeave,
              ].contains(lastMessage.customType)
                  ? lastMessage.userName?.isNotEmpty == true
                      ? lastMessage.userName
                      : lastMessage.initiatorName ?? ''
                  : chatConversation.isGroup ?? false
                      ? lastMessage.senderInfo?.userName
                      : lastMessage.chatName,
              messageType: lastMessage.messageType?.value ?? 0,
              messageId: lastMessage.messageId ?? '',
              conversationId: lastMessage.conversationId ?? '',
              body: lastMessage.body,
              action: lastMessage.action,
              customType: lastMessage.customType,
              readCount: lastMessage.messageId?.isNotEmpty == true
                  ? chatConversation.isGroup ?? false
                      ? lastMessage.readByAll ?? false
                          ? chatConversation.membersCount
                          : lastMessage.lastReadAt?.length
                      : lastMessage.readByAll ?? false
                          ? 1
                          : 0
                  : 0,
              deliveredTo: lastMessage.messageId?.isNotEmpty == true
                  ? lastMessage.deliveredTo
                  : [],
              readBy: lastMessage.messageId?.isNotEmpty == true
                  ? lastMessage.readBy
                  : [],
              deliverCount: lastMessage.messageId?.isNotEmpty == true
                  ? chatConversation.isGroup ?? false
                      ? lastMessage.deliveredToAll ?? false
                          ? chatConversation.membersCount
                          : 0
                      : lastMessage.deliveredToAll ?? false
                          ? 1
                          : 0
                  : 0,
              members: lastMessage.members
                      ?.map((e) => e.memberName ?? '')
                      .toList() ??
                  [],
              initiatorId: lastMessage.initiatorId,
              metaData: lastMessage.metaData,
              isInvalidMessage: lastMessage.isInvalidMessage,
            ),
            unreadMessagesCount: 0,
          );
        }

        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: chatConversation);
        await _controller.conversationController.getConversationsFromDB();
      }
    } else {
      await _controller.conversationController.getChatConversations();
    }

    if (IsmChatUtility.chatPageControllerRegistered) {
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
    }
    unawaited(
        Get.find<IsmChatMqttController>().getChatConversationsUnreadCount());

    return true;
  }

  /// Updates the unread message count for the conversation.
  Future<void> updateUnreadMessgaeCount() async {
    var chatConversation = await IsmChatConfig.dbWrapper
        ?.getConversation(_controller.conversation?.conversationId ?? '');
    if (chatConversation != null) {
      chatConversation = chatConversation.copyWith(
        unreadMessagesCount: 0,
      );
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: chatConversation);
      await _controller.conversationController.getConversationsFromDB();
    }
  }

  /// Deletes message for everyone.
  Future<void> deleteMessageForEveryone(
    IsmChatMessages messages,
  ) async {
    final pendingMessges = IsmChatMessages.from(messages);
    await _controller.viewModel.deleteMessageForEveryone(messages);
    _controller.selectedMessage.clear();
    pendingMessges.entries.where((e) => e.value.messageId == '');
    if (pendingMessges.isNotEmpty) {
      await IsmChatConfig.dbWrapper?.removePendingMessage(
          _controller.conversation?.conversationId ?? '', pendingMessges);
      await _controller.getMessagesFromDB(_controller.conversation!.conversationId!);
      _controller.selectedMessage.clear();
      _controller.isMessageSeleted = false;
    }
    IsmChatUtility.showToast('Deleted your message');
  }

  /// Deletes message for me only.
  Future<void> deleteMessageForMe(
    IsmChatMessages messages,
  ) async {
    final pendingMessges = IsmChatMessages.from(messages);
    await _controller.viewModel.deleteMessageForMe(messages);
    _controller.selectedMessage.clear();
    pendingMessges.entries.where((e) => e.value.messageId == '');
    if (pendingMessges.isNotEmpty) {
      await IsmChatConfig.dbWrapper?.removePendingMessage(
          _controller.conversation?.conversationId ?? '', pendingMessges);
      await _controller.getMessagesFromDB(_controller.conversation?.conversationId ?? '');
      _controller.selectedMessage.clear();
      _controller.isMessageSeleted = false;
    }
    IsmChatUtility.showToast('Deleted your message');
  }

  /// Clears all messages in the conversation.
  Future<void> clearAllMessages(String conversationId,
      {bool fromServer = true}) async {
    await _controller.viewModel.clearAllMessages(
        conversationId: conversationId, fromServer: fromServer);
    _controller.showDownSideButton = false;
  }

  /// Checks if all selected messages are from the current user.
  bool isAllMessagesFromMe() => _controller.selectedMessage.every(
        (e) => e.sentByMe,
      );

  /// Checks if any selected message is deleted for everyone.
  bool isAnyMessageDeletedForEveryone() => _controller.selectedMessage
      .any((e) => e.customType == IsmChatCustomMessageType.deletedForEveryone);
}


