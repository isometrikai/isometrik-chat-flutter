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

  /// Handles updates to conversation details.
  ///
  /// * `actionModel`: The action model containing updated conversation details.
  void handleConversationUpdate(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      if (IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
            actionModel.conversationId) {
          await controller.getConverstaionDetails();
          if (controller.messages.isNotEmpty) {
            await controller.getMessagesFromAPI(
              lastMessageTimestamp: controller.messages.last.sentAt,
            );
          } else {
            await controller.getMessagesFromAPI();
          }
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
