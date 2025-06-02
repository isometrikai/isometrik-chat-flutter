part of '../chat_page_controller.dart';

mixin IsmChatPageSendMessageMixin on GetxController {
  IsmChatPageController get _controller => IsmChatUtility.chatPageController;

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
  }) async {
    if (IsmChatConfig.sendPaidWalletMessage?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            _controller.conversation,
            IsmChatCustomMessageType.fromString(customType)) ??
        false) {
      var messageMetaData = metaData?.toMap() ?? {};
      if (IsmChatConfig.paidWalletModel?.customType != null) {
        final customType = await IsmChatConfig.paidWalletModel?.customType
                ?.call(_controller.conversation) ??
            {};
        messageMetaData['customType'] = customType;
      }
      final response = await _controller.commonController.sendPaidWalletMessage(
        showInConversation: true,
        messageType: messageType,
        encrypted: true,
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
      var isMessageSent = await _controller.commonController.sendMessage(
        showInConversation: true,
        encrypted: true,
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
      await sendBroadcastMessage(
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
      );
    }
  }

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

  void sendMediaWeb() async {
    var isMaxSize = false;
    _controller.showCloseLoaderForMoble();

    for (var x in _controller.webMedia) {
      if (!x.dataSize.size()) {
        isMaxSize = true;
        break;
      }
    }
    if (isMaxSize == false) {
      _controller.showCloseLoaderForMoble(showLoader: false);
      // IsmChatRoute.goBack();
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
      _controller.showCloseLoaderForMoble(showLoader: false);
      _controller.isCameraView = false;
      _controller.webMedia.clear();
    }
  }

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

  void sendAudio(
      {String? path,
      required String conversationId,
      required String userId,
      WebMediaModel? webMediaModel,
      Duration? duration}) async {
    conversationId = await createConversation(
      conversationId: conversationId,
      userId: userId,
    );
    IsmChatMessageModel? audioMessage;
    String? nameWithExtension;
    Uint8List? bytes;
    String? mediaId;

    String? extension;
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    if (path == null || path.isEmpty) {
      return;
    }
    if (webMediaModel == null) {
      bytes = kIsWeb
          ? await IsmChatUtility.fetchBytesFromBlobUrl(path)
          : Uint8List.fromList(
              await File.fromUri(Uri.parse(path)).readAsBytes());
      nameWithExtension = path.split('/').last;
      extension = nameWithExtension.split('.').last;
      mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      bytes = webMediaModel.platformFile.bytes ?? Uint8List(0);
      nameWithExtension = webMediaModel.platformFile.name;
      extension = webMediaModel.platformFile.extension;
      mediaId = sentAt.toString();
    }

    audioMessage = IsmChatMessageModel(
      body: 'Audio',
      conversationId: conversationId,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.audio,
      senderInfo: _controller.currentUser,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.audio,
          thumbnailUrl: path,
          size: bytes.length,
          name: nameWithExtension,
          mimeType: extension,
          mediaUrl: path,
          mediaId: mediaId,
          extension: extension,
        ),
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
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.audio,
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
        duration: duration ?? webMediaModel?.duration,
      ),
    );

    _controller.messages.add(audioMessage);

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper
          ?.saveMessage(audioMessage, IsmChatDbBox.pending);
      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(audioMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    await ismPostMediaUrl(
      imageAndFile: true,
      bytes: bytes,
      createdAt: sentAt,
      ismChatChatMessageModel: audioMessage,
      mediaId: sentAt.toString(),
      mediaType: IsmChatMediaType.audio.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: IsmChatStrings.sentAudio,
      notificationTitle: notificationTitle,
    );
  }

  void sendDocument({
    required String conversationId,
    required String userId,
  }) async {
    IsmChatMessageModel? documentMessage;
    String? nameWithExtension;
    Uint8List? bytes;
    Uint8List? thumbnailBytes;
    String? thumbnailNameWithExtension;
    String? thumbnailMediaId;
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result?.files.isNotEmpty ?? false) {
      conversationId = await createConversation(
          conversationId: conversationId, userId: userId);
      final resultFiles = result?.files ?? [];

      for (var x in resultFiles) {
        var sizeMedia = kIsWeb
            ? IsmChatUtility.formatBytes(
                int.parse((x.bytes?.length ?? 0).toString()),
              )
            : await IsmChatUtility.fileToSize(File(x.path ?? ''));

        bytes = x.bytes;
        if (sizeMedia.size()) {
          final document = kIsWeb
              ? await PdfDocument.openData(x.bytes ?? Uint8List(0))
              : await PdfDocument.openFile(x.path ?? '');
          final page = await document.getPage(1);
          final pdfImage = await page.render(
            width: page.width,
            height: page.height,
            backgroundColor: '#ffffff',
          );
          await page.close();

          thumbnailBytes = pdfImage?.bytes;
          thumbnailNameWithExtension = pdfImage?.format.toString();
          thumbnailMediaId = sentAt.toString();
          nameWithExtension = x.name;
          documentMessage = IsmChatMessageModel(
            body: IsmChatStrings.document,
            conversationId: conversationId,
            senderInfo: _controller.currentUser,
            customType: _controller.isreplying
                ? IsmChatCustomMessageType.reply
                : IsmChatCustomMessageType.file,
            attachments: [
              AttachmentModel(
                attachmentType: IsmChatMediaType.file,
                thumbnailUrl: pdfImage?.bytes.toString(),
                size: bytes?.length,
                name: nameWithExtension,
                mimeType: x.extension,
                mediaUrl: kIsWeb ? (bytes).toString() : x.path,
                mediaId: sentAt.toString(),
                extension: x.extension,
              )
            ],
            deliveredToAll: false,
            messageId: '',
            deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
            messageType: _controller.isreplying
                ? IsmChatMessageType.reply
                : IsmChatMessageType.normal,
            messagingDisabled: false,
            parentMessageId: _controller.isreplying
                ? _controller.replayMessage?.messageId
                : '',
            readByAll: false,
            sentAt: sentAt,
            sentByMe: true,
            isUploading: true,
            metaData: IsmChatMetaData(
              messageSentAt: sentAt,
              isDownloaded: true,
              replyMessage: _controller.isreplying
                  ? IsmChatReplyMessageModel(
                      forMessageType: IsmChatCustomMessageType.file,
                      parentMessageMessageType:
                          _controller.replayMessage?.customType,
                      parentMessageInitiator:
                          _controller.replayMessage?.sentByMe,
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
        } else {
          await IsmChatContextWidget.showDialogContext(
            content: const IsmChatAlertDialogBox(
              title: IsmChatStrings.youCanNotSend,
              cancelLabel: IsmChatStrings.okay,
            ),
          );
        }
      }
    }

    if (documentMessage != null) {
      _controller.messages.add(documentMessage);
      _controller.isreplying = false;

      if (!_controller.isBroadcast) {
        await IsmChatConfig.dbWrapper!
            .saveMessage(documentMessage, IsmChatDbBox.pending);
        if (kIsWeb &&
            IsmChatResponsive.isWeb(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context)) {
          _controller.updateLastMessagOnCurrentTime(documentMessage);
        }
      }

      var notificationTitle =
          IsmChatConfig.communicationConfig.userConfig.userName ??
              _controller.conversationController.userDetails?.userName ??
              '';
      if (await IsmChatProperties
              .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
              ?.call(
                  IsmChatConfig.kNavigatorKey.currentContext ??
                      IsmChatConfig.context,
                  IsmChatUtility.chatPageController.conversation!,
                  IsmChatCustomMessageType.file) ??
          true) {
        await ismPostMediaUrl(
          imageAndFile: false,
          bytes: bytes ?? Uint8List(0),
          createdAt: sentAt,
          ismChatChatMessageModel: documentMessage,
          mediaId: sentAt.toString(),
          mediaType: IsmChatMediaType.file.value,
          nameWithExtension: nameWithExtension ?? '',
          notificationBody: IsmChatStrings.sentDoc,
          notificationTitle: notificationTitle,
          thumbnailNameWithExtension: thumbnailNameWithExtension,
          thumbnailMediaId: thumbnailMediaId,
          thumbnailBytes: thumbnailBytes,
          thumbanilMediaType: IsmChatMediaType.image.value,
        );
      }
    }
  }

  Future<void> sendVideo({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
  }) async {
    conversationId = await createConversation(
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
        deleteOrigin: false, // It's false by default
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

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    await ismPostMediaUrl(
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

  Future<void> sendImage({
    required String conversationId,
    required String userId,
    required WebMediaModel webMediaModel,
  }) async {
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    IsmChatMessageModel? imageMessage;
    var sentAt = DateTime.now().millisecondsSinceEpoch;
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

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    await ismPostMediaUrl(
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

  Future<void> sendMessageWithImageUrl({
    required String conversationId,
    required String userId,
    required String imageUrl,
    String? caption,
    bool sendPushNotification = false,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
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
    var sentAt = DateTime.now().millisecondsSinceEpoch;
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
    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    sendMessage(
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

  void sendLocation({
    required double latitude,
    required double longitude,
    required String placeId,
    required String locationName,
    required String locationSubName,
    required String conversationId,
    required String userId,
  }) async {
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    var locationMessage = IsmChatMessageModel(
      body: IsmChatStrings.location,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.location,
      deliveredToAll: false,
      messageId: '',
      messageType: _controller.isreplying
          ? IsmChatMessageType.reply
          : IsmChatMessageType.normal,
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messagingDisabled: false,
      parentMessageId:
          _controller.isreplying ? _controller.replayMessage?.messageId : '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      attachments: [
        AttachmentModel(
          mediaUrl:
              'https://www.google.com/maps/search/?api=1&map_action=map&query=$latitude%2C$longitude&query_place_id=$placeId',
          address: locationSubName,
          attachmentType: IsmChatMediaType.location,
          latitude: latitude,
          longitude: longitude,
          title: locationName,
        ),
      ],
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.location,
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

    _controller.messages.add(locationMessage);
    _controller.isreplying = false;
    _controller.chatInputController.clear();

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(locationMessage, IsmChatDbBox.pending);

      if (kIsWeb &&
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context)) {
        _controller.updateLastMessagOnCurrentTime(locationMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    sendMessage(
      metaData: locationMessage.metaData,
      deviceId: locationMessage.deviceId ?? '',
      body: locationMessage.body,
      customType: locationMessage.customType?.value ?? '',
      createdAt: locationMessage.sentAt,
      conversationId: locationMessage.conversationId ?? '',
      messageType: locationMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentLocation,
      notificationTitle: notificationTitle,
      attachments: locationMessage.attachments != null
          ? [locationMessage.attachments!.first.toMap()]
          : null,
      isBroadcast: _controller.isBroadcast,
      parentMessageId: locationMessage.parentMessageId,
    );
  }

  void sendContact({
    required String conversationId,
    required String userId,
    required List<Contact> contacts,
  }) async {
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    var contactMessage = IsmChatMessageModel(
      body: IsmChatStrings.contact,
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.contact,
      deliveredToAll: false,
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
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      metaData: IsmChatMetaData(
        messageSentAt: sentAt,
        contacts: contacts
            .map(
              (e) => IsmChatContactMetaDatModel(
                contactId: e.id,
                contactName: e.displayName,
                contactImageUrl: e.photo != null ? e.photo.toString() : '',
                contactIdentifier: GetPlatform.isAndroid
                    ? e.phones.first.normalizedNumber
                    : e.phones.first.number,
              ),
            )
            .toList(),
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.contact,
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

    _controller.messages.add(contactMessage);
    _controller.isreplying = false;

    if (!_controller.isBroadcast) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(contactMessage, IsmChatDbBox.pending);
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    sendMessage(
      metaData: contactMessage.metaData,
      deviceId: contactMessage.deviceId ?? '',
      body: contactMessage.body,
      customType: contactMessage.customType?.value ?? '',
      createdAt: contactMessage.sentAt,
      conversationId: contactMessage.conversationId ?? '',
      messageType: contactMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentContact,
      notificationTitle: notificationTitle,
      isBroadcast: _controller.isBroadcast,
      parentMessageId: contactMessage.parentMessageId,
    );
  }

  void sendTextMessage({
    required String conversationId,
    required String userId,
    bool pushNotifications = true,
  }) async {
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    var sentAt = DateTime.now().millisecondsSinceEpoch;
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
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.text,
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

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';

    sendMessage(
      isBroadcast: _controller.isBroadcast,
      metaData: textMessage.metaData,
      deviceId: textMessage.deviceId ?? '',
      body: textMessage.body,
      customType: textMessage.customType?.value ?? '',
      createdAt: sentAt,
      parentMessageId: textMessage.parentMessageId,
      conversationId: textMessage.conversationId ?? '',
      messageType: textMessage.messageType?.value ?? 0,
      notificationBody: textMessage.body,
      notificationTitle: notificationTitle,
      mentionedUsers:
          _controller.userMentionedList.map((e) => e.toMap()).toList(),
      sendPushNotification: pushNotifications,
    );
  }

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
        var attachment = [
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
        ];
        attachment.map((e) => e.removeWhere((key, value) => key == 'bytes'));

        sendMessage(
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

  Future<void> addReacton({required Reaction reaction}) async {
    if (reaction.messageId.isEmpty) {
      return;
    }
    var response = await _controller.viewModel.addReacton(reaction: reaction);
    if (response != null && !response.hasError) {
      await _controller.conversationController.getChatConversations();
    }
  }

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
  }) async {
    metaData = metaData?.copyWith(customType: {'broadcastMessage': true});
    var response = await _controller.viewModel.sendBroadcastMessage(
      showInConversation: true,
      notifyOnCompletion: false,
      hideNewConversationsForSender: false,
      sendPushForNewConversationCreated: false,
      groupcastId: groupcastId,
      messageType: messageType,
      encrypted: true,
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
        messages.messageId = createdAt.toString();
        messages.deliveredToAll = false;
        messages.readByAll = false;
        messages.isUploading = false;
        _controller.messages[x] = messages;
      }
    }
  }

  void sendAboutTextMessage({
    required String conversationId,
    required String userId,
    required OutSideMessage? outSideMessage,
    bool pushNotifications = true,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isBroadcast) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        isGroup: _controller.conversation?.isCreateGroupFromOutSide ?? false,
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
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    var aboutTextMessage = IsmChatMessageModel(
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
    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    sendMessage(
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

  Future<String> createConversation({
    required String conversationId,
    String? userId,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper
        ?.getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && _controller.isBroadcast == false) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        isGroup: _controller.conversation?.isCreateGroupFromOutSide ?? false,
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
      unawaited(
        _controller.getConverstaionDetails(),
      );
    } else if (_controller.isBroadcast && _controller.messages.isEmpty) {
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
    }
    return conversationId;
  }
}
