import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatDeletedMessage extends StatelessWidget {
  const IsmChatDeletedMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmChatDimens.edgeInsets4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_circle_outline_rounded,
              color: message.textColor,
            ),
            IsmChatDimens.boxWidth4,
            Flexible(
              child: Text(
                message.sentByMe
                    ? IsmChatStrings.deletedMessage
                    : IsmChatStrings.wasDeletedMessage,
                style: message.style.copyWith(fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
