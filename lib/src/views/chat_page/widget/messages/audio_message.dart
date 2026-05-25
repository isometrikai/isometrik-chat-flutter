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

  /// Same as [IsmChatConfig.isChatDarkMode] — set [IsmChatConfig.chatBrightness] from the app.
  static bool get _isSdkDarkMode => IsmChatConfig.isChatDarkMode;

  /// Voice bar fill: black in dark mode so it does not show a grey card patch
  /// behind the waveform (app [audioMessageBGColor] is often a light surface).
  static Color voiceBarBackgroundColor({
    required bool sentByMe,
  }) {
    if (_isSdkDarkMode) {
      return IsmChatColors.blackColor;
    }
    final messageTheme = sentByMe
        ? IsmChatConfig.chatTheme.chatPageTheme?.selfMessageTheme
        : IsmChatConfig.chatTheme.chatPageTheme?.opponentMessageTheme;
    return messageTheme?.audioMessageBGColor ??
        IsmChatConfig.chatTheme.primaryColor ??
        IsmChatColors.primaryColorLight;
  }

  /// In dark mode, skip app overlay colors (often semi-transparent cards/grey).
  static Color? voiceProgressOverlayColor({
    required bool sentByMe,
  }) {
    if (_isSdkDarkMode) {
      return null;
    }
    return sentByMe
        ? IsmChatProperties
            .chatPageProperties.voiceMessageProgressOverlayColorMe
        : IsmChatProperties
            .chatPageProperties.voiceMessageProgressOverlayColorOpponent;
  }

  @override
  Widget build(BuildContext context) {
    final data = IsmChatProperties.chatPageProperties.isShowMessageBlur
        ?.call(context, message);
    final voiceBg =
        voiceBarBackgroundColor(sentByMe: message.sentByMe);
    return Material(
      color: Colors.transparent,
      child: BlurFilter(
        isBlured: data?.shouldBlured ?? false,
        sigmaX: data?.sigmaX ?? 10,
        sigmaY: data?.sigmaY ?? 10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VoiceMessage(
              audioSrc: url,
              noise: noise,
              me: message.sentByMe,
              playIcon:
                  IsmChatProperties.chatPageProperties.voiceMessagePlayIcon,
              pauseIcon:
                  IsmChatProperties.chatPageProperties.voiceMessagePauseIcon,
              loadingIcon:
                  IsmChatProperties.chatPageProperties.voiceMessageLoadingIcon,
              meBgColor: voiceBg,
              opponentBgColor: voiceBg,
              mePlayIconColor: IsmChatConfig.chatTheme.primaryColor ??
                  IsmChatColors.primaryColorLight,
              meProgressOverlayColor:
                  voiceProgressOverlayColor(sentByMe: true),
              opponentProgressOverlayColor:
                  voiceProgressOverlayColor(sentByMe: false),
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
