import 'package:flutter/material.dart';

class IsmChatMessageStatusTheme {
  IsmChatMessageStatusTheme(
      {this.readCheckColor,
      this.unreadCheckColor,
      this.checkSize,
      this.inValidIconColor});

  final Color? unreadCheckColor;
  final Color? readCheckColor;
  final double? checkSize;
  final Color? inValidIconColor;
}
