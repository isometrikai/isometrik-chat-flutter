import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event.dart';

/// A controller class that handles MQTT communication for the chat functionality.
/// This controller manages MQTT connections, message handling, and various chat events.
class IsmChatMqttController extends GetxController with IsmChatMqttEventMixin {
  /// Creates a new instance of `IsmChatMqttController`.
  ///
  /// Requires an `IsmChatMqttViewModel` instance to handle business logic.
  IsmChatMqttController(this.viewModel);

  /// The view model that handles business logic for MQTT operations.
  final IsmChatMqttViewModel viewModel;

  /// Helper class for MQTT operations.
  final mqttHelper = MqttHelper();

  /// List of topics that the client is currently subscribed to.
  List<String> subscribedTopics = [];

  /// Configuration for the current project.
  IsmChatProjectConfig? projectConfig;

  /// Configuration for the current user.
  IsmChatUserConfig? userConfig;

  /// Current state of the MQTT connection.
  IsmChatConnectionState connectionState = IsmChatConnectionState.disconnected;

  /// MQTT-specific configuration settings.
  IsmChatMqttConfig? mqttConfig;

  /// Configuration instance that holds all communication-related settings for the chat system.
  ///
  /// This private variable stores the core configuration settings including:
  /// - Project configuration (account ID, project ID)
  /// - User configuration (user ID, authentication details)
  /// - MQTT settings (host, port, credentials)
  /// - Connection preferences
  ///
  /// It can be initialized either through the `setup` method or by using the global `IsmChat.i.config`.
  /// When null, the controller falls back to the global configuration.
  ///
  /// Example usage:
  /// ```dart
  /// _config = config ?? IsmChat.i.config;
  /// projectConfig = _config?.projectConfig;
  /// mqttConfig = _config?.mqttConfig;
  /// userConfig = _config?.userConfig;
  /// ```
  IsmChatCommunicationConfig? _config;

  /// Chat delegate for handling chat-related callbacks.
  final chatDelegate = const IsmChatDelegate();

  /// Sets up the MQTT controller with necessary configurations.
  ///
  /// Parameters:
  /// - `config`: Optional communication configuration
  /// - `mqttProperties`: Required MQTT properties for setup
  ///
  /// This method initializes the MQTT connection and sets up necessary configurations.
  Future<void> setup({
    IsmChatCommunicationConfig? config,
    required IsmMqttProperties mqttProperties,
  }) async {
    _config = config ?? IsmChat.i.config;
    projectConfig = _config?.projectConfig;
    mqttConfig = _config?.mqttConfig;
    userConfig = _config?.userConfig;
    if (mqttProperties.shouldSetupMqtt) {
      await setupIsmMqttConnection(
        topics: mqttProperties.topics,
        topicChannels: mqttProperties.topicChannels,
        autoReconnect: mqttProperties.autoReconnect,
        enableLogging: mqttProperties.enableLogging,
      );
    }

    unawaited(getChatConversationsUnreadCount());
  }

  /// Initializes the MQTT connection with specified parameters.
  ///
  /// Parameters:
  /// - `topics`: Optional list of additional topics to subscribe to
  /// - `topicChannels`: Optional list of channel topics
  /// - `autoReconnect`: Whether to automatically reconnect (defaults to true)
  /// - `enableLogging`: Whether to enable logging (defaults to true)
  Future<void> setupIsmMqttConnection({
    List<String>? topics,
    List<String>? topicChannels,
    bool autoReconnect = true,
    bool enableLogging = true,
  }) async {
    final topicPrefix =
        '/${projectConfig?.accountId ?? ''}/${projectConfig?.projectId ?? ''}';
    final userTopic = '$topicPrefix/User/${userConfig?.userId ?? ''}';
    final messageTopic = '$topicPrefix/Message/${userConfig?.userId ?? ''}';
    final statusTopic = '$topicPrefix/Status/${userConfig?.userId ?? ''}';

    var channelTopics = topicChannels
        ?.map((e) => '$topicPrefix/$e/${userConfig?.userId ?? ''}')
        .toList();

    subscribedTopics.addAll([
      ...?topics,
      ...?channelTopics,
      userTopic,
      messageTopic,
      statusTopic,
    ]);

    await mqttHelper.initialize(
      MqttConfig(
        projectConfig: ProjectConfig(
          deviceId: projectConfig?.deviceId ?? '',
          userIdentifier: userConfig?.userId ?? '',
          username: _config?.username ?? '',
          password: _config?.password ?? '',
        ),
        serverConfig: ServerConfig(
          hostName: mqttConfig?.hostName ?? '',
          port: mqttConfig?.port ?? 0,
        ),
        enableLogging: enableLogging,
        secure: false,
        autoReconnect: autoReconnect,
        webSocketConfig: WebSocketConfig(
          useWebsocket: mqttConfig?.useWebSocket ?? false,
          websocketProtocols: mqttConfig?.websocketProtocols ?? [],
        ),
      ),

      callbacks: MqttCallbacks(
        onConnected: _onConnected,
        onDisconnected: _onDisconnected,
        onSubscribed: _onSubscribed,
        onSubscribeFail: _onSubscribeFailed,
        onUnsubscribed: _onUnSubscribed,
        pongCallback: _pong,
      ),
      autoSubscribe: true,
      topics: subscribedTopics,
      subscribedTopicsCallback: (topics) {
        subscribedTopics = topics;
      },
      // unSubscribedTopicsCallback: (topics) {
      //   subscribedTopics = topics;
      // },
    );
    mqttHelper.onConnectionChange((value) {
      if (value) {
        IsmChatConfig.mqttConnectionStatus
            ?.call(IsmChatConnectionState.connected);
      } else {
        IsmChatConfig.mqttConnectionStatus
            ?.call(IsmChatConnectionState.disconnected);
      }
    });
    mqttHelper.onEvent(
      (event) {
        IsmChatLog.info('Mqtt event ${event.toMap()}');
        onMqttEvent(event: event);
      },
    );
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    connectionState = IsmChatConnectionState.connected;
    IsmChatConfig.mqttConnectionStatus?.call(connectionState);
    IsmChatLog.success('Mqtt event');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    connectionState = IsmChatConnectionState.disconnected;
    IsmChatConfig.mqttConnectionStatus?.call(connectionState);
    IsmChatLog.error('MQTT Disconnected Successfully ');
  }

