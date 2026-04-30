import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatListCardTheme {
  const IsmChatListCardTheme({
    this.trailingBackgroundColor,
    this.trailingTextStyle,
    this.subTitleTextStyle,
    this.subTitleColor,
    this.titleTextStyle,
    this.messageCountTheme,
    this.iconSize,
    this.backgroundColor,
    this.messageStatusTheme,
  });

  IsmChatListCardTheme.light()
      : trailingBackgroundColor = IsmChatColors.backgroundColorDark,
        subTitleColor = IsmChatColors.backgroundColorDark,
        trailingTextStyle = IsmChatStyles.w400Black10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12,
        iconSize = 15,
        backgroundColor =
            IsmChatConfig.chatTheme.primaryColor?.applyIsmOpacity(.2),
        messageCountTheme = const MessageCountTheme(),
        messageStatusTheme = IsmChatMessageStatusTheme(
          readCheckColor: IsmChatColors.blueColor,
          unreadCheckColor: IsmChatColors.greyColor,
          inValidIconColor: IsmChatColors.greyColor,
        );

  IsmChatListCardTheme.dark()
      : trailingBackgroundColor = IsmChatColors.backgroundColorLight,
        subTitleColor = IsmChatColors.backgroundColorLight,
        trailingTextStyle = IsmChatStyles.w400White10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12,
        iconSize = 15,
        backgroundColor =
            IsmChatConfig.chatTheme.primaryColor?.applyIsmOpacity(.2),
        messageCountTheme = const MessageCountTheme(),
        messageStatusTheme = IsmChatMessageStatusTheme(
          readCheckColor: IsmChatColors.blueColor,
          unreadCheckColor: IsmChatColors.greyColor,
          inValidIconColor: IsmChatColors.greyColor,
        );

  final Color? trailingBackgroundColor;
  final TextStyle? trailingTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? titleTextStyle;
  final Color? subTitleColor;
  final MessageCountTheme? messageCountTheme;
  final double? iconSize;
  final Color? backgroundColor;
  final IsmChatMessageStatusTheme? messageStatusTheme;
}
