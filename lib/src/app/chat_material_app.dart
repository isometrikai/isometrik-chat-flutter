import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatApp extends StatelessWidget {
  IsmChatApp({
    super.key,
    this.context,
    this.chatPageProperties,
    this.conversationProperties,
    this.chatTheme,
    this.chatDarkTheme,
    this.loadingDialog,
    this.noChatSelectedPlaceholder,
    this.sideWidgetWidth,
    this.fontFamily,
    this.conversationParser,
    this.conversationModifier,
  }) {
    assert(IsmChatConfig.configInitilized,
        '''communicationConfig of type IsmChatCommunicationConfig must be initialized
    1. Either initialize using IsmChatApp.initializeMqtt() by passing  communicationConfig.
    2. Or Pass  communicationConfig in IsmChatApp
    ''');

    IsmChatConfig.fontFamily = fontFamily;
    IsmChatConfig.conversationParser = conversationParser;
    IsmChatProperties.loadingDialog = loadingDialog;
    IsmChatProperties.sideWidgetWidth = sideWidgetWidth;
    IsmChatProperties.noChatSelectedPlaceholder = noChatSelectedPlaceholder;
    IsmChatConfig.context = context;
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();
    IsmChatConfig.chatDarkTheme =
        chatDarkTheme ?? chatTheme ?? IsmChatThemeData.dark();
    if (chatPageProperties != null) {
      IsmChatProperties.chatPageProperties = chatPageProperties!;
    }
    if (conversationProperties != null) {
      IsmChatProperties.conversationProperties = conversationProperties!;
    }
    IsmChatProperties.conversationModifier = conversationModifier;
  }

  final BuildContext? context;

  /// Required field
  ///
  /// This class takes sevaral parameters which are necessary to establish connection between `host` & `application`
  ///
  /// For details see:- [IsmChatCommunicationConfig]
  // final IsmChatCommunicationConfig? communicationConfig;

  final IsmChatThemeData? chatTheme;

  final IsmChatThemeData? chatDarkTheme;

  /// Opitonal field
  ///
  /// loadingDialog takes a widget which override the classic [CircularProgressIndicator], and will be shown incase of api call or loading something
  final Widget? loadingDialog;

  final IsmChatConversationProperties? conversationProperties;
  final IsmChatPageProperties? chatPageProperties;

  ///  It is showing you have no tap any converstaion
  final Widget? noChatSelectedPlaceholder;

  final double? sideWidgetWidth;

  final String? fontFamily;

  final IsmChatConversationModifier? conversationModifier;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  final ConversationParser? conversationParser;

  @override
  Widget build(BuildContext context) => const IsmChatConversations();
}
