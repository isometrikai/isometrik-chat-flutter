import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Message status mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling message delivery and read status events.
mixin IsmChatMqttEventMessageStatusMixin {
  /// Handles a message delivered event.
  ///
  /// * `actionModel`: The message delivered event model to handle
  // ignore: unused_element
  // This method is called from event_processing.dart via mixin composition
  void handleMessageDelivered(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;

      vars.deliverdActions.add(actionModel);
      final actionsData =
          List<IsmChatMqttActionModel>.from(vars.deliverdActions);
      vars.ismChatActionDebounce.run(() async {
        for (final action in actionsData) {
          var conversation = await IsmChatConfig.dbWrapper
              ?.getConversation(action.conversationId ?? '');
          final message = conversation?.messages?.values
              .cast<IsmChatMessageModel?>()
              .firstWhere(
                (e) => e?.messageId == action.messageId,
                orElse: () => null,
              );
          if (message != null) {
            final isDelivered = message.deliveredTo
                ?.any((e) => e.userId == action.userDetails?.userId);
            if (isDelivered == false) {
              message.deliveredTo?.add(
                MessageStatus(
                  userId: action.userDetails?.userId ?? '',
                  timestamp: action.sentAt,
                ),
              );
            }
            message.deliveredToAll = message.deliveredTo?.length ==
                (conversation?.membersCount ?? 0) - 1;
            conversation?.messages?[message.key] = message;
            conversation = conversation?.copyWith(
              lastMessageDetails: conversation.lastMessageDetails?.copyWith(
                deliverCount: message.deliveredTo?.length,
                deliveredTo: message.deliveredTo,
              ),
            );
            await IsmChatConfig.dbWrapper
                ?.saveConversation(conversation: conversation!);
            if (IsmChatUtility.chatPageControllerRegistered) {
              await IsmChatUtility.chatPageController
                  .getMessagesFromDB(action.conversationId ?? '');
            }
            if (IsmChatUtility.conversationControllerRegistered) {
              unawaited(IsmChatUtility.conversationController
                  .getConversationsFromDB());
            }
          }
          vars.deliverdActions.remove(action);
        }
      });
    }
  }

  /// Handles a message read event.
  ///
  /// * `actionModel`: The message read event model to handle
  // ignore: unused_element
  // This method is called from event_processing.dart via mixin composition
  void handleMessageRead(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      vars.readActions.add(actionModel);
      vars.ismChatActionDebounce.run(() async {
        final actionsData = List<IsmChatMqttActionModel>.from(vars.readActions);
        for (var action in actionsData) {
          var conversation = await IsmChatConfig.dbWrapper
              ?.getConversation(action.conversationId ?? '');
          final message = conversation?.messages?.values
              .cast<IsmChatMessageModel?>()
              .firstWhere(
                (e) => e?.messageId == action.messageId,
                orElse: () => null,
              );
          if (message != null) {
            final isRead = message.readBy
                ?.any((e) => e.userId == action.userDetails?.userId);
            if (isRead == false) {
              message.readBy?.add(
                MessageStatus(
                  userId: action.userDetails?.userId ?? '',
                  timestamp: action.sentAt,
                ),
              );
            }
            message.readByAll =
                message.readBy?.length == (conversation?.membersCount ?? 0) - 1;
            // If readByAll is true, deliveredToAll must also be true
            // (you can't read a message that hasn't been delivered)
            if (message.readByAll == true) {
              message.deliveredToAll = true;
            }
            conversation?.messages?[message.key] = message;
            conversation = conversation?.copyWith(
              lastMessageDetails: conversation.lastMessageDetails?.copyWith(
                readCount: message.readBy?.length,
                readBy: message.readBy,
              ),
            );
            await IsmChatConfig.dbWrapper
                ?.saveConversation(conversation: conversation!);
            if (IsmChatUtility.chatPageControllerRegistered) {
              await IsmChatUtility.chatPageController
                  .getMessagesFromDB(action.conversationId ?? '');
            }
            if (IsmChatUtility.conversationControllerRegistered) {
              unawaited(IsmChatUtility.conversationController
                  .getConversationsFromDB());
            }
          }
          vars.readActions.remove(action);
        }
      });
    }
  }

  /// Handles a multiple message read event.
  ///
  /// * `actionModel`: The multiple message read event model to handle
  void handleMultipleMessageRead(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');
      if (conversation != null) {
        final allMessages = conversation.messages ?? {};
        final modifiedMessages = {};
        for (var message in allMessages.values) {
          if (message.deliveredToAll == true && message.readByAll == true) {
            modifiedMessages.addEntries({message.key: message}.entries);
          } else {
            final isDelivered = message.deliveredTo
                ?.any((e) => e.userId == actionModel.userDetails?.userId);
            final isRead = message.readBy
                ?.any((e) => e.userId == actionModel.userDetails?.userId);
            final deliveredTo = message.deliveredTo ?? [];
            final readBy = message.readBy ?? [];
            var modified = message.copyWith(
              deliveredTo: isDelivered == true
                  ? deliveredTo
                  : [
                      ...deliveredTo,
                      MessageStatus(
                        userId: actionModel.userDetails?.userId ?? '',
                        timestamp: actionModel.sentAt,
                      ),
                    ],
              readBy: isRead == true
                  ? readBy
                  : [
                      ...readBy,
                      MessageStatus(
                        userId: actionModel.userDetails?.userId ?? '',
                        timestamp: actionModel.sentAt,
                      ),
                    ],
            );

            final readByAllValue =
                modified.readBy?.length == (conversation.membersCount ?? 0) - 1;
            final deliveredToAllValue = modified.deliveredTo?.length ==
                    (conversation.membersCount ?? 0) - 1
                ? true
                : false;

            modified = modified.copyWith(
              readByAll: readByAllValue,
              // If readByAll is true, deliveredToAll must also be true
              // (you can't read a message that hasn't been delivered)
              deliveredToAll: readByAllValue ? true : deliveredToAllValue,
            );

            modifiedMessages.addEntries(
                {'${modified.metaData?.messageSentAt}': modified}.entries);
          }
        }
        final meesages = IsmChatMessages.from(modifiedMessages);
        conversation = conversation.copyWith(
          messages: meesages,
          lastMessageDetails: conversation.lastMessageDetails?.copyWith(
            deliverCount: meesages.isEmpty
                ? 1
                : meesages.values.last.deliveredTo?.length ?? 0,
            readCount:
                meesages.isEmpty ? 1 : meesages.values.last.readBy?.length ?? 0,
            readBy: meesages.isEmpty ? [] : meesages.values.last.readBy,
            deliveredTo:
                meesages.isEmpty ? [] : meesages.values.last.deliveredTo,
          ),
        );

        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }
      if (IsmChatUtility.chatPageControllerRegistered) {
        var controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
            actionModel.conversationId) {
          await controller.getMessagesFromDB(actionModel.conversationId ?? '');
        }
      }
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getConversationsFromDB();
      }
    }
  }

  /// Handles a message delete for everyone event.
  ///
  /// * `actionModel`: The message delete for everyone event model to handle
  void handleMessageDelelteForEveryOne(
      IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');
      final allMessages = conversation?.messages;
      if (allMessages == null) return;
      if (actionModel.messageIds?.isNotEmpty == true) {
        for (final x in actionModel.messageIds ?? []) {
          final message = allMessages.values
              .cast<IsmChatMessageModel?>()
              .firstWhere((e) => e?.messageId == x, orElse: () => null);
          if (message != null) {
            allMessages[message.key] = message.copyWith(
              customType: IsmChatCustomMessageType.deletedForEveryone,
              reactions: [],
            );
          }
        }
      }
      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }

      if (IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
            actionModel.conversationId) {
          await controller.getMessagesFromDB(actionModel.conversationId ?? '');
        }
      }
    }
  }
}