  /// onSubscribed callback, it will be called when connection successfully subscribes to certain topic
  void _onSubscribed(String topic) {
    IsmChatLog.success('MQTT Subscribed - $topic');
  }

  /// onUnsubscribed callback, it will be called when connection successfully unsubscribes to certain topic
  void _onUnSubscribed(String? topic) {
    IsmChatLog.success('MQTT Unsubscribed - $topic');
  }

  /// onSubscribeFailed callback, it will be called when connection fails to subscribe to certain topic
  void _onSubscribeFailed(String topic) {
    IsmChatLog.error('MQTT Subscription failed - $topic');
  }

  /// Callback method that handles the MQTT pong response.
  ///
  /// This method is invoked when the MQTT server sends a pong response to a ping request,
  /// confirming that the connection is still active. It logs the pong event for debugging purposes.
  ///
  /// The pong mechanism is part of the MQTT protocol's keep-alive functionality that ensures
  /// the connection between client and broker remains active.
  void _pong() {
    IsmChatLog.info('MQTT pong');
  }

  /// Subscribes to the specified list of topics.
  ///
  /// This method allows the client to subscribe to multiple MQTT topics simultaneously.
  /// It only processes the subscription request when the connection state is
  /// `IsmChatConnectionState.connected`. If the client is disconnected, the subscription
  /// request will be ignored.
  ///
  /// - `topic`: List of topics to subscribe to. Each topic should follow the MQTT topic format
  ///   and adhere to any project-specific topic structure conventions.

  void subscribeTopics(List<String> topic) {
    if (connectionState == IsmChatConnectionState.connected) {
      mqttHelper.subscribeTopics(topic);
    }
  }

  /// Unsubscribes from the specified list of topics.
  ///
  /// This method allows the client to unsubscribe from multiple MQTT topics simultaneously.
  /// It only processes the unsubscription request when the connection state is
  /// `IsmChatConnectionState.connected`. If the client is disconnected, the unsubscription
  /// request will be ignored.
  ///
  /// - `topic`: List of topics to unsubscribe from. These should be topics that the client
  ///   has previously subscribed to.
  void unSubscribeTopics(List<String> topic) {
    if (connectionState == IsmChatConnectionState.connected) {
      mqttHelper.unsubscribeTopics(topic);
    }
  }

