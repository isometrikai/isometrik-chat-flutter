import 'dart:async';

import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Message handlers mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling incoming messages and local notifications.
mixin IsmChatMqttEventMessageHandlersMixin {
  /// Handles a message.
  ///
  /// * `message`: The message to handle
  // ignore: unused_element
  // This method is called from event_processing.dart via mixin composition
  Future<void> handleMessage(IsmChatMessageModel message) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(message.senderInfo?.userId,
          deviceId: message.deviceId)) {
        return;
      }
      utils.handleUnreadMessages(message.senderInfo?.userId ?? '');
    }
    if (!IsmChatUtility.conversationControllerRegistered) {
      return;
    }
    var conversation = await IsmChatConfig.dbWrapper
        ?.getConversation(message.conversationId ?? '');
    if (conversation != null && IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (message.conversationId == controller.conversation?.conversationId) {
        if (controller.messages.isEmpty) {
          controller.messages =
              controller.commonController.sortMessages([message]);
        } else {
          controller.messages.add(message);
        }
      }
    }
    if (conversation == null) return;
    if (conversation.lastMessageDetails?.messageId == message.messageId) return;

    // To handle and show last message & unread count in conversation list
    conversation = conversation.copyWith(
      unreadMessagesCount: IsmChatResponsive.isWeb(
                  IsmChatConfig.kNavigatorKey.currentContext ??
                      IsmChatConfig.context) &&
              (IsmChatUtility.chatPageControllerRegistered &&
                  IsmChatUtility
                          .chatPageController.conversation?.conversationId ==
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

    if (message.conversationId == conversation.conversationId) {
      if (conversation.messages?.isNotEmpty == true) {
        conversation.messages?.addEntries({message.key: message}.entries);
      }
    }
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: conversation);
    unawaited(IsmChatUtility.conversationController.getConversationsFromDB());
    final controller = Get.find<IsmChatMqttController>();
    await controller.pingMessageDelivered(
      conversationId: message.conversationId ?? '',
      messageId: message.messageId ?? '',
    );
    if (!IsmChatUtility.chatPageControllerRegistered) {
      return;
    }
    var chatController = IsmChatUtility.chatPageController;
    if (chatController.conversation?.conversationId != message.conversationId) {
      return;
    }
    unawaited(chatController.getMessagesFromDB(message.conversationId ?? ''));
    await Future.delayed(const Duration(milliseconds: 50));
    final self2 = this;
    if (self2 is IsmChatMqttEventVariablesMixin) {
      final vars = self2 as IsmChatMqttEventVariablesMixin;
      if (vars.isAppInBackground == false) {
        final controller = Get.find<IsmChatMqttController>();
        await controller.readSingleMessage(
          conversationId: message.conversationId ?? '',
          messageId: message.messageId ?? '',
        );
      }
    }
  }

  /// Handles a local notification.
  ///
  /// * `message`: The message to handle
  void handleLocalNotification(IsmChatMessageModel message) {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      if (utils.isSenderMe(message.senderInfo?.userId,
          deviceId: message.deviceId)) {
        return;
      }
    }
    if (message.events != null &&
        message.events?.sendPushNotification == false) {
      return;
    }
    final notificationTitle =
        '${message.senderInfo?.metaData?.firstName ?? ''} ${message.senderInfo?.metaData?.lastName ?? ''}'
            .trim();
    if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      if (self is IsmChatMqttEventVariablesMixin) {
        final vars = self as IsmChatMqttEventVariablesMixin;
        if (vars.isAppInBackground) {
          final notificationData = message.toMap();
          // Ensure conversationId is always included in notification payload
          // even if it was null and removed by removeNullValues()
          if (!notificationData.containsKey('conversationId') ||
              notificationData['conversationId'] == null) {
            notificationData['conversationId'] = message.conversationId ?? '';
          }
          if (self is IsmChatMqttEventUtilitiesMixin) {
            (self as IsmChatMqttEventUtilitiesMixin).showPushNotification(
                title: notificationTitle.isNotEmpty
                    ? notificationTitle
                    : message.notificationTitle ?? '',
                body: message.notificationBody ?? '',
                data: notificationData);
          }
          return;
        }
      }
    }
    if (IsmChatUtility.chatPageControllerRegistered) {
      if (IsmChatUtility.chatPageController.conversation?.conversationId ==
          message.conversationId) {
        return;
      }
    }
    try {
      final notificationData = message.toMap();
      // Ensure conversationId is always included in notification payload
      // even if it was null and removed by removeNullValues()
      if (!notificationData.containsKey('conversationId') ||
          notificationData['conversationId'] == null) {
        notificationData['conversationId'] = message.conversationId ?? '';
      }
      if (self is IsmChatMqttEventUtilitiesMixin) {
        (self as IsmChatMqttEventUtilitiesMixin).showPushNotification(
            title: notificationTitle.isNotEmpty
                ? notificationTitle
                : message.notificationTitle ?? '',
            body: message.notificationBody ?? '',
            data: notificationData);
      }
    } catch (_) {}
  }
}
