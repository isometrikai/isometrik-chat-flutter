import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Observer operations mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling observer join and leave events.
mixin IsmChatMqttEventObserverOperationsMixin {
  /// Handles an observer join and leave event.
  ///
  /// * `actionModel`: The observer join and leave event model to handle
  void handleObserverJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.senderId)) return;
      final conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');
      if (conversation != null) {
        final message = IsmChatMessageModel(
          body: '',
          userName: actionModel.userDetails?.userName ?? '',
          customType: actionModel.customType,
          sentAt: actionModel.sentAt,
          sentByMe: false,
          senderInfo: UserDetails(
            userProfileImageUrl: actionModel.userDetails?.profileImageUrl ?? '',
            userName: actionModel.userDetails?.userName ?? '',
            userIdentifier: actionModel.userDetails?.userIdentifier ?? '',
            userId: actionModel.userDetails?.userId ?? '',
            online: true,
            lastSeen: 0,
          ),
          metaData: IsmChatMetaData(messageSentAt: actionModel.sentAt),
        );

        conversation.messages?.addEntries({message.key: message}.entries);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
        if (IsmChatUtility.chatPageControllerRegistered) {
          final chatController = IsmChatUtility.chatPageController;
          if (chatController.conversation?.conversationId ==
              message.conversationId) {
            await chatController
                .getMessagesFromDB(actionModel.conversationId ?? '');
          }
        }
        if (IsmChatUtility.conversationControllerRegistered) {
          unawaited(
              IsmChatUtility.conversationController.getConversationsFromDB());
        }
      }
    }
  }
}
