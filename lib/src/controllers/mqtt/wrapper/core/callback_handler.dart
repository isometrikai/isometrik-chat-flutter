import 'package:mqtt_client/mqtt_client.dart';

/// A class that holds callback functions for MQTT events.
///
/// This class provides a convenient way to manage callback functions for various MQTT events, such as connection, disconnection, subscription, and unsubscription.
class MqttCallbacks {
  /// A callback function that is called when the MQTT client is disconnected.
  final DisconnectCallback? onDisconnected;

  /// A callback function that is called when the MQTT client is connected.
  final ConnectCallback? onConnected;

  /// A callback function that is called when a subscription attempt fails.
  final SubscribeFailCallback? onSubscribeFail;

  /// A callback function that is called when a subscription is successful.
  final SubscribeCallback? onSubscribed;

  /// A callback function that is called when an unsubscription is successful.
  final UnsubscribeCallback? onUnsubscribed;

  /// A callback function that is called when a PING response is received from the MQTT broker.
  final PongCallback? pongCallback;

  /// Called when the MQTT client starts auto-reconnect (connection lost).
  final void Function()? onAutoReconnect;

  /// Called when the MQTT client successfully completes auto-reconnect.
  /// [updatesReattached] indicates whether the inbound message listener was
  /// successfully re-created.
  final void Function({required bool updatesReattached})? onAutoReconnected;

  /// Creates a new instance of `MqttCallbacks` with the provided callback functions.
  MqttCallbacks({
    this.onDisconnected,
    this.onConnected,
    this.onSubscribeFail,
    this.onSubscribed,
    this.onUnsubscribed,
    this.pongCallback,
    this.onAutoReconnect,
    this.onAutoReconnected,
  });
}
