import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatLinkMessage extends StatelessWidget {
  const IsmChatLinkMessage(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            minHeight: (IsmChatResponsive.isWeb(context))
                ? context.height * .04
                : context.height * .05,
          ),
          child: LinkPreviewView(
            url: message.body.convertToValidUrl,
            message: message,
          ),
        ),
      );
}
