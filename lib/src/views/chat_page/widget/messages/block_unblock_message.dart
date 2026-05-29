import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBlockedMessage extends StatelessWidget {
  const IsmChatBlockedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        tag: IsmChat.i.chatListPageTag,
        builder: (controller) {
          final isBlock = message.customType == IsmChatCustomMessageType.block;
          final isInitiatedByMe =
              IsmChatConfig.communicationConfig.userConfig.userId ==
                  message.initiatorId;
          final text = isBlock
              ? (isInitiatedByMe
                  ? IsmChatStrings.youBlockUser
                  : IsmChatStrings.youareBlocked)
              : (isInitiatedByMe ? 'You unblocked this user' : 'You are unblocked');
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
                text,
                style: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageTheme
                        ?.textStyle ??
                    IsmChatStyles.w500Black12.copyWith(
                      color: IsmChatConfig.chatTheme.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
}
