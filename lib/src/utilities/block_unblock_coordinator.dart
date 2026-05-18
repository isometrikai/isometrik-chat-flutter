import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Option A: block/unblock UI is driven by **message rows** (`customType` block/unblock)
/// plus `messagingDisabled` on the conversation — not `metaData.blockedMessage`.
///
/// Used by: chat-page block/unblock, MQTT (user B), settings unblock.
class IsmChatBlockUnblockCoordinator {
  IsmChatBlockUnblockCoordinator._();

  static bool isBlockAction(IsmChatActionEvents action) =>
      action == IsmChatActionEvents.userBlock ||
      action == IsmChatActionEvents.userBlockConversation;

  static bool isUnblockAction(IsmChatActionEvents action) =>
      action == IsmChatActionEvents.userUnblock ||
      action == IsmChatActionEvents.userUnblockConversation;

  static bool isBannerMessage(IsmChatMessageModel message) =>
      message.customType == IsmChatCustomMessageType.block ||
      message.customType == IsmChatCustomMessageType.unblock;

  /// True when the conversation should show block UI (banner + disabled input).
  static bool isConversationBlocked(IsmChatConversationModel? conversation) =>
      conversation?.messagingDisabled == true;

  static void removeBannerRowsFromList(List<IsmChatMessageModel> messages) {
    messages.removeWhere(isBannerMessage);
  }

  static Map<String, IsmChatMessageModel> removeBannerRowsFromMap(
    Map<String, IsmChatMessageModel> messages,
  ) {
    final cleaned = Map<String, IsmChatMessageModel>.from(messages);
    cleaned.removeWhere((_, m) => isBannerMessage(m));
    return cleaned;
  }

  /// Drops stale block/unblock rows from DB when chat is no longer disabled.
  static Future<void> pruneBlockBannersIfChatAllowed(
    String conversationId,
  ) async {
    if (conversationId.isEmpty) return;
    final existing = await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (existing == null || existing.messagingDisabled == true) return;

    final messages = existing.messages;
    if (messages == null ||
        !messages.values.any(isBannerMessage)) {
      return;
    }

    final cleaned = removeBannerRowsFromMap(messages);
    await IsmChatConfig.dbWrapper?.saveConversation(
      conversation: existing.copyWith(
        messages: cleaned,
        metaData: existing.metaData?.copyWith(blockedMessage: null),
      ),
    );
    await IsmChatConfig.dbWrapper?.purgeBlockUnblockAndRefreshLastMessage(
      conversationId,
    );
  }

  /// Builds the centered banner row shown in the message list.
  static IsmChatMessageModel buildBannerMessage({
    required bool isBlock,
    required String conversationId,
    required String initiatorId,
    required String initiatorName,
    required int sentAt,
    String? messageId,
    String? action,
  }) {
    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;
    return IsmChatMessageModel(
      messageId: messageId ?? '',
      action: action ??
          (isBlock
              ? IsmChatActionEvents.userBlockConversation.name
              : IsmChatActionEvents.userUnblockConversation.name),
      initiatorId: initiatorId,
      initiatorName: initiatorName,
      userId: initiatorId,
      userName: initiatorName,
      body: '',
      conversationId: conversationId,
      customType:
          isBlock ? IsmChatCustomMessageType.block : IsmChatCustomMessageType.unblock,
      sentAt: sentAt,
      sentByMe: initiatorId == currentUserId,
      showInConversation: true,
    );
  }

  static IsmChatMessageModel bannerFromMqtt(
    IsmChatMqttActionModel actionModel, {
    required String conversationId,
    required bool isBlock,
  }) =>
      buildBannerMessage(
        isBlock: isBlock,
        conversationId: conversationId,
        initiatorId: actionModel.initiatorDetails?.userId ?? '',
        initiatorName: actionModel.initiatorDetails?.userName ?? '',
        sentAt: actionModel.sentAt,
        messageId: actionModel.messageId,
        action: actionModel.action.name,
      );

