import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:isometrik_chat_flutter/src/controllers/mqtt/mqtt_helper.dart';
import 'package:mqtt_client/mqtt_client.dart';

/// A helper class for working with MQTT connections and events.
///
/// This class provides a convenient way to manage MQTT connections, subscriptions, and events. It also provides streams for listening to connection changes, raw events, and parsed events.
class MqttHelper {
  /// Passed to `MqttClient.connectTimeoutPeriod`. The synchronous server handler
  /// uses this as the CONNACK wait per attempt (`reconnectTimePeriod` in
  /// mqtt_client). At 30s a single slow/failed handshake matches user-visible
  /// ~25–30s reconnect delays; 10s keeps recovery responsive on mobile after
  /// backgrounding without being as tight as the library default (5s).
  static const int kDefaultConnectTimeoutMs = 10000;
  /// The underlying MQTT configuration.
  ///
  /// This configuration object holds the necessary settings for connecting to an MQTT broker, such as the server URL, port, and credentials.
  late MqttConfig _config;

  /// Whether the MQTT helper has been initialized.
  ///
  /// This flag indicates whether the `initialize` method has been called and the MQTT helper is ready for use.
  bool _initialized = false;

  /// The callback functions for MQTT events.
  ///
  /// These callback functions are called when specific MQTT events occur, such as connection, disconnection, subscription, and unsubscription.
  MqttCallbacks? _callbacks;

  /// The underlying MQTT client.
  ///
  /// This is the actual MQTT client that connects to the MQTT broker and handles the communication.
  MqttClient? _client;

  /// The MQTT helper client.
  ///
  /// This is a wrapper around the underlying MQTT client that provides additional functionality and convenience methods.
  MqttHelperClient? _helperClient;

  /// The list of topics to subscribe to.
  ///
  /// This list of topics is used when auto-subscribing to topics during initialization.
  late List<String> _topics;

  /// The callback function for subscribed topics.
  ///
  /// This callback function is called when the subscription to topics is successful.
  void Function(List<String>)? _subscribedTopicsCallback;

  /// The callback function for unSubscribed topics.
  ///
  /// This callback function is called when the unSubscription to topics is successful.
  void Function(List<String>)? _unSubscribedTopicsCallback;

  /// The list of subscribed topics.
  ///
  /// This list keeps track of the topics that the MQTT helper is currently subscribed to.
  List<String> subscribedTopics = [];

  /// Topics requested while the client is not yet fully connected.
  ///
  /// `mqtt_client` throws if `subscribe()` is called while the client is in
  /// `connecting`. This can happen during initial handshake, auto-reconnect,
  /// or when `initialize()` is invoked while a connect cycle is still in-flight.
  final Set<String> _pendingSubscriptions = <String>{};

  /// Whether to auto-subscribe to topics.
  ///
  /// If set to true, the MQTT helper will automatically subscribe to the specified topics during initialization.
  bool _autoSubscribe = false;

  /// A stream controller for raw events.
  ///
  /// This stream controller is used to broadcast raw MQTT events to listeners.
  late StreamController<MqttHelperPayload?> _rawEventStream;

  /// A stream controller for parsed events.
  ///
  /// This stream controller is used to broadcast parsed MQTT events to listeners.
  late StreamController<EventModel> _eventStream;

  /// A stream controller for connection changes.
  ///
  /// This stream controller is used to broadcast connection changes (e.g., connected, disconnected) to listeners.
  late StreamController<bool> _connectionStream;

  /// A stream for listening to parsed events.
  ///
  /// This stream allows listeners to receive parsed MQTT events of type [EventModel]
  StreamSubscription<EventModel> onEvent(
    Function(EventModel) event,
  ) =>
      _eventStream.stream.listen(event);

  /// A stream for listening to raw events.
  ///
  /// This stream allows listeners to receive raw MQTT events.
  StreamSubscription<MqttHelperPayload?> onRawEvent(
    Function(MqttHelperPayload?) event,
  ) =>
      _rawEventStream.stream.listen(event);

