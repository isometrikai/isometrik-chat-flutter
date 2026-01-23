import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Variables mixin for IsmChatMqttEventMixin.
///
/// This mixin contains all state variables, queues, controllers, and observable variables
/// used by the MQTT event mixin. All variables are directly accessible by other mixins
/// since they're all part of the same mixin composition.
mixin IsmChatMqttEventVariablesMixin {
  // Note: _controller getter removed as it's not used in the current implementation.
  // If needed in the future, it can be accessed via Get.find<IsmChatMqttController>() directly.

  /// Queue for storing incoming chat messages that need to be processed.
  final Queue<IsmChatMessageModel> eventQueue = Queue();

  /// Flag indicating whether event processing is currently in progress.
  var isEventProcessing = false;

  /// Stores the ID of the last processed message to prevent duplicates.
  String messageId = '';

  /// List of actions related to message delivery status.
  List<IsmChatMqttActionModel> deliverdActions = [];

  /// List of actions related to message read status.
  List<IsmChatMqttActionModel> readActions = [];

  /// Debouncer for handling rapid MQTT actions.
  final ismChatActionDebounce = IsmChatActionDebounce();

  /// Stream controller for broadcasting MQTT events.
  var eventStreamController = StreamController<EventModel>.broadcast();

  /// List of event listener callbacks.
  var eventListeners = <Function(EventModel)>[];

  /// Observable list of users currently typing.
  final RxList<IsmChatTypingModel> _typingUsers = <IsmChatTypingModel>[].obs;
  List<IsmChatTypingModel> get typingUsers => _typingUsers;
  set typingUsers(List<IsmChatTypingModel> value) => _typingUsers.value = value;

  /// Observable flag indicating if the app is in background.
  final RxBool _isAppBackground = false.obs;
  bool get isAppInBackground => _isAppBackground.value;
  set isAppInBackground(bool value) => _isAppBackground.value = value;

  /// Stores messages pending to be processed.
  IsmChatConversationModel? chatPendingMessages;
}
