part of '../isometrik_chat_flutter.dart';

/// Initialization mixin for IsmChat.
///
/// This mixin contains methods related to SDK initialization and platform version.
mixin IsmChatInitializationMixin {
  /// Gets the platform version.
  ///
  /// Returns the platform version string, or null if unavailable.
  Future<String?> getPlatformVersion() =>
      IsometrikChatFlutterPlatform.instance.getPlatformVersion();

  /// Initializes the MQTT controller.
  ///
  /// `communicationConfig` is the configuration for the MQTT communication.
  /// `useDatabase` is whether to use a database. Defaults to `true`.
  /// `databaseName` is the name of the database. Defaults to `IsmChatStrings.dbname`.
  /// `showNotification` is the callback for showing notifications.
  /// `context` is the build context.
  /// `mqttProperties` is whether to set up MQTT. Defaults to `true`.
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
