// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class IsmChatMessageThemeData {
  IsmChatMessageThemeData({
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
  final bool? isShowProfile;
  final bool? isPostionBottom;
  ShowProfile({
    this.isShowProfile,
    this.isPostionBottom,
  });
}