  /// Resolves conversation id when MQTT payload omits it.
  static Future<String> resolveConversationIdFromMqtt(
    IsmChatMqttActionModel actionModel,
  ) async {
    final provided = (actionModel.conversationId ?? '').trim();
    if (provided.isNotEmpty) return provided;

    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;
    final candidates = <String>{
      (actionModel.opponentDetails?.userId ?? '').trim(),
      (actionModel.initiatorDetails?.userId ?? '').trim(),
    }..removeWhere((e) => e.isEmpty || e == currentUserId);

    if (IsmChatUtility.conversationControllerRegistered) {
      final conversationController = IsmChatUtility.conversationController;
      for (final userId in candidates) {
        final convId = conversationController.getConversationId(userId);
        if (convId.isNotEmpty) return convId;
      }
    }

    final local = await IsmChatConfig.dbWrapper?.getAllConversations();
    final match = (local ?? const <IsmChatConversationModel>[])
        .cast<IsmChatConversationModel?>()
        .firstWhere(
          (c) => candidates.contains((c?.opponentDetails?.userId ?? '').trim()),
          orElse: () => null,
        );
    return (match?.conversationId ?? '').trim();
  }

  /// Persists block state: `messagingDisabled` + one banner row in `messages`.
  static Future<void> applyBlock({
    required String conversationId,
    required IsmChatMessageModel bannerMessage,
  }) async {
    if (conversationId.isEmpty) return;

    final existing = await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (existing == null) return;

    final messages = Map<String, IsmChatMessageModel>.from(
      existing.messages ?? const <String, IsmChatMessageModel>{},
    );
    messages.removeWhere((_, m) => isBannerMessage(m));
    messages[bannerMessage.key] = bannerMessage;

    final updated = existing.copyWith(
      messagingDisabled: true,
      messages: messages,
      metaData: (existing.metaData ?? IsmChatMetaData()).copyWith(
        blockedMessage: null,
      ),
    );

    await IsmChatConfig.dbWrapper?.saveConversation(conversation: updated);
    await _syncConversationInLists(updated);
  }

  /// Clears block state and removes banner rows from local messages.
  static Future<void> applyUnblock({
    required String conversationId,
    bool syncServerMetadataClear = false,
  }) async {
    if (conversationId.isEmpty) return;

    final existing = await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (existing == null) return;

    Map<String, IsmChatMessageModel>? cleanedMessages;
    if (existing.messages != null) {
      cleanedMessages = Map<String, IsmChatMessageModel>.from(existing.messages!);
      cleanedMessages.removeWhere((_, m) => isBannerMessage(m));
    }

    final updated = existing.copyWith(
      messagingDisabled: false,
      messages: cleanedMessages,
      metaData: existing.metaData?.copyWith(blockedMessage: null),
    );

    await IsmChatConfig.dbWrapper?.saveConversation(conversation: updated);
    await IsmChatConfig.dbWrapper?.purgeBlockUnblockAndRefreshLastMessage(
      conversationId,
    );
    await _syncConversationInLists(updated);

    if (syncServerMetadataClear &&
        IsmChatUtility.conversationControllerRegistered) {
      unawaited(
        IsmChatUtility.conversationController.updateConversation(
          conversationId: conversationId,
          metaData: updated.metaData ?? IsmChatMetaData(),
          includeNullBlockedMessage: true,
        ),
      );
    }
  }

