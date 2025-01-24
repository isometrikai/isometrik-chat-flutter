import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatDeletedMessage extends StatelessWidget {
  const IsmChatDeletedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: Container(
          constraints: IsmChatConfig.chatTheme.chatPageTheme?.messageConstraints
                  ?.textConstraints ??
              BoxConstraints(
                maxWidth: (IsmChatResponsive.isWeb(context))
                    ? context.width * .3
                    : context.width * .7,
                minWidth: IsmChatResponsive.isWeb(context)
                    ? context.width * .05
                    : context.width * .2,
                minHeight: (IsmChatResponsive.isWeb(context))
                    ? context.height * .04
                    : context.height * .05,
                // maxHeight: (IsmChatResponsive.isWeb(context))
                //     ? context.height * .3
                //     : context.height * .7,
              ),
          padding: IsmChatDimens.edgeInsets4,
          child: Row(
            children: [
              Icon(
                Icons.remove_circle_outline_rounded,
                color: message.textColor,
              ),
              IsmChatDimens.boxWidth4,
              Text(
                message.sentByMe
                    ? IsmChatStrings.deletedMessage
                    : IsmChatStrings.wasDeletedMessage,
                style: message.style.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
}
