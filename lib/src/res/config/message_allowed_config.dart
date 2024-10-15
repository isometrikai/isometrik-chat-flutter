import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MessageAllowedConfig {
  MessageAllowedConfig({this.isShowTextfiledConfig, this.isMessgeAllowed});
  Future<bool?>? Function(
          BuildContext, IsmChatConversationModel, IsmChatCustomMessageType)?
      isMessgeAllowed;
  IsShowTextfiledConfig? isShowTextfiledConfig;
}

class IsShowTextfiledConfig {
  IsShowTextfiledConfig({
    required this.isShowMessageAllowed,
    this.shwoMessage,
    this.messageWidget,
  });
  bool Function(BuildContext, IsmChatConversationModel) isShowMessageAllowed;
  String Function(BuildContext, IsmChatConversationModel)? shwoMessage;

  Widget Function(BuildContext, IsmChatConversationModel)? messageWidget;
}
