import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Broadcast mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling broadcast message events.
mixin IsmChatMqttEventBroadcastMixin {
  /// Handles a broadcast event.
  ///
  /// * `actionModel`: The broadcast event model to handle
  /// This method is called from event_processing.dart via mixin composition
  // ignore: unused_element
  void handleBroadcast(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.senderId)) return;
      await Future.delayed(const Duration(milliseconds: 100));

      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');

      if (conversation == null ||
          conversation.lastMessageDetails?.messageId == actionModel.messageId) {
        return;
      }

      // To handle and show last message & unread count in conversation list
      conversation = conversation.copyWith(
        unreadMessagesCount: IsmChatResponsive.isWeb(
                    IsmChatConfig.kNavigatorKey.currentContext ??
                        IsmChatConfig.context) &&
                (IsmChatUtility.chatPageControllerRegistered &&
                    IsmChatUtility
                            .chatPageController.conversation?.conversationId ==
                        actionModel.conversationId)
            ? 0
            : (conversation.unreadMessagesCount ?? 0) + 1,
        lastMessageDetails: conversation.lastMessageDetails?.copyWith(
          sentByMe: false,
          showInConversation: true,
          sentAt: actionModel.sentAt,
          senderName: actionModel.senderName,
          messageType: actionModel.messageType?.value ?? 0,
          messageId: actionModel.messageId ?? '',
          conversationId: actionModel.conversationId ?? '',
          body: actionModel.body,
          customType: actionModel.customType,
          action: '',
        ),
      );
      final message = IsmChatMessageModel(
        body: actionModel.body ?? '',
        sentAt: actionModel.sentAt,
        customType: actionModel.customType,
        sentByMe: false,
        messageId: actionModel.messageId,
        attachments: actionModel.attachments,
        conversationId: actionModel.conversationId,
        isGroup: false,
        messageType: actionModel.messageType,
        metaData: actionModel.metaData,
        senderInfo: UserDetails(
          userProfileImageUrl: '',
          userName: actionModel.senderName ?? '',
          userIdentifier: '',
          userId: actionModel.senderId ?? '',
          online: false,
          lastSeen: 0,
        ),
      );

      conversation.messages?.addEntries({message.key: message}.entries);
      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
      if (IsmChatUtility.conversationControllerRegistered) {
        unawaited(
            IsmChatUtility.conversationController.getConversationsFromDB());
        final controller = Get.find<IsmChatMqttController>();
        await controller.pingMessageDelivered(
          conversationId: actionModel.conversationId ?? '',
          messageId: actionModel.messageId ?? '',
        );
      }
      utils.handleUnreadMessages(message.senderInfo?.userId ?? '');
      if (!IsmChatUtility.chatPageControllerRegistered) {
        return;
      }
      final chatController = IsmChatUtility.chatPageController;
      if (chatController.conversation?.conversationId !=
          message.conversationId) {
        return;
      }
      unawaited(chatController.getMessagesFromDB(message.conversationId ?? ''));
      await Future.delayed(const Duration(milliseconds: 50));
      final controller = Get.find<IsmChatMqttController>();
      await controller.readSingleMessage(
        conversationId: message.conversationId ?? '',
        messageId: message.messageId ?? '',
      );
    }
  }
}
