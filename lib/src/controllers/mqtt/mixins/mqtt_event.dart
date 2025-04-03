import 'dart:async';
import 'dart:collection';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Mixin that handles MQTT events and message processing for the chat system.
mixin IsmChatMqttEventMixin {
  IsmChatMqttController get _controller => Get.find<IsmChatMqttController>();

  /// Queue for storing incoming chat messages that need to be processed.
  final Queue<IsmChatMessageModel> _eventQueue = Queue();

  /// Flag indicating whether event processing is currently in progress.
  var _isEventProcessing = false;

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

  /// Handles incoming MQTT events and routes them to appropriate handlers.
  ///
  /// - `event`: The MQTT event to process
  void onMqttEvent({required EventModel event}) async {
    _controller.eventStreamController.add(event);
    final payload = event.payload;
    if (payload['action'] != 'chatMessageSent') {
      var action = payload['action'];
      if (IsmChatActionEvents.values
          .map((e) => e.toString())
          .contains(action)) {
        var actionModel = IsmChatMqttActionModel.fromMap(payload);
        _handleAction(actionModel);
      }
    } else {
      var message = IsmChatMessageModel.fromMap(payload);
      if (messageId == message.messageId) return;
      messageId = message.messageId ?? '';
      _handleLocalNotification(message);
      deliverdActions.clear();
      readActions.clear();
      _eventQueue.add(message);
      if (!_isEventProcessing) {
        _eventProcessQueue();
      }
    }
  }

  /// Processes the event queue.
  ///
  /// This method is called when the event queue is not empty and event processing is not in progress.
  void _eventProcessQueue() async {
    if (_isEventProcessing) return;
    _isEventProcessing = true;
    try {
      while (_eventQueue.isNotEmpty) {
        final event = _eventQueue.removeFirst();
        await _handleMessage(event);
      }
    } catch (e, stack) {
      IsmChatLog.error(
          'Error during event processing: $e Stack trace: $stack ');
    } finally {
      _isEventProcessing = false;
    }
  }

  /// Handles an MQTT action.
  ///
  /// * `actionModel`: The MQTT action model to handle
  void _handleAction(IsmChatMqttActionModel actionModel) async {
    switch (actionModel.action) {
      case IsmChatActionEvents.typingEvent:
        _handleTypingEvent(actionModel);
        break;
      case IsmChatActionEvents.conversationCreated:
        await _handleCreateConversation(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');

        break;
      case IsmChatActionEvents.messageDelivered:
        _handleMessageDelivered(actionModel);
        break;
      case IsmChatActionEvents.messageRead:
        _handleMessageRead(actionModel);
        break;
      case IsmChatActionEvents.messagesDeleteForAll:
        _handleMessageDelelteForEveryOne(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.multipleMessagesRead:
        _handleMultipleMessageRead(actionModel);
        break;
      case IsmChatActionEvents.userBlock:
      case IsmChatActionEvents.userUnblock:
      case IsmChatActionEvents.userBlockConversation:
      case IsmChatActionEvents.userUnblockConversation:
        _handleBlockUserOrUnBlock(actionModel);
        _handleUnreadMessages(actionModel.initiatorDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.clearConversation:
        break;
      case IsmChatActionEvents.deleteConversationLocally:
        _handleDeletChatFromLocal(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.memberLeave:
      case IsmChatActionEvents.memberJoin:
        _handleMemberJoinAndLeave(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.addMember:
      case IsmChatActionEvents.membersRemove:
        _handleGroupRemoveAndAddUser(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.removeAdmin:
      case IsmChatActionEvents.addAdmin:
        _handleAdminRemoveAndAdd(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;

      case IsmChatActionEvents.reactionAdd:
      case IsmChatActionEvents.reactionRemove:
        _handleAddAndRemoveReaction(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.conversationDetailsUpdated:
      case IsmChatActionEvents.conversationTitleUpdated:
      case IsmChatActionEvents.conversationImageUpdated:
        _handleConversationUpdate(actionModel);
        _handleUnreadMessages(actionModel.userDetails?.userId ?? '');
        break;
      case IsmChatActionEvents.broadcast:
        _handleBroadcast(actionModel);
        break;

      case IsmChatActionEvents.observerJoin:
      case IsmChatActionEvents.observerLeave:
        _handleObserverJoinAndLeave(actionModel);
        break;
      case IsmChatActionEvents.userUpdate:
      case IsmChatActionEvents.messageDetailsUpdated:
        break;
      case IsmChatActionEvents.meetingCreated:
      case IsmChatActionEvents.meetingEndedByHost:
      case IsmChatActionEvents.meetingEndedDueToRejectionByAll:
        _handleOneToOneCall(actionModel);
        break;
    }
  }

  /// Handles an observer join and leave event.
  ///
  /// * `actionModel`: The observer join and leave event model to handle
  void _handleObserverJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    if (actionModel.senderId == _controller.userConfig?.userId) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper
        ?.getConversation(conversationId: actionModel.conversationId);
    if (conversation != null) {
      var message = IsmChatMessageModel(
        body: '',
        userName: actionModel.userDetails?.userName ?? '',
        customType: actionModel.customType,
        sentAt: actionModel.sentAt,
        sentByMe: false,
        senderInfo: UserDetails(
          userProfileImageUrl: actionModel.userDetails?.profileImageUrl ?? '',
          userName: actionModel.userDetails?.userName ?? '',
          userIdentifier: actionModel.userDetails?.userIdentifier ?? '',
          userId: actionModel.userDetails?.userId ?? '',
          online: true,
          lastSeen: 0,
        ),
        metaData: IsmChatMetaData(messageSentAt: actionModel.sentAt),
      );
      conversation.messages
          ?.addEntries({'${message.metaData?.messageSentAt}': message}.entries);
      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
      if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
        var chatController =
            Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
        if (chatController.conversation?.conversationId ==
            message.conversationId) {
          await chatController
              .getMessagesFromDB(actionModel.conversationId ?? '');
        }
      }
      if (Get.isRegistered<IsmChatConversationsController>()) {
        unawaited(Get.find<IsmChatConversationsController>()
            .getConversationsFromDB());
      }
    }
  }

  /// Handles a broadcast event.
  ///
  /// * `actionModel`: The broadcast event model to handle
  void _handleBroadcast(IsmChatMqttActionModel actionModel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (actionModel.senderId == _controller.userConfig?.userId) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId);

    if (conversation == null ||
        conversation.lastMessageDetails?.messageId == actionModel.messageId) {
      return;
    }

    // To handle and show last message & unread count in conversation list
    conversation = conversation.copyWith(
      unreadMessagesCount: IsmChatResponsive.isWeb(Get.context!) &&
              (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag) &&
                  Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                          .conversation
                          ?.conversationId ==
                      actionModel.conversationId)
          ? 0
          : (conversation.unreadMessagesCount ?? 0) + 1,
      lastMessageDetails: conversation.lastMessageDetails?.copyWith(
        sentByMe: false,
        showInConversation: true,
        sentAt: actionModel.sentAt,
        senderName: actionModel.senderName,
        messageType: actionModel.messageType?.value ?? 0,
        messageId: actionModel.messageId ?? '',
        conversationId: actionModel.conversationId ?? '',
        body: actionModel.body,
        customType: actionModel.customType,
        action: '',
      ),
    );
    var message = IsmChatMessageModel(
      body: actionModel.body ?? '',
      sentAt: actionModel.sentAt,
      customType: actionModel.customType,
      sentByMe: false,
      messageId: actionModel.messageId,
      attachments: actionModel.attachments,
      conversationId: actionModel.conversationId,
      isGroup: false,
      messageType: actionModel.messageType,
      metaData: actionModel.metaData,
      senderInfo: UserDetails(
        userProfileImageUrl: '',
        userName: actionModel.senderName ?? '',
        userIdentifier: '',
        userId: actionModel.senderId ?? '',
        online: false,
        lastSeen: 0,
      ),
    );

    conversation.messages?.addEntries({'${message.sentAt}': message}.entries);
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: conversation);
    if (Get.isRegistered<IsmChatConversationsController>()) {
      var conversationController = Get.find<IsmChatConversationsController>();
      unawaited(conversationController.getConversationsFromDB());
      await conversationController.pingMessageDelivered(
        conversationId: actionModel.conversationId ?? '',
        messageId: actionModel.messageId ?? '',
      );
    }
    _handleUnreadMessages(message.senderInfo?.userId ?? '');

    // To handle messages in chatList
    if (!Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      return;
    }
    var chatController = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
    if (chatController.conversation?.conversationId != message.conversationId) {
      return;
    }

    unawaited(chatController.getMessagesFromDB(message.conversationId ?? ''));
    await Future.delayed(const Duration(milliseconds: 30));
    await chatController.readSingleMessage(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );
  }

  /// Handles a message.
  ///
  /// * `message`: The message to handle
  Future<void> _handleMessage(IsmChatMessageModel message) async {
    _handleUnreadMessages(message.senderInfo?.userId ?? '');
    await Future.delayed(const Duration(milliseconds: 100));
    if (message.senderInfo?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    var conversationController = Get.find<IsmChatConversationsController>();
    var conversation = await IsmChatConfig.dbWrapper
        ?.getConversation(conversationId: message.conversationId);

    if (conversation == null &&
        Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      final controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

      if (message.conversationId == controller.conversation?.conversationId) {
        if (controller.messages.isEmpty) {
          controller.messages =
              controller.commonController.sortMessages([message]);
        } else {
          controller.messages.add(message);
        }
        return;
      }
    }

    if (conversation == null ||
        conversation.lastMessageDetails?.messageId == message.messageId) {
      return;
    }

    // To handle and show last message & unread count in conversation list
    conversation = conversation.copyWith(
      unreadMessagesCount: IsmChatResponsive.isWeb(Get.context!) &&
              (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag) &&
                  Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                          .conversation
                          ?.conversationId ==
                      message.conversationId)
          ? 0
          : (conversation.unreadMessagesCount ?? 0) + 1,
      lastMessageDetails: conversation.lastMessageDetails?.copyWith(
        sentByMe: message.sentByMe,
        senderId: message.senderInfo?.userId ?? '',
        showInConversation: true,
        sentAt: message.sentAt,
        senderName: message.senderInfo?.userName,
        messageType: message.messageType?.value ?? 0,
        messageId: message.messageId ?? '',
        conversationId: message.conversationId ?? '',
        body: message.body,
        customType: message.customType,
        action: '',
        deliverCount: 0,
        deliveredTo: [],
        readCount: 0,
        readBy: [],
        reactionType: '',
      ),
    );
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var chatController = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (chatController.conversation?.conversationId ==
          message.conversationId) {
        conversation.messages
            ?.addEntries({'${message.sentAt}': message}.entries);
      }
    }

    await IsmChatConfig.dbWrapper?.saveConversation(conversation: conversation);
    unawaited(conversationController.getConversationsFromDB());
    await conversationController.pingMessageDelivered(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );

    if (!Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) return;
    var chatController = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
    if (chatController.conversation?.conversationId != message.conversationId) {
      return;
    }
    unawaited(chatController.getMessagesFromDB(message.conversationId ?? ''));
    await Future.delayed(const Duration(milliseconds: 100));
    if (_controller.isAppInBackground == false) {
      await chatController.readSingleMessage(
        conversationId: message.conversationId ?? '',
        messageId: message.messageId ?? '',
      );
    }
  }

  /// Handles a local notification.
  ///
  /// * `message`: The message to handle
  void _handleLocalNotification(IsmChatMessageModel message) {
    if (message.senderInfo?.userId == _controller.userConfig?.userId) {
      return;
    }
    String? mqttMessage;

    switch (message.customType) {
      case IsmChatCustomMessageType.image:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.video:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.file:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.audio:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.location:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.reply:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.forward:
        mqttMessage = message.notificationBody;
        break;
      case IsmChatCustomMessageType.link:
        mqttMessage = message.notificationBody;
        break;
      default:
        mqttMessage = message.body;
    }

    if (message.events != null &&
        message.events?.sendPushNotification == false) {
      return;
    }

    final notificationTitle =
        '${message.senderInfo?.metaData?.firstName ?? ''} ${message.senderInfo?.metaData?.lastName ?? ''}'
            .trim();

    if (!IsmChatResponsive.isWeb(Get.context!)) {
      if (isAppInBackground) {
        showPushNotification(
            title: notificationTitle.isNotEmpty
                ? notificationTitle
                : message.notificationTitle ?? '',
            body: mqttMessage ?? '',
            conversationId: message.conversationId ?? '');

        return;
      }
      if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
        var chatController =
            Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
        if (chatController.conversation?.conversationId !=
            message.conversationId) {
          showPushNotification(
              title: notificationTitle.isNotEmpty
                  ? notificationTitle
                  : message.notificationTitle ?? '',
              body: mqttMessage ?? '',
              conversationId: message.conversationId ?? '');
        }
      } else {
        showPushNotification(
            title: notificationTitle.isNotEmpty
                ? notificationTitle
                : message.notificationTitle ?? '',
            body: mqttMessage ?? '',
            conversationId: message.conversationId ?? '');
      }
    } else {
      if (Get.isRegistered<IsmChatConversationsController>()) {
        if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
          var chatController =
              Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
          if (chatController.conversation?.conversationId ==
              message.conversationId) {
            return;
          }
        }
        ElegantNotification(
          icon: Icon(
            Icons.message_rounded,
            color: IsmChatConfig.chatTheme.primaryColor ?? Colors.blue,
          ),
          width: IsmChatDimens.twoHundredFifty,
          // notificationPosition: NotificationPosition.topRight,
          animation: AnimationType.fromRight,
          title: Text(notificationTitle.isNotEmpty
              ? notificationTitle
              : message.notificationTitle ?? ''),
          description: Expanded(
            child: Text(
              mqttMessage ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          progressIndicatorColor:
              IsmChatConfig.chatTheme.primaryColor ?? Colors.blue,
        ).show(IsmChatConfig.context ??
            Get.find<IsmChatConversationsController>().context!);
      }
    }
  }

  /// Shows a push notification.
  ///
  /// * `title`: The title of the notification.
  /// * `body`: The body of the notification.
  /// * `conversationId`: The conversation ID.
  void showPushNotification({
    required String title,
    required String body,
    required String conversationId,
  }) {
    if (IsmChatConfig.showNotification != null) {
      IsmChatConfig.showNotification?.call(
        title,
        body,
        conversationId,
      );
    }
  }

  /// Handles a typing event.
  ///
  /// * `actionModel`: The typing event model to handle
  void _handleTypingEvent(IsmChatMqttActionModel actionModel) {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    var user = IsmChatTypingModel(
      conversationId: actionModel.conversationId ?? '',
      userName: actionModel.userDetails?.userName ?? '',
    );
    _controller.typingUsers.add(user);
    Future.delayed(
      const Duration(seconds: 3),
      () {
        _controller.typingUsers.remove(user);
      },
    );
  }

  /// Handles a message delivered event.
  ///
  /// * `actionModel`: The message delivered event model to handle
  void _handleMessageDelivered(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    deliverdActions.add(actionModel);
    final actionsData = List<IsmChatMqttActionModel>.from(deliverdActions);
    ismChatActionDebounce.run(() async {
      for (var action in actionsData) {
        var conversation = await IsmChatConfig.dbWrapper
            ?.getConversation(conversationId: action.conversationId);
        var message = conversation?.messages?.values
            .cast<IsmChatMessageModel?>()
            .firstWhere(
              (e) => e?.messageId == action.messageId,
              orElse: () => null,
            );
        if (message != null) {
          var isDelivered = message.deliveredTo
              ?.any((e) => e.userId == action.userDetails?.userId);
          if (isDelivered == false) {
            message.deliveredTo?.add(
              MessageStatus(
                userId: action.userDetails?.userId ?? '',
                timestamp: action.sentAt,
              ),
            );
          }
          message.deliveredToAll = message.deliveredTo?.length ==
              (conversation?.membersCount ?? 0) - 1;

          conversation?.messages?['${message.metaData?.messageSentAt}'] =
              message;
          conversation = conversation?.copyWith(
            lastMessageDetails: conversation.lastMessageDetails?.copyWith(
              deliverCount: message.deliveredTo?.length,
              deliveredTo: message.deliveredTo,
            ),
          );
          await IsmChatConfig.dbWrapper
              ?.saveConversation(conversation: conversation!);
          if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
            await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                .getMessagesFromDB(action.conversationId ?? '');
          }
          if (Get.isRegistered<IsmChatConversationsController>()) {
            unawaited(Get.find<IsmChatConversationsController>()
                .getConversationsFromDB());
          }
        }
        deliverdActions.remove(action);
      }
    });
  }

// Handles a message read event.
  ///
  /// * `actionModel`: The message read event model to handle
  void _handleMessageRead(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    readActions.add(actionModel);
    ismChatActionDebounce.run(() async {
      final actionsData = List<IsmChatMqttActionModel>.from(readActions);

      for (var action in actionsData) {
        var conversation = await IsmChatConfig.dbWrapper
            ?.getConversation(conversationId: action.conversationId);

        var message = conversation?.messages?.values
            .cast<IsmChatMessageModel?>()
            .firstWhere(
              (e) => e?.messageId == action.messageId,
              orElse: () => null,
            );
        if (message != null) {
          var isRead = message.readBy
              ?.any((e) => e.userId == action.userDetails?.userId);
          if (isRead == false) {
            message.readBy?.add(
              MessageStatus(
                userId: action.userDetails?.userId ?? '',
                timestamp: action.sentAt,
              ),
            );
          }
          message.readByAll =
              message.readBy?.length == (conversation?.membersCount ?? 0) - 1;

          conversation?.messages?['${message.metaData?.messageSentAt}'] =
              message;
          conversation = conversation?.copyWith(
            lastMessageDetails: conversation.lastMessageDetails?.copyWith(
              readCount: message.readBy?.length,
              readBy: message.readBy,
            ),
          );
          await IsmChatConfig.dbWrapper
              ?.saveConversation(conversation: conversation!);
          if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
            await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                .getMessagesFromDB(action.conversationId ?? '');
          }
          if (Get.isRegistered<IsmChatConversationsController>()) {
            unawaited(Get.find<IsmChatConversationsController>()
                .getConversationsFromDB());
          }
        }
        readActions.remove(action);
      }
    });
  }

  /// Handles a multiple message read event.
  ///
  /// * `actionModel`: The multiple message read event model to handle
  void _handleMultipleMessageRead(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (IsmChatConfig.dbWrapper == null) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper
        ?.getConversation(conversationId: actionModel.conversationId);
    if (conversation != null) {
      var allMessages = conversation.messages ?? {};
      var modifiedMessages = {};
      for (var message in allMessages.values) {
        if (message.deliveredToAll == true && message.readByAll == true) {
          modifiedMessages.addEntries(
              {'${message.metaData?.messageSentAt}': message}.entries);
        } else {
          var isDelivered = message.deliveredTo
              ?.any((e) => e.userId == actionModel.userDetails?.userId);
          var isRead = message.readBy
              ?.any((e) => e.userId == actionModel.userDetails?.userId);
          var deliveredTo = message.deliveredTo ?? [];
          var readBy = message.readBy ?? [];
          var modified = message.copyWith(
            deliveredTo: isDelivered == true
                ? deliveredTo
                : [
                    ...deliveredTo,
                    MessageStatus(
                      userId: actionModel.userDetails?.userId ?? '',
                      timestamp: actionModel.sentAt,
                    ),
                  ],
            readBy: isRead == true
                ? readBy
                : [
                    ...readBy,
                    MessageStatus(
                      userId: actionModel.userDetails?.userId ?? '',
                      timestamp: actionModel.sentAt,
                    ),
                  ],
          );

          modified = modified.copyWith(
            readByAll:
                modified.readBy?.length == (conversation.membersCount ?? 0) - 1
                    ? true
                    : false,
            deliveredToAll: modified.deliveredTo?.length ==
                    (conversation.membersCount ?? 0) - 1
                ? true
                : false,
          );

          modifiedMessages.addEntries(
              {'${modified.metaData?.messageSentAt}': modified}.entries);
        }
      }
      final meesages = IsmChatMessages.from(modifiedMessages);
      conversation = conversation.copyWith(
        messages: meesages,
        lastMessageDetails: conversation.lastMessageDetails?.copyWith(
          deliverCount: meesages.isEmpty
              ? 1
              : meesages.values.last.deliveredTo?.length ?? 0,
          readCount:
              meesages.isEmpty ? 1 : meesages.values.last.readBy?.length ?? 0,
          readBy: meesages.isEmpty ? [] : meesages.values.last.readBy,
          deliveredTo: meesages.isEmpty ? [] : meesages.values.last.deliveredTo,
        ),
      );

      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
    }
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getMessagesFromDB(actionModel.conversationId ?? '');
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getConversationsFromDB();
    }
  }

  /// Handles a message delete for everyone event.
  ///
  /// * `actionModel`: The message delete for everyone event model to handle
  void _handleMessageDelelteForEveryOne(
      IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    var allMessages = await IsmChatConfig.dbWrapper
        ?.getMessage(actionModel.conversationId ?? '');
    if (allMessages == null) {
      return;
    }
    if (actionModel.messageIds?.isNotEmpty == true) {
      for (var x in actionModel.messageIds ?? []) {
        var message = allMessages.values
            .cast<IsmChatMessageModel?>()
            .firstWhere((e) => e?.messageId == x, orElse: () => null);
        if (message != null) {
          allMessages['${message.metaData?.messageSentAt}']?.customType =
              IsmChatCustomMessageType.deletedForEveryone;
        }
      }
    }

    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper
          ?.saveConversation(conversation: conversation);
    }

    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getMessagesFromDB(actionModel.conversationId ?? '');
      }
    }
  }

  /// Handles a block user or unblock event.
  ///
  /// * `actionModel`: The block user or unblock event model to handle
  void _handleBlockUserOrUnBlock(IsmChatMqttActionModel actionModel) async {
    if (actionModel.initiatorDetails?.userId ==
        _controller.userConfig?.userId) {
      return;
    }
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getConverstaionDetails();
        await controller.getMessagesFromAPI(
          lastMessageTimestamp: controller.messages.last.sentAt,
        );
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      var conversationController = Get.find<IsmChatConversationsController>();
      await conversationController.getBlockUser();
      await conversationController.getChatConversations();
    }
  }

  /// Handles a one to one call event.
  ///
  /// * `actionModel`: The one to one call event model to handle
  void _handleOneToOneCall(IsmChatMqttActionModel actionModel) async {
    if (messageId == actionModel.sentAt.toString()) return;
    messageId = actionModel.sentAt.toString();
    if (actionModel.initiatorId == _controller.userConfig?.userId) {
      return;
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    unawaited(
        Get.find<IsmChatConversationsController>().getChatConversations());
    if (!Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) return;
    var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
    if (controller.conversation?.conversationId == actionModel.conversationId) {
      await controller.getMessagesFromAPI(
        lastMessageTimestamp: controller.messages.last.sentAt,
      );
    }
  }

  /// Handles a group remove and add user event.
  ///
  /// * `actionModel`: The group remove and add user event model to handle
  void _handleGroupRemoveAndAddUser(IsmChatMqttActionModel actionModel) async {
    if (messageId == actionModel.sentAt.toString()) return;
    messageId = actionModel.sentAt.toString();
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    var conversationController = Get.find<IsmChatConversationsController>();
    if (actionModel.action == IsmChatActionEvents.addMember) {
      await conversationController.getChatConversations();
    }
    var allMessages = await IsmChatConfig.dbWrapper
        ?.getMessage(actionModel.conversationId ?? '');
    allMessages?.addEntries(
      {
        '${actionModel.sentAt}': IsmChatMessageModel(
          members: actionModel.members,
          initiatorId: actionModel.userDetails?.userId,
          initiatorName: actionModel.userDetails?.userName,
          customType:
              IsmChatCustomMessageType.fromString(actionModel.action.name),
          body: '',
          sentAt: actionModel.sentAt,
          sentByMe: false,
          isGroup: true,
          conversationId: actionModel.conversationId,
          memberId: actionModel.members?.first.memberId,
          memberName: actionModel.members?.first.memberName,
          senderInfo: UserDetails(
            userProfileImageUrl: actionModel.userDetails?.profileImageUrl ?? '',
            userName: actionModel.userDetails?.userName ?? '',
            userIdentifier: actionModel.userDetails?.userIdentifier ?? '',
            userId: actionModel.userDetails?.userId ?? '',
            online: true,
            lastSeen: 0,
          ),
        )
      }.entries,
    );

    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var chatPageController =
          Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (actionModel.conversationId ==
          chatPageController.conversation?.conversationId) {
        chatPageController.conversation =
            chatPageController.conversation?.copyWith(
          lastMessageDetails: LastMessageDetails(
            sentByMe: false,
            showInConversation: true,
            sentAt: actionModel.sentAt,
            senderName: actionModel.userDetails?.userName ?? '',
            messageType: 0,
            messageId: '',
            conversationId: actionModel.conversationId ?? '',
            body: '',
            customType:
                IsmChatCustomMessageType.fromString(actionModel.action.name),
            senderId: actionModel.userDetails?.userId ?? '',
            userId: actionModel.members?.first.memberId,
            members:
                actionModel.members?.map((e) => e.memberName ?? '').toList(),
            reactionType: '',
          ),
        );
        await chatPageController
            .getMessagesFromDB(actionModel.conversationId ?? '');
      }
    }
    if (actionModel.action == IsmChatActionEvents.membersRemove) {
      var conversation = await IsmChatConfig.dbWrapper!
          .getConversation(conversationId: actionModel.conversationId ?? '');
      if (conversation != null) {
        conversation.lastMessageDetails?.copyWith(
          sentByMe: false,
          showInConversation: true,
          sentAt: actionModel.sentAt,
          senderName: actionModel.userDetails?.userName ?? '',
          messageType: 0,
          messageId: '',
          conversationId: actionModel.conversationId ?? '',
          body: '',
          customType:
              IsmChatCustomMessageType.fromString(actionModel.action.name),
          senderId: actionModel.userDetails?.userId ?? '',
          userId: actionModel.members?.first.memberId,
          members:
              actionModel.members?.map((e) => e.memberName.toString()).toList(),
          reactionType: '',
        );
        conversation = conversation.copyWith(unreadMessagesCount: 0);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
        await conversationController.getConversationsFromDB();
      }
    }
  }

  /// Handles a member join and leave event.
  ///
  /// * `actionModel`: The member join and leave event model to handle
  void _handleMemberJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    if (messageId == actionModel.sentAt.toString()) return;
    messageId = actionModel.sentAt.toString();
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (controller.conversation?.conversationId ==
              actionModel.conversationId &&
          controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
        await controller.getMessagesFromAPI(
          lastMessageTimestamp: controller.messages.last.sentAt,
        );
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

// Handles an admin remove and add event.
  ///
  /// * `actionModel`: The admin remove and add event model to handle
  void _handleAdminRemoveAndAdd(IsmChatMqttActionModel actionModel) async {
    if (messageId == actionModel.sentAt.toString()) return;
    messageId = actionModel.sentAt.toString();
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (controller.conversation?.conversationId ==
              actionModel.conversationId &&
          actionModel.memberId ==
              IsmChatConfig.communicationConfig.userConfig.userId &&
          controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
        await controller.getMessagesFromAPI(
          lastMessageTimestamp: controller.messages.last.sentAt,
        );
      }
    }
    if (actionModel.memberId ==
            IsmChatConfig.communicationConfig.userConfig.userId &&
        Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  Future<void> _handleCreateConversation(
      IsmChatMqttActionModel actionModel) async {
    if ((actionModel.isGroup ?? false) &&
        actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    } else if (actionModel.userDetails?.userId ==
        _controller.userConfig?.userId) {
      return;
    }

    showPushNotification(
      title: actionModel.userDetails?.userName ?? '',
      body: 'Conversation Created',
      conversationId: actionModel.conversationId ?? '',
    );
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  // Handles an add and remove reaction event.
  ///
  /// * `actionModel`: The add and remove reaction event model to handle
  void _handleAddAndRemoveReaction(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    var allMessages = await IsmChatConfig.dbWrapper
        ?.getMessage(actionModel.conversationId ?? '');

    if (allMessages != null) {
      var message = allMessages.entries
          .where((e) => e.value.messageId == actionModel.messageId)
          .first;
      var isEmoji = false;

      if (actionModel.action == IsmChatActionEvents.reactionAdd) {
        for (var x in message.value.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType) {
            x.userIds.add(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
            break;
          }
        }
        if (isEmoji == false) {
          message.value.reactions ??= [];
          message.value.reactions?.add(
            MessageReactionModel(
              emojiKey: actionModel.reactionType ?? '',
              userIds: [actionModel.userDetails?.userId ?? ''],
            ),
          );
        }
      } else {
        for (var x in message.value.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType && x.userIds.length > 1) {
            x.userIds.remove(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
          }
        }

        if (isEmoji == false) {
          message.value.reactions ??= [];
          message.value.reactions
              ?.removeWhere((e) => e.emojiKey == actionModel.reactionType);
        }
      }
      allMessages[message.key] = message.value;
      var conversation = await IsmChatConfig.dbWrapper!
          .getConversation(conversationId: actionModel.conversationId);
      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);

        await IsmChatConfig.dbWrapper!
            .saveConversation(conversation: conversation);
        if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
          var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
          if (controller.conversation?.conversationId ==
              actionModel.conversationId) {
            await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                .getMessagesFromDB(actionModel.conversationId ?? '');
          }
        }
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  /// Handles unread messages for a specific user.
  ///
  /// * `userId`: The user ID to check for unread messages.
  void _handleUnreadMessages(String userId) async {
    if (userId == _controller.userConfig?.userId) {
      return;
    }
    await _controller.getChatConversationsUnreadCount();
  }

  /// Handles deletion of chat from local storage.
  ///
  /// * `actionModel`: The action model containing details for deletion.
  void _handleDeletChatFromLocal(IsmChatMqttActionModel actionModel) async {
    if (IsmChatProperties.chatPageProperties.isAllowedDeleteChatFromLocal) {
      final deleteChat = await _controller.deleteChatFormDB('',
          conversationId: actionModel.conversationId ?? '');

      if (deleteChat && Get.isRegistered<IsmChatConversationsController>()) {
        await Get.find<IsmChatConversationsController>().getChatConversations();
      }
    }
  }

  /// Handles updates to conversation details.
  ///
  /// * `actionModel`: The action model containing updated conversation details.
  void _handleConversationUpdate(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getConverstaionDetails();
        if (controller.messages.isNotEmpty) {
          await controller.getMessagesFromAPI(
            lastMessageTimestamp: controller.messages.last.sentAt,
          );
        } else {
          await controller.getMessagesFromAPI();
        }
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }
}
