part of '../isometrik_chat_flutter.dart';

/// Initialization mixin for IsmChatDelegate.
///
/// This mixin contains methods related to SDK initialization and MQTT setup.
/// All methods in this mixin are part of the IsmChatDelegate class.
mixin IsmChatDelegateInitializationMixin {
  /// Initializes the SDK with the provided configuration.
  ///
  /// Sets up all necessary components including database, MQTT connection,
  /// and configuration parameters.
  Future<void> initialize({
    required IsmChatCommunicationConfig communicationConfig,
    required GlobalKey<NavigatorState> kNavigatorKey,
    bool useDatabase = true,
    NotificaitonCallback? showNotification,
    String databaseName = IsmChatStrings.dbname,
    bool shouldPendingMessageSend = true,
    SendMessageCallback? sendPaidWalletMessage,
    IsmPaidWalletConfig? paidWalletConfig,
    ResponseCallback? paidWalletMessageApiResponse,
    SortingConversationCallback? sortConversationWithIdentifier,
    ConnectionStateCallback? mqttConnectionStatus,
    ResponseCallback? chatInvalidate,
    IsmMqttProperties? mqttProperties,
    bool? isMonthFirst,
    bool messageEncrypted = false,
    NotificationBodyCallback? notificationBody,
  }) async {
    IsmChatConfig.kNavigatorKey = kNavigatorKey;
    IsmChatConfig.messageEncrypted = messageEncrypted;
    IsmChatConfig.notificationBody = notificationBody;
    IsmChatConfig.dbName = databaseName;
    IsmChatConfig.useDatabase = !kIsWeb && useDatabase;
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.mqttConnectionStatus = mqttConnectionStatus;
    IsmChatConfig.sortConversationWithIdentifier =
        sortConversationWithIdentifier;
    IsmChatConfig.shouldPendingMessageSend = shouldPendingMessageSend;
    IsmChatConfig.sendPaidWalletMessage = sendPaidWalletMessage;
    IsmChatConfig.paidWalletModel = paidWalletConfig;
    IsmChatConfig.paidWalletMessageApiResponse = paidWalletMessageApiResponse;
    IsmChatConfig.chatInvalidate = chatInvalidate;
    IsmChatConfig.isMonthFirst = isMonthFirst;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.dbWrapper = await IsmChatDBWrapper.create();
    await _initializeMqtt(
      config: communicationConfig,
      mqttProperties: mqttProperties ?? IsmMqttProperties(),
    );
  }

  /// Initializes the MQTT connection with the provided configuration.
  ///
  /// Sets up the MQTT controller and establishes the connection.
  Future<void> _initializeMqtt({
    required IsmChatCommunicationConfig config,
    required IsmMqttProperties mqttProperties,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    IsmChatConfig.shouldSetupMqtt = mqttProperties.shouldSetupMqtt;
    await Get.find<IsmChatMqttController>().setup(
      config: config,
      mqttProperties: mqttProperties,
    );
  }
}
