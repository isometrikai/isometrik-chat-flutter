import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatBlockedMessage extends StatelessWidget {
  const IsmChatBlockedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        builder: (controller) {
          var status = message.customType == IsmChatCustomMessageType.block
              ? 'blocked'
              : 'unblocked';
          var text = IsmChatConfig.communicationConfig.userConfig.userId ==
                  message.initiatorId
              ? 'You $status this user'
              : 'You are $status';
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: IsmChatConfig.chatTheme.chatPageTheme
                        ?.centerMessageThemData?.backgroundColor ??
                    IsmChatConfig.chatTheme.backgroundColor,
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
              ),
              padding: IsmChatDimens.edgeInsets8_4,
              child: Text(
                text,
                style: IsmChatConfig.chatTheme.chatPageTheme
                        ?.centerMessageThemData?.textStyle ??
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
