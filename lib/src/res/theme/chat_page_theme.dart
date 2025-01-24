import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageTheme {
  IsmChatPageTheme({
    this.profileImageSize,
    this.messageSelectionColor,
    this.selfMessageTheme,
    this.opponentMessageTheme,
    this.pageDecoration,
    this.backgroundColor,
    this.sendButtonTheme,
    this.textFiledTheme,
    this.centerMessageTheme,
    this.replyMessageTheme,
    this.messageStatusTheme,
    this.messageHoverTheme,
    this.messageConstraints,
  });

  final double? profileImageSize;
  final Color? messageSelectionColor;
  final IsmChatMessageTheme? selfMessageTheme;
  final IsmChatMessageTheme? opponentMessageTheme;

  final Decoration? pageDecoration;
  final Color? backgroundColor;

  final IsmChatSendButtonTheme? sendButtonTheme;
  final IsmChatTextFiledTheme? textFiledTheme;
  final IsmChatCenterMessageTheme? centerMessageTheme;
  final IsmChatReplyMessageTheme? replyMessageTheme;
  final IsmChatMessageStatusTheme? messageStatusTheme;
  final IsmChatMessageHoverTheme? messageHoverTheme;
  final IsmChatMessageConstraints? messageConstraints;
}
