import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

class IsmChatMqttController extends GetxController with IsmChatMqttEventMixin {
  IsmChatMqttController(this.viewModel);
  final IsmChatMqttViewModel viewModel;

  final mqttHelper = MqttHelper();

  final _deviceConfig = Get.find<IsmChatDeviceConfig>();

  late String messageTopic;

  late String statusTopic;

  late IsmChatProjectConfig projectConfig;

  late IsmChatUserConfig userConfig;

  late IsmChatConnectionState connectionState;

  IsmChatMqttConfig? mqttConfig;

  @override
  void onInit() async {
    super.onInit();
    projectConfig = IsmChatConfig.communicationConfig.projectConfig;
    mqttConfig = IsmChatConfig.communicationConfig.mqttConfig;
    userConfig = IsmChatConfig.communicationConfig.userConfig;
    if (!IsmChatConfig.isMqttInitializedFromOutSide) {
      await setupIsmMqttConnection();
    }
    unawaited(getChatConversationsUnreadCount());
  }

  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    var response = await viewModel.getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
    IsmChatApp.unReadConversationMessages = response;
  }

  Future<void> setupIsmMqttConnection() async {
    messageTopic =
        '/${projectConfig.accountId}/${projectConfig.projectId}/Message/${userConfig.userId}';
    statusTopic =
        '/${projectConfig.accountId}/${projectConfig.projectId}/Status/${userConfig.userId}';
    await mqttHelper.initialize(
      MqttConfig(
        projectConfig: ProjectConfig(
          accountId: projectConfig.accountId,
          appSecret: projectConfig.appSecret,
          userSecret: projectConfig.userSecret,
          keySetId: projectConfig.keySetId,
          licenseKey: projectConfig.licenseKey,
          projectId: projectConfig.projectId,
          deviceId: _deviceConfig.deviceId ?? '',
        ),
        serverConfig: ServerConfig(
          hostName: mqttConfig?.hostName ?? '',
          port: mqttConfig?.port ?? 0,
        ),
        userId: userConfig.userId,
        username: IsmChatConfig.communicationConfig.username,
        password: IsmChatConfig.communicationConfig.password,
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
      IsmChatApp.isMqttConnected = value;
    });
    mqttHelper.onEvent(
      (data) async {
        IsmChatLog.info('Mqtt event ${data.toMap()}');
        await onMqttEvent(payload: data.payload);
      },
    );
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    IsmChatApp.isMqttConnected = true;
    connectionState = IsmChatConnectionState.connected;
    IsmChatLog.success('Mqtt event');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    IsmChatApp.isMqttConnected = false;
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
