import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatListThemeData {
  const IsmChatListThemeData({
    this.tileColor,
    this.dividerColor,
    this.dividerThickness,
    this.backGroundColor,
    this.pushSnackBarBackGroundColor,
  });

  const IsmChatListThemeData.light()
      : tileColor = IsmChatColors.backgroundColorLight,
        dividerColor = IsmChatColors.primaryColorLight,
        backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor,
        dividerThickness = _kDividerThickness;

  const IsmChatListThemeData.dark()
      : tileColor = IsmChatColors.backgroundColorDark,
        dividerColor = IsmChatColors.primaryColorDark,
        backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor,
        dividerThickness = _kDividerThickness;

  final Color? tileColor;
  final Color? dividerColor;
  final Color? backGroundColor;

  final double? dividerThickness;
  final Color? pushSnackBarBackGroundColor;

  static const double _kDividerThickness = 0.5;
}
