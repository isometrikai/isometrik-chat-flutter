import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmMaterialChatPage extends StatefulWidget {
  IsmMaterialChatPage({
    super.key,
    this.communicationConfig,
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
    // assert(IsmChatConfig.isInitialized,
    //     'ChatHiveBox is not initialized\nYou are getting this error because the Database class is not initialized, to initialize ChatHiveBox class call IsmChat.i.initialize() before your runApp()');
    assert(IsmChatConfig.configInitilized || communicationConfig != null,
        '''communicationConfig of type IsmChatCommunicationConfig must be initialized
    1. Either initialize using IsmChatApp.initializeMqtt() by passing  communicationConfig.
    2. Or Pass  communicationConfig in IsmChatApp
    ''');

    IsmChatConfig.dbName = databaseName ?? IsmChatStrings.dbname;

    IsmChatConfig.fontFamily = fontFamily;
    IsmChatConfig.conversationParser = conversationParser;
    IsmChatProperties.loadingDialog = loadingDialog;
    IsmChatConfig.useDatabase = useDataBase;
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();

    IsmChatConfig.chatDarkTheme =
        chatDarkTheme ?? chatTheme ?? IsmChatThemeData.dark();

    if (communicationConfig != null) {
      IsmChatConfig.communicationConfig = communicationConfig!;
      IsmChatConfig.configInitilized = true;
    }
    if (chatPageProperties != null) {
      IsmChatProperties.chatPageProperties = chatPageProperties!;
    }
  }

  /// Required field
  ///
  /// This class takes sevaral parameters which are necessary to establish connection between `host` & `application`
  ///
  /// For details see:- [IsmChatCommunicationConfig]
  final IsmChatCommunicationConfig? communicationConfig;

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
  /// If not provided `isometrik_flutter_chat` will be used by default
  final String? databaseName;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  final ConversationParser? conversationParser;

  @override
  State<IsmMaterialChatPage> createState() => _IsmMaterialChatPageState();
}

class _IsmMaterialChatPageState extends State<IsmMaterialChatPage> {
  @override
  void initState() {
    startInit();
    super.initState();
  }

  startInit() async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    while (!Get.isRegistered<IsmChatConversationsController>()) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final conversationController = Get.find<IsmChatConversationsController>();
    conversationController.navigateToMessages(widget.conversation);
  }

  @override
  Widget build(BuildContext context) => const IsmChatPageView();
}
