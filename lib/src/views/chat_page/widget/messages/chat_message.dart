import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/models/models.dart';
import 'package:isometrik_chat_flutter/src/utilities/utilities.dart';
import 'package:isometrik_chat_flutter/src/views/chat_page/widget/messages/messages.dart';

class IsmChatMessageWrapper extends StatelessWidget {
  IsmChatMessageWrapper(
    this.message, {
    super.key,
  }) : messageType = message.customType ?? IsmChatCustomMessageType.date;

  final IsmChatMessageModel message;
  final IsmChatCustomMessageType messageType;

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case IsmChatCustomMessageType.text:
        return IsmChatTextMessage(message);

      case IsmChatCustomMessageType.reply:
        return IsmChatReplyMessage(message);

      case IsmChatCustomMessageType.forward:
        return IsmChatForwardMessage(message);

      case IsmChatCustomMessageType.image:
        return IsmChatImageMessage(message);

      case IsmChatCustomMessageType.video:
        return IsmChatVideoMessage(message);

      case IsmChatCustomMessageType.audio:
        return IsmChatAudioMessage(message);

      case IsmChatCustomMessageType.file:
        return IsmChatFileMessage(message);

      case IsmChatCustomMessageType.location:
        return IsmChatLocationMessage(message);

      case IsmChatCustomMessageType.block:
        return IsmChatBlockedMessage(message);

      case IsmChatCustomMessageType.unblock:
        return IsmChatBlockedMessage(message);

      case IsmChatCustomMessageType.deletedForMe:
        return IsmChatDeletedMessage(message);

      case IsmChatCustomMessageType.deletedForEveryone:
        return IsmChatDeletedMessage(message);

      case IsmChatCustomMessageType.link:
        return IsmChatLinkMessage(message);

      case IsmChatCustomMessageType.date:
        return IsmChatDateMessage(message);

      case IsmChatCustomMessageType.aboutText:
        return IsmChatAboutTextMessage(message);

      case IsmChatCustomMessageType.conversationCreated:
        return IsmChatConversationCreatedMessage(message);

      case IsmChatCustomMessageType.removeMember:
        return IsmChatAddRemoveMember(message, isAdded: false);

      case IsmChatCustomMessageType.addMember:
        return IsmChatAddRemoveMember(message);

      case IsmChatCustomMessageType.addAdmin:
        return IsmChatAddRevokeAdmin(message);

      case IsmChatCustomMessageType.removeAdmin:
        return IsmChatAddRevokeAdmin(message, isAdded: false);

      case IsmChatCustomMessageType.memberLeave:
        return IsmChatMemberLeaveAndJoin(message, didLeft: true);

      case IsmChatCustomMessageType.conversationTitleUpdated:
      case IsmChatCustomMessageType.conversationImageUpdated:
        return IsmChatConversationUpdate(message);

      case IsmChatCustomMessageType.contact:
        return IsmChatContactMessage(message);

      case IsmChatCustomMessageType.memberJoin:
        return IsmChatMemberLeaveAndJoin(message, didLeft: false);

      case IsmChatCustomMessageType.observerJoin:
        return IsmChatObserverLeaveAndJoin(message);
      case IsmChatCustomMessageType.observerLeave:
        return IsmChatObserverLeaveAndJoin(message, didLeft: true);
      case IsmChatCustomMessageType.oneToOneCall:
        return IsmOneToOneCallMessage(message);
    }
  }
}

class IsmChatMessageWrapperWithMetaData extends StatelessWidget {
  IsmChatMessageWrapperWithMetaData(
    this.message, {
    super.key,
  }) : replayMessageCustomType =
            message.metaData?.replyMessage?.forMessageType ??
                IsmChatCustomMessageType.text;

  final IsmChatMessageModel message;
  final IsmChatCustomMessageType replayMessageCustomType;

  @override
  Widget build(BuildContext context) {
    switch (replayMessageCustomType) {
      case IsmChatCustomMessageType.text:
        return IsmChatTextMessage(message);

      case IsmChatCustomMessageType.reply:
        return IsmChatReplyMessage(message);

      case IsmChatCustomMessageType.forward:
        return IsmChatForwardMessage(message);

      case IsmChatCustomMessageType.image:
        return IsmChatImageMessage(message);

      case IsmChatCustomMessageType.video:
        return IsmChatVideoMessage(message);

      case IsmChatCustomMessageType.audio:
        return IsmChatAudioMessage(message);

      case IsmChatCustomMessageType.file:
        return IsmChatFileMessage(message);

      case IsmChatCustomMessageType.location:
        return IsmChatLocationMessage(message);

      case IsmChatCustomMessageType.block:
        return IsmChatBlockedMessage(message);

      case IsmChatCustomMessageType.unblock:
        return IsmChatBlockedMessage(message);

      case IsmChatCustomMessageType.deletedForMe:
        return IsmChatDeletedMessage(message);

      case IsmChatCustomMessageType.deletedForEveryone:
        return IsmChatDeletedMessage(message);

      case IsmChatCustomMessageType.link:
        return IsmChatLinkMessage(message);

      case IsmChatCustomMessageType.date:
        return IsmChatDateMessage(message);

      case IsmChatCustomMessageType.aboutText:
        return IsmChatAboutTextMessage(message);

      case IsmChatCustomMessageType.conversationCreated:
        return IsmChatConversationCreatedMessage(message);

      case IsmChatCustomMessageType.removeMember:
        return IsmChatAddRemoveMember(message, isAdded: false);

      case IsmChatCustomMessageType.addMember:
        return IsmChatAddRemoveMember(message);

      case IsmChatCustomMessageType.addAdmin:
        return IsmChatAddRevokeAdmin(message);

      case IsmChatCustomMessageType.removeAdmin:
        return IsmChatAddRevokeAdmin(message, isAdded: false);

      case IsmChatCustomMessageType.memberLeave:
        return IsmChatMemberLeaveAndJoin(message, didLeft: true);

      case IsmChatCustomMessageType.conversationTitleUpdated:
      case IsmChatCustomMessageType.conversationImageUpdated:
        return IsmChatConversationUpdate(message);

      case IsmChatCustomMessageType.contact:
        return IsmChatContactMessage(message);

      case IsmChatCustomMessageType.memberJoin:
        return IsmChatMemberLeaveAndJoin(message, didLeft: false);

      case IsmChatCustomMessageType.observerJoin:
        return IsmChatObserverLeaveAndJoin(message);

      case IsmChatCustomMessageType.observerLeave:
        return IsmChatObserverLeaveAndJoin(message, didLeft: true);

      case IsmChatCustomMessageType.oneToOneCall:
        return IsmOneToOneCallMessage(message);
    }
  }
}
