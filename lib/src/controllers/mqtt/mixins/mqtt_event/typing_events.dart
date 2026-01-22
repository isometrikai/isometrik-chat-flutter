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
