part of '../chat_page_controller.dart';

/// Block and unblock operations mixin for IsmChatPageController.
///
/// Option A: banner = message row in local DB; see [IsmChatBlockUnblockCoordinator].
mixin IsmChatPageBlockUnblockMixin on GetxController {
  IsmChatPageController get _controller => this as IsmChatPageController;

  Map<String, dynamic> _opponentMetaDataJson() => Map<String, dynamic>.from(
        _controller.conversation?.opponentDetails?.metaData?.customMetaData ??
            const <String, dynamic>{},
      );

  Future<void> blockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    if ((_controller.conversation?.isChattingAllowed == false) &&
        (_controller.conversation?.isBlockedByMe == false)) {
      await IsmChatUtility.showErrorDialog(
        IsmChatStrings.cannotBlockWhenAlreadyBlocked,
      );
      return;
    }

    final convId = _controller.conversation?.conversationId ?? '';
    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;
    final currentUserName =
        IsmChatConfig.communicationConfig.userConfig.userName ?? '';

    final blokedUser = await _controller.viewModel.blockUser(
      opponentId: opponentId,
      conversationId: convId,
      isLoading: isLoading,
    );
    if (!blokedUser) return;

    if (convId.isNotEmpty) {
      await IsmChatBlockUnblockCoordinator.applyBlock(
        conversationId: convId,
        bannerMessage: IsmChatBlockUnblockCoordinator.buildBannerMessage(
          isBlock: true,
          conversationId: convId,
          initiatorId: currentUserId,
          initiatorName: currentUserName,
          sentAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    await _controller.conversationController.getBlockUser();
    unawaited(
      IsmChatProperties.chatPageProperties.onBlockUnblockSuccess?.call(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
        _controller.conversation!,
        true,
        _opponentMetaDataJson(),
      ),
    );

    if (fromUser == false && convId.isNotEmpty) {
      _controller.conversation = _controller.conversation?.copyWith(
        messagingDisabled: true,
      );
      await IsmChatBlockUnblockCoordinator.refreshChatPageIfOpen(convId);
      await Future.wait([
        _controller.getConverstaionDetails(),
        _controller.getMessagesFromAPI(lastMessageTimestamp: 0),
        _controller.conversationController.getChatConversations(),
      ]);
      await _controller.getMessagesFromDB(convId);
    }
  }

  Future<void> unblockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    final isUnblockUser = await _controller.conversationController.unblockUser(
      opponentId: opponentId,
      isLoading: isLoading,
      fromUser: fromUser,
    );
    if (!isUnblockUser) return;

    unawaited(_controller.conversationController.getBlockUser());
    unawaited(
      IsmChatProperties.chatPageProperties.onBlockUnblockSuccess?.call(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
        _controller.conversation!,
        false,
        _opponentMetaDataJson(),
      ),
    );
    _controller.chatInputController.clear();

    final convId = _controller.conversation?.conversationId ?? '';
    if (convId.isNotEmpty) {
      _controller.conversation = _controller.conversation?.copyWith(
        messagingDisabled: false,
        metaData: _controller.conversation?.metaData?.copyWith(
          blockedMessage: null,
        ),
      );
    }

    if (fromUser == false && convId.isNotEmpty) {
      // Refresh UI from local DB first so the banner disappears immediately.
      await IsmChatBlockUnblockCoordinator.refreshChatPageIfOpen(convId);
      await _controller.getConverstaionDetails();
      await _controller.getMessagesFromAPI(lastMessageTimestamp: 0);
      unawaited(_controller.conversationController.getChatConversations());
      await IsmChatBlockUnblockCoordinator.pruneBlockBannersIfChatAllowed(convId);
      await IsmChatBlockUnblockCoordinator.refreshChatPageIfOpen(convId);
    }
  }
}
