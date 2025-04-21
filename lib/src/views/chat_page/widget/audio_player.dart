import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAudioPlayer extends StatelessWidget {
  const IsmChatAudioPlayer({super.key, required this.message});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: IsmChatConfig.chatTheme.primaryColor!,
          height: IsmChatDimens.eighty,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IsmChatAudioMessage(
                message,
                decoration: const BoxDecoration(),
              ),
              IconButton(
                  onPressed: IsmChatRoute.goBack,
                  icon: Icon(
                    Icons.close,
                    color: IsmChatConfig.chatTheme.backgroundColor,
                  ))
            ],
          ),
        ),
      );
}
