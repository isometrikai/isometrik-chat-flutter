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

  /// Active SDK UI locale (`en` / `fr` / `pt`). Prefer `IsmChatL10n.setLocale`
  /// or `IsmChat.i.setLocale` when the host app language changes.
  ///
  /// Unsupported values fall back to English — do not leave an invalid locale
  /// active (mismatched labels / host MaterialApp language).
  static Locale get locale => IsmChatL10n.locale;
  static set locale(Locale value) {
    if (IsmChatL10n.isSupportedLocale(value)) {
      IsmChatL10n.setLocale(value);
    } else {
      IsmChatL10n.setLocale(IsmChatL10n.fallbackLocale);
    }
  }

  static bool isUserApiCall = false;
  static Widget? loadingDialog;
  static Widget? noChatSelectedPlaceholder;
  static double? sideWidgetWidth;
  static IsmChatConversationModifier? conversationModifier;
}
