part of '../chat_conversations_controller.dart';

/// MQTT connection health checks while the user is on the chat list.
mixin IsmChatConversationsMqttHealthCheckMixin on GetxController {
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Interval for verifying MQTT while chat list is open.
  static const Duration mqttHealthCheckInterval = Duration(seconds: 30);

  /// Starts periodic MQTT checks (call when chat list mounts / controller inits).
  void startMqttHealthCheckForChatList() {
    stopMqttHealthCheckForChatList();
    unawaited(ensureMqttConnectionForChatList());
    _controller.mqttHealthCheckTimer = Timer.periodic(
      mqttHealthCheckInterval,
      (_) => unawaited(ensureMqttConnectionForChatList()),
    );
  }

  /// Stops periodic MQTT checks (call when chat list controller disposes).
  void stopMqttHealthCheckForChatList() {
    _controller.mqttHealthCheckTimer?.cancel();
    _controller.mqttHealthCheckTimer = null;
  }

  /// If MQTT is disconnected, reconnects; does nothing when already connected.
  Future<void> ensureMqttConnectionForChatList() async {
    if (!await IsmChatUtility.isNetworkAvailable) return;
    if (!Get.isRegistered<IsmChatMqttController>()) return;
    final mqtt = Get.find<IsmChatMqttController>();
    if (mqtt.connectionState == IsmChatConnectionState.connected) return;
    await mqtt.ensureMqttConnected();
  }
}
