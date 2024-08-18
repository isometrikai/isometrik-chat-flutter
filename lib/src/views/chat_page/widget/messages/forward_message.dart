import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatForwardMessage extends StatelessWidget {
  const IsmChatForwardMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Text(
        message.body,
        style: IsmChatStyles.w400Black12,
      );
}