  /// A stream for listening to connection changes.
  ///
  /// This stream allows listeners to receive connection change events (e.g., connected, disconnected).
  StreamSubscription<bool> onConnectionChange(
    Function(bool) change,
  ) =>
      _connectionStream.stream.listen(change);

  /// Whether the MQTT client currently has an active broker connection.
  ///
  /// False before [initialize] completes or after [disconnect].
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  /// Subscription for inbound MQTT messages; replaced on each successful connect.
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSub;

  /// Initializes the MQTT helper with the provided configuration.
  ///
  /// This method sets up the underlying MQTT client and configures it with the provided configuration. It also sets up the streams for listening to events and connection changes.
  ///
  /// Parameters:
  ///   - `config`: The MQTT configuration.
  ///   - `callbacks`: The callback functions for MQTT events.
  ///   - `autoSubscribe`: Whether to auto-subscribe to topics.
  ///   - `topics`: The list of topics to subscribe to.
  ///   - `subscribedTopicsCallback`: The callback function for subscribed topics.
  Future<void> initialize(
    MqttConfig config, {
    MqttCallbacks? callbacks,
    bool autoSubscribe = false,
    List<String>? topics,
    void Function(List<String>)? subscribedTopicsCallback,
    void Function(List<String>)? unSubscribedTopicsCallback,
  }) async {
    if (autoSubscribe) {
      if (topics == null || topics.isEmpty) {
        throw Exception(
          'You must specify at least one topic when auto-subscribing',
        );
      }
    }

    // Tear down any previous client/streams before swapping in new ones.
    // Without this, an in-flight auto-reconnect on the previous `_client`
    // can complete after `_client` has been replaced, causing the previous
    // client's `onConnected` / `onAutoReconnected` callbacks to fire into
    // the new helper state (observed as duplicate `mqtt_connected` events
    // with `helper_connected:false`, and stream-topic subscriptions queued
    // against a not-yet-connected client and subsequently lost).
    _teardownPreviousClient();

    _rawEventStream = StreamController<MqttHelperPayload>.broadcast();
    _eventStream = StreamController<EventModel>.broadcast();
    _connectionStream = StreamController<bool>.broadcast();

    _initialized = true;
    _config = config;
    _callbacks = callbacks;
    _topics = topics ?? [];
    _autoSubscribe = autoSubscribe;
    _pendingSubscriptions.clear();

    _subscribedTopicsCallback = subscribedTopicsCallback;
    _unSubscribedTopicsCallback = unSubscribedTopicsCallback;
    await _initializeClient();
    await _connectClient();
  }

  /// Detaches callbacks from and disconnects the previous `_client` (if any)
  /// so that pending auto-reconnect cycles on the old socket cannot fire
  /// callbacks into the helper after `initialize()` has swapped in a new
  /// client. Safe to call even when `_client` is null or already disconnected.
  void _teardownPreviousClient() {
    final previous = _client;
    _updatesSub?.cancel();
    _updatesSub = null;
    if (previous == null) return;
    try {
      // Detach callbacks first so any in-flight reconnect that completes
      // mid-teardown cannot reach helper state.
      previous.onConnected = null;
      previous.onDisconnected = null;
      previous.onAutoReconnect = null;
      previous.onAutoReconnected = null;
      previous.onSubscribed = null;
      previous.onUnsubscribed = null;
      previous.onSubscribeFail = null;
      previous.pongCallback = null;
      previous.autoReconnect = false;
      final state = previous.connectionStatus?.state;
      if (state == MqttConnectionState.connected ||
          state == MqttConnectionState.connecting) {
        previous.disconnect();
      }
    } catch (e, st) {
      _debugLog('Error tearing down previous MQTT client: $e\n$st');
    }
  }

  bool _isClientConnected() =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  void _enqueueSubscription(String topic) {
    if (topic.isEmpty) return;
    _pendingSubscriptions.add(topic);
  }

