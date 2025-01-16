import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatListCardTheme {
  const IsmChatListCardTheme({
    this.trailingBackgroundColor,
    this.trailingTextStyle,
    this.subTitleTextStyle,
    this.subTitleColor,
    this.titleTextStyle,
  });

  IsmChatListCardTheme.light()
      : trailingBackgroundColor = IsmChatColors.backgroundColorDark,
        subTitleColor = IsmChatColors.backgroundColorDark,
        trailingTextStyle = IsmChatStyles.w400Black10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12;

  IsmChatListCardTheme.dark()
      : trailingBackgroundColor = IsmChatColors.backgroundColorLight,
        subTitleColor = IsmChatColors.backgroundColorLight,
        trailingTextStyle = IsmChatStyles.w400White10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12;

  final Color? trailingBackgroundColor;
  final TextStyle? trailingTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? titleTextStyle;
  final Color? subTitleColor;
}
