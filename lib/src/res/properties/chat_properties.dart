import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatProperties {
  const IsmChatProperties._();
  static IsmChatConversationProperties conversationProperties =
      IsmChatConversationProperties();
  static IsmChatPageProperties chatPageProperties = IsmChatPageProperties();

  /// Icons / widgets for Group Info and 1:1 conversation info screens.
  /// Prefer this over stuffing icon overrides into [chatPageProperties].
  static IsmChatConversationInfoAssets conversationInfoAssets =
      IsmChatConversationInfoAssets();

  static bool isUserApiCall = false;
  static Widget? loadingDialog;
  static Widget? noChatSelectedPlaceholder;
  static double? sideWidgetWidth;
  static IsmChatConversationModifier? conversationModifier;
}