  void _flushPendingSubscriptions() {
    if (!_initialized || !_isClientConnected()) return;
    if (_pendingSubscriptions.isEmpty) return;

    final pending = List<String>.from(_pendingSubscriptions);
    _pendingSubscriptions.clear();
    for (final topic in pending) {
      // Use public method so subscription-status checks remain centralized.
      subscribeTopic(topic);
    }
  }

  /// Initializes the underlying MQTT client.
  ///
  /// This method sets up the underlying MQTT client with the provided configuration and sets up the necessary callbacks.
  Future<void> _initializeClient() async {
    if (!_initialized) {
      throw Exception(
        'MqttConfig is not initialized. Initialize it by calling initialize(config)',
      );
    }

    _helperClient = MqttHelperClient();
    var userIdentifier = _config.projectConfig.userIdentifier;
    var deviceId = _config.projectConfig.deviceId;
    var identifier = '$userIdentifier$deviceId';

    _client = _helperClient?.setup(_config);
    _client?.port = _config.serverConfig.port;
    _client?.keepAlivePeriod = _config.keepAliveSeconds;
    // After a ping, drop the session if no PONG within this window (detects dead network faster).
    _client?.disconnectOnNoResponsePeriod =
        _config.disconnectOnNoPingResponseSeconds;
    _client?.connectTimeoutPeriod = kDefaultConnectTimeoutMs;
    _client?.onDisconnected = _onDisconnected;
    _client?.onUnsubscribed = _onUnSubscribed;
    _client?.onSubscribeFail = _onSubscribeFailed;
    _client?.logging(on: _config.enableLogging);
    _applyAutoReconnectSettings();
    _client?.pongCallback = _pong;
    _client?.setProtocolV311();
    _client?.websocketProtocols =
        _config.webSocketConfig?.websocketProtocols ?? [];
    _client?.onAutoReconnect = _onAutoReconnect;
    _client?.onAutoReconnected = _onAutoReconnected;

    /// Add the successful connection callback
    _client?.onConnected = _onConnected;
    _client?.onSubscribed = _onSubscribed;

    _client?.connectionMessage =
        MqttConnectMessage().withClientIdentifier(identifier).startClean();
  }

  /// Applies [MqttConfig.autoReconnect] to the client and enables broker-side
  /// resubscription after each successful auto-reconnect when it is `true`.
  void _applyAutoReconnectSettings() {
    final client = _client;
    if (client == null) return;
    client.autoReconnect = _config.autoReconnect;
    client.resubscribeOnAutoReconnect = _config.autoReconnect;
  }

  void _debugLog(String message) {
    if (_config.enableLogging) {
      log('[MQTTHelper] $message');
    }
  }

  void _handleUpdatesStreamError(Object error, StackTrace stack) {
    if (error is SocketException ||
        error is HandshakeException ||
        error is TimeoutException) {
      _debugLog('updates stream transient network error: $error');
      return;
    }
    _debugLog('updates stream error: $error\n$stack');
  }

  /// Runs [body] inside a guarded zone so that *asynchronous, unhandled*
  /// errors thrown by `mqtt_client`'s internals (e.g. the prior socket's
  /// `onError` completing after the library already caught the synchronous
  /// variant) are captured here instead of bubbling up as
  /// `Unhandled Exception: SocketException` on the Flutter root zone.
  ///
  /// This does NOT alter control flow: `mqtt_client`'s own auto-reconnect
  /// loop runs independently and keeps retrying. We only intercept the
  /// orphaned Future errors that would otherwise just pollute logs / be
  /// flagged by crash reporters as uncaught.
  ///
  /// Typical triggers: Android tearing down the idle TCP socket while the
  /// app is paused (errno 103 "Software caused connection abort"), DNS
  /// resets, brief Wi-Fi/cellular handovers.
  Future<T?> _runZoneGuarded<T>(
    String label,
    FutureOr<T> Function() body,
  ) async {
    final completer = Completer<T?>();
    runZonedGuarded<void>(
      () async {
        try {
          final result = await body();
          if (!completer.isCompleted) completer.complete(result);
        } catch (e, st) {
          // Synchronous / awaited errors still propagate normally so callers
          // that already have try/catch see them.
          if (!completer.isCompleted) completer.completeError(e, st);
        }
      },
      (error, stack) {
        // Orphan async errors from mqtt_client's internals. Swallow the
        // known-transient network ones; surface the rest so they are not
        // silently lost.
        if (error is SocketException ||
            error is HandshakeException ||
            error is TimeoutException) {
          _debugLog(
            '$label: swallowed transient async network error: $error',
          );
        } else {
          _debugLog('$label: swallowed async error: $error\n$stack');
        }
      },
    );
    return completer.future;
  }

