import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IsmChatHeaderThemeData {
  IsmChatHeaderThemeData(
      {this.backgroundColor,
      this.iconColor,
      this.elevation,
      this.shadowColor,
      this.subtileStyle,
      this.titleStyle,
      this.popupBackgroundColor,
      this.popupShape,
      this.popupshadowColor,
      this.systemUiOverlayStyle,
      this.popupLableStyle});

  IsmChatHeaderThemeData.light()
      : backgroundColor = IsmChatColors.backgroundColorLight,
        iconColor = IsmChatColors.primaryColorLight,
        elevation = _kelevation,
        shadowColor = IsmChatColors.greyColor,
        titleStyle = IsmChatStyles.w400Black14,
        subtileStyle = IsmChatStyles.w400Black12,
        popupBackgroundColor = IsmChatColors.whiteColor,
        popupShape = null,
        popupshadowColor = IsmChatColors.whiteColor,
        systemUiOverlayStyle = null,
        popupLableStyle = null;

  IsmChatHeaderThemeData.dark()
      : backgroundColor = IsmChatColors.backgroundColorDark,
        iconColor = IsmChatColors.primaryColorLight,
        elevation = _kelevation,
        shadowColor = IsmChatColors.greyColor,
        titleStyle = IsmChatStyles.w400White14,
        subtileStyle = IsmChatStyles.w400White12,
        popupBackgroundColor = IsmChatColors.whiteColor,
        popupShape = null,
        popupLableStyle = null,
        systemUiOverlayStyle = null,
        popupshadowColor = IsmChatColors.whiteColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? popupBackgroundColor;

  final double? elevation;
  final Color? shadowColor;
  final TextStyle? titleStyle;
  final TextStyle? subtileStyle;
  final ShapeBorder? popupShape;
  final TextStyle? popupLableStyle;

  final Color? popupshadowColor;
  static const double _kelevation = 1;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
}
