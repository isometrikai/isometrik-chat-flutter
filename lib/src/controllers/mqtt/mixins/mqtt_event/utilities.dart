import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Utilities mixin for IsmChatMqttEventMixin.
///
/// This mixin contains utility methods used across the MQTT event handling system.
mixin IsmChatMqttEventUtilitiesMixin {
  /// Checks if the sender is the current user.
  ///
  /// * `senderId`: The sender's user ID
  /// * `deviceId`: Optional device ID for multi-device support
  bool isSenderMe(String? senderId, {String? deviceId}) {
    final controller = Get.find<IsmChatMqttController>();
    if (deviceId == null) {
      return senderId == controller.userConfig?.userId;
    }
    final isMyMessage = controller.userConfig?.userId == senderId &&
        deviceId == controller.projectConfig?.deviceId;
    return isMyMessage;
  }

  /// Shows a push notification.
  ///
  /// * `title`: The title of the notification.
  /// * `body`: The body of the notification.
  /// * `data`: The notification data payload.
  void showPushNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    if (IsmChatConfig.showNotification == null) return;
    IsmChatConfig.showNotification?.call(
      title,
      body,
      data,
    );
  }

  /// Handles unread messages for a specific user.
  ///
  /// * `userId`: The user ID to check for unread messages.
  void handleUnreadMessages(String userId) async {
    if (isSenderMe(userId)) return;
    final controller = Get.find<IsmChatMqttController>();
    await controller.getChatConversationsUnreadCount();
  }
}

String resolveMessageNotificationTitle(IsmChatMessageModel message) {
  // Prefer conversation title when present — MQTT may omit isGroup but still
  // send conversationTitle (e.g. group chats).
  final conversationTitle = _resolveGroupNotificationTitle(
    conversationId: message.conversationId,
    conversationTitle: message.conversationTitle,
    conversationDetails: message.conversationDetails,
  );
  if (conversationTitle.isNotEmpty) return conversationTitle;

  final senderDisplayName = message.senderInfo?.displayName.trim() ?? '';
  if (senderDisplayName.isNotEmpty &&
      senderDisplayName != (message.senderInfo?.userName ?? '').trim()) {
    return senderDisplayName;
  }

  final cachedConversation = message.conversationId != null &&
          message.conversationId!.isNotEmpty &&
          IsmChatUtility.conversationControllerRegistered
      ? IsmChatUtility.conversationController
          .getConversation(message.conversationId ?? '')
      : null;
  final cachedOpponentName =
      cachedConversation?.opponentDetails?.displayName.trim() ?? '';
  if (cachedOpponentName.isNotEmpty) return cachedOpponentName;

  final notificationTitle = message.notificationTitle?.trim();
  if (notificationTitle != null && notificationTitle.isNotEmpty) {
    return notificationTitle;
  }
  final fallback = message.senderInfo?.userName ?? '';
  return fallback;
}

String resolveCreateConversationNotificationTitle(
    IsmChatMqttActionModel actionModel) {
  final conversationTitle = _resolveGroupNotificationTitle(
    conversationId: actionModel.conversationId,
    conversationTitle: actionModel.conversationDetails?.conversationTitle,
  );
  if (conversationTitle.isNotEmpty) return conversationTitle;
  return actionModel.userDetails?.userName ?? '';
}

String _resolveGroupNotificationTitle({
  String? conversationId,
  String? conversationTitle,
  Map<String, dynamic>? conversationDetails,
}) {
  final fromMessage = conversationTitle?.trim();
  if (fromMessage != null && fromMessage.isNotEmpty) {
    return fromMessage;
  }
  final fromDetails =
      conversationDetails?['conversationTitle'] as String?;
  final detailsTitle = fromDetails?.trim();
  if (detailsTitle != null && detailsTitle.isNotEmpty) {
    return detailsTitle;
  }
  if (IsmChatUtility.conversationControllerRegistered) {
    final conversation = IsmChatUtility.conversationController
        .getConversation(conversationId ?? '');
    final fromCache = conversation?.conversationTitle?.trim();
    if (fromCache != null && fromCache.isNotEmpty) {
      return fromCache;
    }
  }
  return '';
}
