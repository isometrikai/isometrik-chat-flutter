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

  /// Optional timezone offset for all chat dates/times.
  ///
  /// - If `null` (default), the SDK uses the device's local timezone.
  /// - If set, all date/time formatting helpers will convert timestamps using
  ///   this offset (assuming timestamps are in UTC or server time).
  ///
  /// This is useful when you want to display times according to a specific
  /// region (e.g., the server or tenant region) instead of the device timezone.
  ///
  /// **Note:** For per-user timezone support, use [userTimeZoneOffset] callback instead.
  ///
  /// Example (IST, UTC+5:30):
  /// ```dart
  /// IsmChatConfig.timeZoneOffset = const Duration(hours: 5, minutes: 30);
  /// ```
  static Duration? timeZoneOffset;

  /// Callback to get timezone offset for a specific user.
  ///
  /// This allows displaying timestamps according to the user's timezone,
  /// which is especially useful for agent/admin interfaces where you want to
  /// show times as the user sees them, not as the agent sees them.
  ///
  /// **Parameters:**
  /// - `userId`: The user ID to get timezone for
  /// - `conversationId`: Optional conversation ID for context
  ///
  /// **Returns:**
  /// - `Duration?`: Timezone offset from UTC (e.g., `Duration(hours: -5)` for EST)
  /// - `null`: Falls back to [timeZoneOffset] or device timezone
  ///
  /// **Example:**
  /// ```dart
  /// IsmChatConfig.userTimeZoneOffset = (userId, conversationId) {
  ///   // Get user's timezone from your user database
  ///   if (userId == 'user123') {
  ///     return const Duration(hours: -5); // EST
  ///   }
  ///   return null; // Use default
  /// };
  /// ```
  ///
  /// **Use Case:**
  /// - Agent in Europe viewing chat with user in USA
  /// - Agent should see "9 AM" (user's time) not "3:33 PM" (agent's time)
  /// - This prevents confusion when agent says "you let me wait since morning"
  static Duration? Function(String userId, String? conversationId)?
      userTimeZoneOffset;
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
  static ConversationVoidCallback? onConversationCreated;
  static bool? messageEncrypted;
  static NotificationBodyCallback? notificationBody;
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
