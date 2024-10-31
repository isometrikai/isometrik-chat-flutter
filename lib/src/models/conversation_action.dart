import 'package:flutter/widgets.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationAction {
  IsmChatConversationAction({
    required this.onTap,
    this.labelStyle,
    this.label,
    this.decoration,
    required this.icon,
  });

  final Decoration? decoration;
  final Widget icon;
  final String? label;
  final TextStyle? labelStyle;
  final void Function(IsmChatConversationModel) onTap;
}
