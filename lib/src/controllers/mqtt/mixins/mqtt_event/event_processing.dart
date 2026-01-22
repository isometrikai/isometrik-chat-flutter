import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/block_unblock.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/broadcast.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/calls.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/conversation_operations.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/group_operations.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/message_handlers.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/message_status.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/observer_operations.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/reactions.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/typing_events.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Event processing mixin for IsmChatMqttEventMixin.
///
/// This mixin contains the main event processing logic including event routing
/// and queue management.
mixin IsmChatMqttEventProcessingMixin {
  /// Handles incoming MQTT events and routes them to appropriate handlers.
  ///
  /// - `event`: The MQTT event to process
  void onMqttEvent({required EventModel event}) async {
    final self = this;
    if (self is IsmChatMqttEventVariablesMixin) {
      (self as IsmChatMqttEventVariablesMixin).eventStreamController.add(event);
    }
    final payload = event.payload;
    if (!['chatMessageSentBulk', 'chatMessageSent']
        .contains(payload['action'])) {
      final action = payload['action'];
      if (IsmChatActionEvents.values
          .map((e) => e.toString())
          .contains(action)) {
        final actionModel = IsmChatMqttActionModel.fromMap(payload);
        _handleAction(actionModel);
      }
    } else {
      final message = IsmChatMessageModel.fromMap(payload);
      final self = this;
      if (self is IsmChatMqttEventVariablesMixin) {
        final vars = self as IsmChatMqttEventVariablesMixin;
        if (vars.messageId == message.messageId) return;
        vars.messageId = message.messageId ?? '';
        if (self is IsmChatMqttEventMessageHandlersMixin) {
          (self as IsmChatMqttEventMessageHandlersMixin)
              .handleLocalNotification(message);
        }
        vars.deliverdActions.clear();
        vars.readActions.clear();
        vars.eventQueue.add(message);
        if (!vars.isEventProcessing) {
          _eventProcessQueue();
        }
      }
    }
  }

  /// Processes the event queue.
  ///
  /// This method is called when the event queue is not empty and event processing is not in progress.
  void _eventProcessQueue() async {
    // Access variables from VariablesMixin - available when mixins are composed
    final self = this;
    if (self is IsmChatMqttEventVariablesMixin) {
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (vars.isEventProcessing) return;
      vars.isEventProcessing = true;
      try {
        while (vars.eventQueue.isNotEmpty) {
          final event = vars.eventQueue.removeFirst();
          if (self is IsmChatMqttEventMessageHandlersMixin) {
            await (self as IsmChatMqttEventMessageHandlersMixin)
                .handleMessage(event);
          }
        }
      } catch (e, stack) {
        IsmChatLog.error(
            'Error during event processing: $e Stack trace: $stack ');
      } finally {
        vars.isEventProcessing = false;
      }
    }
  }

  /// Handles an MQTT action.
  ///
  /// * `actionModel`: The MQTT action model to handle
  void _handleAction(IsmChatMqttActionModel actionModel) async {
    final self = this;
    switch (actionModel.action) {
      case IsmChatActionEvents.typingEvent:
        if (self is IsmChatMqttEventTypingEventsMixin) {
          (self as IsmChatMqttEventTypingEventsMixin)
              .handleTypingEvent(actionModel);
        }
        break;
      case IsmChatActionEvents.conversationCreated:
        if (self is IsmChatMqttEventConversationOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          await (self as IsmChatMqttEventConversationOperationsMixin)
              .handleCreateConversation(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.messageDelivered:
        if (self is IsmChatMqttEventMessageStatusMixin) {
          (self as IsmChatMqttEventMessageStatusMixin)
              .handleMessageDelivered(actionModel);
        }
        break;
      case IsmChatActionEvents.messageRead:
        if (self is IsmChatMqttEventMessageStatusMixin) {
          (self as IsmChatMqttEventMessageStatusMixin)
              .handleMessageRead(actionModel);
        }
        break;
      case IsmChatActionEvents.messagesDeleteForAll:
        if (self is IsmChatMqttEventMessageStatusMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventMessageStatusMixin)
              .handleMessageDelelteForEveryOne(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.multipleMessagesRead:
        if (self is IsmChatMqttEventMessageStatusMixin) {
          (self as IsmChatMqttEventMessageStatusMixin)
              .handleMultipleMessageRead(actionModel);
        }
        break;
      case IsmChatActionEvents.userBlock:
      case IsmChatActionEvents.userUnblock:
      case IsmChatActionEvents.userBlockConversation:
      case IsmChatActionEvents.userUnblockConversation:
        if (self is IsmChatMqttEventBlockUnblockMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventBlockUnblockMixin)
              .handleBlockUserOrUnBlock(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.initiatorDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.clearConversation:
        break;
      case IsmChatActionEvents.deleteConversationLocally:
        if (self is IsmChatMqttEventConversationOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventConversationOperationsMixin)
              .handleDeletChatFromLocal(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.memberLeave:
      case IsmChatActionEvents.memberJoin:
        if (self is IsmChatMqttEventGroupOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventGroupOperationsMixin)
              .handleMemberJoinAndLeave(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.addMember:
      case IsmChatActionEvents.membersRemove:
        if (self is IsmChatMqttEventGroupOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventGroupOperationsMixin)
              .handleGroupRemoveAndAddUser(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.removeAdmin:
      case IsmChatActionEvents.addAdmin:
        if (self is IsmChatMqttEventGroupOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventGroupOperationsMixin)
              .handleAdminRemoveAndAdd(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.reactionAdd:
      case IsmChatActionEvents.reactionRemove:
        if (self is IsmChatMqttEventReactionsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventReactionsMixin)
              .handleAddAndRemoveReaction(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.conversationDetailsUpdated:
      case IsmChatActionEvents.conversationTitleUpdated:
      case IsmChatActionEvents.conversationImageUpdated:
        if (self is IsmChatMqttEventConversationOperationsMixin &&
            self is IsmChatMqttEventUtilitiesMixin) {
          (self as IsmChatMqttEventConversationOperationsMixin)
              .handleConversationUpdate(actionModel);
          (self as IsmChatMqttEventUtilitiesMixin)
              .handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        }
        break;
      case IsmChatActionEvents.broadcast:
        if (self is IsmChatMqttEventBroadcastMixin) {
          (self as IsmChatMqttEventBroadcastMixin).handleBroadcast(actionModel);
        }
        break;
      case IsmChatActionEvents.observerJoin:
      case IsmChatActionEvents.observerLeave:
        if (self is IsmChatMqttEventObserverOperationsMixin) {
          (self as IsmChatMqttEventObserverOperationsMixin)
              .handleObserverJoinAndLeave(actionModel);
        }
        break;
      case IsmChatActionEvents.userUpdate:
      case IsmChatActionEvents.messageDetailsUpdated:
        break;
      case IsmChatActionEvents.meetingCreated:
      case IsmChatActionEvents.meetingEndedByHost:
      case IsmChatActionEvents.meetingEndedDueToRejectionByAll:
        if (self is IsmChatMqttEventCallsMixin) {
          (self as IsmChatMqttEventCallsMixin).handleOneToOneCall(actionModel);
        }
        break;
    }
  }
}
