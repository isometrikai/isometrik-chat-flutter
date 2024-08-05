import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:flutter/material.dart';

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
        dividerColor = IsmChatColors.backgroundColorDark,
        backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor,
        dividerThickness = _kDividerThickness;

  const IsmChatListThemeData.dark()
      : tileColor = IsmChatColors.backgroundColorDark,
        dividerColor = IsmChatColors.backgroundColorLight,
        backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor,
        dividerThickness = _kDividerThickness;

  final Color? tileColor;
  final Color? dividerColor;
  final Color? backGroundColor;

  final double? dividerThickness;
  final Color? pushSnackBarBackGroundColor;

  static const double _kDividerThickness = 2;
}
