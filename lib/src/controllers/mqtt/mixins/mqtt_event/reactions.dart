import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Reactions mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling message reaction events.
mixin IsmChatMqttEventReactionsMixin
     {
  /// Handles an add and remove reaction event.
  ///
  /// * `actionModel`: The add and remove reaction event model to handle
  void handleAddAndRemoveReaction(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');
      final allMessages = conversation?.messages;
    if (allMessages != null) {
      final message = allMessages.entries
          .where((e) => e.value.messageId == actionModel.messageId)
          .first;
      var isEmoji = false;

      if (actionModel.action == IsmChatActionEvents.reactionAdd) {
        for (var x in message.value.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType) {
            x.userIds.add(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
            break;
          }
        }
        if (isEmoji == false) {
          message.value.reactions ??= [];
          message.value.reactions?.add(
            MessageReactionModel(
              emojiKey: actionModel.reactionType ?? '',
              userIds: [actionModel.userDetails?.userId ?? ''],
            ),
          );
        }
      } else {
        for (var x in message.value.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType && x.userIds.length > 1) {
            x.userIds.remove(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
          }
        }

        if (isEmoji == false) {
          message.value.reactions ??= [];
          message.value.reactions
              ?.removeWhere((e) => e.emojiKey == actionModel.reactionType);
        }
      }
      allMessages[message.key] = message.value;

      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
        if (IsmChatUtility.chatPageControllerRegistered) {
          var controller = IsmChatUtility.chatPageController;
          if (controller.conversation?.conversationId ==
              actionModel.conversationId) {
            await IsmChatUtility.chatPageController
                .getMessagesFromDB(actionModel.conversationId ?? '');
          }
        }
      }
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
    }
  }
}

