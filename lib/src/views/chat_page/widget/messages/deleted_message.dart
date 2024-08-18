import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatDeletedMessage extends StatelessWidget {
  const IsmChatDeletedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: Padding(
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
