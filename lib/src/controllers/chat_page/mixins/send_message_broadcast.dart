part of '../chat_page_controller.dart';

/// Mixin for handling broadcast message sending in the chat page controller.
///
/// This mixin provides functionality for sending broadcast messages and
/// creating broadcast conversations.
mixin IsmChatPageSendMessageBroadcastMixin {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Sends a broadcast message to multiple conversations.
  ///
  /// [createdAt] - Timestamp when the message was created
  /// [groupcastId] - ID of the broadcast group
  /// [messageType] - Type of the message
  /// [deviceId] - Device ID
  /// [body] - Message body
  /// [notificationBody] - Notification body text
  /// [notificationTitle] - Notification title
  /// [searchableTags] - Optional searchable tags
  /// [parentMessageId] - Optional parent message ID for replies
  /// [metaData] - Optional message metadata
  /// [customType] - Optional custom message type
  /// [attachments] - Optional attachments
  /// [mentionedUsers] - Optional mentioned users
  /// [isLoading] - Whether to show loading indicator
  /// [sendPushNotification] - Whether to send push notification
  /// [encrypted] - Whether the message is encrypted
  Future<void> sendBroadcastMessage({
    required int createdAt,
    required String groupcastId,
    required int messageType,
    required String deviceId,
    required String body,
    required String notificationBody,
    required String notificationTitle,
    List<String>? searchableTags,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    String? customType,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? mentionedUsers,
    bool isLoading = false,
    bool sendPushNotification = true,
    bool encrypted = false,
  }) async {
    metaData = metaData?.copyWith(customType: {'broadcastMessage': true});
    metaData = metaData?.copyWith(isBroadCastMessage: true);
    metaData = metaData?.copyWith(groupCastId: groupcastId);
    final response = await _controller.viewModel.sendBroadcastMessage(
      showInConversation: true,
      notifyOnCompletion: false,
      hideNewConversationsForSender: false,
      sendPushForNewConversationCreated: false,
      groupcastId: groupcastId,
      messageType: messageType,
      encrypted: encrypted,
      deviceId: deviceId,
      body: body,
      notificationBody: notificationBody,
      notificationTitle: notificationTitle,
      attachments: attachments,
      customType: customType,
      events: {
        'updateUnreadCount': true,
        'sendPushNotification': sendPushNotification,
        'sendOneSignalNotification': false,
        'sendEmailNotification': false,
      },
      isLoading: isLoading,
      mentionedUsers: mentionedUsers,
      metaData: metaData,
      parentMessageId: parentMessageId,
      searchableTags: searchableTags,
    );
    if (response?.hasError == false) {
      if (_controller.messages.length == 1) {
        _controller.messages =
            _controller.commonController.sortMessages(_controller.messages);
      }
      for (var x = 0; x < _controller.messages.length; x++) {
        var messages = _controller.messages[x];
        if (messages.messageId?.isNotEmpty == true ||
            messages.sentAt != createdAt) {
          continue;
        }
        messages
          ..messageId = createdAt.toString()
          ..deliveredToAll = false
          ..readByAll = false
          ..isUploading = false;
        _controller.messages[x] = messages;
      }
    }
  }

  /// Creates a broadcast conversation.
  ///
  /// [groupcastTitle] - Title of the broadcast group
  /// [groupcastImageUrl] - Image URL for the broadcast group
  /// [membersId] - List of member IDs
  /// [isLoading] - Whether to show loading indicator
  /// [searchableTags] - Optional searchable tags
  /// [metaData] - Optional metadata
  /// [customType] - Optional custom type
  ///
  /// Returns the conversation ID of the created broadcast.
  Future<String?> createBroadcastConversation({
    bool isLoading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    required String groupcastTitle,
    required String groupcastImageUrl,
    String? customType,
    required List<String> membersId,
  }) async =>
      _controller.viewModel.createBroadcastConversation(
        groupcastTitle: groupcastTitle,
        groupcastImageUrl: groupcastImageUrl,
        membersId: membersId,
        customType: customType,
        isLoading: isLoading,
        metaData: metaData,
        searchableTags: searchableTags,
      );
}
