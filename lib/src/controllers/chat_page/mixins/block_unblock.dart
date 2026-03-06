part of '../chat_page_controller.dart';

/// Block and unblock operations mixin for IsmChatPageController.
///
/// This mixin handles blocking and unblocking users in conversations.
mixin IsmChatPageBlockUnblockMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Blocks a user.
  Future<void> blockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    bool? blokedUser;
    // Build block message once for UI and re-apply after getConverstaionDetails
    final blockMessage = IsmChatMessageModel(
      action: 'userBlockConversation',
      initiatorId: IsmChatConfig.communicationConfig.userConfig.userId,
      initiatorName: IsmChatConfig.communicationConfig.userConfig.userName,
      userId: IsmChatConfig.communicationConfig.userConfig.userId,
      userName: IsmChatConfig.communicationConfig.userConfig.userName,
      body: '',
      conversationId: _controller.conversation?.conversationId ?? '',
      customType: IsmChatCustomMessageType.block,
      sentAt: DateTime.now().millisecondsSinceEpoch,
      sentByMe: false,
    );
    _controller.conversation = _controller.conversation?.copyWith(
      metaData: _controller.conversation?.metaData?.copyWith(
        blockedMessage: blockMessage,
      ),
    );
    await IsmChatUtility.conversationController.updateConversation(
        conversationId: _controller.conversation?.conversationId ?? '',
        metaData: _controller.conversation?.metaData ?? IsmChatMetaData());
    await _saveBlockUnblockMetaDataLocally();
    if (IsmChatProperties.chatPageProperties.onCallBlockUnblock != null) {
      blokedUser = await IsmChatProperties.chatPageProperties.onCallBlockUnblock
              ?.call(
                  IsmChatConfig.kNavigatorKey.currentContext ??
                      IsmChatConfig.context,
                  _controller.conversation!,
                  userBlockOrNot) ??
          false;
    } else {
      blokedUser = await _controller.viewModel.blockUser(
          opponentId: opponentId,
          conversationId: _controller.conversation?.conversationId ?? '',
          isLoading: isLoading);
    }
    if (!blokedUser) {
      _controller.conversation = _controller.conversation?.copyWith(
        metaData: _controller.conversation?.metaData?.copyWith(
          blockedMessage: null,
        ),
      );
      await IsmChatUtility.conversationController.updateConversation(
          conversationId: _controller.conversation?.conversationId ?? '',
          metaData: _controller.conversation?.metaData ?? IsmChatMetaData());
      return;
    }
    // IsmChatUtility.showToast(IsmChatStrings.blockedSuccessfully);
    await _controller.conversationController.getBlockUser();
    if (fromUser == false) {
      await _controller.getConverstaionDetails();
      // Re-apply block message so "You blocked this user" shows (getConverstaionDetails overwrites metaData)
      if (_controller.conversation != null) {
        _controller.conversation = _controller.conversation!.copyWith(
          metaData: _controller.conversation!.metaData?.copyWith(
            blockedMessage: blockMessage,
          ),
        );
      }
      await Future.wait([
        _controller.getMessagesFromAPI(),
        _controller.conversationController.getChatConversations(),
      ]);
      await _controller
          .getMessagesFromDB(_controller.conversation?.conversationId ?? '');
    }
  }

  /// Unblocks a user.
  Future<void> unblockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    bool isUnblockUser;
    if (IsmChatProperties.chatPageProperties.onCallBlockUnblock != null) {
      isUnblockUser =
          await IsmChatProperties.chatPageProperties.onCallBlockUnblock?.call(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context,
                _controller.conversation!,
                userBlockOrNot,
              ) ??
              false;
    } else {
      isUnblockUser = await _controller.conversationController.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );
    }
    if (!isUnblockUser) {
      return;
    }
    _controller.chatInputController.clear();
    if (fromUser == false) {
      await Future.wait([
        _controller.getConverstaionDetails(),
        _controller.getMessagesFromAPI(),
        _controller.conversationController.getChatConversations(),
      ]);
    }
    // Clear block message so "You are blocked" goes away from UI (local + server)
    if (_controller.conversation?.metaData?.blockedMessage != null) {
      _controller.conversation = _controller.conversation!.copyWith(
        metaData: _controller.conversation!.metaData?.copyWith(
          blockedMessage: null,
        ),
      );
      unawaited(
        IsmChatUtility.conversationController.updateConversation(
          conversationId: _controller.conversation?.conversationId ?? '',
          metaData: _controller.conversation?.metaData ?? IsmChatMetaData(),
        ),
      );
      await _saveBlockUnblockMetaDataLocally();
      final convId = _controller.conversation?.conversationId ?? '';
      if (convId.isNotEmpty) {
        await _controller.getMessagesFromDB(convId);
      }
    }
  }

  /// Saves the current conversation's metaData (including blockedMessage) to local DB.
  Future<void> _saveBlockUnblockMetaDataLocally() async {
    final convId = _controller.conversation?.conversationId ?? '';
    if (convId.isEmpty) return;
    final existing = await IsmChatConfig.dbWrapper?.getConversation(convId);
    if (existing == null) return;
    final updated = existing.copyWith(
      metaData: _controller.conversation?.metaData ?? existing.metaData,
    );
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: updated);
  }
}
