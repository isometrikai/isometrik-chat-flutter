import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Typing events mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling typing indicator events.
mixin IsmChatMqttEventTypingEventsMixin {
  /// Handles a typing event.
  ///
  /// * `actionModel`: The typing event model to handle
  // ignore: unused_element
  // This method is called from event_processing.dart via mixin composition
  void handleTypingEvent(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
//this is to update user status when they are typing(if lastTimestamp logic is removed , remove this code too)
      // Call conversation details API when typing event is received to refresh online status
      if (IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
            actionModel.conversationId) {
          // Trigger conversation details update to refresh opponent's online status
          unawaited(controller.getConverstaionDetails());
        }
      }

      final user = IsmChatTypingModel(
        conversationId: actionModel.conversationId ?? '',
        userName: actionModel.userDetails?.userName ?? '',
      );
      (self as IsmChatMqttEventVariablesMixin).typingUsers.add(user);
      await Future.delayed(
        const Duration(seconds: 2),
        () {
          (self as IsmChatMqttEventVariablesMixin).typingUsers.remove(user);
        },
      );
    }
  }
}
