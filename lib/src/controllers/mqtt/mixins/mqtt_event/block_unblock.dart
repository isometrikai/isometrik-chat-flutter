import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Block/unblock mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling user block and unblock events.
mixin IsmChatMqttEventBlockUnblockMixin {
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
      if (IsmChatUtility.conversationControllerRegistered) {
        final conversationController = IsmChatUtility.conversationController;
        await conversationController.getBlockUser();
        await conversationController.getChatConversations();
      }
    }
  }
}
