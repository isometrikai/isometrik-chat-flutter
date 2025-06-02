import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPage extends StatefulWidget {
  IsmChatPage({
    super.key,
    this.chatPageProperties,
    this.chatTheme,
    this.chatDarkTheme,
    this.loadingDialog,
    this.databaseName,
    this.useDataBase = true,
    this.isShowMqttConnectErrorDailog = false,
    this.fontFamily,
    this.conversationParser,
    required this.conversation,
  }) {
    assert(IsmChatConfig.configInitilized,
        '''communicationConfig of type IsmChatCommunicationConfig must be initialized
    Either initialize using IsmChat.i.initialize() by passing  communicationConfig.
    ''');

    IsmChatConfig.dbName = databaseName ?? IsmChatStrings.dbname;

    IsmChatConfig.fontFamily = fontFamily;
    IsmChatConfig.conversationParser = conversationParser;
    IsmChatProperties.loadingDialog = loadingDialog;
    IsmChatConfig.useDatabase = useDataBase;
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();

    IsmChatConfig.chatDarkTheme =
        chatDarkTheme ?? chatTheme ?? IsmChatThemeData.dark();

    if (chatPageProperties != null) {
      IsmChatProperties.chatPageProperties = chatPageProperties!;
    }
  }

  final IsmChatThemeData? chatTheme;

  final IsmChatThemeData? chatDarkTheme;

  final bool useDataBase;

  final IsmChatPageProperties? chatPageProperties;

  final String? fontFamily;

  final bool isShowMqttConnectErrorDailog;

  final IsmChatConversationModel conversation;

  /// Opitonal field
  ///
  /// loadingDialog takes a widget which override the classic [CircularProgressIndicator], and will be shown incase of api call or loading something
  final Widget? loadingDialog;

  /// databaseName is to be provided if you want to specify some name for the local database file.
  ///
  /// If not provided `isometrik_chat_flutter` will be used by default
  final String? databaseName;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  final ConversationParser? conversationParser;

  @override
  State<IsmChatPage> createState() => _IsmChatPageState();
}

class _IsmChatPageState extends State<IsmChatPage> {
  @override
  void initState() {
    startInit();
    super.initState();
  }

  startInit() async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    while (!IsmChatUtility.conversationControllerRegistered) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final conversationController = IsmChatUtility.conversationController;
    conversationController.updateLocalConversation(widget.conversation);
  }

  @override
  Widget build(BuildContext context) => const IsmChatPageView();
}
