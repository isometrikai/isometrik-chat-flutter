import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

mixin IsmChatMqttEventMixin {
  IsmChatMqttController get _controller => Get.find<IsmChatMqttController>();

  String messageId = '';

  var eventStreamController = StreamController<EventModel>.broadcast();

  var eventListeners = <Function(EventModel)>[];

  final RxList<IsmChatTypingModel> _typingUsers = <IsmChatTypingModel>[].obs;
  List<IsmChatTypingModel> get typingUsers => _typingUsers;
  set typingUsers(List<IsmChatTypingModel> value) => _typingUsers.value = value;

  final RxBool _isAppBackground = false.obs;
  bool get isAppInBackground => _isAppBackground.value;
  set isAppInBackground(bool value) => _isAppBackground.value = value;

  Future<void> onMqttEvent({required EventModel event}) async {
    _controller.eventStreamController.add(event);
    final payload = event.payload;
    if (payload['action'] != null) {
      var action = payload['action'];
      if (IsmChatActionEvents.values
          .map((e) => e.toString())
          .contains(action)) {
        var actionModel = IsmChatMqttActionModel.fromMap(payload);
        await _handleAction(actionModel);
      }
    } else {
      var message = IsmChatMessageModel.fromMap(payload);
      _handleLocalNotification(message);
      await _handleMessage(message);
    }
  }

  Future<void> _handleAction(IsmChatMqttActionModel actionModel) async {
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
      case IsmChatActionEvents.removeMember:
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
        break;
      case IsmChatActionEvents.meetingCreated:
      case IsmChatActionEvents.meetingEndedByHost:
      case IsmChatActionEvents.meetingEndedDueToRejectionByAll:
        _handleOneToOneCall(actionModel);
        break;
    }
  }

  void _handleObserverJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    if (actionModel.senderId == _controller.userConfig?.userId) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId);
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
      );
      conversation.messages?.add(message);
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
      if (Get.isRegistered<IsmChatPageController>()) {
        var chatController = Get.find<IsmChatPageController>();
        if (chatController.conversation?.conversationId ==
            message.conversationId) {
          await chatController.getMessagesFromDB(actionModel.conversationId!);
        }
      }
      if (Get.isRegistered<IsmChatConversationsController>()) {
        unawaited(Get.find<IsmChatConversationsController>()
            .getConversationsFromDB());
      }
    }
  }

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
              (Get.isRegistered<IsmChatPageController>() &&
                  Get.find<IsmChatPageController>()
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
        ));
    conversation.messages?.add(message);
    await IsmChatConfig.dbWrapper!.saveConversation(conversation: conversation);
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
    if (!Get.isRegistered<IsmChatPageController>()) {
      return;
    }
    var chatController = Get.find<IsmChatPageController>();
    if (chatController.conversation?.conversationId != message.conversationId) {
      return;
    }

    unawaited(chatController.getMessagesFromDB(message.conversationId!));
    await Future.delayed(const Duration(milliseconds: 30));
    await chatController.readSingleMessage(
      conversationId: message.conversationId!,
      messageId: message.messageId!,
    );
  }

  Future<void> _handleMessage(IsmChatMessageModel message) async {
    _handleUnreadMessages(message.senderInfo?.userId ?? '');
    await Future.delayed(const Duration(milliseconds: 100));
    if (message.senderInfo?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    var conversationController = Get.find<IsmChatConversationsController>();
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: message.conversationId);
    await Future.delayed(const Duration(milliseconds: 50));
    if (conversation == null && Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();

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
              (Get.isRegistered<IsmChatPageController>() &&
                  Get.find<IsmChatPageController>()
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
        messageId: message.messageId!,
        conversationId: message.conversationId!,
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
    if (Get.isRegistered<IsmChatPageController>()) {
      var chatController = Get.find<IsmChatPageController>();
      if (chatController.conversation?.conversationId ==
          message.conversationId) {
        conversation.messages?.add(message);
      }
    }

    await IsmChatConfig.dbWrapper!.saveConversation(conversation: conversation);
    unawaited(conversationController.getConversationsFromDB());
    await conversationController.pingMessageDelivered(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );

    if (!Get.isRegistered<IsmChatPageController>()) return;
    var chatController = Get.find<IsmChatPageController>();
    if (chatController.conversation?.conversationId != message.conversationId) {
      return;
    }
    unawaited(chatController.getMessagesFromDB(message.conversationId ?? ''));
    await Future.delayed(const Duration(milliseconds: 30));
    if (_controller.isAppInBackground == false) {
      await chatController.readSingleMessage(
        conversationId: message.conversationId ?? '',
        messageId: message.messageId ?? '',
      );
    }
  }

  void _handleLocalNotification(IsmChatMessageModel message) {
    if (message.senderInfo?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (messageId == message.messageId) {
      return;
    }

    String? mqttMessage;
    // String mqttMessageTitle = message.s;

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
        messageId = message.messageId ?? '';
        return;
      }
      if (Get.isRegistered<IsmChatPageController>()) {
        var chatController = Get.find<IsmChatPageController>();
        if (chatController.conversation?.conversationId !=
            message.conversationId) {
          showPushNotification(
              title: notificationTitle.isNotEmpty
                  ? notificationTitle
                  : message.notificationTitle ?? '',
              body: mqttMessage ?? '',
              conversationId: message.conversationId ?? '');
          messageId = message.messageId ?? '';
        }
      } else {
        showPushNotification(
            title: notificationTitle.isNotEmpty
                ? notificationTitle
                : message.notificationTitle ?? '',
            body: mqttMessage ?? '',
            conversationId: message.conversationId ?? '');

        messageId = message.messageId!;
      }
    } else {
      if (Get.isRegistered<IsmChatConversationsController>()) {
        if (Get.isRegistered<IsmChatPageController>()) {
          var chatController = Get.find<IsmChatPageController>();
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
          description: Text(mqttMessage ?? ''),
          progressIndicatorColor:
              IsmChatConfig.chatTheme.primaryColor ?? Colors.blue,
        ).show(IsmChatConfig.context ??
            Get.find<IsmChatConversationsController>().context!);
      }
    }
  }

  void showPushNotification({
    required String title,
    required String body,
    required String conversationId,
  }) {
    LocalNoticeService().cancelAllNotification();
    LocalNoticeService().addNotification(
      title, // Add the  sender user name here
      body, // MessageName
      DateTime.now().millisecondsSinceEpoch + 1 * 1000,
      sound: '',
      channel: 'message',
      payload: {
        'conversationId': conversationId,
      },
    );
    if (GetPlatform.isAndroid) {
      if (IsmChatConfig.showNotification != null) {
        IsmChatConfig.showNotification?.call(
          title,
          body,
          conversationId,
        );
      } else {
        LocalNoticeService().showFlutterNotification(
          title,
          body,
          conversataionId: conversationId,
        );
      }
    }
  }

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

  void _handleMessageDelivered(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails!.userId == _controller.userConfig?.userId) {
      return;
    }

    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId);

    if (conversation != null) {
      var message =
          conversation.messages?.cast<IsmChatMessageModel?>().firstWhere(
                (e) => e?.messageId == actionModel.messageId,
                orElse: () => null,
              );

      if (message != null) {
        var isDelivered = message.deliveredTo
            ?.any((e) => e.userId == actionModel.userDetails?.userId);

        if (isDelivered == false) {
          message.deliveredTo?.add(
            MessageStatus(
              userId: actionModel.userDetails?.userId ?? '',
              timestamp: actionModel.sentAt,
            ),
          );
        }
        message.deliveredToAll =
            message.deliveredTo?.length == (conversation.membersCount ?? 0) - 1;
        final messageIndex = conversation.messages
            ?.indexWhere((e) => e.messageId == actionModel.messageId);
        if (messageIndex != -1) {
          conversation.messages?[
              messageIndex ?? conversation.messages?.length ?? 0] = message;
          conversation = conversation.copyWith(
            lastMessageDetails: conversation.lastMessageDetails?.copyWith(
              deliverCount: message.deliveredTo?.length,
              deliveredTo: message.deliveredTo,
            ),
          );

          await IsmChatConfig.dbWrapper!
              .saveConversation(conversation: conversation);
          if (Get.isRegistered<IsmChatPageController>()) {
            await Get.find<IsmChatPageController>()
                .getMessagesFromDB(actionModel.conversationId!);
          }
          if (Get.isRegistered<IsmChatConversationsController>()) {
            unawaited(Get.find<IsmChatConversationsController>()
                .getConversationsFromDB());
          }
        }
      }
    }
  }

  void _handleMessageRead(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId!);

    if (conversation != null) {
      var message =
          conversation.messages?.cast<IsmChatMessageModel?>().firstWhere(
                (e) => e?.messageId == actionModel.messageId,
                orElse: () => null,
              );
      if (message != null) {
        var isDelivered = message.readBy
            ?.any((e) => e.userId == actionModel.userDetails?.userId);
        if (isDelivered == false) {
          message.readBy?.add(
            MessageStatus(
              userId: actionModel.userDetails?.userId ?? '',
              timestamp: actionModel.sentAt,
            ),
          );
        }
        message.readByAll =
            message.readBy?.length == (conversation.membersCount ?? 0) - 1;
        final messageIndex = conversation.messages
            ?.indexWhere((e) => e.messageId == actionModel.messageId);
        if (messageIndex != -1) {
          conversation.messages?[
              messageIndex ?? conversation.messages?.length ?? 0] = message;
          conversation = conversation.copyWith(
            lastMessageDetails: conversation.lastMessageDetails?.copyWith(
              readCount: message.readBy?.length,
              readBy: message.readBy,
            ),
          );
          await IsmChatConfig.dbWrapper!
              .saveConversation(conversation: conversation);
          if (Get.isRegistered<IsmChatPageController>()) {
            await Get.find<IsmChatPageController>()
                .getMessagesFromDB(actionModel.conversationId!);
          }
          if (Get.isRegistered<IsmChatConversationsController>()) {
            unawaited(Get.find<IsmChatConversationsController>()
                .getConversationsFromDB());
          }
        }
      }
    }
  }

  void _handleMultipleMessageRead(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (IsmChatConfig.dbWrapper == null) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId!);

    if (conversation == null) {
      return;
    }
    var allMessages = conversation.messages;
    var modifiedMessages = <IsmChatMessageModel>[];
    for (var message in allMessages ?? <IsmChatMessageModel>[]) {
      if (message.deliveredToAll == true && message.readByAll == true) {
        modifiedMessages.add(message);
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

        modifiedMessages.add(modified);
      }
    }
    conversation = conversation.copyWith(
      messages: modifiedMessages,
      lastMessageDetails: conversation.lastMessageDetails?.copyWith(
        deliverCount: modifiedMessages.isEmpty
            ? 1
            : modifiedMessages.last.deliveredTo?.length ?? 0,
        readCount: modifiedMessages.isEmpty
            ? 1
            : modifiedMessages.last.readBy?.length ?? 0,
        readBy: modifiedMessages.isEmpty ? [] : modifiedMessages.last.readBy,
        deliveredTo:
            modifiedMessages.isEmpty ? [] : modifiedMessages.last.deliveredTo,
      ),
    );

    await IsmChatConfig.dbWrapper!.saveConversation(conversation: conversation);
    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation!.conversationId ==
          actionModel.conversationId) {
        await controller.getMessagesFromDB(actionModel.conversationId!);
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getConversationsFromDB();
    }
  }

  void _handleMessageDelelteForEveryOne(
      IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    var allMessages =
        await IsmChatConfig.dbWrapper!.getMessage(actionModel.conversationId!);
    if (allMessages == null) {
      return;
    }
    if (actionModel.messageIds?.isNotEmpty == true) {
      for (var x in actionModel.messageIds!) {
        var messageIndex = allMessages.indexWhere((e) => e.messageId == x);
        if (messageIndex != -1) {
          allMessages[messageIndex].customType =
              IsmChatCustomMessageType.deletedForEveryone;
        }
      }
    }

    var conversation = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: actionModel.conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: allMessages);
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: conversation);
    }

    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation!.conversationId ==
          actionModel.conversationId) {
        await controller.getMessagesFromDB(actionModel.conversationId!);
      }
    }
  }

  void _handleBlockUserOrUnBlock(IsmChatMqttActionModel actionModel) async {
    if (actionModel.initiatorDetails!.userId ==
        _controller.userConfig?.userId) {
      return;
    }

    if (messageId == actionModel.sentAt.toString()) {
      return;
    }

    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation!.conversationId ==
          actionModel.conversationId) {
        await controller.getConverstaionDetails(
            conversationId: actionModel.conversationId ?? '');
        await controller.getMessagesFromAPI(
            conversationId: actionModel.conversationId ?? '',
            lastMessageTimestamp: controller.messages.last.sentAt);
        messageId = actionModel.sentAt.toString();
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      var conversationController = Get.find<IsmChatConversationsController>();
      await conversationController.getBlockUser();
      await conversationController.getChatConversations();
    }
  }

  void _handleOneToOneCall(IsmChatMqttActionModel actionModel) async {
    if (actionModel.initiatorId == _controller.userConfig?.userId) {
      return;
    }
    if (messageId == actionModel.sentAt.toString()) {
      return;
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    unawaited(
        Get.find<IsmChatConversationsController>().getChatConversations());
    if (!Get.isRegistered<IsmChatPageController>()) return;
    var controller = Get.find<IsmChatPageController>();
    if (controller.conversation?.conversationId == actionModel.conversationId) {
      await controller.getMessagesFromAPI(
          conversationId: actionModel.conversationId ?? '',
          lastMessageTimestamp: controller.messages.last.sentAt);
      messageId = actionModel.sentAt.toString();
    }
  }

  void _handleGroupRemoveAndAddUser(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (messageId == actionModel.sentAt.toString()) {
      return;
    }

    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    var conversationController = Get.find<IsmChatConversationsController>();
    if (actionModel.action == IsmChatActionEvents.addMember) {
      await conversationController.getChatConversations();
    }
    var allMessages =
        await IsmChatConfig.dbWrapper?.getMessage(actionModel.conversationId!);
    allMessages?.add(
      IsmChatMessageModel(
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
      ),
    );

    messageId = actionModel.sentAt.toString();
    if (Get.isRegistered<IsmChatPageController>()) {
      var chatPageController = Get.find<IsmChatPageController>();
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
    if (actionModel.action == IsmChatActionEvents.removeMember) {
      var conversation = await IsmChatConfig.dbWrapper
          ?.getConversation(conversationId: actionModel.conversationId ?? '');
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

  void _handleMemberJoinAndLeave(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }
    if (messageId == actionModel.sentAt.toString()) {
      return;
    }
    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation?.conversationId ==
              actionModel.conversationId &&
          controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
        await controller.getMessagesFromAPI(
            conversationId: actionModel.conversationId ?? '',
            lastMessageTimestamp: controller.messages.last.sentAt);
        messageId = actionModel.sentAt.toString();
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  void _handleAdminRemoveAndAdd(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (messageId == actionModel.sentAt.toString()) {
      return;
    }

    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation?.conversationId ==
              actionModel.conversationId &&
          actionModel.memberId ==
              IsmChatConfig.communicationConfig.userConfig.userId &&
          controller.conversation?.lastMessageSentAt != actionModel.sentAt) {
        await controller.getMessagesFromAPI(
            conversationId: actionModel.conversationId ?? '',
            lastMessageTimestamp: controller.messages.last.sentAt);
        messageId = actionModel.sentAt.toString();
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
    if (actionModel.opponentDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (!Get.isRegistered<IsmChatConversationsController>()) return;
    var ismChatConversationController =
        Get.find<IsmChatConversationsController>();
    await ismChatConversationController.getChatConversations();
  }

  void _handleAddAndRemoveReaction(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    var allMessages =
        await IsmChatConfig.dbWrapper!.getMessage(actionModel.conversationId!);
    if (!allMessages.isNullOrEmpty) {
      var message =
          allMessages?.where((e) => e.messageId == actionModel.messageId).first;
      var isEmoji = false;

      if (actionModel.action == IsmChatActionEvents.reactionAdd) {
        for (var x in message?.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType) {
            x.userIds.add(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
            break;
          }
        }
        if (isEmoji == false) {
          message?.reactions ??= [];
          message?.reactions?.add(
            MessageReactionModel(
              emojiKey: actionModel.reactionType ?? '',
              userIds: [actionModel.userDetails?.userId ?? ''],
            ),
          );
        }
      } else {
        for (var x in message?.reactions ?? <MessageReactionModel>[]) {
          if (x.emojiKey == actionModel.reactionType && x.userIds.length > 1) {
            x.userIds.remove(actionModel.userDetails?.userId ?? '');
            x.userIds.toSet().toList();
            isEmoji = true;
          }
        }

        if (isEmoji == false) {
          message?.reactions ??= [];
          message?.reactions
              ?.removeWhere((e) => e.emojiKey == actionModel.reactionType);
        }
      }

      var messageIndex =
          allMessages?.indexWhere((e) => e.messageId == actionModel.messageId);
      allMessages![messageIndex ?? 0] = message!;
      var conversation = await IsmChatConfig.dbWrapper!
          .getConversation(conversationId: actionModel.conversationId);
      if (conversation != null) {
        conversation = conversation.copyWith(messages: allMessages);

        await IsmChatConfig.dbWrapper!
            .saveConversation(conversation: conversation);
        if (Get.isRegistered<IsmChatPageController>()) {
          var controller = Get.find<IsmChatPageController>();
          if (controller.conversation?.conversationId ==
              actionModel.conversationId) {
            await Get.find<IsmChatPageController>()
                .getMessagesFromDB(actionModel.conversationId ?? '');
          }
        }
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  void _handleUnreadMessages(String userId) async {
    if (userId == _controller.userConfig?.userId) {
      return;
    }
    await _controller.getChatConversationsUnreadCount();
  }

  void _handleDeletChatFromLocal(IsmChatMqttActionModel actionModel) async {
    if (IsmChatProperties.chatPageProperties.isAllowedDeleteChatFromLocal) {
      final deleteChat = await deleteChatFormDB('',
          conversationId: actionModel.conversationId ?? '');

      if (deleteChat && Get.isRegistered<IsmChatConversationsController>()) {
        await Get.find<IsmChatConversationsController>().getChatConversations();
      }
    }
  }

  void _handleConversationUpdate(IsmChatMqttActionModel actionModel) async {
    if (actionModel.userDetails?.userId == _controller.userConfig?.userId) {
      return;
    }

    if (Get.isRegistered<IsmChatPageController>()) {
      var controller = Get.find<IsmChatPageController>();
      if (controller.conversation?.conversationId ==
          actionModel.conversationId) {
        await controller.getConverstaionDetails(
          conversationId: actionModel.conversationId ?? '',
          includeMembers:
              controller.conversation?.isGroup == true ? true : false,
        );
        if (controller.messages.isNotEmpty) {
          await controller.getMessagesFromAPI(
            conversationId: actionModel.conversationId ?? '',
            lastMessageTimestamp: controller.messages.last.sentAt,
          );
        } else {
          await controller.getMessagesFromAPI(
            conversationId: actionModel.conversationId ?? '',
          );
        }
      }
    }
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  Future<String> getChatConversationsCount({
    bool isLoading = false,
  }) async =>
      await _controller.viewModel.getChatConversationsCount(
        isLoading: isLoading,
      );

  Future<String> getChatConversationsMessageCount({
    bool isLoading = false,
    required String converationId,
    required List<String> senderIds,
    bool senderIdsExclusive = false,
    int lastMessageTimestamp = 0,
  }) async =>
      await _controller.viewModel.getChatConversationsMessageCount(
        conversationId: converationId,
        senderIds: senderIds,
        isLoading: isLoading,
        lastMessageTimestamp: lastMessageTimestamp,
        senderIdsExclusive: senderIdsExclusive,
      );

  Future<bool> deleteChatFormDB(String isometrickChatId,
      {String conversationId = ''}) async {
    if (conversationId.isEmpty) {
      final conversations = await getAllConversationFromDB();
      if (conversations != null || conversations?.isNotEmpty == true) {
        var conversation = conversations?.firstWhere(
            (element) => element.opponentDetails?.userId == isometrickChatId,
            orElse: IsmChatConversationModel.new);

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

  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async =>
      await IsmChatConfig.dbWrapper?.getAllConversations();
}
