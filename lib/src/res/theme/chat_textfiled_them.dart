import 'package:flutter/material.dart';

class IsmChatTextFiledThemData {
  IsmChatTextFiledThemData({
    this.inputTextStyle,
    this.decoration,
    this.backgroundColor,
    this.cursorColor,
    this.textfieldInsets,
    this.attchmentColor,
    this.emojiColor,
    this.borderColor,
    this.hintTextStyle,
  });

  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final Decoration? decoration;
  final Color? backgroundColor;
  final Color? cursorColor;
  final EdgeInsetsGeometry? textfieldInsets;
  final Color? attchmentColor;
  final Color? emojiColor;
  final Color? borderColor;
}
