import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatListTheme {
  const IsmChatListTheme.dark()
      : backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor;

  const IsmChatListTheme({
    this.backGroundColor,
    this.pushSnackBarBackGroundColor,
  });

  const IsmChatListTheme.light()
      : backGroundColor = IsmChatColors.whiteColor,
        pushSnackBarBackGroundColor = IsmChatColors.whiteColor;

  final Color? backGroundColor;
  final Color? pushSnackBarBackGroundColor;
}
