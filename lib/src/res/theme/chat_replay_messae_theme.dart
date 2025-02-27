import 'package:flutter/material.dart';

class IsmChatReplyMessageTheme {
  IsmChatReplyMessageTheme({
    required this.selfMessage,
    required this.opponentMessage,
    required this.fontSizeMessage,
  });
  final Color selfMessage;
  final Color opponentMessage;
  final double fontSizeMessage;
}
