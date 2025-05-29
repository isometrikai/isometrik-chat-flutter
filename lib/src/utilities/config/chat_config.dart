import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConfig {
  const IsmChatConfig._();
  static late IsmChatCommunicationConfig communicationConfig;
  static late GlobalKey<NavigatorState> kNavigatorKey;
  static late BuildContext context;
  static bool configInitilized = false;
  static IsmChatThemeData? _chatLightTheme;
  static IsmChatThemeData? _chatDarkTheme;
  static IsmChatDBWrapper? dbWrapper;

  static bool useDatabase = false;
  static bool shouldPendingMessageSend = true;
  static bool shouldSetupMqtt = true;
  static String dbName = IsmChatStrings.dbname;
  static Duration animationDuration = const Duration(milliseconds: 300);
  static NotificaitonCallback? showNotification;
  static ConnectionStateCallback? mqttConnectionStatus;
  static SortingConversationCallback? sortConversationWithIdentifier;
  // static bool isShowMqttConnectErrorDailog = false;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  static ConversationParser? conversationParser;

  static IsmChatThemeData get chatTheme => Get.isDarkMode
      ? _chatDarkTheme ?? IsmChatThemeData.light()
      : _chatLightTheme ?? IsmChatThemeData.dark();

  // ignore: avoid_setters_without_getters
  static set chatLightTheme(IsmChatThemeData data) => _chatLightTheme = data;

  // ignore: avoid_setters_without_getters
  static set chatDarkTheme(IsmChatThemeData data) => _chatDarkTheme = data;
  static String? fontFamily;
  static String? notificationIconPath;
  static SendMessageCallback? sendPaidWalletMessage;
  static IsmPaidWalletConfig? paidWalletModel;
  static ResponseCallback? paidWalletMessageApiResponse;
  static ResponseCallback? chatInvalidate;
  static bool? isMonthFirst;
}

class IsmPaidWalletConfig {
  IsmPaidWalletConfig({
    required this.apiUrl,
    required this.authToken,
    this.customType,
  });
  final String apiUrl;
  final String authToken;
  final Future<Map<String, dynamic>> Function(
    IsmChatConversationModel?,
  )? customType;
}
