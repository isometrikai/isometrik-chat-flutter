import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Conversation operations mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling conversation-related events.
mixin IsmChatMqttEventConversationOperationsMixin {
  /// Handles the creation of a new conversation event.
  ///
  /// * `actionModel`: the creation of a new conversation event model to handle
  // ignore: unused_element
  // This method is called from event_processing.dart via mixin composition
  Future<void> handleCreateConversation(
      IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      utils.showPushNotification(
        title: actionModel.userDetails?.userName ?? '',
        body: 'Conversation Created',
        data: actionModel.toMap(),
      );
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
  }

  /// Handles updates to conversation details (e.g. conversationDetailsUpdated).
  ///
  /// When the recipient is already on the chat screen, refresh from local DB
  /// first (block banner is Option A message rows) and fetch conversation
  /// details in the background so the banner is not blocked on the API round trip.
  ///
  /// * `actionModel`: The action model containing updated conversation details.
  void handleConversationUpdate(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      final convId = actionModel.conversationId ?? '';
      if (IsmChatUtility.chatPageControllerRegistered &&
          convId.isNotEmpty &&
          IsmChatUtility.chatPageController.conversation?.conversationId ==
              convId) {
        final controller = IsmChatUtility.chatPageController;
        controller.isCoverationApiDetails = true;
        await IsmChatBlockUnblockCoordinator.refreshChatPageIfOpen(convId);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!IsmChatUtility.chatPageControllerRegistered) return;
          final c = IsmChatUtility.chatPageController;
          if (c.conversation?.conversationId != convId) return;
          c.update();
          if (IsmChatUtility.conversationControllerRegistered) {
            IsmChatUtility.conversationController.currentConversation =
                c.conversation;
            IsmChatUtility.conversationController.update();
          }
        });
        unawaited(controller.getConverstaionDetails().then((_) {
          if (!IsmChatUtility.chatPageControllerRegistered) return;
          final c = IsmChatUtility.chatPageController;
          if (c.conversation?.conversationId != convId) return;
          c.update();
        }));
        if (controller.messages.isNotEmpty) {
          unawaited(controller.getMessagesFromAPI(
            lastMessageTimestamp: controller.messages.last.sentAt,
          ));
        } else {
          unawaited(controller.getMessagesFromAPI());
        }
      }
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
  }

  /// Handles deletion of chat from local storage.
  ///
  /// * `actionModel`: The action model containing details for deletion.
  void handleDeletChatFromLocal(IsmChatMqttActionModel actionModel) async {
    if (IsmChatProperties.chatPageProperties.isAllowedDeleteChatFromLocal) {
      final controller = Get.find<IsmChatMqttController>();
      final deleteChat = await controller.deleteChatFormDB('',
          conversationId: actionModel.conversationId ?? '');

      if (deleteChat && IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
  }
}
