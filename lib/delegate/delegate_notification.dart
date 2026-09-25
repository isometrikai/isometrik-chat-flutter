part of '../isometrik_chat_flutter.dart';

/// Notification handling mixin for IsmChatDelegate.
///
/// This mixin contains methods related to handling push notifications
/// and navigating to conversations from notification taps.
mixin IsmChatDelegateNotificationMixin {
  /// Handles notification tap/payload and navigates to the chat conversation.
  ///
  /// This method should be called when a push notification is tapped.
  /// It extracts the conversationId from the notification data and navigates to that conversation.
  ///
  /// Parameters:
  /// - `notificationData`: The notification payload data (Map<String, dynamic>)
  ///   Expected to contain 'conversationId' key
  ///
  /// Example:
  /// ```dart
  /// // In your notification tap handler
  /// FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  ///   IsmChat.i.handleNotificationPayload(message.data);
  /// });
  /// ```
  Future<void> handleNotificationPayload(
    dynamic notificationData,
  ) async {
    try {
      Map<String, dynamic> payload;

      // Handle both Map and JSON string payloads
      if (notificationData is Map<String, dynamic>) {
        payload = notificationData;
      } else if (notificationData is String) {
        try {
          payload = json.decode(notificationData) as Map<String, dynamic>;
        } catch (e) {
          IsmChatLog.error(
              'handleNotificationPayload: Could not parse JSON string: $e');
          return;
        }
      } else {
        IsmChatLog.error(
            'handleNotificationPayload: Invalid payload type: ${notificationData.runtimeType}');
        return;
      }

      // Extract conversationId from notification data
      // Try direct key first, then try parsing as message object
      var conversationId = payload['conversationId'] as String?;

      // If not found directly, try to parse as message and extract conversationId
      if ((conversationId == null || conversationId.isEmpty) &&
          payload.isNotEmpty) {
        try {
          final message = IsmChatMessageModel.fromMap(payload);
          conversationId = message.conversationId;
          IsmChatLog.info(
              'handleNotificationPayload: Extracted conversationId from message: $conversationId');
        } catch (e) {
          IsmChatLog.error(
              'handleNotificationPayload: Could not parse message from payload: $e');
        }
      }

      // If still not found, log error and return
      if (conversationId == null || conversationId.isEmpty) {
        IsmChatLog.error(
            'handleNotificationPayload: conversationId not found in notification data. Available keys: ${payload.keys.toList()}');
        // Try to create conversation from sender info if available
        if (payload.containsKey('senderInfo')) {
          try {
            final message = IsmChatMessageModel.fromMap(payload);
            final senderInfo = message.senderInfo;
            if (senderInfo != null && senderInfo.userId.isNotEmpty) {
              IsmChatLog.info(
                  'handleNotificationPayload: Creating conversation from sender info');
              await (this as IsmChatDelegate).chatFromOutside(
                name: senderInfo.userName,
                userIdentifier: senderInfo.userIdentifier,
                userId: senderInfo.userId,
                online: senderInfo.online ?? false,
                profileImageUrl: senderInfo.userProfileImageUrl,
              );
              return;
            }
          } catch (e) {
            IsmChatLog.error(
                'handleNotificationPayload: Error creating conversation from sender info: $e');
          }
        }
        return;
      }

      // Controller + Hive must exist before we open the chat (cold start from
      // a killed app runs this in parallel with [IsmChat.i.initialize]).
      await _ensureConversationStackForNotification();
      if (!IsmChatUtility.conversationControllerRegistered) {
        IsmChatLog.error(
            'handleNotificationPayload: conversation controller not registered');
        return;
      }

      final conversationController = IsmChatUtility.conversationController;

      // Prefer Hive for the message map; the in-memory list item is usually a
      // stub (lastMessageDetails only). Merge so list metadata is kept.
      final memoryConversation =
          conversationController.getConversation(conversationId);
      final dbConversation =
          await IsmChatConfig.dbWrapper?.getConversation(conversationId);
      var conversation = memoryConversation?.withCachedMessagesFrom(
            dbConversation,
          ) ??
          dbConversation;

      // If still not found, try to create from message data if available
      if (conversation == null && payload.containsKey('senderInfo')) {
        try {
          final message = IsmChatMessageModel.fromMap(payload);
          final senderInfo = message.senderInfo;
          if (senderInfo != null && senderInfo.userId.isNotEmpty) {
            await (this as IsmChatDelegate).chatFromOutside(
              name: senderInfo.userName,
              userIdentifier: senderInfo.userIdentifier,
              userId: senderInfo.userId,
              online: senderInfo.online ?? false,
              profileImageUrl: senderInfo.userProfileImageUrl,
            );
            return;
          }
        } catch (e) {
          IsmChatLog.error('Error creating conversation from message: $e');
        }
      }

      // If conversation found, navigate to it.
      // [updateLocalConversation] also sets currentConversation (after merging
      // Hive messages); do not reassign the pre-merge stub afterwards.
      if (conversation != null) {
        await conversationController.updateLocalConversation(conversation);
        final opened =
            conversationController.currentConversation ?? conversation;

        // Call onChatTap callback if available
        IsmChatProperties.conversationProperties.onChatTap?.call(
          IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
          opened,
        );

        // Navigate to chat page
        await conversationController.goToChatPage();
      } else {
        IsmChatLog.error(
            'handleNotificationPayload: Could not find or create conversation for id: $conversationId');
      }
    } catch (e, stackTrace) {
      IsmChatLog.error(
          'handleNotificationPayload error: $e\nStackTrace: $stackTrace');
    }
  }

  /// Waits until the conversation controller and Hive wrapper exist.
  ///
  /// Bounded so a hung SDK init cannot block notification navigation forever.
  Future<void> _ensureConversationStackForNotification() async {
    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    var attempts = 0;
    while (!IsmChatUtility.conversationControllerRegistered &&
        attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    attempts = 0;
    while (IsmChatConfig.dbWrapper == null && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }
}
