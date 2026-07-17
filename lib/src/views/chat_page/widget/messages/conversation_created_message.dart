import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationCreatedMessage extends StatelessWidget {
  const IsmChatConversationCreatedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final conversation = IsmChatUtility.chatPageController.conversation;
    final customWidget = IsmChatProperties
        .chatPageProperties.conversationCreatedMessageBuilder
        ?.call(
      context,
      message,
      conversation,
    );
    if (customWidget != null) {
      return customWidget;
    }

    var name = '';
    if (IsmChatProperties.chatPageProperties.messageSenderName?.call(
          context,
          message,
          conversation,
        ) !=
        null) {
      name = IsmChatProperties.chatPageProperties.messageSenderName?.call(
            context,
            message,
            conversation,
          ) ??
          '';
    } else {
      name = message.userName ?? '';
    }
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageTheme
                  ?.backgroundColor ??
              IsmChatConfig.chatTheme.backgroundColor,
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
        padding: IsmChatDimens.edgeInsets8_4,
        child: Text(
          message.isGroup == true
              ? (message.userId ==
                      IsmChatConfig.communicationConfig.userConfig.userId
                  ? IsmChatStrings.youCreatedGroup
                  : '${name.trim().isNotEmpty ? name : message.userName} created a group')
              : 'Messages are end to end encrypted. No one outside of this chat can read your messages.',
          style: IsmChatConfig
                  .chatTheme.chatPageTheme?.centerMessageTheme?.textStyle ??
              IsmChatStyles.w500Black12.copyWith(
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
