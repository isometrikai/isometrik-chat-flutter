import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MessageAllowedConfig {
  MessageAllowedConfig({this.isShowTextfiledConfig, this.isMessgeAllowed});
  ConditionConversationCustomeTypeCallback? isMessgeAllowed;
  IsShowTextfiledConfig? isShowTextfiledConfig;
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