  /// Notifies listeners the session is down (connection stream + [MqttCallbacks.onDisconnected]).
  ///
  /// With [MqttClient.autoReconnect] enabled, [mqtt_client] does not invoke
  /// [MqttClient.onDisconnected] for an unexpected socket loss; it only fires
  /// [MqttClient.onAutoReconnect]. We emit the same side effects from there.
  void _notifySessionLost(String logMessage) {
    _debugLog(logMessage);
    _updatesSub?.cancel();
    _updatesSub = null;
    if (!_connectionStream.isClosed) {
      _connectionStream.add(false);
    }
    _callbacks?.onDisconnected?.call();
  }

  /// Connects the underlying MQTT client to the MQTT broker.
  ///
  /// This method attempts to connect the underlying MQTT client to the MQTT broker using the provided configuration.
  Future<void> _connectClient() async {
    try {
      if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
        _client?.disconnect();
      }
      // Guarded zone isolates orphan async errors (e.g. OS aborting a prior
      // socket during backgrounding) from the Flutter root zone. The awaited
      // result still reaches us normally, so the existing try/catch below
      // keeps working for real connect failures.
      var res = await _runZoneGuarded<MqttClientConnectionStatus?>(
        '_connectClient',
        () => _client?.connect(
          _config.projectConfig.username.isNotEmpty
              ? _config.projectConfig.username
              : null,
          _config.projectConfig.password.isNotEmpty
              ? _config.projectConfig.password
              : null,
        ),
      );
      if (res?.state == MqttConnectionState.connected) {
        _debugLog(
          'MQTT connect() finished (state: ${res?.state}, '
          'autoReconnect: ${_config.autoReconnect})',
        );
        _applyAutoReconnectSettings();
        if (_autoSubscribe) {
          subscribedTopics.clear();
          subscribeTopics(_topics);
        }
      } else {
        throw Exception('Failed MQTT connect: ${res?.state}');
      }
    } on NoConnectionException catch (e, st) {
      disconnect();
      log('[MQTTHelper] - $e', stackTrace: st);
    } catch (e, st) {
      disconnect();
      log('[MQTTHelper] - $e', stackTrace: st);
    }
  }

  /// Subscribes to a single topic.
  ///
  /// This method subscribes to a single topic on the MQTT broker.
  ///
  /// Parameters:
  ///   - `topic`: The topic to subscribe to.
  void subscribeTopic(String topic) {
    if (!_initialized) {
      throw Exception(
        'MqttConfig is not initialized. Initialize it by calling initialize(config)',
      );
    }
    // `mqtt_client` requires the connection to be fully established before
    // subscribing; defer until `_onConnected` / `_onAutoReconnected`.
    if (!_isClientConnected()) {
      _enqueueSubscription(topic);
      return;
    }
    if (_client?.getSubscriptionsStatus(topic) ==
        MqttSubscriptionStatus.doesNotExist) {
      _client?.subscribe(topic, MqttQos.atMostOnce);
      subscribedTopics.add(topic);
    }
  }

  /// Subscribes to multiple topics.
  ///
  /// This method subscribes to multiple topics on the MQTT broker.
  ///
  /// Parameters:
  ///   - `topics`: The list of topics to subscribe to.
  void subscribeTopics(List<String> topics) {
    if (!_initialized) {
      throw Exception(
        'MqttConfig is not initialized. Initialize it by calling initialize(config)',
      );
    }
    for (var topic in topics) {
      subscribeTopic(topic);
    }
    _subscribedTopicsCallback?.call(subscribedTopics);
  }

  /// Unsubscribes from a single topic.
  ///
  /// This method unsubscribes from a single topic on the MQTT broker.
  ///
  /// Parameters:
  ///   - `topic`: The topic to unsubscribe from.
  void unsubscribeTopic(String topic) {
    if (_client?.getSubscriptionsStatus(topic) ==
        MqttSubscriptionStatus.active) {
      _client?.unsubscribe(topic);
    }
  }

  /// Unsubscribes from multiple topics.
  ///
  /// This method unsubscribes from multiple topics on the MQTT broker.
  ///
  /// Parameters:
  ///   - `topics`: The list of topics to unsubscribe from.
  void unsubscribeTopics(List<String> topics) {
    for (var topic in topics) {
      unsubscribeTopic(topic);
    }
    _unSubscribedTopicsCallback?.call(subscribedTopics);
  }

  /// If the client is down but `MqttClient.autoReconnect` is still enabled,
  /// requests a reconnect cycle. Safe to call on app resume; no-op when
  /// already connected, not initialized, or auto-reconnect was disabled.
  void requestAutoReconnectIfDisconnected() {
    final client = _client;
    if (!_initialized || client == null || !client.autoReconnect) return;
    final state = client.connectionStatus?.state;
    if (state == MqttConnectionState.connected) return;
    if (state != MqttConnectionState.disconnected &&
        state != MqttConnectionState.faulted) {
      return;
    }
    // Fire-and-forget; run inside a guarded zone so that any async
    // `SocketException` emitted by the library's prior-connection cleanup
    // (common when the OS aborted the socket during background) is captured
    // instead of surfacing as a root-zone unhandled exception. The library's
    // own auto-reconnect loop is unaffected.
    unawaited(
      _runZoneGuarded<void>(
        'requestAutoReconnectIfDisconnected',
        () async => client.doAutoReconnect(force: false),
      ),
    );
  }

  /// Disconnects from the broker and stops auto-reconnect until the next
  /// [initialize]. The underlying client clears subscriptions on disconnect.
  void disconnect() {
    _debugLog('disconnect() called — auto-reconnect disabled, closing client');
    _updatesSub?.cancel();
    _updatesSub = null;
    _pendingSubscriptions.clear();
    _client?.autoReconnect = false;
    _client?.disconnect();
  }

  /// A callback function for when the MQTT client receives a PONG response.
  ///
  /// This function is called when the MQTT client receives a PONG response from the MQTT broker.
  void _pong() {
    _callbacks?.pongCallback?.call();
  }

  /// A callback function for when the MQTT client is disconnected.
  ///
  /// This function is called when the MQTT client is disconnected from the MQTT broker.
  void _onDisconnected() {
    _notifySessionLost(
      'MQTT disconnected — ${_client?.connectionStatus ?? 'no status'}',
    );
  }

  /// A callback function for when the MQTT client subscribes to a topic.
  ///
  /// This function is called when the MQTT client subscribes to a topic on the MQTT broker.
  void _onSubscribed(String topic) {
    _callbacks?.onSubscribed?.call(topic);
  }

  /// A callback function for when the MQTT client unsubscribes from a topic.
  ///
  /// This function is called when the MQTT client unsubscribes from a topic on the MQTT broker.
  void _onUnSubscribed(String? topic) {
    _callbacks?.onUnsubscribed?.call(topic);
  }

  /// A callback function for when the MQTT client fails to subscribe to a topic.
  ///
  /// This function is called when the MQTT client fails to subscribe to a topic on the MQTT broker.
  void _onSubscribeFailed(String topic) {
    _callbacks?.onSubscribeFail?.call(topic);
  }

  /// A callback function for when the MQTT client connects to the MQTT broker.
  ///
  /// This function is called when the MQTT client connects to the MQTT broker.
  void _onConnected() {
    _debugLog(
      'MQTT connected — ${_client?.connectionStatus ?? 'no status'}',
    );
    _connectionStream.add(true);
    _callbacks?.onConnected?.call();
    // Subscriptions may have been requested while the client was still
    // connecting (or while auto-reconnect was in progress).
    _flushPendingSubscriptions();
    _updatesSub?.cancel();
    final updates = _client?.updates;
    if (updates == null) return;
    _updatesSub = updates.listen(
      (List<MqttReceivedMessage<MqttMessage>> c) async {
        _rawEventStream.add(c);
        if (c.isEmpty) return;
        final recMess = c.first.payload as MqttPublishMessage;
        final topic = c.first.topic;

        var payload = jsonDecode(
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message),
        ) as Map<String, dynamic>;

        _eventStream.add(
          EventModel(
            topic: topic,
            payload: payload,
          ),
        );
      },
      onError: _handleUpdatesStreamError,
    );
  }

  /// Publishes a message to an MQTT topic.
  ///
  /// This method publishes a message to an MQTT topic on the MQTT broker.
  ///
  /// Parameters:
  ///   - `message`: The message to publish.
  ///   - `pubTopic`: The topic to publish to.
  ///   - `retain`: Whether to retain the message on the MQTT broker.
  int? publishMessage({
    required String message,
    required String pubTopic,
    bool retain = false,
  }) {
    if (message.isEmpty || pubTopic.isEmpty) {
      throw ArgumentError('Message and topic cannot be empty');
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      throw Exception('Client is not connected');
    }

    return _client?.publishMessage(
      pubTopic,
      MqttQos.atMostOnce,
      builder.payload!,
      retain: retain,
    );
  }

  /// This function is called when the MQTT client attempts to reconnect to the MQTT broker.
  void _onAutoReconnect() {
    _notifySessionLost(
      'MQTT connection lost — auto-reconnect started (network/broker unreachable)',
    );
    _callbacks?.onAutoReconnect?.call();
  }

  /// Called after the broker connection is restored by the client's auto-reconnect.
  ///
  /// Subscriptions are re-established by [MqttClient.resubscribeOnAutoReconnect]
  /// when [MqttConfig.autoReconnect] is true; do not call [disconnect] here.
  ///
  /// Re-attaches the updates listener and notifies connection-stream subscribers
  /// so the app resumes processing inbound messages (the listener was cancelled
  /// in [_onAutoReconnect] → [_notifySessionLost]).
  void _onAutoReconnected() {
    _debugLog(
      'MQTT auto-reconnect completed — broker up, resubscribe handled by client',
    );

    // Re-attach the inbound message listener that was cancelled during
    // _onAutoReconnect. Without this, the MQTT client receives messages but
    // the app never processes them (green indicator, no messages).
    _updatesSub?.cancel();
    final updates = _client?.updates;
    if (updates != null) {
      _updatesSub = updates.listen(
        (List<MqttReceivedMessage<MqttMessage>> c) async {
          _rawEventStream.add(c);
          if (c.isEmpty) return;
          final recMess = c.first.payload as MqttPublishMessage;
          final topic = c.first.topic;

          var payload = jsonDecode(
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message),
          ) as Map<String, dynamic>;

          _eventStream.add(
            EventModel(
              topic: topic,
              payload: payload,
            ),
          );
        },
        onError: _handleUpdatesStreamError,
      );
    }

    final updatesReattached = _updatesSub != null;

    if (!_connectionStream.isClosed) {
      _connectionStream.add(true);
    }
    _callbacks?.onConnected?.call();
    _callbacks?.onAutoReconnected?.call(updatesReattached: updatesReattached);

    // In case app requested new topics while reconnecting, flush them now.
    _flushPendingSubscriptions();
  }
}