  /// Retrieves the unread conversation count for the current user.
  ///
  /// This method queries the backend service to get the count of unread conversations
  /// for the user configured in the controller. The result is stored in the chatDelegate's
  /// unReadConversationCount property.
  ///
  /// - `isLoading`: Boolean flag indicating whether to show a loading indicator while
  ///   the request is in progress. Defaults to false.
  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    var response = await viewModel.getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
    chatDelegate.unReadConversationCount = response;
  }

  /// Retrieves unread conversation counts for multiple users.
  ///
  /// This method queries the backend service to get the count of unread conversations
  /// for a list of specified users. Unlike the single-user version, this method doesn't
  /// update the chatDelegate directly.
  ///
  /// - `userIds`: Required list of user IDs to get unread counts for. Each ID should
  ///   represent a valid user in the system.
  /// - `isLoading`: Boolean flag indicating whether to show a loading indicator while
  ///   the request is in progress. Defaults to false.
  Future<void> getChatConversationsUnreadCountBulk({
    required List<String> userIds,
    bool isLoading = false,
  }) async {
    await viewModel.getChatConversationsUnreadCountBulk(
      isLoading: isLoading,
      userIds: userIds,
    );
  }

  /// Gets the total count of conversations for the current user.
  ///
  /// This method queries the backend service to get the total number of conversations
  /// associated with the user configured in the controller.
  ///
  /// - `isLoading`: Boolean flag indicating whether to show a loading indicator while
  ///   the request is in progress. Defaults to false.
  Future<String> getChatConversationsCount({
    bool isLoading = false,
  }) async =>
      await viewModel.getChatConversationsCount(
        isLoading: isLoading,
      );

  /// Gets the message count for a specific conversation.
  ///
  /// This method queries the backend service to get the count of messages in a specific
  /// conversation, with filtering options for senders and timestamps.
  ///
  /// - `isLoading`: Boolean flag indicating whether to show a loading indicator while
  ///   the request is in progress. Defaults to false.
  /// - `converationId`: Required ID of the conversation to count messages for.
  /// - `senderIds`: Required list of user IDs to filter messages by sender.
  /// - `senderIdsExclusive`: Whether to exclude or include the specified senderIds in the count.
  ///   When true, only count messages NOT from the senderIds list. When false, only count
  ///   messages FROM the senderIds list. Defaults to false.
  /// - `lastMessageTimestamp`: Optional timestamp to filter messages by time. When provided,
  ///   only counts messages after this timestamp. Defaults to 0 (no filtering).
  Future<String> getChatConversationsMessageCount({
    bool isLoading = false,
    required String converationId,
    required List<String> senderIds,
    bool senderIdsExclusive = false,
    int lastMessageTimestamp = 0,
  }) async =>
      await viewModel.getChatConversationsMessageCount(
        conversationId: converationId,
        senderIds: senderIds,
        isLoading: isLoading,
        lastMessageTimestamp: lastMessageTimestamp,
        senderIdsExclusive: senderIdsExclusive,
      );

  /// Deletes a chat conversation from the local database.
  ///
  /// This method removes a conversation from the local database, either by direct conversationId
  /// or by finding the conversation associated with a specific user ID.
  ///
  /// - `isometrickChatId`: The user ID of the chat partner to delete the conversation with.
  /// - `conversationId`: Optional direct conversation ID. If provided, the method will delete
  ///   this specific conversation. If not provided, the method will search for a conversation
  ///   with the specified user. Defaults to an empty string.
  Future<bool> deleteChatFormDB(
    String isometrickChatId, {
    String conversationId = '',
  }) async {
    if (conversationId.isEmpty) {
      final conversations = await getAllConversationFromDB();
      if (conversations != null || conversations?.isNotEmpty == true) {
        var conversation = conversations?.firstWhere(
            (element) => element.opponentDetails?.userId == isometrickChatId,
            orElse: IsmChatConversationModel.new);

        if (conversation?.conversationId != null) {
          await IsmChatConfig.dbWrapper
              ?.removeConversation(conversation?.conversationId ?? '');
          return true;
        }
      }
    } else {
      await IsmChatConfig.dbWrapper?.removeConversation(conversationId);
      return true;
    }
    return false;
  }

  /// Retrieves all conversations from the local database.
  ///
  /// This method fetches all stored conversations from the local database
  /// without any filtering or ordering. It provides direct access to the
  /// conversation data stored locally on the device.
  ///
  /// This method is typically used for local data operations like:
  /// - Displaying offline conversation history
  /// - Syncing with server data
  /// - Finding specific conversations by filtering the results
  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async =>
      await IsmChatConfig.dbWrapper?.getAllConversations();

  /// Retrieves conversations from the API with pagination and search support.
  ///
  /// This method queries the backend API to fetch conversation data with
  /// various filtering and pagination options. Unlike the local database method,
  /// this provides server-side filtered and sorted results.
  ///
  /// - `skip`: Number of conversations to skip for pagination. Defaults to 0.
  /// - `limit`: Maximum number of conversations to return. Defaults to 20.
  /// - `searchTag`: Optional search term to filter conversations. Defaults to null.
  /// - `includeConversationStatusMessagesInUnreadMessagesCount`: Whether to include
  ///   status messages when counting unread messages. Defaults to false.
  Future<List<IsmChatConversationModel>> getChatConversationApi({
    int skip = 0,
    int limit = 20,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async =>
      await viewModel.getChatConversationApi(
        skip: skip,
        limit: limit,
        searchTag: searchTag ?? '',
        includeConversationStatusMessagesInUnreadMessagesCount:
            includeConversationStatusMessagesInUnreadMessagesCount,
      );

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await viewModel.readSingleMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}
