// ignore_for_file: avoid_setters_without_getters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConfig {
  const IsmChatConfig._();
  static late IsmChatCommunicationConfig communicationConfig;
  static bool configInitilized = false;
  static IsmChatThemeData? _chatLightTheme;
  static IsmChatThemeData? _chatDarkTheme;
  static IsmChatDBWrapper? dbWrapper;

  static bool useDatabase = false;
  static bool shouldSetupMqtt = false;
  static String dbName = IsmChatStrings.dbname;
  static Duration animationDuration = const Duration(milliseconds: 300);
  static void Function(
    String title,
    String body,
    String conversationId,
  )? showNotification;
  // static bool isShowMqttConnectErrorDailog = false;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  static ConversationParser? conversationParser;

  static IsmChatThemeData get chatTheme => Get.isDarkMode
      ? _chatDarkTheme ?? IsmChatThemeData.light()
      : _chatLightTheme ?? IsmChatThemeData.dark();

  static set chatLightTheme(IsmChatThemeData data) => _chatLightTheme = data;

  static set chatDarkTheme(IsmChatThemeData data) => _chatDarkTheme = data;
  static String? fontFamily;
  static String? notificationIconPath;
  static BuildContext? context;
}
