part of '../isometrik_chat_flutter.dart';

/// MQTT event handling mixin for IsmChatDelegate.
///
/// This mixin contains methods related to MQTT event listening, topic subscription,
/// and event stream management.
mixin IsmChatDelegateMqttMixin {
  /// Listens to MQTT events and processes them.
  ///
  /// Updates the notification callback and forwards the event to the MQTT controller.
  Future<void> listenMqttEvent({
    required EventModel event,
    NotificaitonCallback? showNotification,
  }) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      IsmChatConfig.showNotification = showNotification;
      Get.find<IsmChatMqttController>().onMqttEvent(
        event: event,
      );
    }
  }

  /// Adds an event listener to the MQTT event stream.
  ///
  /// Returns a StreamSubscription that can be used to cancel the listener.
  StreamSubscription<EventModel> addEventListener(
      Function(EventModel) listener) {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmChatMqttController>();
    mqttController.eventListeners.add(listener);
    return mqttController.eventStreamController.stream.listen(listener);
  }

  /// Removes an event listener from the MQTT event stream.
  ///
  /// Re-subscribes all remaining listeners after removal.
  Future<void> removeEventListener(Function(EventModel) listener) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      var mqttController = Get.find<IsmChatMqttController>();
      mqttController.eventListeners.remove(listener);
      await mqttController.eventStreamController.stream.drain();
      for (var listener in mqttController.eventListeners) {
        mqttController.eventStreamController.stream.listen(listener);
      }
    }
  }

  /// Subscribes to MQTT topics.
  ///
  /// Subscribes the MQTT controller to the specified topics.
  void subscribeTopics(List<String> topic) {
    if (Get.isRegistered<IsmChatMqttController>()) {
      Get.find<IsmChatMqttController>().subscribeTopics(topic);
    }
  }

  /// Unsubscribes from MQTT topics.
  ///
  /// Unsubscribes the MQTT controller from the specified topics.
  void unSubscribeTopics(List<String> topic) {
    if (Get.isRegistered<IsmChatMqttController>()) {
      Get.find<IsmChatMqttController>().unSubscribeTopics(topic);
    }
  }
}
