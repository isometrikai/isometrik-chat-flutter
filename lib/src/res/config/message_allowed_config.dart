import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MessageAllowedConfig {
  MessageAllowedConfig(
      {this.isShowTextfiledConfig, this.isMessgeAllowed, this.messageText});
  ConditionConversationCustomeTypeCallback? isMessgeAllowed;
  IsShowTextfiledConfig? isShowTextfiledConfig;
  StringConversationCallback? messageText;
}

class IsShowTextfiledConfig {
  IsShowTextfiledConfig({
    required this.isShowMessageAllowed,
    this.shwoMessage,
    this.messageWidget,
  });
  ConditionConversationCallback isShowMessageAllowed;

  StringConversationCallback? shwoMessage;

  WidgetConversationCallback? messageWidget;
}
