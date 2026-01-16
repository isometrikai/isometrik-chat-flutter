part of '../chat_page_controller.dart';

/// Mixin for handling media message sending (images, videos) in the chat page controller.
///
/// This mixin provides functionality for sending media messages including images and videos.
/// It depends on:
/// - `createConversation()` from send_message_core mixin
/// - `sendMessage()` from send_message_core mixin
/// - `ismPostMediaUrl()` (defined in this mixin)
mixin IsmChatPageSendMessageMediaMixin {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Validates and sends media files (mobile).
  void sendMedia() async {
    var isMaxSize = false;
    for (var media in _controller.webMedia) {
      if (media.dataSize.split(' ').last == 'KB') {
        continue;
      }
      if (!media.dataSize.size()) {
        isMaxSize = true;
        break;
      }
    }
    if (isMaxSize == false) {
      IsmChatRoute.goBack<void>();
      sendPhotoAndVideo();
    } else {
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatAlertDialogBox(
          title: IsmChatStrings.youCanNotSend,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  /// Validates and sends media files (web).
  void sendMediaWeb() async {
    var isMaxSize = false;
    _controller.showCloseLoaderForMoble();

    for (final x in _controller.webMedia) {
      if (!x.dataSize.size()) {
        isMaxSize = true;
        break;
      }
    }
    if (isMaxSize == false) {
      _controller.showCloseLoaderForMoble(showLoader: false);
      sendPhotoAndVideoForWeb();
    } else {
      IsmChatUtility.closeLoader();
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatAlertDialogBox(
          title: IsmChatStrings.youCanNotSend,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  /// Sends photos and videos for web platform.
  void sendPhotoAndVideoForWeb() async {
    if (_controller.webMedia.isNotEmpty) {
      _controller.showCloseLoaderForMoble();

      for (var media in _controller.webMedia) {
        if (IsmChatConstants.imageExtensions
            .contains(media.platformFile.extension)) {
          await sendImage(
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            webMediaModel: media,
          );
        } else {
          await sendVideo(
            webMediaModel: media,
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
          );
        }
      }
      _controller
        ..showCloseLoaderForMoble(showLoader: false)
        ..isCameraView = false
        ..webMedia.clear();
    }
  }

  /// Sends photos and videos for mobile platform.
  void sendPhotoAndVideo() async {
    if (_controller.webMedia.isNotEmpty) {
      for (var media in _controller.webMedia) {
        if (await IsmChatProperties
                .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
                ?.call(
                    IsmChatConfig.kNavigatorKey.currentContext ??
                        IsmChatConfig.context,
                    IsmChatUtility.chatPageController.conversation!,
                    media.isVideo
                        ? IsmChatCustomMessageType.video
                        : IsmChatCustomMessageType.image) ??
            true) {
          if (media.isVideo) {
            await sendVideo(
              webMediaModel: media,
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
            );
          } else {
            await sendImage(
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              webMediaModel: media,
            );
          }
        }
      }
      _controller.webMedia.clear();
    }
  }

  /// Sends a video message.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [webMediaModel] - Web media model containing video data
  ///
  /// Note: This method requires `createConversation` and `ismPostMediaUrl`
  /// to be available through other mixins on the controller.
  Future<void> sendVideo({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
  }) async {
    // Note: createConversation is provided by send_message_core mixin
    conversationId = await _controller.createConversation(
      conversationId: conversationId,
      userId: userId,
    );
    IsmChatMessageModel? videoMessage;
    Uint8List? bytes;
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    if (IsmChatResponsive.isMobile(IsmChatConfig.kNavigatorKey.currentContext ??
            IsmChatConfig.context) &
        !kIsWeb) {
      final mediaInfo = await VideoCompress.compressVideo(
        webMediaModel.platformFile.path ?? '',
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
      );

      if (mediaInfo != null) {
        final videoCompresFile = mediaInfo.file;
        bytes = await videoCompresFile?.readAsBytes();
      } else {
        bytes = webMediaModel.platformFile.bytes;
      }
    } else {
      bytes = webMediaModel.platformFile.bytes;
    }
    final thumbnailBytes = webMediaModel.platformFile.thumbnailBytes;
    final thumbnailNameWithExtension = '$sentAt.png';
    final thumbnailMediaId = '$sentAt';
    final nameWithExtension = webMediaModel.platformFile.name;
    final mediaId = '$sentAt';
    final extension = webMediaModel.platformFile.extension;

    videoMessage = IsmChatMessageModel(
      body: IsmChatStrings.video,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.video,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.video,
          thumbnailUrl: thumbnailBytes.toString(),
          size: bytes?.length ?? 0,
          name: nameWithExtension,
          mimeType: extension,
          mediaUrl: kIsWeb
              ? webMediaModel.platformFile.bytes.toString()
              : webMediaModel.platformFile.path,
          mediaId: mediaId,
          extension: extension,
        )
      ],
      deliveredToAll: false,
      messageId: '',
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageType: _controller.isreplying
          ? IsmChatMessageType.reply
          : IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId:
          _controller.isreplying ? _controller.replayMessage?.messageId : '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        isDownloaded: true,
        caption: webMediaModel.caption,
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.video,
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

    _controller.messages.add(videoMessage);
    _controller.isreplying = false;

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(videoMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(videoMessage);
      }
    }

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    await _controller.ismPostMediaUrl(
      imageAndFile: false,
      bytes: bytes ?? Uint8List(0),
      createdAt: sentAt,
      ismChatChatMessageModel: videoMessage,
      mediaId: mediaId,
      mediaType: IsmChatMediaType.video.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: IsmChatStrings.video,
      thumbnailNameWithExtension: thumbnailNameWithExtension,
      thumbnailMediaId: thumbnailMediaId,
      thumbnailBytes: thumbnailBytes,
      thumbanilMediaType: IsmChatMediaType.image.value,
      notificationTitle: notificationTitle,
    );
  }

  /// Sends an image message.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [webMediaModel] - Web media model containing image data
  ///
  /// Note: This method requires `createConversation` and `ismPostMediaUrl`
  /// to be available through other mixins on the controller.
  Future<void> sendImage({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
  }) async {
    // Note: createConversation is provided by send_message_core mixin
    conversationId = await _controller.createConversation(
        conversationId: conversationId, userId: userId);
    IsmChatMessageModel? imageMessage;
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final bytes = webMediaModel.platformFile.bytes;
    final nameWithExtension = webMediaModel.platformFile.name;
    final mediaId = sentAt.toString();
    final extension = webMediaModel.platformFile.extension;
    imageMessage = IsmChatMessageModel(
      body: IsmChatStrings.image,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.image,
          thumbnailUrl: webMediaModel.platformFile.path,
          size: webMediaModel.platformFile.size,
          name: nameWithExtension,
          mimeType: extension,
          mediaUrl: webMediaModel.platformFile.path,
          mediaId: mediaId,
          bytes: webMediaModel.platformFile.bytes,
          extension: extension,
        )
      ],
      deliveredToAll: false,
      messageId: '',
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageType: _controller.isreplying
          ? IsmChatMessageType.reply
          : IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId:
          _controller.isreplying ? _controller.replayMessage?.messageId : '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        isDownloaded: true,
        caption: webMediaModel.caption,
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.image,
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

    _controller.messages.add(imageMessage);
    _controller.isreplying = false;

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(imageMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(imageMessage);
      }
    }

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    await _controller.ismPostMediaUrl(
      bytes: bytes ?? Uint8List(0),
      createdAt: sentAt,
      ismChatChatMessageModel: imageMessage,
      mediaId: mediaId,
      mediaType: IsmChatMediaType.image.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: IsmChatStrings.sentImage,
      imageAndFile: true,
      notificationTitle: notificationTitle,
    );
  }

  /// Sends a message with an image URL.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [imageUrl] - URL of the image to send
  /// [caption] - Optional caption for the image
  /// [sendPushNotification] - Whether to send push notification
  ///
  /// Note: This method requires `sendMessage` to be available through
  /// send_message_core mixin on the controller.
  Future<void> sendMessageWithImageUrl({
    required String conversationId,
    required String userId,
    required String imageUrl,
    String? caption,
    bool sendPushNotification = false,
  }) async {
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper!.getConversation(conversationId);
    if (chatConversationResponse == null && !_controller.isBroadcast) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
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
    IsmChatMessageModel? imageMessage;
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final bytes = await IsmChatUtility.getUint8ListFromUrl(imageUrl);
    final nameWithExtension = imageUrl.split('/').last;
    final mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    final extension = nameWithExtension.split('.').last;
    imageMessage = IsmChatMessageModel(
      body: IsmChatStrings.image,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.image,
          thumbnailUrl: imageUrl,
          size: bytes.length,
          name: nameWithExtension,
          mimeType: 'image/jpeg',
          mediaUrl: imageUrl,
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
        messageSentAt: sentAt,
        caption: caption,
      ),
    );

    _controller.messages.add(imageMessage);
    _controller.isreplying = false;
    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(imageMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(imageMessage);
      }
    }
    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Note: sendMessage is provided by send_message_core mixin
    _controller.sendMessage(
      metaData: imageMessage.metaData,
      deviceId: imageMessage.deviceId ?? '',
      body: imageMessage.body,
      customType: imageMessage.customType?.value ?? '',
      createdAt: imageMessage.sentAt,
      conversationId: imageMessage.conversationId ?? '',
      messageType: imageMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentImage,
      notificationTitle: notificationTitle,
      attachments: imageMessage.attachments != null
          ? [imageMessage.attachments!.first.toMap()]
          : null,
      isBroadcast: _controller.isBroadcast,
      parentMessageId: imageMessage.parentMessageId,
      sendPushNotification: sendPushNotification,
    );
  }

  /// Posts media URL to the server and sends the message.
  ///
  /// This method handles uploading media files and sending the message with
  /// the uploaded media URL. It supports both regular conversations and broadcasts.
  ///
  /// Note: This method requires `sendMessage` to be available through
  /// send_message_core mixin on the controller.
  Future<void> ismPostMediaUrl({
    required IsmChatMessageModel ismChatChatMessageModel,
    required String notificationBody,
    required String notificationTitle,
    required String nameWithExtension,
    required int createdAt,
    required int mediaType,
    required Uint8List bytes,
    required bool? imageAndFile,
    required String mediaId,
    String? thumbnailNameWithExtension,
    String? thumbnailMediaId,
    int? thumbanilMediaType,
    Uint8List? thumbnailBytes,
    bool isLoading = false,
  }) async {
    try {
      PresignedUrlModel? presignedUrlModel;
      if (_controller.isBroadcast) {
        presignedUrlModel = await _controller.commonController.getPresignedUrl(
          isLoading: isLoading,
          mediaExtension:
              ismChatChatMessageModel.attachments?.first.extension ?? '',
          userIdentifier:
              IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
          bytes: bytes,
        );
      } else {
        presignedUrlModel = await _controller.commonController.postMediaUrl(
          conversationId: ismChatChatMessageModel.conversationId ?? '',
          nameWithExtension: nameWithExtension,
          mediaType: mediaType,
          mediaId: mediaId,
          bytes: bytes,
          isLoading: isLoading,
        );
      }
      var mediaUrlPath = '';
      var thumbnailUrlPath = '';
      mediaUrlPath = presignedUrlModel?.mediaUrl ?? '';
      mediaId =
          _controller.isBroadcast ? mediaId : presignedUrlModel?.mediaId ?? '';
      if (!(imageAndFile ?? false)) {
        PresignedUrlModel? presignedUrlModel;
        if (_controller.isBroadcast) {
          presignedUrlModel =
              await _controller.commonController.getPresignedUrl(
            isLoading: isLoading,
            mediaExtension: thumbnailNameWithExtension?.split('.').last ?? '',
            userIdentifier:
                IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
            bytes: bytes,
          );
        } else {
          presignedUrlModel = await _controller.commonController.postMediaUrl(
            conversationId: ismChatChatMessageModel.conversationId ?? '',
            nameWithExtension: thumbnailNameWithExtension ?? '',
            mediaType: thumbanilMediaType ?? 0,
            mediaId: thumbnailMediaId ?? '',
            isLoading: isLoading,
            bytes: thumbnailBytes ?? Uint8List(0),
            isUpdateThumbnail: true,
          );
        }
        thumbnailUrlPath = _controller.isBroadcast
            ? presignedUrlModel?.mediaUrl ?? ''
            : presignedUrlModel?.thumbnailUrl ?? '';
      }
      if (mediaUrlPath.isNotEmpty) {
        final attachment = [
          AttachmentModel(
            thumbnailUrl:
                !(imageAndFile ?? false) ? thumbnailUrlPath : mediaUrlPath,
            size: ismChatChatMessageModel.attachments?.first.size ?? 0,
            name: ismChatChatMessageModel.attachments?.first.name,
            mimeType: ismChatChatMessageModel.attachments?.first.mimeType,
            mediaUrl: mediaUrlPath,
            mediaId: mediaId,
            extension: ismChatChatMessageModel.attachments?.first.extension,
            attachmentType:
                ismChatChatMessageModel.attachments?.first.attachmentType,
          ).toMap()
        ]..map((e) => e.removeWhere((key, value) => key == 'bytes'));

        // Note: sendMessage is provided by send_message_core mixin
        _controller.sendMessage(
          body: ismChatChatMessageModel.body,
          conversationId: ismChatChatMessageModel.conversationId ?? '',
          createdAt: createdAt,
          deviceId: ismChatChatMessageModel.deviceId ?? '',
          messageType: ismChatChatMessageModel.messageType?.value ?? 0,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachment,
          customType: ismChatChatMessageModel.customType?.value ?? '',
          metaData: ismChatChatMessageModel.metaData,
          isBroadcast: _controller.isBroadcast,
          parentMessageId: ismChatChatMessageModel.parentMessageId,
        );
      }
    } catch (e, st) {
      IsmChatLog.error(e, st);
    }
  }
}
