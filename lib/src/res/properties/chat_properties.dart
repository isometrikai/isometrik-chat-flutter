import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

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
