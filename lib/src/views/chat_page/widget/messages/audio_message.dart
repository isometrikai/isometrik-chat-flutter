import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAudioMessage extends StatelessWidget {
  IsmChatAudioMessage(
    this.message, {
    super.key,
  })  : url = message.attachments?.first.mediaUrl ?? '',
        duration = message.metaData?.duration,
        noise = IsmChatUtility.chatPageController
            .getNoise(message.sentAt, message.sentByMe);

  final IsmChatMessageModel message;
  final String url;
  final Duration? duration;
  final Widget noise;

  @override
  Widget build(BuildContext context) => Material(
        color: message.sentByMe
            ? IsmChatConfig.chatTheme.primaryColor
            : IsmChatConfig.chatTheme.backgroundColor,
        child: BlurFilter(
          isBlured: IsmChatProperties.chatPageProperties.isShowMediaMessageBlur
                  ?.call(context, message) ??
              false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VoiceMessage(
                audioSrc: url,
                noise: noise,
                me: message.sentByMe,
                meBgColor: IsmChatConfig.chatTheme.chatPageTheme
                        ?.selfMessageTheme?.audioMessageBGColor ??
                    IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
                opponentBgColor: IsmChatConfig.chatTheme.chatPageTheme
                        ?.opponentMessageTheme?.audioMessageBGColor ??
                    IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
                mePlayIconColor: IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
                duration: duration,
              ),
              if (message.isUploading == true)
                IsmChatUtility.circularProgressBar(
                  IsmChatColors.blackColor,
                  IsmChatColors.whiteColor,
                ),
            ],
          ),
        ),
      );
}

/// document will be added
class Noises extends StatelessWidget {
  const Noises({
    super.key,
    required this.noises,
  });
  final List<Widget> noises;

  @override
  Widget build(BuildContext context) => FittedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: noises,
        ),
      );
}
