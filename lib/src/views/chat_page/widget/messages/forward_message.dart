import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class IsmChatForwardMessage extends StatelessWidget {
  const IsmChatForwardMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Text(
        message.body,
        style: IsmChatStyles.w400Black12,
      );
}
