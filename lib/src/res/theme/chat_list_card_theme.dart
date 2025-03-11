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
    this.dividerColor,
    this.dividerThickness,
  });

  IsmChatListCardTheme.light()
      : trailingBackgroundColor = IsmChatColors.backgroundColorDark,
        subTitleColor = IsmChatColors.backgroundColorDark,
        trailingTextStyle = IsmChatStyles.w400Black10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12,
        dividerThickness = _kDividerThickness,
        dividerColor = IsmChatColors.primaryColorLight,
        iconSize = 16,
        backgroundColor =
            IsmChatConfig.chatTheme.primaryColor?.applyIsmOpacity(.2),
        messageCountTheme = const MessageCountTheme();

  IsmChatListCardTheme.dark()
      : trailingBackgroundColor = IsmChatColors.backgroundColorLight,
        subTitleColor = IsmChatColors.backgroundColorLight,
        trailingTextStyle = IsmChatStyles.w400White10,
        subTitleTextStyle = IsmChatStyles.w400Black10,
        titleTextStyle = IsmChatStyles.w600Black12,
        dividerColor = IsmChatColors.primaryColorDark,
        dividerThickness = _kDividerThickness,
        iconSize = 16,
        backgroundColor =
            IsmChatConfig.chatTheme.primaryColor?.applyIsmOpacity(.2),
        messageCountTheme = const MessageCountTheme();

  final Color? trailingBackgroundColor;
  final TextStyle? trailingTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? titleTextStyle;
  final Color? subTitleColor;
  final MessageCountTheme? messageCountTheme;
  final double? iconSize;
  final Color? backgroundColor;
  final double? dividerThickness;
  final Color? dividerColor;

  static const double _kDividerThickness = 0.5;
}
