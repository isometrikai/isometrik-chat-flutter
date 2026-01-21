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
    _controller.conversation = _controller.conversation?.copyWith(
      metaData: _controller.conversation?.metaData?.copyWith(
        blockedMessage: IsmChatMessageModel(
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
        ),
      ),
    );
    await IsmChatUtility.conversationController.updateConversation(
        conversationId: _controller.conversation?.conversationId ?? '',
        metaData: _controller.conversation?.metaData ?? IsmChatMetaData());
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
    IsmChatUtility.showToast(IsmChatStrings.blockedSuccessfully);
    await Future.wait([
      _controller.conversationController.getBlockUser(),
      if (fromUser == false) ...[
        _controller.getConverstaionDetails(),
        _controller.getMessagesFromAPI(),
        _controller.conversationController.getChatConversations()
      ]
    ]);
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
        _controller.conversationController.getChatConversations()
      ]);
    }
    if (_controller.conversation?.metaData?.blockedMessage != null) {
      final conversationData = _controller.conversation?.copyWith(
        metaData: _controller.conversation?.metaData?.copyWith(
          blockedMessage: null,
        ),
      );
      _controller.conversation = conversationData;
      unawaited(
        IsmChatUtility.conversationController.updateConversation(
            conversationId: _controller.conversation?.conversationId ?? '',
            metaData: _controller.conversation?.metaData ?? IsmChatMetaData()),
      );
    }
  }
}


