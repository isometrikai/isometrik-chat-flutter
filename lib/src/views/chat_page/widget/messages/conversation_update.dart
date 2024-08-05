import 'package:flutter/material.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatConversationUpdate extends StatelessWidget {
  const IsmChatConversationUpdate(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageThemData
                  ?.backgroundColor ??
              IsmChatConfig.chatTheme.backgroundColor,
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
        padding: IsmChatDimens.edgeInsets8_4,
        child: Text(
          '${message.initiator} changed the ${message.customType == IsmChatCustomMessageType.conversationTitleUpdated ? 'title' : 'profile picture'} of the group',
          textAlign: TextAlign.center,
          style: IsmChatConfig
                  .chatTheme.chatPageTheme?.centerMessageThemData?.textStyle ??
              IsmChatStyles.w500Black12.copyWith(
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
        ),
      );
}