  /// After app restart / API hydration: ensure a block row exists when chat is disabled.
  static Future<void> ensureBlockBannerForDisabledChat(
    IsmChatConversationModel conversation,
  ) async {
    final convId = conversation.conversationId ?? '';
    if (convId.isEmpty || conversation.messagingDisabled != true) return;

    final existing = await IsmChatConfig.dbWrapper?.getConversation(convId);
    final messages = existing?.messages ?? const <String, IsmChatMessageModel>{};
    final hasBlockRow =
        messages.values.any((m) => m.customType == IsmChatCustomMessageType.block);
    if (hasBlockRow) return;

    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;
    final opponentId = conversation.opponentDetails?.userId ?? '';
    final isBlockedByMe = conversation.isBlockedByMe;
    final initiatorId = isBlockedByMe ? currentUserId : opponentId;
    final initiatorName = isBlockedByMe
        ? (IsmChatConfig.communicationConfig.userConfig.userName ?? '')
        : (conversation.opponentDetails?.userName ?? '');
    if (initiatorId.isEmpty) return;

    await applyBlock(
      conversationId: convId,
      bannerMessage: buildBannerMessage(
        isBlock: true,
        conversationId: convId,
        initiatorId: initiatorId,
        initiatorName: initiatorName,
        sentAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// MQTT entry: updates local DB, chat list, and open chat UI (user A and user B).
  static Future<void> handleMqttEvent(IsmChatMqttActionModel actionModel) async {
    final isBlock = isBlockAction(actionModel.action);
    final isUnblock = isUnblockAction(actionModel.action);
    if (!isBlock && !isUnblock) return;

    final conversationId = await resolveConversationIdFromMqtt(actionModel);
    if (conversationId.isEmpty) return;

    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;
    final initiatorId = actionModel.initiatorDetails?.userId ?? '';
    final initiatedByMe = initiatorId == currentUserId;

    if (isBlock) {
      await applyBlock(
        conversationId: conversationId,
        bannerMessage: bannerFromMqtt(
          actionModel,
          conversationId: conversationId,
          isBlock: true,
        ),
      );
      if (initiatedByMe && IsmChatUtility.conversationControllerRegistered) {
        final opponentId = actionModel.opponentDetails?.userId ?? '';
        if (opponentId.isNotEmpty) {
          _addOpponentToBlockUsersLocally(opponentId, actionModel);
        }
      }
    } else {
      await applyUnblock(
        conversationId: conversationId,
        syncServerMetadataClear: true,
      );
      if (initiatedByMe && IsmChatUtility.conversationControllerRegistered) {
        final opponentId = actionModel.opponentDetails?.userId ?? '';
        if (opponentId.isNotEmpty) {
          _removeOpponentFromBlockUsersLocally(opponentId);
        }
      }
    }

    await refreshChatPageIfOpen(conversationId);

    if (IsmChatUtility.conversationControllerRegistered) {
      final conversationController = IsmChatUtility.conversationController;
      if (initiatedByMe) {
        unawaited(conversationController.getBlockUser());
      }
      unawaited(conversationController.getChatConversations());
      conversationController.update();
    }
  }

  /// Reloads open chat page from local DB so user B sees banner + disabled input.
  static Future<void> refreshChatPageIfOpen(String conversationId) async {
    if (conversationId.isEmpty || !IsmChatUtility.chatPageControllerRegistered) {
      return;
    }

    final chatController = IsmChatUtility.chatPageController;
    if (chatController.conversation?.conversationId != conversationId) {
      return;
    }

    final cached = await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (cached != null) {
      chatController.conversation = chatController.conversation?.copyWith(
            messagingDisabled: cached.messagingDisabled,
            metaData: cached.metaData?.copyWith(blockedMessage: null),
          ) ??
          cached;
    }

    await pruneBlockBannersIfChatAllowed(conversationId);
    await chatController.getMessagesFromDB(conversationId);
    chatController.update();

    if (IsmChatUtility.conversationControllerRegistered) {
      final cc = IsmChatUtility.conversationController;
      cc.currentConversation = chatController.conversation;
      cc.update();
    }
  }

  static Future<void> _syncConversationInLists(
    IsmChatConversationModel updated,
  ) async {
    if (!IsmChatUtility.conversationControllerRegistered) return;
    final cc = IsmChatUtility.conversationController;
    final convId = updated.conversationId ?? '';
    if (convId.isEmpty) return;

    void patchList(List<IsmChatConversationModel> source) {
      final i = source.indexWhere((c) => c.conversationId == convId);
      if (i == -1) return;
      final next = List<IsmChatConversationModel>.from(source);
      next[i] = next[i].copyWith(
        messagingDisabled: updated.messagingDisabled,
        metaData:
            next[i].metaData?.copyWith(blockedMessage: null) ?? updated.metaData,
      );
      if (identical(source, cc.conversations)) {
        cc.conversations = next;
      } else {
        cc.suggestions = next;
      }
    }

    patchList(cc.conversations);
    patchList(cc.suggestions);

    if (cc.currentConversationId == convId) {
      cc.currentConversation = cc.currentConversation?.copyWith(
            messagingDisabled: updated.messagingDisabled,
            metaData: cc.currentConversation?.metaData
                ?.copyWith(blockedMessage: null),
          ) ??
          updated;
    }
  }

  static void _addOpponentToBlockUsersLocally(
    String opponentId,
    IsmChatMqttActionModel actionModel,
  ) {
    final cc = IsmChatUtility.conversationController;
    if (cc.blockUsers.any((u) => u.userId == opponentId)) return;
    final details = actionModel.opponentDetails;
    cc.blockUsers = [
      ...cc.blockUsers,
      UserDetails(
        userId: opponentId,
        userName: details?.userName ?? '',
        userIdentifier: details?.userIdentifier ?? '',
        userProfileImageUrl: details?.profileImageUrl ?? '',
        online: false,
        lastSeen: 0,
      ),
    ];
  }

  static void _removeOpponentFromBlockUsersLocally(String opponentId) {
    final cc = IsmChatUtility.conversationController;
    cc.blockUsers = List<UserDetails>.from(cc.blockUsers)
      ..removeWhere((u) => u.userId == opponentId);
  }
}
