import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageTheme {
  IsmChatPageTheme({
    this.profileImageSize,
    this.messageSelectionColor,
    this.selfMessageTheme,
    this.opponentMessageTheme,
    this.constraints,
    this.pageDecoration,
    this.backgroundColor,
    this.sendButtonTheme,
    this.textFiledTheme,
    this.centerMessageTheme,
    this.replyMessageTheme,
    this.messageStatusTheme,
  });

  final double? profileImageSize;
  final Color? messageSelectionColor;
  final IsmChatMessageTheme? selfMessageTheme;
  final IsmChatMessageTheme? opponentMessageTheme;
  final BoxConstraints? constraints;

  final Decoration? pageDecoration;
  final Color? backgroundColor;

  final IsmChatSendButtonTheme? sendButtonTheme;
  final IsmChatTextFiledTheme? textFiledTheme;
  final IsmChatCenterMessageTheme? centerMessageTheme;
  final IsmChatReplyMessageTheme? replyMessageTheme;
  final IsmChatMessageStatusTheme? messageStatusTheme;
}
