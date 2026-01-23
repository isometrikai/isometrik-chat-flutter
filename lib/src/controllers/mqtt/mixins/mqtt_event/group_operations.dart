import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Group operations mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling group-related events like member add/remove,
/// admin changes, and member join/leave.
mixin IsmChatMqttEventGroupOperationsMixin {
  /// Handles a group remove and add user event.
  ///
  /// * `actionModel`: The group remove and add user event model to handle
  void handleGroupRemoveAndAddUser(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      if (vars.messageId == actionModel.sentAt.toString()) return;
      vars.messageId = actionModel.sentAt.toString();

      if (!IsmChatUtility.conversationControllerRegistered) {
        return;
      }
      final conversationController = IsmChatUtility.conversationController;
      if (actionModel.action == IsmChatActionEvents.addMember) {
        await conversationController.getChatConversations();
      }

      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(actionModel.conversationId ?? '');
      final allMessages = conversation?.messages;
      allMessages?.addEntries(
        {
          '${actionModel.sentAt}': IsmChatMessageModel(
            members: actionModel.members,
            initiatorId: actionModel.userDetails?.userId,
            initiatorName: actionModel.userDetails?.userName,
            customType:
                IsmChatCustomMessageType.fromString(actionModel.action.name),
            body: '',
            sentAt: actionModel.sentAt,
            sentByMe: false,
            isGroup: true,
            conversationId: actionModel.conversationId,
            memberId: actionModel.members?.first.memberId,
            memberName: actionModel.members?.first.memberName,
            senderInfo: UserDetails(
              userProfileImageUrl:
                  actionModel.userDetails?.profileImageUrl ?? '',
              userName: actionModel.userDetails?.userName ?? '',
              userIdentifier: actionModel.userDetails?.userIdentifier ?? '',
              userId: actionModel.userDetails?.userId ?? '',
              online: true,
              lastSeen: 0,
            ),
          )
        }.entries,
      );

      if (IsmChatUtility.chatPageControllerRegistered) {
        final chatPageController = IsmChatUtility.chatPageController;
        if (actionModel.conversationId ==
            chatPageController.conversation?.conversationId) {
          chatPageController.conversation =
              chatPageController.conversation?.copyWith(
            lastMessageDetails: LastMessageDetails(
              sentByMe: false,
              showInConversation: true,
              sentAt: actionModel.sentAt,
              senderName: actionModel.userDetails?.userName ?? '',
              messageType: 0,
              messageId: '',
              conversationId: actionModel.conversationId ?? '',
              body: '',
              customType:
                  IsmChatCustomMessageType.fromString(actionModel.action.name),
              senderId: actionModel.userDetails?.userId ?? '',
              userId: actionModel.members?.first.memberId,
              members:
                  actionModel.members?.map((e) => e.memberName ?? '').toList(),
              reactionType: '',
            ),
          );
          await chatPageController
              .getMessagesFromDB(actionModel.conversationId ?? '');
        }
      }
      if (actionModel.action == IsmChatActionEvents.membersRemove) {
        if (conversation != null) {
          conversation.lastMessageDetails?.copyWith(
            sentByMe: false,
            showInConversation: true,
            sentAt: actionModel.sentAt,
            senderName: actionModel.userDetails?.userName ?? '',
            messageType: 0,
            messageId: '',
            conversationId: actionModel.conversationId ?? '',
            body: '',
            customType:
                IsmChatCustomMessageType.fromString(actionModel.action.name),
            senderId: actionModel.userDetails?.userId ?? '',
            userId: actionModel.members?.first.memberId,
            members: actionModel.members
                ?.map((e) => e.memberName.toString())
                .toList(),
            reactionType: '',
          );
          conversation = conversation.copyWith(unreadMessagesCount: 0);
          await IsmChatConfig.dbWrapper
              ?.saveConversation(conversation: conversation);
          await conversationController.getConversationsFromDB();
        }
      }
    }
  }

  /// Handles a member join and leave event.
  ///
  /// * `actionModel`: The member join and leave event model to handle
  void handleMemberJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      if (vars.messageId == actionModel.sentAt.toString()) return;
      vars.messageId = actionModel.sentAt.toString();
      if (IsmChatUtility.chatPageControllerRegistered) {
        var controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
                actionModel.conversationId &&
            controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
          await controller.getMessagesFromAPI(
            lastMessageTimestamp: controller.messages.last.sentAt,
          );
        }
      }
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
  }

  /// Handles an admin remove and add event.
  ///
  /// * `actionModel`: The admin remove and add event model to handle
  void handleAdminRemoveAndAdd(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (utils.isSenderMe(actionModel.userDetails?.userId)) return;
      if (vars.messageId == actionModel.sentAt.toString()) return;
      vars.messageId = actionModel.sentAt.toString();
      if (IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (controller.conversation?.conversationId ==
                actionModel.conversationId &&
            actionModel.memberId ==
                IsmChatConfig.communicationConfig.userConfig.userId &&
            controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
          await controller.getMessagesFromAPI(
            lastMessageTimestamp: controller.messages.last.sentAt,
          );
        }
      }
      if (actionModel.memberId ==
              IsmChatConfig.communicationConfig.userConfig.userId &&
          IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    }
  }
}
