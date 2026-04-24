part of '../chat_page_controller.dart';

/// Block and unblock operations mixin for IsmChatPageController.
///
/// This mixin handles blocking and unblocking users in conversations.
mixin IsmChatPageBlockUnblockMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Removes persisted block/unblock banner messages from local DB.
  ///
  /// The centered "You blocked/unblocked" banner is rendered from messages whose
  /// `customType` is `block` or `unblock` (see `IsmChatBlockedMessage`).
  /// Even if we clear `metaData.blockedMessage`, an old stored message can keep
  /// showing the banner. This helper ensures local DB can't re-hydrate it.
  Future<void> _removeBlockUnblockBannerMessages(String conversationId) async {
    if (conversationId.isEmpty) return;
    final existing =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (existing?.messages == null || existing!.messages!.isEmpty) return;

    final cleaned = Map<String, IsmChatMessageModel>.from(existing.messages!);
    cleaned.removeWhere(
      (_, msg) =>
          msg.customType == IsmChatCustomMessageType.block ||
          msg.customType == IsmChatCustomMessageType.unblock,
    );

    await IsmChatConfig.dbWrapper?.saveConversation(
      conversation: existing.copyWith(messages: cleaned),
    );
  }

  /// Returns opponent metadata in raw API-like JSON form.
  ///
  /// We pass `customMetaData` directly because this preserves the incoming API
  /// payload shape better than rebuilding from model fields.
  Map<String, dynamic> _opponentMetaDataJson() => Map<String, dynamic>.from(
        _controller.conversation?.opponentDetails?.metaData?.customMetaData ??
            const <String, dynamic>{},
      );

  /// Blocks a user.
  Future<void> blockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    bool blokedUser;
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
    // Always block from SDK side.
    blokedUser = await _controller.viewModel.blockUser(
        opponentId: opponentId,
        conversationId: _controller.conversation?.conversationId ?? '',
        isLoading: isLoading);
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
    unawaited(
      IsmChatProperties.chatPageProperties.onBlockUnblockSuccess?.call(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
        _controller.conversation!,
        true,
        _opponentMetaDataJson(),
      ),
    );
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
    // Always unblock from SDK side.
    isUnblockUser = await _controller.conversationController.unblockUser(
      opponentId: opponentId,
      isLoading: isLoading,
      fromUser: fromUser,
    );
    if (!isUnblockUser) {
      return;
    }
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
    if (fromUser == false) {
      await Future.wait([
        _controller.getConverstaionDetails(),
        _controller.getMessagesFromAPI(),
        _controller.conversationController.getChatConversations(),
      ]);
    }
    final convId = _controller.conversation?.conversationId ?? '';

    // Always clear the block banner sources:
    // - `metaData.blockedMessage` (injected into message list)
    // - stored block/unblock system messages in local DB
    if (_controller.conversation?.metaData?.blockedMessage != null) {
      _controller.conversation = _controller.conversation!.copyWith(
        metaData: _controller.conversation!.metaData?.copyWith(
          blockedMessage: null,
        ),
      );
      unawaited(
        IsmChatUtility.conversationController.updateConversation(
          conversationId: convId,
          metaData: _controller.conversation?.metaData ?? IsmChatMetaData(),
        ),
      );
      await _saveBlockUnblockMetaDataLocally();
    }

    await _removeBlockUnblockBannerMessages(convId);
    if (convId.isNotEmpty) {
      await _controller.getMessagesFromDB(convId);
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
