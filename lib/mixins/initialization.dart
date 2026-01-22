part of '../isometrik_chat_flutter.dart';

/// Initialization mixin for IsmChat.
///
/// This mixin contains methods related to SDK initialization and platform version.
/// It provides the core initialization functionality that must be called before
/// using any other SDK features.
///
/// **Key Responsibilities:**
/// - SDK initialization with configuration
/// - Platform version detection
/// - Setting initialization state
///
/// **Usage:**
/// ```dart
/// await IsmChat.i.initialize(
///   communicationConfig: config,
///   kNavigatorKey: navigatorKey,
/// );
/// ```
///
/// **See Also:**
/// - [IsmChatDelegate] - Handles actual initialization implementation
/// - [ARCHITECTURE.md] - Architecture documentation
mixin IsmChatInitializationMixin {
  /// Gets the platform version.
  ///
  /// Retrieves the version of the platform (iOS, Android, Web) where the
  /// SDK is running. This is useful for debugging and platform-specific logic.
  ///
  /// **Returns:**
  /// - `Future<String?>`: The platform version string, or `null` if unavailable.
  ///
  /// **Example:**
  /// ```dart
  /// final version = await IsmChat.i.getPlatformVersion();
  /// print('Platform version: $version');
  /// ```
  Future<String?> getPlatformVersion() =>
      IsometrikChatFlutterPlatform.instance.getPlatformVersion();

  /// Initializes the MQTT controller and SDK.
  ///
  /// This is the main initialization method that must be called before using
  /// any other SDK features. It sets up MQTT connection, database, controllers,
  /// and all necessary configurations.
  ///
  /// **Required Parameters:**
  /// - `communicationConfig`: The configuration for MQTT communication.
  ///   Contains connection details, user info, and API endpoints.
  /// - `kNavigatorKey`: Global navigator key for navigation operations.
  ///
  /// **Optional Parameters:**
  /// - `useDatabase`: Whether to use local database. Defaults to `true`.
  /// - `databaseName`: Database name. Defaults to `IsmChatStrings.dbname`.
  /// - `showNotification`: Callback for showing push notifications.
  /// - `shouldPendingMessageSend`: Whether to send pending messages on init.
  ///   Defaults to `true`.
  /// - `sendPaidWalletMessage`: Callback for paid wallet messages (optional).
  /// - `paidWalletConfig`: Configuration for paid wallet feature (optional).
  /// - `paidWalletMessageApiResponse`: Callback for paid wallet API responses (optional).
  /// - `sortingConversationWithIdentifier`: Custom conversation sorting (optional).
  /// - `mqttConnectionStatus`: Callback for MQTT connection status changes (optional).
  /// - `chatInvalidate`: Callback for chat invalidation events (optional).
  /// - `mqttProperties`: MQTT-specific properties (optional).
  /// - `isMonthFirst`: Date format preference (optional).
  /// - `messageEncrypted`: Whether messages are encrypted. Defaults to `false`.
  /// - `notificationBody`: Callback for custom notification body (optional).
  ///
  /// **Throws:**
  /// - `AssertionError`: If paid wallet callbacks are provided without required config.
  ///
  /// **Example:**
  /// ```dart
  /// await IsmChat.i.initialize(
  ///   communicationConfig: IsmChatCommunicationConfig(
  ///     baseUrl: 'https://api.example.com',
  ///     userId: 'user123',
  ///     // ... other config
  ///   ),
  ///   kNavigatorKey: navigatorKey,
  ///   useDatabase: true,
  ///   showNotification: (title, body, data) {
  ///     // Handle notification
  ///   },
  /// );
  /// ```
  ///
  /// **Note:** After initialization, [IsmChat._initialized] is set to `true`,
  /// and other SDK methods can be safely called.
  Future<void> initialize({
    required IsmChatCommunicationConfig communicationConfig,
    required GlobalKey<NavigatorState> kNavigatorKey,
    bool useDatabase = true,
    String databaseName = IsmChatStrings.dbname,
    NotificaitonCallback? showNotification,
    bool shouldPendingMessageSend = true,
    SendMessageCallback? sendPaidWalletMessage,
    IsmPaidWalletConfig? paidWalletConfig,
    ResponseCallback? paidWalletMessageApiResponse,
    SortingConversationCallback? sortingConversationWithIdentifier,
    ConnectionStateCallback? mqttConnectionStatus,
    ResponseCallback? chatInvalidate,
    IsmMqttProperties? mqttProperties,
    bool? isMonthFirst,
    bool messageEncrypted = false,
    NotificationBodyCallback? notificationBody,
  }) async {
    if (sendPaidWalletMessage != null) {
      assert(
        paidWalletConfig != null,
        'isPadiWalletMessage = true, paidWalletConfig should be mandatory',
      );
    }
    if (paidWalletMessageApiResponse != null) {
      assert(
        sendPaidWalletMessage != null && paidWalletConfig != null,
        'isPadiWalletMessage = true, paidWalletConfig should be mandatory for isPaidWalletMessageApiResponse callback',
      );
    }

    // Access _delegate directly since we're in the same library (part of)
    // Cast to dynamic to access private field, then cast to correct type
    final delegate = (this as dynamic)._delegate as IsmChatDelegate;
    await delegate.initialize(
      kNavigatorKey: kNavigatorKey,
      communicationConfig: communicationConfig,
      useDatabase: useDatabase,
      showNotification: showNotification,
      databaseName: databaseName,
      shouldPendingMessageSend: shouldPendingMessageSend,
      sendPaidWalletMessage: sendPaidWalletMessage,
      paidWalletConfig: paidWalletConfig,
      paidWalletMessageApiResponse: paidWalletMessageApiResponse,
      sortConversationWithIdentifier: sortingConversationWithIdentifier,
      mqttConnectionStatus: mqttConnectionStatus,
      chatInvalidate: chatInvalidate,
      mqttProperties: mqttProperties,
      isMonthFirst: isMonthFirst,
      messageEncrypted: messageEncrypted,
      notificationBody: notificationBody,
    );
    // Set static field - IsmChat is defined in the same library (part of)
    IsmChat._initialized = true;
  }
}
