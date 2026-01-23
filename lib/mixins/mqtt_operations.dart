part of '../isometrik_chat_flutter.dart';

/// MQTT operations mixin for IsmChat.
///
/// This mixin contains methods related to MQTT event handling and topic management.
mixin IsmChatMqttOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Listens for MQTT events.
  ///
  /// data is the data to listen for.
  /// `showNotification` is the callback for showing notifications.
  ///
  /// Throws an [AssertionError] if the MQTT controller has not been initialized.
  Future<void> listenMqttEvent(
    EventModel event, {
    NotificaitonCallback? showNotification,
  }) async {
    assert(
      IsmChat._initialized,
      '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChatApp is called''',
    );
    await _delegate.listenMqttEvent(
      event: event,
      showNotification: showNotification,
    );
  }

  /// Adds a listener for MQTT events with a specific event model.
  ///
  /// This function must be called after initializing the MQTT controller using
  /// `initialize`. The listener will be called with an `EventModel` object
  /// containing the event data.
  ///
  /// Example:
  /// ```dart
  /// StreamSubscription<EventModel> subscription = IsmChat.i.addEventListener((event) {
  ///   print('Received MQTT event: ${event.type}');
  /// });
  ///
  StreamSubscription<EventModel> addEventListener(
      Function(EventModel) listener) {
    assert(
      IsmChat._initialized,
      '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChat is called''',
    );
    return _delegate.addEventListener(listener);
  }

  /// Removes a listener for MQTT events with a specific event model.
  ///
  /// This function must be called after initializing the MQTT controller using
  /// `initialize`. The listener to be removed must be the same instance that was
  /// added using `addEventListener`.
  ///
  /// Example:
  /// ```dart
  /// void myListener(EventModel event) {
  ///   print('Received MQTT event: ${event.type}');
  /// }
  ///
  /// // Add the listener
  /// StreamSubscription<EventModel> subscription = IsmChat.i.addEventListener(myListener);
  ///
  /// // Remove the listener
  /// await IsmChat.i.removeEventListener(myListener);
  ///
  Future<void> removeEventListener(Function(EventModel) listener) async {
    assert(
      IsmChat._initialized,
      '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChat is called''',
    );
    await _delegate.removeEventListener(listener);
  }

  /// Subscribes to the given list of topics in an MQTT broker.
  /// which is responsible for communicating with the MQTT broker.
  ///
  /// Example:
  /// ```dart
  /// var topics = ['sports', 'politics', 'technology'];
  /// IsmChat.i.subscribeTopics(topics);
  /// ```
  ///
  /// @param topics The list of topics to subscribe to. In MQTT, topics are used to
  ///   filter incoming messages from the broker. Each topic is a string that may
  ///   contain wildcards (+ or #) to match multiple topics.
  void subscribeTopics(List<String> topic) {
    _delegate.subscribeTopics(topic);
  }

  /// Unsubscribes from the given list of topics in an MQTT broker.
  /// which is responsible for communicating with the MQTT broker.
  ///
  /// Example:
  /// ```dart
  /// var topics = ['sports', 'politics', 'technology'];
  /// IsmChat.i.unsubscribeTopics(topics);
  /// ```
  ///
  /// @param topics The list of topics to unsubscribe from. Unsubscribing from a
  ///   topic stops the client from receiving messages from the broker for that
  ///   topic.
  void unSubscribeTopics(List<String> topic) {
    _delegate.unSubscribeTopics(topic);
  }

  /// Disconnects from the MQTT broker.
  Future<void> disconnectMQTT() async => await _delegate.disconnectMQTT();
}

