import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event.dart';

class IsmChatMqttController extends GetxController with IsmChatMqttEventMixin {
  IsmChatMqttController(this.viewModel);
  final IsmChatMqttViewModel viewModel;

  final mqttHelper = MqttHelper();

  List<String> subscribedTopics = [];

  IsmChatProjectConfig? projectConfig;

  IsmChatUserConfig? userConfig;

  IsmChatConnectionState connectionState = IsmChatConnectionState.disconnected;

  IsmChatMqttConfig? mqttConfig;

  IsmChatCommunicationConfig? _config;

  final chatDelegate = const IsmChatDelegate();

  Future<void> setup({
    IsmChatCommunicationConfig? config,
    List<String>? topics,
    List<String>? topicChannels,
    required bool shouldSetupMqtt,
  }) async {
    _config = config ?? IsmChat.i.config;
    projectConfig = _config?.projectConfig;
    mqttConfig = _config?.mqttConfig;
    userConfig = _config?.userConfig;
    if (!shouldSetupMqtt) {
      await setupIsmMqttConnection(
        topics: topics,
        topicChannels: topicChannels,
      );
    }

    unawaited(getChatConversationsUnreadCount());
  }

  Future<void> setupIsmMqttConnection({
    List<String>? topics,
    List<String>? topicChannels,
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
        enableLogging: true,
        secure: false,
        autoReconnect: true,
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

  void _pong() {
    IsmChatLog.info('MQTT pong');
  }

  void subscribeTopics(List<String> topic) {
    if (connectionState == IsmChatConnectionState.connected) {
      mqttHelper.subscribeTopics(topic);
    }
  }

  void unSubscribeTopics(List<String> topic) {
    if (connectionState == IsmChatConnectionState.connected) {
      mqttHelper.unsubscribeTopics(topic);
    }
  }

  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    var response = await viewModel.getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
    chatDelegate.unReadConversationCount = response;
  }

  Future<String> getChatConversationsCount({
    bool isLoading = false,
  }) async =>
      await viewModel.getChatConversationsCount(
        isLoading: isLoading,
      );

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

  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async =>
      await IsmChatConfig.dbWrapper?.getAllConversations();

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
}
