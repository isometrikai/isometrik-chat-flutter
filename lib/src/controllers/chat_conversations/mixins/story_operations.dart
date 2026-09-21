part of '../chat_conversations_controller.dart';

/// Story operations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to story functionality including
/// replying to stories with media messages.
mixin IsmChatConversationsStoryOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Replies to stories with a media message.
  ///
  /// `conversationId`: The ID of the conversation to reply in.
  /// `userDetails`: The user details of the person whose story is being replied to.
  /// `storyMediaUrl`: The URL of the story media.
  /// `caption`: Optional caption for the reply.
  /// `sendPushNotification`: Indicates if a push notification should be sent.
  Future<void> replayOnStories({
    required String conversationId,
    required UserDetails userDetails,
    String? storyMediaUrl,
    String? caption,
    bool sendPushNotification = false,
  }) async {
    final resolvedStoryMediaUrl = storyMediaUrl?.trim() ?? '';
    if (resolvedStoryMediaUrl.isEmpty) {
      IsmChatLog.error('replayOnStories aborted: storyMediaUrl is empty');
      return;
    }
    if (userDetails.userId.trim().isEmpty) {
      IsmChatLog.error('replayOnStories aborted: userId is empty');
      return;
    }

    var resolvedConversationId = conversationId.trim();
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper?.getConversation(resolvedConversationId);
    if (chatConversationResponse == null) {
      if (_controller.currentConversation == null) {
        IsmChatLog.error(
          'replayOnStories aborted: currentConversation is null',
        );
        return;
      }
      final conversation = await _controller.commonController.createConversation(
        conversation: _controller.currentConversation!,
        userId: [userDetails.userId],
        metaData: _controller.currentConversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              userDetails.userName,
          userDetails.userName
        ],
      );
      resolvedConversationId = conversation?.conversationId?.trim() ?? '';
      if (resolvedConversationId.isEmpty) {
        IsmChatLog.error(
          'replayOnStories aborted: createConversation returned no id',
        );
        return;
      }
      _controller.currentConversation = _controller.currentConversation!.copyWith(
        conversationId: resolvedConversationId,
      );
      _controller.currentConversationId = resolvedConversationId;
    }

    final sentAt = DateTime.now().millisecondsSinceEpoch;
    var mediaSize = 0;
    try {
      final bytes =
          await IsmChatUtility.getUint8ListFromUrl(resolvedStoryMediaUrl);
      mediaSize = bytes.length;
    } catch (e, st) {
      // Size is optional for the API — same fallback as sendMessageWithImageUrl.
      IsmChatLog.error('replayOnStories: story media size lookup failed', st);
    }

    final nameWithExtension = resolvedStoryMediaUrl.split('/').last;
    var mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    if (mediaId.isEmpty) {
      mediaId = sentAt.toString();
    }
    final extension = nameWithExtension.contains('.')
        ? nameWithExtension.split('.').last
        : 'jpeg';
    final imageMessage = IsmChatMessageModel(
      body: IsmChatStrings.image,
      conversationId: resolvedConversationId,
      senderInfo: UserDetails(
          userProfileImageUrl:
              IsmChatConfig.communicationConfig.userConfig.userProfile ?? '',
          userName: IsmChatConfig.communicationConfig.userConfig.userName ?? '',
          userIdentifier:
              IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
          userId: IsmChatConfig.communicationConfig.userConfig.userId,
          online: false,
          lastSeen: 0),
      customType: IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.image,
          thumbnailUrl: resolvedStoryMediaUrl,
          size: mediaSize,
          name: nameWithExtension,
          mimeType: 'image/jpeg',
          mediaUrl: resolvedStoryMediaUrl,
          mediaId: mediaId,
          extension: extension,
        )
      ],
      deliveredToAll: false,
      messageId: '',
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageType: IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId: '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      metaData: IsmChatMetaData(
        caption: caption,
      ),
    );

    await IsmChatConfig.dbWrapper?.saveMessage(
      imageMessage,
      IsmChatDbBox.pending,
    );

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            userDetails.userName;
    await _controller.commonController.sendMessage(
      showInConversation: true,
      encrypted: IsmChatConfig.messageEncrypted ?? false,
      events: {
        'updateUnreadCount': true,
        'sendPushNotification': sendPushNotification
      },
      body: imageMessage.body,
      conversationId: imageMessage.conversationId ?? '',
      createdAt: sentAt,
      deviceId: imageMessage.deviceId ?? '',
      messageType: imageMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentImage,
      notificationTitle: notificationTitle,
      attachments: [imageMessage.attachments?.first.toMap() ?? {}],
      customType: imageMessage.customType?.value ?? '',
      metaData: imageMessage.metaData,
      parentMessageId: imageMessage.parentMessageId,
      isUpdateMesage: true,
    );
  }
}

