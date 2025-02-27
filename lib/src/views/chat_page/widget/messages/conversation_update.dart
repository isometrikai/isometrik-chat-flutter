import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationUpdate extends StatelessWidget {
  const IsmChatConversationUpdate(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageTheme
                  ?.backgroundColor ??
              IsmChatConfig.chatTheme.backgroundColor,
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
        padding: IsmChatDimens.edgeInsets8_4,
        child: Text(
          '${message.initiator} changed the ${message.customType == IsmChatCustomMessageType.conversationTitleUpdated ? 'title' : 'profile picture'} of the group',
          textAlign: TextAlign.center,
          style: IsmChatConfig
                  .chatTheme.chatPageTheme?.centerMessageTheme?.textStyle ??
              IsmChatStyles.w500Black12.copyWith(
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
        ),
      );
}
