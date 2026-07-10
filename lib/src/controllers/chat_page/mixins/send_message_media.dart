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
      // Check if paid media handling is enabled and delegate
      Map<String, dynamic>? paidMediaMetaData;
      if (IsmChatProperties.chatPageProperties.enablePaidMediaHandling &&
          IsmChat.i.onPaidMediaSend != null) {
        final context =
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context;
        final result = await IsmChat.i.onPaidMediaSend!(
          context,
          _controller.conversation,
          _controller.webMedia,
        );
        if (result.handled) {
          _controller
            ..showCloseLoaderForMoble(showLoader: false)
            ..isCameraView = false
            ..webMedia.clear();
          return;
        }
        paidMediaMetaData = result.metaData;
      }

      _controller.showCloseLoaderForMoble();

      for (var media in _controller.webMedia) {
        if (IsmChatConstants.imageExtensions
            .contains(media.platformFile.extension)) {
          if (_isGifExtension(media.platformFile.extension)) {
            await sendGif(
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              webMediaModel: media,
              metaDataFromDelegate: paidMediaMetaData,
            );
          } else {
            await sendImage(
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              webMediaModel: media,
              metaDataFromDelegate: paidMediaMetaData,
            );
          }
        } else {
          await sendVideo(
            webMediaModel: media,
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            metaDataFromDelegate: paidMediaMetaData,
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
      // Check if paid media handling is enabled and delegate
      Map<String, dynamic>? paidMediaMetaData;
      if (IsmChatProperties.chatPageProperties.enablePaidMediaHandling &&
          IsmChat.i.onPaidMediaSend != null) {
        final context =
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context;
        final result = await IsmChat.i.onPaidMediaSend!(
          context,
          _controller.conversation,
          _controller.webMedia,
        );
        if (result.handled) {
          _controller.webMedia.clear();
          return;
        }
        paidMediaMetaData = result.metaData;
      }

      for (var media in _controller.webMedia) {
        if (await IsmChatProperties
                .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
                ?.call(
                    IsmChatConfig.kNavigatorKey.currentContext ??
                        IsmChatConfig.context,
                    IsmChatUtility.chatPageController.conversation!,
                    media.isVideo
                        ? IsmChatCustomMessageType.video
                        : IsmChatCustomMessageType.image,
                    _controller.chatInputController.text.trim()) ??
            true) {
          if (media.isVideo) {
            await sendVideo(
              webMediaModel: media,
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              metaDataFromDelegate: paidMediaMetaData,
            );
          } else if (_isGifExtension(media.platformFile.extension)) {
            await sendGif(
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              webMediaModel: media,
              metaDataFromDelegate: paidMediaMetaData,
            );
          } else {
            await sendImage(
              conversationId: _controller.conversation?.conversationId ?? '',
              userId: _controller.conversation?.opponentDetails?.userId ?? '',
              webMediaModel: media,
              metaDataFromDelegate: paidMediaMetaData,
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
    Map<String, dynamic>? metaDataFromDelegate,
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
      final compressionQuality = _resolveVideoCompressionQuality();
      if (compressionQuality != null) {
        final mediaInfo = await VideoCompress.compressVideo(
          webMediaModel.platformFile.path ?? '',
          quality: compressionQuality,
          deleteOrigin: false,
        );

        if (mediaInfo != null) {
          final videoCompresFile = mediaInfo.file;
          bytes = await videoCompresFile?.readAsBytes();
        } else {
          bytes = await _readVideoBytes(webMediaModel);
        }
      } else {
        bytes = await _readVideoBytes(webMediaModel);
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
        customMetaData: metaDataFromDelegate,
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
    unawaited(_controller.scrollDown());
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
    Map<String, dynamic>? metaDataFromDelegate,
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
        customMetaData: metaDataFromDelegate,
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
    unawaited(_controller.scrollDown());
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

  /// Sends a message with a remote media URL (image, GIF, sticker).
  Future<void> sendMessageWithMediaUrl({
    required String conversationId,
    required String userId,
    required String mediaUrl,
    required IsmChatMediaType mediaType,
    required String body,
    required String notificationBody,
    required String nameWithExtension,
    required String mediaId,
    String? caption,
    String? extension,
    String? stillUrl,
    int? size,
    bool sendPushNotification = true,
    List<String>? searchableTags,
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

    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final resolvedExtension = extension ??
        (nameWithExtension.contains('.')
            ? nameWithExtension.split('.').last
            : 'gif');
    final mediaMessage = IsmChatMessageModel(
      body: body,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: mediaType,
          thumbnailUrl: mediaUrl,
          size: size ?? 0,
          name: nameWithExtension,
          mimeType: resolvedExtension,
          mediaUrl: mediaUrl,
          mediaId: mediaId,
          extension: resolvedExtension,
          stillUrl: stillUrl ?? mediaUrl,
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
      isUploading: false,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        isDownloaded: true,
        caption: caption,
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

    _controller.messages.add(mediaMessage);
    unawaited(_controller.scrollDown());
    _controller.isreplying = false;
    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(mediaMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(mediaMessage);
      }
    }

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    final attachment =
        mediaMessage.attachments?.first.toOutgoingMap() ?? <String, dynamic>{};

    await _controller.sendMessage(
      metaData: mediaMessage.metaData,
      deviceId: mediaMessage.deviceId ?? '',
      body: mediaMessage.body,
      customType: _resolveOutgoingCustomType(mediaMessage),
      createdAt: mediaMessage.sentAt,
      conversationId: mediaMessage.conversationId ?? '',
      messageType: mediaMessage.messageType?.value ?? 0,
      notificationBody: notificationBody,
      notificationTitle: notificationTitle,
      attachments: [attachment],
      isBroadcast: _controller.isBroadcast,
      parentMessageId: mediaMessage.parentMessageId,
      sendPushNotification: sendPushNotification,
      searchableTags: searchableTags ??
          _gifStickerSearchableTags(mediaType, nameWithExtension),
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
    final nameWithExtension = imageUrl.split('/').last;
    var mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    if (mediaId.isEmpty) {
      mediaId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    final extension = nameWithExtension.split('.').last;
    int? size;
    try {
      final bytes = await IsmChatUtility.getUint8ListFromUrl(imageUrl);
      size = bytes.length;
    } catch (_) {
      size = 0;
    }

    await sendMessageWithMediaUrl(
      conversationId: conversationId,
      userId: userId,
      mediaUrl: imageUrl,
      mediaType: IsmChatMediaType.image,
      body: IsmChatStrings.image,
      notificationBody: IsmChatStrings.sentImage,
      nameWithExtension: nameWithExtension,
      mediaId: mediaId,
      caption: caption,
      extension: extension,
      size: size,
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
            // Thumbnail upload must use the thumbnail bytes, not the original file bytes.
            bytes: thumbnailBytes ?? Uint8List(0),
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
        _updateUploadingMessageMediaUrl(
          createdAt: createdAt,
          mediaUrl: mediaUrlPath,
          thumbnailUrl: !(imageAndFile ?? false) ? thumbnailUrlPath : mediaUrlPath,
        );
        final uploadedAttachment = AttachmentModel(
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
            stillUrl: mediaUrlPath,
          );
        final attachment = <Map<String, dynamic>>[
          uploadedAttachment.toOutgoingMap(),
        ];

        final attachmentType = uploadedAttachment.attachmentType;
        final attachmentName = uploadedAttachment.name ?? '';

        // Note: sendMessage is provided by send_message_core mixin
        await _controller.sendMessage(
          body: ismChatChatMessageModel.body,
          conversationId: ismChatChatMessageModel.conversationId ?? '',
          createdAt: createdAt,
          deviceId: ismChatChatMessageModel.deviceId ?? '',
          messageType: ismChatChatMessageModel.messageType?.value ?? 0,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachment,
          customType: _resolveOutgoingCustomType(ismChatChatMessageModel),
          metaData: ismChatChatMessageModel.metaData,
          isBroadcast: _controller.isBroadcast,
          parentMessageId: ismChatChatMessageModel.parentMessageId,
          searchableTags: _gifStickerSearchableTags(
            attachmentType,
            attachmentName,
          ),
        );
        _clearMessageUploadingState(createdAt);
      } else {
        IsmChatLog.error(
          'ismPostMediaUrl: presigned upload failed — sendMessage skipped. '
          'presignedMediaType=$mediaType '
          'attachmentType=${ismChatChatMessageModel.attachments?.first.attachmentType?.value}',
        );
        _markUploadFailed(createdAt);
      }
    } catch (e, st) {
      IsmChatLog.error(e, st);
      _markUploadFailed(createdAt);
    }
  }

  void _updateUploadingMessageMediaUrl({
    required int createdAt,
    required String mediaUrl,
    required String thumbnailUrl,
  }) {
    final index = _controller.messages.indexWhere(
      (message) =>
          message.sentAt == createdAt && message.messageId?.isEmpty == true,
    );
    if (index == -1) {
      return;
    }
    final current = _controller.messages[index];
    final attachment = current.attachments?.firstOrNull;
    if (attachment == null) {
      return;
    }
    current.attachments = [
      attachment.copyWith(
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl.isNotEmpty ? thumbnailUrl : mediaUrl,
        stillUrl: thumbnailUrl.isNotEmpty ? thumbnailUrl : mediaUrl,
      ),
    ];
    current.isUploading = false;
    _controller.messages[index] = current;
    if (_controller.messages is RxList<IsmChatMessageModel>) {
      (_controller.messages as RxList<IsmChatMessageModel>).refresh();
    }
    _controller.update();
  }

  void _clearMessageUploadingState(int createdAt) {
    final index = _controller.messages.indexWhere(
      (message) => message.sentAt == createdAt,
    );
    if (index == -1) {
      return;
    }
    final current = _controller.messages[index];
    if (current.isUploading != true) {
      return;
    }
    current.isUploading = false;
    _controller.messages[index] = current;
    if (_controller.messages is RxList<IsmChatMessageModel>) {
      (_controller.messages as RxList<IsmChatMessageModel>).refresh();
    }
    _controller.update();
  }

  bool _isGifExtension(String? extension) =>
      extension?.toLowerCase() == 'gif';

  Future<String> _resolveLocalMediaPath({
    required WebMediaModel webMediaModel,
    required Uint8List bytes,
    required String nameWithExtension,
  }) async {
    final existingPath = webMediaModel.platformFile.path ?? '';
    if (existingPath.isNotEmpty) {
      return existingPath;
    }
    if (bytes.isEmpty) {
      return '';
    }
    if (kIsWeb) {
      return bytes.toString();
    }
    try {
      final dir = await getTemporaryDirectory();
      final safeName = nameWithExtension.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return '';
    }
  }

  List<String>? _gifStickerSearchableTags(
    IsmChatMediaType? mediaType,
    String name,
  ) {
    if (mediaType == IsmChatMediaType.gif) {
      return ['/@gif', name];
    }
    if (mediaType == IsmChatMediaType.sticker) {
      return ['/@sticker', name];
    }
    return null;
  }

  String _resolveOutgoingCustomType(IsmChatMessageModel message) {
    if (message.messageType == IsmChatMessageType.reply) {
      return IsmChatCustomMessageType.reply.value;
    }
    final attachmentType = message.attachments?.firstOrNull?.attachmentType;
    if (attachmentType == IsmChatMediaType.gif ||
        attachmentType == IsmChatMediaType.sticker) {
      return attachmentType!.attachmentMessageCustomType;
    }
    return message.customType?.value ?? '';
  }

  /// Sends a GIF picked from gallery or another local source.
  Future<void> sendGif({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
    Map<String, dynamic>? metaDataFromDelegate,
  }) =>
      _sendVisualAttachment(
        conversationId: conversationId,
        userId: userId,
        webMediaModel: webMediaModel,
        mediaType: IsmChatMediaType.gif,
        body: IsmChatStrings.gif,
        notificationBody: IsmChatStrings.sentGif,
        metaDataFromDelegate: metaDataFromDelegate,
      );

  /// Sends a sticker picked from Giphy or another source.
  Future<void> sendSticker({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
    Map<String, dynamic>? metaDataFromDelegate,
  }) =>
      _sendVisualAttachment(
        conversationId: conversationId,
        userId: userId,
        webMediaModel: webMediaModel,
        mediaType: IsmChatMediaType.sticker,
        body: IsmChatStrings.sticker,
        notificationBody: IsmChatStrings.sentSticker,
        metaDataFromDelegate: metaDataFromDelegate,
      );

  /// Sends a Giphy GIF or sticker using its CDN URL (GifSticker API schema).
  Future<void> sendGiphyItem(
    IsmGiphyItem item, {
    required bool isSticker,
  }) async {
    if (!(_controller.conversation?.isChattingAllowed == true)) {
      _controller.showDialogCheckBlockUnBlock();
      return;
    }
    final allowed = await IsmChatProperties
            .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
            ?.call(
              IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context,
              _controller.conversation,
              IsmChatCustomMessageType.image,
              '',
            ) ??
        true;
    if (!allowed) {
      return;
    }

    final extension =
        item.extension.isNotEmpty ? item.extension : 'gif';
    final mediaType =
        isSticker ? IsmChatMediaType.sticker : IsmChatMediaType.gif;
    final giphyPath = isSticker ? 'stickers' : 'gifs';
    final displayName =
        'GPHMedia(${isSticker ? 'sticker' : 'gif'}) for ${item.id} --> https://giphy.com/$giphyPath/${item.id}';
    final stillUrl =
        item.previewUrl.isNotEmpty ? item.previewUrl : item.sendUrl;

    try {
      await sendMessageWithMediaUrl(
        conversationId: _controller.conversation?.conversationId ?? '',
        userId: _controller.conversation?.opponentDetails?.userId ?? '',
        mediaUrl: item.sendUrl,
        stillUrl: stillUrl,
        mediaType: mediaType,
        body: isSticker ? IsmChatStrings.sticker : IsmChatStrings.gif,
        notificationBody:
            isSticker ? IsmChatStrings.sentSticker : IsmChatStrings.sentGif,
        nameWithExtension: displayName,
        mediaId: item.id,
        extension: extension,
        searchableTags: [
          isSticker ? '/@sticker' : '/@gif',
          displayName,
        ],
      );
    } catch (e, st) {
      IsmChatLog.error(e, st);
      IsmChatUtility.showToast('Unable to send media');
    }
  }

  Future<void> _sendVisualAttachment({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
    required IsmChatMediaType mediaType,
    required String body,
    required String notificationBody,
    Map<String, dynamic>? metaDataFromDelegate,
  }) async {
    conversationId = await _controller.createConversation(
      conversationId: conversationId,
      userId: userId,
    );
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final bytes = webMediaModel.platformFile.bytes ?? Uint8List(0);
    final nameWithExtension = webMediaModel.platformFile.name;
    final mediaId = sentAt.toString();
    final extension = webMediaModel.platformFile.extension;
    final localMediaPath = await _resolveLocalMediaPath(
      webMediaModel: webMediaModel,
      bytes: bytes,
      nameWithExtension: nameWithExtension ?? 'media.gif',
    );
    final forMessageType = mediaType == IsmChatMediaType.sticker
        ? IsmChatCustomMessageType.image
        : IsmChatCustomMessageType.image;

    final visualMessage = IsmChatMessageModel(
      body: body,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: mediaType,
          thumbnailUrl: localMediaPath,
          size: webMediaModel.platformFile.size,
          name: nameWithExtension,
          mimeType: extension,
          mediaUrl: localMediaPath,
          mediaId: mediaId,
          bytes: bytes,
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
        customMetaData: metaDataFromDelegate,
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: forMessageType,
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

    _controller.messages.add(visualMessage);
    unawaited(_controller.scrollDown());
    _controller.isreplying = false;

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(visualMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(visualMessage);
      }
    }

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Presigned URL API uses image mediaType (0), same as photos. GIF/sticker
    // kind is carried in attachments[].attachmentType when sendMessage runs.
    await _controller.ismPostMediaUrl(
      bytes: bytes,
      createdAt: sentAt,
      ismChatChatMessageModel: visualMessage,
      mediaId: mediaId,
      mediaType: IsmChatMediaType.image.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: notificationBody,
      imageAndFile: true,
      notificationTitle: notificationTitle,
    );
  }

  void _markUploadFailed(int createdAt) {
    _clearMessageUploadingState(createdAt);
    final index = _controller.messages.indexWhere(
      (message) => message.sentAt == createdAt,
    );
    if (index == -1) {
      return;
    }
    final current = _controller.messages[index];
    current
      ..isInvalidMessage = true
      ..messageId = '';
    _controller.messages[index] = current;
    if (_controller.messages is RxList<IsmChatMessageModel>) {
      (_controller.messages as RxList<IsmChatMessageModel>).refresh();
    }
    _controller.update();
  }
}

VideoQuality? _resolveVideoCompressionQuality() {
  final config =
      IsmChatProperties.chatPageProperties.attachmentConfig?.videoCompression;
  final IsmChatVideoCompressionSettings settings;
  if (Platform.isIOS) {
    settings = config?.ios ?? const IsmChatVideoCompressionSettings();
  } else if (Platform.isAndroid) {
    settings = config?.android ?? const IsmChatVideoCompressionSettings();
  } else {
    return null;
  }
  if (!settings.enabled) {
    return null;
  }
  return _mapVideoCompressionQuality(settings.quality);
}

VideoQuality _mapVideoCompressionQuality(
  IsmChatVideoCompressionQuality quality,
) {
  switch (quality) {
    case IsmChatVideoCompressionQuality.defaultQuality:
      return VideoQuality.DefaultQuality;
    case IsmChatVideoCompressionQuality.lowQuality:
      return VideoQuality.LowQuality;
    case IsmChatVideoCompressionQuality.mediumQuality:
      return VideoQuality.MediumQuality;
    case IsmChatVideoCompressionQuality.highestQuality:
      return VideoQuality.HighestQuality;
    case IsmChatVideoCompressionQuality.res640x480:
      return VideoQuality.Res640x480Quality;
    case IsmChatVideoCompressionQuality.res960x540:
      return VideoQuality.Res960x540Quality;
    case IsmChatVideoCompressionQuality.res1280x720:
      return VideoQuality.Res1280x720Quality;
    case IsmChatVideoCompressionQuality.res1920x1080:
      return VideoQuality.Res1920x1080Quality;
  }
}

Future<Uint8List?> _readVideoBytes(WebMediaModel webMediaModel) async {
  final cachedBytes = webMediaModel.platformFile.bytes;
  if (cachedBytes != null && cachedBytes.isNotEmpty) {
    return cachedBytes;
  }
  final path = webMediaModel.platformFile.path;
  if (path != null && path.isNotEmpty) {
    return File(path).readAsBytes();
  }
  return cachedBytes;
}
