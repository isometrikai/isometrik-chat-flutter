import 'dart:async';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/controllers/mqtt/mixins/mqtt_event.dart';
import 'package:get/get.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

class IsmChatMqttController extends GetxController with IsmChatMqttEventMixin {
  IsmChatMqttController(this.viewModel);
  final IsmChatMqttViewModel viewModel;

  final mqttHelper = MqttHelper();

  late String messageTopic;

  late String statusTopic;

  IsmChatProjectConfig? projectConfig;

  IsmChatUserConfig? userConfig;

  late IsmChatConnectionState connectionState;

  IsmChatMqttConfig? mqttConfig;

  IsmChatCommunicationConfig? _config;

  final chatDelegate = const IsmChatDelegate();

  Future<void> setup({IsmChatCommunicationConfig? config}) async {
    _config = config ?? IsmChat.i.config;
    projectConfig = _config?.projectConfig;
    mqttConfig = _config?.mqttConfig;
    userConfig = _config?.userConfig;
    await setupIsmMqttConnection();
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

  Future<void> setupIsmMqttConnection() async {
    messageTopic =
        '/${projectConfig?.accountId}/${projectConfig?.projectId}/Message/${userConfig?.userId}';
    statusTopic =
        '/${projectConfig?.accountId}/${projectConfig?.projectId}/Status/${userConfig?.userId}';
    await mqttHelper.initialize(
      MqttConfig(
        projectConfig: ProjectConfig.fromMap(projectConfig?.toMap() ?? {}),
        serverConfig: ServerConfig(
          hostName: mqttConfig?.hostName ?? '',
          port: mqttConfig?.port ?? 0,
        ),
        userId: userConfig?.userId ?? '',
        username: _config?.username,
        password: _config?.password,
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
      topics: [messageTopic, statusTopic],
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
}
