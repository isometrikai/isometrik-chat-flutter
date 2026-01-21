part of '../chat_page_controller.dart';

/// Core mixin for message sending functionality in the chat page controller.
///
/// This mixin provides the core message sending methods including:
/// - `sendMessage()` - Generic message sending method
/// - `sendTextMessage()` - Text message sending
/// - `sendAboutTextMessage()` - About text message sending
/// - `createConversation()` - Conversation creation
///
/// This mixin depends on:
/// - `sendBroadcastMessage()` from send_message_broadcast mixin (for broadcast messages)
mixin IsmChatPageSendMessageCoreMixin {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Core method for sending messages.
  ///
  /// Handles sending messages through various channels:
  /// - Paid wallet messages (if configured)
  /// - Regular messages
  /// - Broadcast messages
  ///
  /// [messageType] - Type of the message
  /// [deviceId] - Device ID
  /// [conversationId] - ID of the conversation
  /// [body] - Message body
  /// [createdAt] - Timestamp when the message was created
  /// [notificationBody] - Notification body text
  /// [notificationTitle] - Notification title
  /// [customType] - Custom message type
  /// [parentMessageId] - Optional parent message ID for replies
  /// [metaData] - Optional message metadata
  /// [mentionedUsers] - Optional mentioned users
  /// [attachments] - Optional attachments
  /// [isBroadcast] - Whether this is a broadcast message
  /// [sendPushNotification] - Whether to send push notification
  /// [encrypted] - Whether the message is encrypted
  ///
  /// Note: This method requires `sendBroadcastMessage` to be available through
  /// send_message_broadcast mixin on the controller.
  void sendMessage({
    required int messageType,
    required String deviceId,
    required String conversationId,
    required String body,
    required int createdAt,
    required String notificationBody,
    required String notificationTitle,
    required String customType,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    List<Map<String, dynamic>>? attachments,
    bool isBroadcast = false,
    bool sendPushNotification = true,
    bool encrypted = false,
  }) async {
    notificationBody = IsmChatConfig.notificationBody?.call(notificationBody,
            IsmChatCustomMessageType.fromString(customType)) ??
        notificationBody;
    if (IsmChatConfig.sendPaidWalletMessage?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            _controller.conversation,
            IsmChatCustomMessageType.fromString(customType)) ??
        false) {
      final messageMetaData = metaData?.toMap() ?? {};
      if (IsmChatConfig.paidWalletModel?.customType != null) {
        final customType = await IsmChatConfig.paidWalletModel?.customType
                ?.call(_controller.conversation) ??
            {};
        messageMetaData['customType'] = customType;
      }
      final response = await _controller.commonController.sendPaidWalletMessage(
        showInConversation: true,
        messageType: messageType,
        encrypted: encrypted,
        deviceId: deviceId,
        conversationId: conversationId,
        body: body,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        attachments: attachments,
        customType: customType,
        events: {
          'updateUnreadCount': true,
          'sendPushNotification': sendPushNotification
        },
        mentionedUsers: mentionedUsers,
        metaData: messageMetaData,
        parentMessageId: parentMessageId,
        createdAt: createdAt,
      );
      if (response.$1) {
        _controller.didReactedLast = false;
        await _controller.getMessagesFromDB(conversationId);
        if (kIsWeb &&
            IsmChatResponsive.isWeb(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context)) {
          await _controller.conversationController.getConversationsFromDB();
        }
      }
      IsmChatConfig.paidWalletMessageApiResponse?.call(
        response.$2,
        IsmChatConfig.paidWalletModel?.apiUrl ?? '',
      );
    } else if (_controller.conversation?.customType !=
        IsmChatStrings.broadcast) {
      final isMessageSent = await _controller.commonController.sendMessage(
        showInConversation: true,
        encrypted: encrypted,
        events: {
          'updateUnreadCount': true,
          'sendPushNotification': sendPushNotification
        },
        attachments: attachments,
        mentionedUsers: mentionedUsers,
        metaData: metaData,
        messageType: messageType,
        customType: customType,
        parentMessageId: parentMessageId,
        deviceId: deviceId,
        conversationId: conversationId,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        body: body,
        createdAt: createdAt,
        isBroadcast: isBroadcast,
      );
      if (isMessageSent && !isBroadcast) {
        _controller.didReactedLast = false;
        await _controller.getMessagesFromDB(conversationId);
        if (kIsWeb &&
            IsmChatResponsive.isWeb(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context)) {
          await _controller.conversationController.getConversationsFromDB();
        }
      }
    } else {
      // Note: sendBroadcastMessage is provided by send_message_broadcast mixin
      await _controller.sendBroadcastMessage(
        groupcastId: conversationId,
        messageType: messageType,
        deviceId: deviceId,
        body: body,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        attachments: attachments,
        customType: customType,
        metaData: metaData,
        searchableTags: [notificationBody],
        createdAt: createdAt,
        mentionedUsers: mentionedUsers,
        parentMessageId: parentMessageId,
        sendPushNotification: sendPushNotification,
        encrypted: encrypted,
      );
    }
  }

  /// Sends a text message.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [pushNotifications] - Whether to send push notifications
  ///
  /// Note: This method requires `createConversation` and `sendMessage`
  /// to be available on the controller.
  void sendTextMessage({
    required String conversationId,
    required String userId,
    bool pushNotifications = true,
  }) async {
    conversationId = await _controller.createConversation(
        conversationId: conversationId, userId: userId);
    final sentAt = DateTime.now().millisecondsSinceEpoch;

    var textMessage = IsmChatMessageModel(
      body: _controller.chatInputController.text.trim(),
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.text,
      deliveredToAll: false,
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageId: '',
      messageType: _controller.isreplying
          ? IsmChatMessageType.reply
          : IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId:
          _controller.isreplying ? _controller.replayMessage?.messageId : '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        isOnelyEmoji: IsmChatUtility.isOnlyEmoji(
          _controller.chatInputController.text.trim(),
        ),
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.text,
                parentMessageAttachmentUrl:
                    _controller.getParentMessageUrl(_controller.replayMessage),
                parentMessageAttachmentDuration:
                    _controller.replayMessage?.metaData?.duration?.inSeconds,
                parentMessageMessageType: _controller.replayMessage?.customType,
                parentMessageInitiator: _controller.replayMessage?.sentByMe,
                parentMessageBody:
                    _controller.getMessageBody(_controller.replayMessage),
                parentMessageUserId:
                    _controller.replayMessage?.senderInfo?.userId,
                parentMessageUserName:
                    _controller.replayMessage?.senderInfo?.userName ?? '',
              )
            : null,
      ),
      mentionedUsers: _controller.userMentionedList.map(
        (e) {
          var user =
              _controller.groupMembers.where((m) => m.userId == e.userId);
          return UserDetails(
            userProfileImageUrl: user.first.profileUrl,
            userName: user.first.userName,
            userIdentifier: user.first.userIdentifier,
            userId: e.userId,
            online: false,
            lastSeen: 0,
          );
        },
      ).toList(),
    );
    _controller.messages.add(textMessage);
    _controller.isreplying = false;
    _controller.chatInputController.clear();
    _controller.isMessageSent = false;
    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper
          ?.saveMessage(textMessage, IsmChatDbBox.pending);
      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(textMessage);
      }
    }

    if ([
      IsmChatCustomMessageType.image,
      IsmChatCustomMessageType.video
    ].contains(textMessage.metaData?.replyMessage?.parentMessageMessageType)) {}

    if (textMessage.metaData?.replyMessage != null) {
      final replyMessage = textMessage.metaData?.replyMessage;
      final isImageReply = replyMessage?.parentMessageMessageType ==
          IsmChatCustomMessageType.image;
      final isVideoReply = replyMessage?.parentMessageMessageType ==
          IsmChatCustomMessageType.video;
      if (isImageReply || isVideoReply) {
        Uint8List? bytes;
        String? parentMessageAttachmentUrl;
        final isForceValidUrl =
            replyMessage?.parentMessageAttachmentUrl?.isForceValidUrl ?? false;

        if (isForceValidUrl == false) {
          if (isImageReply) {
            if ((replyMessage?.parentMessageAttachmentUrl ?? '')
                .startsWith('blob')) {
              bytes = await IsmChatBlob.blobUrlToBytes(
                  replyMessage?.parentMessageAttachmentUrl ?? '');
            } else {
              bytes = await File(replyMessage?.parentMessageAttachmentUrl ?? '')
                  .readAsBytes();
            }
          } else if (isVideoReply) {
            bytes = (replyMessage?.parentMessageAttachmentUrl ?? '')
                .strigToUnit8List;
          }
          final parentMessageUrl =
              await _controller.commonController.postMediaUrl(
            conversationId: textMessage.conversationId ?? '',
            nameWithExtension:
                _controller.replayMessage?.attachments?.first.name ?? '',
            mediaType: IsmChatMediaType.image.value,
            mediaId: sentAt.toString(),
            bytes: bytes ?? Uint8List(0),
            isLoading: false,
          );
          parentMessageAttachmentUrl = parentMessageUrl?.mediaUrl;
        } else {
          parentMessageAttachmentUrl = replyMessage?.parentMessageAttachmentUrl;
        }

        textMessage.metaData = textMessage.metaData?.copyWith(
          replyMessage: replyMessage?.copyWith(
            parentMessageAttachmentUrl: parentMessageAttachmentUrl,
          ),
        );
      }
    }
    final encrypted = IsmChatConfig.messageEncrypted ?? false;
    var body = encrypted
        ? IsmChatUtility.encryptMessage(
            textMessage.body,
            conversationId,
          )
        : textMessage.body;
    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    final notificationBody = encrypted ? 'New Message' : textMessage.body;
    _controller.sendMessage(
      isBroadcast: _controller.isBroadcast,
      metaData: textMessage.metaData,
      deviceId: textMessage.deviceId ?? '',
      body: body,
      customType: textMessage.customType?.value ?? '',
      createdAt: sentAt,
      parentMessageId: textMessage.parentMessageId,
      conversationId: textMessage.conversationId ?? '',
      messageType: textMessage.messageType?.value ?? 0,
      notificationBody: notificationBody,
      notificationTitle: notificationTitle,
      mentionedUsers:
          _controller.userMentionedList.map((e) => e.toMap()).toList(),
      sendPushNotification: pushNotifications,
      encrypted: encrypted,
    );
  }

  /// Sends an "about text" message.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [outSideMessage] - The outside message to send
  /// [pushNotifications] - Whether to send push notifications
  ///
  /// Note: This method requires `sendMessage` to be available on the controller.
  void sendAboutTextMessage({
    required String conversationId,
    required String userId,
    required OutSideMessage? outSideMessage,
    bool pushNotifications = true,
  }) async {
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (chatConversationResponse == null && !_controller.isBroadcast) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        isGroup: _controller.conversation?.isGroup ?? false,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              _controller.conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
        _controller.getConverstaionDetails(),
      );
    }
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final aboutTextMessage = IsmChatMessageModel(
      body: outSideMessage?.messageFromOutSide ?? '',
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.aboutText,
      deliveredToAll: false,
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageId: '',
      messageType: _controller.isreplying
          ? IsmChatMessageType.reply
          : IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId:
          _controller.isreplying ? _controller.replayMessage?.messageId : '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        aboutText: outSideMessage?.aboutText,
        caption: outSideMessage?.caption,
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.aboutText,
                parentMessageMessageType: _controller.replayMessage?.customType,
                parentMessageInitiator: _controller.replayMessage?.sentByMe,
                parentMessageBody:
                    _controller.getMessageBody(_controller.replayMessage),
                parentMessageUserId:
                    _controller.replayMessage?.senderInfo?.userId,
                parentMessageUserName:
                    _controller.replayMessage?.senderInfo?.userName ?? '',
              )
            : null,
      ),
    );
    _controller.messages.add(aboutTextMessage);
    _controller.isreplying = false;
    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(aboutTextMessage, IsmChatDbBox.pending);
      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(aboutTextMessage);
      }
    }
    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    _controller.sendMessage(
      isBroadcast: _controller.isBroadcast,
      metaData: aboutTextMessage.metaData,
      deviceId: aboutTextMessage.deviceId ?? '',
      body: aboutTextMessage.body,
      customType: aboutTextMessage.customType?.value ?? '',
      createdAt: sentAt,
      parentMessageId: aboutTextMessage.parentMessageId,
      conversationId: aboutTextMessage.conversationId ?? '',
      messageType: aboutTextMessage.messageType?.value ?? 0,
      notificationBody: aboutTextMessage.body,
      notificationTitle: notificationTitle,
      sendPushNotification: pushNotifications,
    );
  }

  /// Creates or retrieves a conversation.
  ///
  /// [conversationId] - ID of the conversation (may be empty for new conversations)
  /// [userId] - ID of the user
  ///
  /// Returns the conversation ID (existing or newly created).
  ///
  /// Note: This method requires `createBroadcastConversation` to be available
  /// through send_message_broadcast mixin on the controller.
  Future<String> createConversation({
    required String conversationId,
    String? userId,
  }) async {
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    final isBroadcastConversation = _controller.isBroadcast ||
        _controller.conversation?.customType == IsmChatStrings.broadcast;

    // Ensure isBroadcast flag is set if conversation is a broadcast
    if (!_controller.isBroadcast && isBroadcastConversation) {
      _controller.isBroadcast = true;
    }

    if (chatConversationResponse == null && !isBroadcastConversation) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        isGroup: _controller.conversation?.isGroup ?? false,
        userId: [userId ?? ''],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              _controller.conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      IsmChatConfig.onConversationCreated?.call(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
        _controller.conversation,
      );
      unawaited(
        _controller.getConverstaionDetails(),
      );
    } else if (isBroadcastConversation) {
      // Check if conversation already has a conversationId (existing broadcast)
      final existingConversationId = _controller.conversation?.conversationId;

      // Only create new broadcast if:
      // 1. The conversationId parameter is empty AND
      // 2. The conversation object doesn't have a conversationId AND
      // 3. The conversation is not found in local database
      if (conversationId.isEmpty &&
          (existingConversationId == null || existingConversationId.isEmpty) &&
          chatConversationResponse == null) {
        // Note: createBroadcastConversation is provided by send_message_broadcast mixin
        conversationId = await _controller.createBroadcastConversation(
              groupcastImageUrl:
                  'https://png.pngtree.com/element_our/20190528/ourmid/pngtree-speaker-broadcast-icon-image_1144351.jpg',
              groupcastTitle: IsmChatStrings.defaultString,
              customType: 'broadcast',
              membersId: _controller.conversation?.members
                      ?.map((e) => e.userId)
                      .toList() ??
                  [],
              metaData: {
                'membersDetail': _controller.conversation?.members
                        ?.map((e) => {
                              'memberName': e.userName,
                              'memberId': e.userId,
                            })
                        .toList() ??
                    []
              },
              searchableTags: [
                IsmChatConfig.communicationConfig.userConfig.userName ??
                    _controller.conversationController.userDetails?.userName ??
                    '',
                _controller.conversation?.chatName ?? ''
              ],
            ) ??
            '';
        _controller.conversation =
            _controller.conversation?.copyWith(conversationId: conversationId);
      } else {
        // Use existing conversationId from conversation object if available
        conversationId = existingConversationId ?? conversationId;
        // Update conversation with the correct conversationId if it wasn't set
        if (conversationId.isNotEmpty &&
            (_controller.conversation?.conversationId?.isEmpty ?? true)) {
          _controller.conversation = _controller.conversation
              ?.copyWith(conversationId: conversationId);
        }
      }
    }
    return conversationId;
  }
}
