import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Calls mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling one-to-one call events.
mixin IsmChatMqttEventCallsMixin {
  /// Handles a one to one call event.
  ///
  /// * `actionModel`: The one to one call event model to handle
  void handleOneToOneCall(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.initiatorId)) return;
      if (vars.messageId == actionModel.sentAt.toString()) return;
      vars.messageId = actionModel.sentAt.toString();
      if (!IsmChatUtility.conversationControllerRegistered) {
        return;
      }
      unawaited(IsmChatUtility.conversationController.getChatConversations());
      if (!IsmChatUtility.chatPageControllerRegistered) {
        return;
      }
      final controller = IsmChatUtility.chatPageController;
      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getMessagesFromAPI(
          lastMessageTimestamp: controller.messages.last.sentAt,
        );
      }
    }
  }
}
