import 'package:flutter/material.dart';

class IsmChatMessageTheme {
  IsmChatMessageTheme({
    this.backgroundColor,
    this.gradient,
    this.textColor,
    this.textStyle,
    this.borderRadius,
    this.borderColor,
    this.showProfile,
    this.audioMessageBGColor,
    this.timeStyle,
    this.readMoreTextStyle,
    this.linkPreviewColor,
  });

  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? textColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final ShowProfile? showProfile;
  final Color? audioMessageBGColor;
  final TextStyle? timeStyle;
  final TextStyle? readMoreTextStyle;
  final Color? linkPreviewColor;
}

class ShowProfile {
  ShowProfile({
    this.isShowProfile,
    this.isPostionBottom,
  });
  final bool? isShowProfile;
  final bool? isPostionBottom;
}
