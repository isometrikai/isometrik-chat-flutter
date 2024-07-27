import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/res/properties/chat_properties.dart';

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
    assert(IsmChatConfig.isInitialized,
        'ChatHiveBox is not initialized\nYou are getting this error because the Database class is not initialized, to initialize ChatHiveBox class call IsometrikChat.initialize() before your runApp()');
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
    IsmChatConfig.isShowMqttConnectErrorDailog = isShowMqttConnectErrorDailog;
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
  /// If not provided `isometrik_chat_flutter` will be used by default
  final String? databaseName;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  final ConversationParser? conversationParser;

  /// Call this funcation for get messages for perticular conversation with api
  static Future<List<IsmChatMessageModel>?> getMessagesFromApi({
    required String conversationId,
    required int lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
  }) async {
    if (Get.isRegistered<IsmChatCommonController>()) {
      return await Get.find<IsmChatCommonController>().getChatMessages(
        conversationId: conversationId,
        lastMessageTimestamp: lastMessageTimestamp,
        limit: limit,
        skip: skip,
        searchText: searchText,
        isLoading: isLoading,
      );
    }
    return null;
  }

  /// Call this funcation for showing Block un Block Dialog
  static void showBlockUnBlockDialog() {
    if (Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();
      if (!(controller.conversation?.isChattingAllowed == true)) {
        controller.showDialogCheckBlockUnBlock();
      }
    }
  }

  /// Call this function for update conversation Details in meta data
  static Future<void> updateConversation(
          {required String conversationId,
          required IsmChatMetaData metaData}) async =>
      await Get.find<IsmChatConversationsController>().updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  /// Call this function for update conversation setting in meta data
  static Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async =>
      await Get.find<IsmChatConversationsController>()
          .updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  /// Call this function for Get  conversations count
  /// You can call this funcation after MQTT controller intilized
  static Future<String> getChatConversationsCount({
    bool isLoading = false,
  }) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      return Get.find<IsmChatMqttController>()
          .getChatConversationsCount(isLoading: isLoading);
    }
    return '';
  }

  /// Call this function for Listen MQTT Evnet from OutSide
  /// [IsmChatConfig.configInitilized] this variable must be true
  /// You can call this funcation after MQTT controller intilized
  static Future<void> listenMqttEventFromOutSide({
    required Map<String, dynamic> payload,
    void Function(
      String,
      String,
      String,
    )? showNotification,
  }) async {
    assert(IsmChatConfig.configInitilized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChatApp.initializeMqtt() or add listener after IsmChatApp is called''');
    if (Get.isRegistered<IsmChatMqttController>()) {
      IsmChatConfig.showNotification = showNotification;
      await Get.find<IsmChatMqttController>().onMqttEvent(
        payload: payload,
      );
    }
  }

  /// Call this function for unblock user form out side
  static Future<void> unblockUser({
    required String opponentId,
    bool includeMembers = false,
    bool isLoading = false,
    bool fromUser = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().unblockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: true,
      );
    }
  }

  /// Call this function for block user form out side
  static Future<void> blockUser({
    required String opponentId,
    bool includeMembers = false,
    bool isLoading = false,
    bool fromUser = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().blockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: false,
      );
    }
  }

  /// Call this function on SignOut to delete the data stored locally in the Local Database
  static Future<void> logout() async {
    await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
    await Future.wait([
      Get.delete<IsmChatConversationsController>(force: true),
      Get.delete<IsmChatCommonController>(force: true),
      Get.delete<IsmChatMqttController>(force: true),
    ]);
  }

  /// Call this function on deleteChat to delete the data stored locally in the Local Database
  static Future<void> deleteChatFromLocal() async {
    await clearChatLocalDb();
    await Future.wait([
      Get.delete<IsmChatConversationsController>(force: true),
      Get.delete<IsmChatCommonController>(force: true),
      Get.delete<IsmChatPageController>(force: true),
    ]);
  }

  /// Call this function for clear the data stored locally in the Local Database
  static Future<void> clearChatLocalDb() async {
    await IsmChatConfig.dbWrapper?.clearChatLocalDb();
  }

  /// Call this function on to delete chat with and local the data stored locally in the Local Database
  ///
  /// [deleteFromServer] - is a `boolean` parameter which signifies whether or not to delete the chat from server
  ///
  /// The chat will be deleted locally in all cases
  static Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
  }) async {
    assert(
      conversationId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      conversationId cannot be empty.''',
    );
    await Get.find<IsmChatConversationsController>().deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
    );
  }

  /// Call this function on to delete chat the data stored locally in the Local Database
  ///
  /// The chat will be deleted locally in all cases
  static Future<bool> deleteChatFormDB(String isometrickChatId) async {
    assert(
      isometrickChatId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      isometrickChatId cannot be empty.''',
    );
    return await Get.find<IsmChatMqttController>().deleteChatFormDB(
      isometrickChatId,
    );
  }

  /// Call this funcation for the initialize mqtt
  static void initializeMqtt(
    IsmChatCommunicationConfig communicationConfig, {
    IsmChatThemeData? chatTheme,
    IsmChatThemeData? chatDarkTheme,
    String? notificationIconPath,
    void Function(
      String,
      String,
      String,
    )? showNotification,
    bool isShowMqttConnectErrorDailog = false,
  }) {
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();
    IsmChatConfig.chatDarkTheme = chatDarkTheme ?? IsmChatThemeData.dark();
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.configInitilized = true;

    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatLog.info(
          'IsmMQttController initiliazing fron {initializeMqtt} function');
      IsmChatMqttBinding().dependencies();
      IsmChatLog.info(
          'IsmMQttController initiliazing success fron {initializeMqtt} function ');
    }
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.notificationIconPath = notificationIconPath;
    IsmChatConfig.isShowMqttConnectErrorDailog = isShowMqttConnectErrorDailog;
  }

  /// Call this funcation for the initialize mqtt
  static void initializeMqttFromOutSide(
    IsmChatCommunicationConfig communicationConfig, {
    String? notificationIconPath,
    void Function(
      String,
      String,
      String,
    )? showNotification,
    IsmChatThemeData? chatTheme,
    IsmChatThemeData? chatDarkTheme,
  }) {
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();
    IsmChatConfig.chatDarkTheme = chatDarkTheme ?? IsmChatThemeData.dark();
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.isMqttInitializedFromOutSide = true;
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatLog.info(
          'IsmMQttController initiliazing fron {initializeMqtt} function');
      IsmChatMqttBinding().dependencies();
      IsmChatLog.info(
          'IsmMQttController initiliazing success fron {initializeMqtt} function ');
    }
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.notificationIconPath = notificationIconPath;
  }

  /// Call this funcation on to listener for mqtt events
  ///
  /// [IsmChatConfig.configInitilized] this variable must be true
  ///
  /// You can call this funcation after initialize mqtt [initializeMqtt] funcation
  static StreamSubscription<Map<String, dynamic>> addListener(
      Function(Map<String, dynamic>) listener) {
    assert(IsmChatConfig.configInitilized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChatApp.initializeMqtt() or add listener after IsmChatApp is called''');
    var mqttController = Get.find<IsmChatMqttController>();
    return mqttController.actionStreamController.stream.listen(listener);
  }

  /// This variable use for store conversation unread count value
  /// This variable update when call api UnreadConverstaion on every action in chat
  static final RxString _unReadConversationMessages = ''.obs;
  static String get unReadConversationMessages =>
      _unReadConversationMessages.value;
  static set unReadConversationMessages(String value) =>
      _unReadConversationMessages.value = value;

  /// This variable use for mqtt connected or not
  /// This variable update when mqtt connection on app initlized
  static final RxBool _isMqttConnected = false.obs;
  static bool get isMqttConnected => _isMqttConnected.value;
  static set isMqttConnected(bool value) => _isMqttConnected.value = value;

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
    if (!Get.isRegistered<IsmChatCommonController>()) {
      IsmChatCommonBinding().dependencies();
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatConversationsBinding().dependencies();
    }
    final conversationController = Get.find<IsmChatConversationsController>();
    while (!conversationController.intilizedContrller) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    conversationController.navigateToMessages(widget.conversation);
  }

  @override
  Widget build(BuildContext context) => const IsmChatPageView();
}
