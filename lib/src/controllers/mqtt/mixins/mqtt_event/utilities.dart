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

