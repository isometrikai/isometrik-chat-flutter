import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MessageAllowedConfig {
  MessageAllowedConfig({this.isShowTextfiledConfig, this.isMessgeAllowed});
  Future<bool?>? Function(BuildContext, IsmChatConversationModel)?
      isMessgeAllowed;
  IsShowTextfiledConfig? isShowTextfiledConfig;
}

class IsShowTextfiledConfig {
  IsShowTextfiledConfig({
    required this.isShowMessageAllowed,
    required this.shwoMessage,
  });
  bool Function(BuildContext, IsmChatConversationModel) isShowMessageAllowed;
  String Function(BuildContext, IsmChatConversationModel) shwoMessage;
}
