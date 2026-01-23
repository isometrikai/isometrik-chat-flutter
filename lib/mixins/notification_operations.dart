part of '../isometrik_chat_flutter.dart';

/// Notification operations mixin for IsmChat.
///
/// This mixin contains methods related to push notification handling.
mixin IsmChatNotificationOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Handles notification tap/payload and navigates to the chat conversation.
  ///
  /// This method should be called when a push notification is tapped.
  /// It extracts the conversationId from the notification data and navigates to that conversation.
  ///
  /// Parameters:
  /// - `notificationData`: The notification payload data (Map<String, dynamic> or JSON string)
  ///   Expected to contain 'conversationId' key, or will try to extract from message object
  ///
  /// Example:
  /// ```dart
  /// // In your notification tap handler
  /// FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  ///   IsmChat.i.handleNotificationPayload(message.data);
  /// });
  ///
  /// // Or for local notifications (payload is JSON string)
  /// LocalNoticeService.onNotificationTap.listen((payload) {
  ///   IsmChat.i.handleNotificationPayload(payload);
  /// });
  /// ```
  Future<void> handleNotificationPayload(
    dynamic notificationData,
  ) async =>
      await _delegate.handleNotificationPayload(notificationData);
}

