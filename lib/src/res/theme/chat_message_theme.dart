import 'package:flutter/material.dart';

class IsmChatMessageTheme {
  IsmChatMessageTheme({
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.borderRadius,
    this.borderColor,
    this.showProfile,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final ShowProfile? showProfile;
}

class ShowProfile {
  ShowProfile({
    this.isShowProfile,
    this.isPostionBottom,
  });
  final bool? isShowProfile;
  final bool? isPostionBottom;
}
