import 'package:flutter/material.dart';

class IsmChatDialogTheme {
  IsmChatDialogTheme({
    this.contentTextStyle,
    this.titleTextStyle,
    this.actionTextStyle,
    this.backgroundColor,
    this.insetPadding,
    this.shape,
  });

  final TextStyle? contentTextStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? actionTextStyle;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? insetPadding;
  final ShapeBorder? shape;
}
