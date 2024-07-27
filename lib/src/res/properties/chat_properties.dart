import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatProperties {
  const IsmChatProperties._();
  static IsmChatConversationProperties conversationProperties =
      IsmChatConversationProperties();
  static IsmChatPageProperties chatPageProperties = IsmChatPageProperties();
  static bool isUserApiCall = false;
  static Widget? loadingDialog;
  static Widget? noChatSelectedPlaceholder;
  static double? sideWidgetWidth;
  static IsmChatConversationModifier? conversationModifier;
}
