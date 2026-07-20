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
    final initTimer = IsmChatInitTimer(
      'SDK.initialize',
      context: communicationConfig.userConfig.userId,
    );
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
    initTimer.checkpoint('config applied');

    IsmChatConfig.dbWrapper = await IsmChatDBWrapper.create();
    initTimer.checkpoint('local database ready');

    // Safety: prevent local history leaking across accounts.
    //
    // The SDK stores conversations/messages locally under a shared DB name.
    // If an app logs out and logs in as another user without clearing the DB,
    // the next user can see the previous user's cached history.
    //
    // We store the last active userId in the user box. If it differs from the
    // current user, we clear the local chat DB before continuing.
    final currentUserId = communicationConfig.userConfig.userId.trim();
    if (currentUserId.isNotEmpty) {
      final lastUserId = (await IsmChatConfig.dbWrapper?.userDetailsBox.get(
        IsmChatStrings.activeUserIdKey,
      ))
          ?.toString()
          .trim();

      if (lastUserId != null &&
          lastUserId.isNotEmpty &&
          lastUserId != currentUserId) {
        await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
        initTimer.checkpoint('cleared DB for new user');
      }
      await IsmChatConfig.dbWrapper?.userDetailsBox.put(
        IsmChatStrings.activeUserIdKey,
        currentUserId,
      );
    }
    initTimer.checkpoint('user session validated');

    await _initializeMqtt(
      config: communicationConfig,
      mqttProperties: mqttProperties ?? IsmMqttProperties(),
      initTimer: initTimer,
    );
    initTimer.finish('SDK ready');
  }

  /// Initializes the MQTT connection with the provided configuration.
  ///
  /// Sets up the MQTT controller and establishes the connection.
  Future<void> _initializeMqtt({
    required IsmChatCommunicationConfig config,
    required IsmMqttProperties mqttProperties,
    IsmChatInitTimer? initTimer,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
      initTimer?.checkpoint('mqtt controller registered');
    }
    IsmChatConfig.shouldSetupMqtt = mqttProperties.shouldSetupMqtt;
    await Get.find<IsmChatMqttController>().setup(
      config: config,
      mqttProperties: mqttProperties,
    );
    initTimer?.checkpoint('mqtt setup complete');
  }
}
