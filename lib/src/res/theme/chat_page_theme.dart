import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageThemeData {
  IsmChatPageThemeData({
    this.profileImageSize,
    this.messageSelectionColor,
    this.selfMessageTheme,
    this.opponentMessageTheme,
    this.constraints,
    this.unreadCheckColor,
    this.readCheckColor,
    this.pageDecoration,
    this.backgroundColor,
    this.sendButtonThemData,
    this.textFiledThemData,
    this.centerMessageThemData,
    this.replyMessageThem,
  });

  final double? profileImageSize;
  final Color? messageSelectionColor;
  final IsmChatMessageThemeData? selfMessageTheme;
  final IsmChatMessageThemeData? opponentMessageTheme;
  final BoxConstraints? constraints;
  final Color? unreadCheckColor;
  final Color? readCheckColor;

  final Decoration? pageDecoration;
  final Color? backgroundColor;

  final IsmChatSendButtonThemData? sendButtonThemData;
  final IsmChatTextFiledThemData? textFiledThemData;
  final IsmChatCenterMessageThemData? centerMessageThemData;
  final IsmChatReplyMessageThem? replyMessageThem;
}
