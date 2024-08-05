import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatAudioMessage extends StatelessWidget {
  IsmChatAudioMessage(
    this.message, {
    super.key,
    this.decoration,
  })  : url = message.attachments?.first.mediaUrl ?? '',
        duration = message.metaData?.duration,
        noise = Get.find<IsmChatPageController>()
            .getNoise(message.sentAt, message.sentByMe);

  final IsmChatMessageModel message;
  final String url;
  final Duration? duration;
  final Widget noise;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) => Material(
        color: message.sentByMe
            ? IsmChatConfig.chatTheme.primaryColor
            : IsmChatConfig.chatTheme.backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VoiceMessage(
              decoration: decoration,
              audioSrc: url,
              noise: noise,
              me: message.sentByMe,
              meBgColor: IsmChatConfig.chatTheme.chatPageTheme?.selfMessageTheme
                      ?.backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor!,
              mePlayIconColor: IsmChatConfig.chatTheme.chatPageTheme
                      ?.selfMessageTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor!,
              contactBgColor: IsmChatConfig.chatTheme.chatPageTheme
                      ?.opponentMessageTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.backgroundColor!,
              contactPlayIconColor: IsmChatConfig.chatTheme.chatPageTheme
                      ?.opponentMessageTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.backgroundColor!,
              contactFgColor: IsmChatConfig.chatTheme.chatPageTheme
                      ?.opponentMessageTheme?.textColor ??
                  IsmChatConfig.chatTheme.primaryColor!,
              duration: duration,
            ),
            if (message.isUploading == true)
              IsmChatUtility.circularProgressBar(
                IsmChatColors.blackColor,
                IsmChatColors.whiteColor,
              ),
          ],
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
