import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event.dart';

/// A controller class that handles MQTT communication for the chat functionality.
/// This controller manages MQTT connections, message handling, and various chat events.
class IsmChatMqttController extends GetxController
    with
        IsmChatMqttEventVariablesMixin,
        IsmChatMqttEventUtilitiesMixin,
        IsmChatMqttEventProcessingMixin,
        IsmChatMqttEventMessageHandlersMixin,
        IsmChatMqttEventMessageStatusMixin,
        IsmChatMqttEventTypingEventsMixin,
        IsmChatMqttEventGroupOperationsMixin,
        IsmChatMqttEventConversationOperationsMixin,
        IsmChatMqttEventReactionsMixin,
        IsmChatMqttEventBlockUnblockMixin,
        IsmChatMqttEventBroadcastMixin,
        IsmChatMqttEventObserverOperationsMixin,
        IsmChatMqttEventCallsMixin {
  /// Creates a new instance of `IsmChatMqttController`.
  ///
  /// Requires an `IsmChatMqttViewModel` instance to handle business logic.
  IsmChatMqttController(this._viewModel);

  /// The view model that handles business logic for MQTT operations.
  final IsmChatMqttViewModel _viewModel;

  /// Helper class for MQTT operations.
  final mqttHelper = MqttHelper();

  /// List of topics that the client is currently subscribed to.
  List<String> subscribedTopics = [];

  /// Configuration for the current project.
  IsmChatProjectConfig? projectConfig;

  /// Configuration for the current user.
  IsmChatUserConfig? userConfig;

  /// Current state of the MQTT connection.
  final Rx<IsmChatConnectionState> _connectionState =
      IsmChatConnectionState.disconnected.obs;
  IsmChatConnectionState get connectionState => _connectionState.value;
  set connectionState(IsmChatConnectionState value) =>
      _connectionState.value = value;

  /// MQTT-specific configuration settings.
  IsmChatMqttConfig? mqttConfig;

  bool _mqttSetupInProgress = false;
  List<String>? _savedExtraTopics;
  List<String>? _savedTopicChannels;
  bool _savedAutoReconnect = true;
  bool _savedEnableLogging = true;

  /// True after a successful [MqttHelper.initialize] for this session. Used to
  /// decide between a soft broker auto-reconnect nudge and a full re-init.
  bool _mqttInitialized = false;

  /// Active subscriptions to the helper's broadcast streams. The helper creates
  /// brand-new stream controllers on every [MqttHelper.initialize], so these
  /// must be cancelled and re-attached after each (re)initialize; otherwise
  /// stale subscriptions to the replaced controllers leak.
  StreamSubscription<bool>? _mqttConnectionSub;
  StreamSubscription<EventModel>? _mqttEventSub;

  /// Grace period before surfacing a disconnected state, preventing UI flicker
  /// from brief network hiccups where the broker auto-reconnect recovers
  /// quickly. Connected transitions are applied immediately.
  static const Duration _disconnectDebounce = Duration(seconds: 3);
  Timer? _disconnectDebounceTimer;

  /// Consecutive soft reconnect nudges since the last successful connect. Once
  /// this exceeds [_maxNudgesBeforeReinit] the next [ensureMqttConnected]
  /// escalates to a full re-init so a dead/faulted client can never get stuck.
  int _consecutiveNudges = 0;
  static const int _maxNudgesBeforeReinit = 3;

  /// Guards [setupIsmMqttConnection] so two callers (e.g. setup() and the
  /// chat-list health check firing at the same time) can never run a full
  /// initialize concurrently — overlapping inits tear each other's client down
  /// and were a source of the zombie-connection event loss.
  bool _initInFlight = false;

  /// Whether a usable MQTT server config is present. Guards every init /
  /// reconnect path against firing before [setup] has supplied the config —
  /// otherwise the client connects to an empty host (`server , port 0`), fails
  /// with `Failed host lookup: '' (errno = 7)`, and gets auto-reconnect
  /// disabled, leaving a dead client that later blocks a proper init.
  bool get _hasValidMqttConfig =>
      _config != null &&
      (mqttConfig?.hostName ?? '').trim().isNotEmpty &&
      (mqttConfig?.port ?? 0) > 0;

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
  final chatDelegate = IsmChatDelegate();

  /// Sets up the MQTT controller with necessary configurations.
  ///
  /// Parameters:
  /// - `config`: Optional communication configuration
  /// - `mqttProperties`: Required MQTT properties for setup
  ///
  /// This method initializes the MQTT connection and sets up necessary configurations.
  Future<void> setup({
    required IsmChatCommunicationConfig config,
    required IsmMqttProperties mqttProperties,
  }) async {
    final previousUserId = userConfig?.userId;
    _config = config;
    projectConfig = _config?.projectConfig;
    mqttConfig = _config?.mqttConfig;
    userConfig = _config?.userConfig;

    if (mqttProperties.shouldSetupMqtt) {
      final userChanged =
          previousUserId != null && previousUserId != userConfig?.userId;

      if (_mqttInitialized && !userChanged) {
        // MQTT is already initialized for this user. Calling setup() again —
        // e.g. on app resume or a repeated initialize() — must NOT trigger a
        // full re-init here. Tearing down a client whose auto-reconnect is
        // already in-flight races two clients: the torn-down client can still
        // complete its reconnect and fire inbound messages into a now-closed
        // event bus ("event bus is closed - event not fired"), while the fresh
        // client may fail its first connect (e.g. DNS not yet back on resume)
        // and get auto-reconnect disabled — silently stopping real-time events.
        //
        // Instead, merge any newly requested topics and let the existing client
        // recover via its own auto-reconnect (soft nudge), with no teardown.
        IsmChatLog.info(
          'MQTT already initialized — ensuring connection instead of '
          'destructive re-init',
        );
        final extraTopics = mqttProperties.topics;
        if (extraTopics != null && extraTopics.isNotEmpty) {
          subscribeTopics(extraTopics);
        }
        unawaited(ensureMqttConnected());
      } else {
        await setupIsmMqttConnection(
          topics: mqttProperties.topics,
          topicChannels: mqttProperties.topicChannels,
          autoReconnect: mqttProperties.autoReconnect,
          enableLogging: mqttProperties.enableLogging,
        );
      }
    }
    await Future.wait([
      getChatConversationsUnreadCount(),
      getUserMessges(
        senderIds: [userConfig?.userId ?? ''],
      ),
    ]);
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
    // Never initialize without a usable config. Doing so connects to an empty
    // host, fails, and disables auto-reconnect on a client that then gets
    // marked "initialized" — blocking the real init once setup() provides the
    // config. setup() (or a later ensureMqttConnected) re-runs this once the
    // config is ready.
    if (!_hasValidMqttConfig) {
      IsmChatLog.error(
        'MQTT setup skipped — config not ready '
        '(host: "${mqttConfig?.hostName ?? ''}", port: ${mqttConfig?.port ?? 0})',
      );
      return;
    }

    // Prevent two overlapping full initializes (e.g. setup() and the chat-list
    // health check at the same time) from tearing down each other's client.
    if (_initInFlight) {
      IsmChatLog.info('MQTT init already in progress — skipping concurrent setup');
      return;
    }
    _initInFlight = true;
    try {
      _savedExtraTopics = topics;
      _savedTopicChannels = topicChannels;
      _savedAutoReconnect = autoReconnect;
      _savedEnableLogging = enableLogging;

      final topicPrefix =
          '/${projectConfig?.accountId ?? ''}/${projectConfig?.projectId ?? ''}';
      final userTopic = '$topicPrefix/User/${userConfig?.userId ?? ''}';
      final messageTopic = '$topicPrefix/Message/${userConfig?.userId ?? ''}';
      final statusTopic = '$topicPrefix/Status/${userConfig?.userId ?? ''}';

      var channelTopics = topicChannels
          ?.map((e) => '$topicPrefix/$e/${userConfig?.userId ?? ''}')
          .toList();

      final topicsToSubscribe = <String>{
        ...?topics,
        ...?channelTopics,
        userTopic,
        messageTopic,
        statusTopic,
      };
      subscribedTopics.addAll(
        topicsToSubscribe.where((t) => !subscribedTopics.contains(t)),
      );

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
          maxAutoReconnectRetry: 15,
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
          onAutoReconnect: _onAutoReconnectStarted,
          onAutoReconnected: _onAutoReconnectCompleted,
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
      // Reflect whether the initialize actually established a connection. If the
      // initial connect failed (e.g. network down), the helper already disabled
      // auto-reconnect on this client, so it must NOT be treated as a live,
      // nudge-able client — leaving this false lets a later ensureMqttConnected
      // / setup() build a fresh client instead of nudging a dead one.
      _mqttInitialized = mqttHelper.isConnected;
      _attachMqttListeners();
    } finally {
      _initInFlight = false;
    }
  }

  /// (Re)attaches listeners to the helper's broadcast streams.
  ///
  /// The helper replaces its stream controllers on every
  /// [MqttHelper.initialize], so any previous subscriptions are stale and must
  /// be cancelled before re-subscribing — otherwise they leak and may keep
  /// firing into replaced state.
  void _attachMqttListeners() {
    _mqttConnectionSub?.cancel();
    _mqttEventSub?.cancel();
    _mqttConnectionSub =
        mqttHelper.onConnectionChange(_handleMqttConnectionChange);
    _mqttEventSub = mqttHelper.onEvent(
      (event) {
        IsmChatLog.info('Mqtt event: => ${event.toMap()}');
        onMqttEvent(event: event);
      },
    );
  }

  void _handleMqttConnectionChange(bool connected) {
    if (connected) {
      _markConnected();
    } else {
      _markDisconnected('connection-stream');
    }
  }

  /// Applies the connected state immediately, cancels any pending disconnect
  /// debounce, resets the nudge counter, and re-asserts topic subscriptions.
  void _markConnected() {
    _disconnectDebounceTimer?.cancel();
    _disconnectDebounceTimer = null;
    _consecutiveNudges = 0;
    // A live connection means we definitely have a usable initialized client,
    // regardless of whether the initial connect attempt had succeeded.
    _mqttInitialized = true;
    if (connectionState != IsmChatConnectionState.connected) {
      connectionState = IsmChatConnectionState.connected;
      IsmChatConfig.mqttConnectionStatus?.call(connectionState);
    }
    // Topics added during a brief disconnect may have been queued and lost on a
    // client swap; re-assert them. Broker-level resubscribe handles the rest.
    _ensureTopicsSubscribed();
  }

  /// Debounces the disconnected state so a quick broker auto-reconnect does not
  /// flicker the UI indicator. After the grace window, if the broker is still
  /// down, surfaces the disconnected state and triggers an app-level reconnect.
  void _markDisconnected(String reason) {
    _disconnectDebounceTimer?.cancel();
    _disconnectDebounceTimer = Timer(_disconnectDebounce, () {
      _disconnectDebounceTimer = null;
      // Recovered during the grace window — nothing to surface.
      if (mqttHelper.isConnected) return;
      if (connectionState != IsmChatConnectionState.disconnected) {
        connectionState = IsmChatConnectionState.disconnected;
        IsmChatConfig.mqttConnectionStatus?.call(connectionState);
      }
      IsmChatLog.error('MQTT disconnected ($reason)');
      if (IsmChatConfig.shouldSetupMqtt) {
        unawaited(ensureMqttConnected());
      }
    });
  }

  /// Reconnects MQTT when disconnected; no-op when already connected.
  ///
  /// Prefers a soft nudge of the broker's own auto-reconnect over a full
  /// re-init (replacing the client mid-flight while its auto-reconnect is
  /// recovering can drop subscriptions and surface stale callbacks). Escalates
  /// to a full re-init when the helper was never initialized, or after repeated
  /// nudges fail to recover.
  Future<void> ensureMqttConnected({bool refreshChatList = true}) async {
    if (!IsmChatConfig.shouldSetupMqtt || _mqttSetupInProgress) return;

    // Config not ready yet (setup() hasn't supplied it) — do nothing. Prevents
    // a connect to an empty host that would disable auto-reconnect and leave a
    // dead client behind.
    if (!_hasValidMqttConfig) {
      IsmChatLog.info('ensureMqttConnected skipped — MQTT config not ready');
      return;
    }

    // Use the real broker state, not the debounced UI flag — the grace window
    // can mask a socket that is actually down.
    if (mqttHelper.isConnected) {
      _markConnected();
      return;
    }

    // Soft nudge path: initialized client that is just temporarily down.
    if (_mqttInitialized && _consecutiveNudges < _maxNudgesBeforeReinit) {
      _consecutiveNudges++;
      IsmChatLog.info(
        'MQTT down — nudging broker auto-reconnect '
        '(attempt $_consecutiveNudges/$_maxNudgesBeforeReinit)',
      );
      mqttHelper.requestAutoReconnectIfDisconnected();
      return;
    }

    _mqttSetupInProgress = true;
    try {
      IsmChatLog.info('MQTT down — full re-init via ensureMqttConnected');
      _consecutiveNudges = 0;
      // Do NOT clear subscribedTopics here: it holds runtime-added topics that
      // must survive the re-init. setupIsmMqttConnection merges the standard
      // topics in without duplicates, and the fresh client subscribes the full
      // set on connect.
      await setupIsmMqttConnection(
        topics: _savedExtraTopics,
        topicChannels: _savedTopicChannels,
        autoReconnect: _savedAutoReconnect,
        enableLogging: _savedEnableLogging,
      );
      if (refreshChatList &&
          IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    } catch (e, st) {
      IsmChatLog.error('ensureMqttConnected failed: $e', st);
    } finally {
      _mqttSetupInProgress = false;
    }
  }

  /// Lightweight reconnect hint for app resume — nudges the broker's own
  /// auto-reconnect when the socket is down. Falls back to a full re-init only
  /// when the helper was never initialized. Safe no-op when already connected.
  void nudgeReconnectAfterAppResume() {
    if (!IsmChatConfig.shouldSetupMqtt || !_hasValidMqttConfig) return;
    if (mqttHelper.isConnected) {
      _markConnected();
      return;
    }
    if (_mqttInitialized) {
      mqttHelper.requestAutoReconnectIfDisconnected();
    } else {
      unawaited(ensureMqttConnected());
    }
  }

  /// Re-asserts all known topic subscriptions. Broker-level resubscribe covers
  /// topics known at disconnect time, but topics added while briefly
  /// disconnected may have been queued and lost on a client swap. Idempotent:
  /// the helper only subscribes to topics not already active.
  void _ensureTopicsSubscribed() {
    if (!_mqttInitialized || subscribedTopics.isEmpty) return;
    if (!mqttHelper.isConnected) return;
    for (final topic in subscribedTopics) {
      try {
        mqttHelper.subscribeTopic(topic);
      } catch (e) {
        IsmChatLog.error('Re-subscribe topic "$topic" failed: $e');
      }
    }
  }

  /// Recovers data that may have been missed while MQTT was down. Triggered
  /// after a successful auto-reconnect.
  Future<void> _refreshAfterReconnect() async {
    try {
      if (IsmChatUtility.conversationControllerRegistered) {
        await IsmChatUtility.conversationController.getChatConversations();
      }
    } catch (e, st) {
      IsmChatLog.error('Refresh after MQTT reconnect failed: $e', st);
    }
  }

  @override
  void onClose() {
    _disconnectDebounceTimer?.cancel();
    _mqttConnectionSub?.cancel();
    _mqttEventSub?.cancel();
    super.onClose();
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    _markConnected();
    IsmChatLog.success('MQTT connected');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    _markDisconnected('broker/network');
    IsmChatLog.error('MQTT Disconnected');
  }

  /// Called when the broker's own auto-reconnect cycle starts (connection lost).
  void _onAutoReconnectStarted() {
    IsmChatLog.info('MQTT auto-reconnect started');
    _markDisconnected('auto-reconnect-started');
  }

  /// Called when the broker's auto-reconnect completes successfully.
  void _onAutoReconnectCompleted({required bool updatesReattached}) {
    IsmChatLog.success(
      'MQTT auto-reconnect completed (updates reattached: $updatesReattached)',
    );
    _markConnected();
    // Recover anything missed while the socket was down.
    unawaited(_refreshAfterReconnect());
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
  /// The topics are always recorded in [subscribedTopics] first, so they
  /// survive any future reconnect or full re-init (they are re-asserted on
  /// every connect via [_ensureTopicsSubscribed] and passed to the fresh
  /// client on re-init). This is what keeps events flowing for runtime-added
  /// topics after a reconnect.
  ///
  /// The topics are then handed to the helper: if the client is connected they
  /// are subscribed immediately; if not, the helper enqueues them to its
  /// pending queue and flushes them once the connection is (re)established.
  ///
  /// - `topic`: List of topics to subscribe to. Each topic should follow the
  ///   MQTT topic format and adhere to any project-specific topic conventions.
  void subscribeTopics(List<String> topic) {
    for (final t in topic) {
      if (t.isNotEmpty && !subscribedTopics.contains(t)) {
        subscribedTopics.add(t);
      }
    }
    if (_mqttInitialized) {
      mqttHelper.subscribeTopics(topic);
    }
  }

  /// Unsubscribes from the specified list of topics.
  ///
  /// The topics are removed from [subscribedTopics] first so they are not
  /// re-subscribed on the next reconnect / re-init, then handed to the helper
  /// to unsubscribe from the broker when initialized.
  ///
  /// - `topic`: List of topics to unsubscribe from. These should be topics that
  ///   the client has previously subscribed to.
  void unSubscribeTopics(List<String> topic) {
    subscribedTopics.removeWhere(topic.contains);
    if (_mqttInitialized) {
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
    final response = await _viewModel.getChatConversationsUnreadCount(
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
    await _viewModel.getChatConversationsUnreadCountBulk(
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
      await _viewModel.getChatConversationsCount(
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
      await _viewModel.getChatConversationsMessageCount(
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
        // Match 1:1 chats only — groups must be deleted by explicit
        // conversationId to avoid removing the wrong group when several
        // groups share the same member.
        var conversation = conversations?.firstWhere(
          (element) =>
              element.isGroup != true &&
              element.opponentDetails?.userId == isometrickChatId,
          orElse: IsmChatConversationModel.new,
        );

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
      await _viewModel.getChatConversationApi(
        skip: skip,
        limit: limit,
        searchTag: searchTag ?? '',
        includeConversationStatusMessagesInUnreadMessagesCount:
        includeConversationStatusMessagesInUnreadMessagesCount,
      );

  /// Retrieves user messages from the server or local database.
  ///
  /// `ids`: Optional list of message IDs to retrieve.
  /// `messageTypes`: Optional list of message types to filter.
  /// `customTypes`: Optional list of custom message types to filter.
  /// `attachmentTypes`: Optional list of attachment types to filter.
  /// `showInConversation`: Indicates if messages should be shown in conversation.
  /// `senderIds`: Optional list of sender IDs to filter.
  /// `parentMessageId`: Optional parent message ID for threaded messages.
  /// `lastMessageTimestamp`: Optional timestamp for filtering messages.
  /// `conversationStatusMessage`: Indicates if the message is a status message.
  /// `searchTag`: Optional search term for filtering messages.
  /// `fetchConversationDetails`: Indicates if conversation details should be fetched.
  /// `deliveredToMe`: Indicates if the messages should be filtered by delivery status.
  /// `senderIdsExclusive`: Indicates if the sender IDs should be exclusive.
  /// `limit`: Maximum number of messages to retrieve.
  /// `skip`: Number of messages to skip.
  /// `sort`: Sorting order for messages.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> getUserMessges({
    List<String>? ids,
    List<String>? messageTypes,
    List<String>? customTypes,
    List<String>? attachmentTypes,
    String? showInConversation,
    List<String>? senderIds,
    String? parentMessageId,
    int? lastMessageTimestamp,
    bool? conversationStatusMessage,
    String? searchTag,
    String? fetchConversationDetails,
    bool deliveredToMe = false,
    bool senderIdsExclusive = true,
    int limit = 20,
    int? skip = 0,
    int? sort = -1,
    bool isLoading = false,
  }) async {
    var response = await _viewModel.getUserMessges(
      attachmentTypes: attachmentTypes,
      conversationStatusMessage: conversationStatusMessage,
      customTypes: customTypes,
      deliveredToMe: deliveredToMe,
      fetchConversationDetails: fetchConversationDetails,
      ids: ids,
      lastMessageTimestamp: lastMessageTimestamp,
      limit: limit,
      messageTypes: messageTypes,
      parentMessageId: parentMessageId,
      searchTag: searchTag,
      senderIds: senderIds,
      senderIdsExclusive: senderIdsExclusive,
      showInConversation: showInConversation,
      skip: skip,
      sort: sort,
      isLoading: isLoading,
    );
    if (response != null) {
      final userMeessages = response.reversed.toList();
      for (final message in userMeessages) {
        final isSender =
        message.deliveredTo?.any((e) => e.userId == senderIds?.first);
        if (isSender == false) {
          await Future.delayed(
            const Duration(milliseconds: 100),
          );
          await pingMessageDelivered(
            conversationId: message.conversationId ?? '',
            messageId: message.messageId ?? '',
          );
        }
      }
    }
  }

  ///  Notifies the sender that a message has been delivered using MQTT
  ///
  ///  `conversationId`: The ID of the conversation.
  ///  `messageId`: The ID of the message.
  Future<void> pingMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async {
    await _viewModel.pingMessageDelivered(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _viewModel.readSingleMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}