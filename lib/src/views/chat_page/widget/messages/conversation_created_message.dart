import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/res/properties/chat_properties.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatConversationCreatedMessage extends StatelessWidget {
  const IsmChatConversationCreatedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    var name = '';
    if (IsmChatProperties.chatPageProperties.messageSenderName?.call(
          context,
          message,
          Get.find<IsmChatPageController>().conversation!,
        ) !=
        null) {
      name = IsmChatProperties.chatPageProperties.messageSenderName?.call(
            context,
            message,
            Get.find<IsmChatPageController>().conversation!,
          ) ??
          '';
    } else {
      name =
          '${message.senderInfo?.metaData?.firstName ?? ''} ${message.senderInfo?.metaData?.lastName ?? ''}';
    }
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageThemData
                  ?.backgroundColor ??
              IsmChatConfig.chatTheme.backgroundColor,
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
        padding: IsmChatDimens.edgeInsets8_4,
        child: Text(
          message.isGroup == true
              ? '${name.trim().isNotEmpty ? name : message.userName} created a group'
              : 'Messages are end to end encrypted. No one outside of this chat can read to them.',
          style: IsmChatConfig
                  .chatTheme.chatPageTheme?.centerMessageThemData?.textStyle ??
              IsmChatStyles.w500Black12.copyWith(
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
