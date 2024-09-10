import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event.dart';

class IsmChatMqttController extends GetxController with IsmChatMqttEventMixin {
  IsmChatMqttController(this.viewModel);
  final IsmChatMqttViewModel viewModel;

  final mqttHelper = MqttHelper();

  final List<String> subscribedTopics = [];

  IsmChatProjectConfig? projectConfig;

  IsmChatUserConfig? userConfig;

  late IsmChatConnectionState connectionState;

  IsmChatMqttConfig? mqttConfig;

  IsmChatCommunicationConfig? _config;

  final chatDelegate = const IsmChatDelegate();

  Future<void> setup({
    IsmChatCommunicationConfig? config,
    List<String>? topics,
    List<String>? topicChannels,
  }) async {
    _config = config ?? IsmChat.i.config;
    projectConfig = _config?.projectConfig;
    mqttConfig = _config?.mqttConfig;
    userConfig = _config?.userConfig;
    await setupIsmMqttConnection(
      topics: topics,
      topicChannels: topicChannels,
    );
    unawaited(getChatConversationsUnreadCount());
  }

  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    var response = await viewModel.getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
    chatDelegate.unReadConversationMessages = response;
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
    );
    mqttHelper.onConnectionChange((value) {
      chatDelegate.isMqttConnected = value;
    });
    mqttHelper.onEvent(
      (event) async {
        IsmChatLog.info('Mqtt event ${event.toMap()}');
        await onMqttEvent(event: event);
      },
    );
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    chatDelegate.isMqttConnected = true;
    connectionState = IsmChatConnectionState.connected;
    IsmChatLog.success('Mqtt event');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    chatDelegate.isMqttConnected = false;
    connectionState = IsmChatConnectionState.disconnected;
    IsmChatLog.error('MQTT Disconnected');
  }

  /// onSubscribed callback, it will be called when connection successfully subscribes to certain topic
  void _onSubscribed(String topic) {
    connectionState = IsmChatConnectionState.subscribed;
    IsmChatLog.success('MQTT Subscribed - $topic');
  }

  /// onUnsubscribed callback, it will be called when connection successfully unsubscribes to certain topic
  void _onUnSubscribed(String? topic) {
    connectionState = IsmChatConnectionState.unsubscribed;
    IsmChatLog.success('MQTT Unsubscribed - $topic');
  }

  /// onSubscribeFailed callback, it will be called when connection fails to subscribe to certain topic
  void _onSubscribeFailed(String topic) {
    connectionState = IsmChatConnectionState.unsubscribed;
    IsmChatLog.error('MQTT Subscription failed - $topic');
  }

  void _pong() {
    IsmChatLog.info('MQTT pong');
  }

  void subscribeTopics(List<String> topic) {
    if (chatDelegate.isMqttConnected) {
      mqttHelper.subscribeTopics(topic);
    }
  }

  void unSubscribeTopics(List<String> topic) {
    if (chatDelegate.isMqttConnected) {
      mqttHelper.unsubscribeTopics(topic);
    }
  }
}
