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
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (chatConversationResponse == null) {
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
      conversationId = conversation?.conversationId ?? '';
    }
    IsmChatMessageModel? imageMessage;
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final bytes = await IsmChatUtility.getUint8ListFromUrl(storyMediaUrl ?? '');
    final nameWithExtension = storyMediaUrl?.split('/').last ?? '';
    final mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    final extension = nameWithExtension.split('.').last;
    imageMessage = IsmChatMessageModel(
      body: IsmChatStrings.image,
      conversationId: conversationId,
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
          thumbnailUrl: storyMediaUrl,
          size: bytes.length,
          name: nameWithExtension,
          mimeType: 'image/jpeg',
          mediaUrl: storyMediaUrl,
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
      notificationBody: imageMessage.body,
      notificationTitle: notificationTitle,
      attachments: [imageMessage.attachments?.first.toMap() ?? {}],
      customType: imageMessage.customType?.value ?? '',
      metaData: imageMessage.metaData,
      parentMessageId: imageMessage.parentMessageId,
      isUpdateMesage: false,
    );
  }
}

