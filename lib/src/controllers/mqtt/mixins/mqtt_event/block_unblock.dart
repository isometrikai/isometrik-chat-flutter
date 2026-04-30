import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Block/unblock mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling user block and unblock events.
mixin IsmChatMqttEventBlockUnblockMixin {
  Future<void> _purgeBlockUnblockAndRefreshLastMessage(String conversationId) =>
      IsmChatConfig.dbWrapper?.purgeBlockUnblockAndRefreshLastMessage(
        conversationId,
      ) ??
      Future.value();

  /// Clears local "blocked" state for a conversation.
  ///
  /// Important for the device that was blocked:
  /// - `ChatPage` injects the center banner from `conversation.metaData.blockedMessage`
  ///   (see `getMessagesFromDB()`), even if banner message rows were purged.
  /// - Conversation list can also remain in a disabled state if `messagingDisabled`
  ///   isn't refreshed locally yet.
  Future<void> _clearLocalBlockState(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    final existing = await IsmChatConfig.dbWrapper?.getConversation(
      conversationId,
    );
    if (existing == null) return;

    final updated = existing.copyWith(
      messagingDisabled: false,
      metaData: existing.metaData?.copyWith(blockedMessage: null),
    );
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: updated);
  }

  /// Applies local "blocked" state for a conversation (DB + cache).
  ///
  /// Needed because:
  /// - The center banner is injected from `conversation.metaData.blockedMessage`.
  /// - If the chat page isn't open when the MQTT event arrives, we still need
  ///   to persist this in local DB so when user opens the chat later the banner
  ///   and disabled state are still shown.
  Future<void> _applyLocalBlockState({
    required String conversationId,
    required IsmChatMqttActionModel actionModel,
  }) async {
    if (conversationId.trim().isEmpty) return;
    final existing = await IsmChatConfig.dbWrapper?.getConversation(
      conversationId,
    );
    if (existing == null) return;

    final blockMessage = IsmChatMessageModel(
      action: 'userBlockConversation',
      initiatorId: actionModel.initiatorDetails?.userId ?? '',
      initiatorName: actionModel.initiatorDetails?.userName ?? '',
      userId: actionModel.initiatorDetails?.userId ?? '',
      userName: actionModel.initiatorDetails?.userName ?? '',
      body: '',
      conversationId: conversationId,
      customType: IsmChatCustomMessageType.block,
      sentAt: actionModel.sentAt,
      sentByMe: false,
    );

    final updated = existing.copyWith(
      messagingDisabled: true,
      metaData: (existing.metaData ?? IsmChatMetaData()).copyWith(
        blockedMessage: blockMessage,
      ),
    );
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: updated);
  }

  /// Handles a block user or unblock event.
  ///
  /// * `actionModel`: The block user or unblock event model to handle
  void handleBlockUserOrUnBlock(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final isInitiatedByMe =
          utils.isSenderMe(actionModel.initiatorDetails?.userId);
      // Do not early-return for self-initiated block/unblock so UI updates instantly
      if (isInitiatedByMe &&
          !(actionModel.action == IsmChatActionEvents.userBlock ||
              actionModel.action == IsmChatActionEvents.userBlockConversation ||
              actionModel.action == IsmChatActionEvents.userUnblock ||
              actionModel.action ==
                  IsmChatActionEvents.userUnblockConversation)) {
        return;
      }
      if (IsmChatUtility.chatPageControllerRegistered) {
        var controller = IsmChatUtility.chatPageController;

        if (controller.conversation?.conversationId ==
            actionModel.conversationId) {
          // Create block/unblock message in metadata (same as direct block/unblock)
          final isBlockAction = actionModel.action ==
                  IsmChatActionEvents.userBlock ||
              actionModel.action == IsmChatActionEvents.userBlockConversation;
          final isUnblockAction = actionModel.action ==
                  IsmChatActionEvents.userUnblock ||
              actionModel.action == IsmChatActionEvents.userUnblockConversation;

          if (isBlockAction) {
            controller.conversation = controller.conversation?.copyWith(
              metaData: controller.conversation?.metaData?.copyWith(
                blockedMessage: IsmChatMessageModel(
                  action: 'userBlockConversation',
                  initiatorId: actionModel.initiatorDetails?.userId ?? '',
                  initiatorName: actionModel.initiatorDetails?.userName ?? '',
                  userId: actionModel.initiatorDetails?.userId ?? '',
                  userName: actionModel.initiatorDetails?.userName ?? '',
                  body: '',
                  conversationId: actionModel.conversationId ?? '',
                  customType: IsmChatCustomMessageType.block,
                  sentAt: actionModel.sentAt,
                  sentByMe: false,
                ),
              ),
            );
            // Persist block state even when chat page is open so it survives navigation.
            await _applyLocalBlockState(
              conversationId: actionModel.conversationId ?? '',
              actionModel: actionModel,
            );
          } else if (isUnblockAction) {
            // On unblock, clear the local blocked banner immediately.
            controller.conversation = controller.conversation?.copyWith(
              metaData: controller.conversation?.metaData?.copyWith(
                blockedMessage: null,
              ),
            );
            // If this device was previously blocked, it may still have cached
            // conversation metaData/messagingDisabled; clear it too.
            await _clearLocalBlockState(actionModel.conversationId ?? '');
            // Also remove persisted banner rows and refresh last message preview
            // so chat list doesn't stay stuck on "blocked" banner.
            await _purgeBlockUnblockAndRefreshLastMessage(
              actionModel.conversationId ?? '',
            );

            // Critical: clear server-side `metaData.blockedMessage` as well.
            // If we don't, periodic conversation-details sync can re-add the
            // blocked banner a few seconds later.
            final convId = actionModel.conversationId ?? '';
            if (convId.isNotEmpty && IsmChatUtility.conversationControllerRegistered) {
              unawaited(
                IsmChatUtility.conversationController.updateConversation(
                  conversationId: convId,
                  metaData: controller.conversation?.metaData ?? IsmChatMetaData(),
                  includeNullBlockedMessage: true,
                ),
              );
            }
          }

          if (isBlockAction || isUnblockAction) {
            await IsmChatUtility.conversationController.updateConversation(
              conversationId: actionModel.conversationId ?? '',
              metaData: controller.conversation?.metaData ?? IsmChatMetaData(),
            );
          }

          await controller.getConverstaionDetails();
          final lastTs = controller.messages.isNotEmpty
              ? controller.messages.last.sentAt
              : 0;
          await Future.delayed(const Duration(milliseconds: 600));
          await controller.getMessagesFromAPI(
            lastMessageTimestamp: lastTs,
          );
          await controller.getMessagesFromDB(actionModel.conversationId ?? '');
        }
      }

      // If chat page isn't open for this conversation, we still must persist the
      // local blocked banner state so it doesn't disappear when user opens chat later.
      final isBlockAction = actionModel.action == IsmChatActionEvents.userBlock ||
          actionModel.action == IsmChatActionEvents.userBlockConversation;
      if (isBlockAction) {
        await _applyLocalBlockState(
          conversationId: actionModel.conversationId ?? '',
          actionModel: actionModel,
        );
      }

      if (IsmChatUtility.conversationControllerRegistered) {
        final conversationController = IsmChatUtility.conversationController;
        await conversationController.getBlockUser();
        await conversationController.getChatConversations();
      }
    }
  }
}
