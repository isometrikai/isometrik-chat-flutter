part of '../chat_page_controller.dart';

mixin IsmChatPageSendMessageMixin on GetxController {
  IsmChatPageController get _controller => Get.find<IsmChatPageController>();

  IsmChatConversationsController get conversationController =>
      Get.find<IsmChatConversationsController>();

  IsmChatCommonController get commonController =>
      Get.find<IsmChatCommonController>();

  final _deviceConfig = Get.find<IsmChatDeviceConfig>();

  void sendMessage({
    required int messageType,
    required String deviceId,
    required String conversationId,
    required String body,
    required int createdAt,
    required String notificationBody,
    required String notificationTitle,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    String? customType,
    List<Map<String, dynamic>>? attachments,
    bool isTemporaryChat = false,
    bool sendPushNotification = true,
  }) async {
    if (_controller.conversation?.customType != 'Broadcasting') {
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
        isTemporaryChat: isTemporaryChat,
      );

      if (isMessageSent && !isTemporaryChat) {
        _controller.didReactedLast = false;
        await _controller.getMessagesFromDB(conversationId);
        if (kIsWeb && Responsive.isWeb(Get.context!)) {
          await conversationController.getConversationsFromDB();
        }
      }
    } else {
      if (_controller.conversation?.members?.isNotEmpty == true &&
          (_controller.conversation?.members?.length ?? 0) >= 2) {
        await sendBroadcastMessage(
          userIds: (_controller.conversation?.members ?? [])
              .map((e) => e.userId)
              .toList(),
          showInConversation: true,
          encrypted: true,
          events: {
            'updateUnreadCount': true,
            'sendPushNotification': sendPushNotification
          },
          messageType: messageType,
          deviceId: deviceId,
          body: body,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachments,
          customType: customType,
          isLoading: false,
          metaData: metaData,
          searchableTags: [notificationBody],
          createdAt: createdAt,
        );
      } else {
        await Get.dialog(
          const IsmChatAlertDialogBox(
            title: IsmChatStrings.broadcastAlert,
            cancelLabel: 'Okay',
          ),
        );
      }
    }
    _controller.isMessageSent = false;
  }

  void sendMedia() async {
    var isMaxSize = false;
    for (var x in _controller.listOfAssetsPath) {
      var sizeMedia = await IsmChatUtility.fileToSize(
          File(x.attachmentModel.mediaUrl ?? ''));
      if (sizeMedia.split(' ').last == 'KB') {
        continue;
      }

      if (!sizeMedia.size()) {
        isMaxSize = true;
        break;
      }
    }

    if (isMaxSize == false) {
      Get.back<void>();
      if (await IsmChatProperties
              .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
              ?.call(Get.context!,
                  Get.find<IsmChatPageController>().conversation!) ??
          true) {
        sendPhotoAndVideo();
      }
    } else {
      await Get.dialog(
        const IsmChatAlertDialogBox(
          title: IsmChatStrings.youCanNotSend,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  void sendMediaWeb() async {
    var isMaxSize = false;
    IsmChatUtility.showLoader();
    for (var x in _controller.webMedia) {
      if (!x.dataSize.size()) {
        isMaxSize = true;
        break;
      }
    }
    if (isMaxSize == false) {
      IsmChatUtility.closeLoader();
      Get.back<void>();
      sendPhotoAndVideoForWeb();
    } else {
      IsmChatUtility.closeLoader();
      await Get.dialog(
        const IsmChatAlertDialogBox(
          title: IsmChatStrings.youCanNotSend,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  void sendPhotoAndVideoForWeb() async {
    if (_controller.webMedia.isNotEmpty) {
      IsmChatUtility.showLoader();
      for (var media in _controller.webMedia) {
        if (IsmChatConstants.imageExtensions
            .contains(media.platformFile.extension)) {
          await sendImage(
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            webMediaModel: media,
            caption: media.caption ?? '',
          );
        } else {
          await sendVideo(
            webMediaModel: media,
            isThumbnail: true,
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            caption: media.caption ?? '',
          );
        }
      }
      IsmChatUtility.closeLoader();
      _controller.isCameraView = false;
      _controller.webMedia.clear();
    }
  }

  void sendPhotoAndVideo() async {
    if (_controller.listOfAssetsPath.isNotEmpty) {
      for (var media in _controller.listOfAssetsPath) {
        if (media.attachmentModel.attachmentType == IsmChatMediaType.image) {
          await sendImage(
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            imagePath: File(
              media.attachmentModel.mediaUrl ?? '',
            ),
            caption: media.caption,
          );
        } else {
          await sendVideo(
            caption: media.caption,
            file: File(media.attachmentModel.mediaUrl ?? ''),
            isThumbnail: true,
            thumbnailFiles: File(media.attachmentModel.thumbnailUrl ?? ''),
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
          );
        }
      }
      _controller.listOfAssetsPath.clear();
    }
  }

  void sendAudio(
      {String? path,
      required String conversationId,
      required String userId,
      WebMediaModel? webMediaModel,
      Duration? duration}) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }
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
      deviceId: _controller._deviceConfig.deviceId ?? '',
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

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(audioMessage, IsmChatDbBox.pending);

      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(audioMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
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
      isTemporaryChat: _controller.isTemporaryChat,
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
      allowCompression: true,
      withData: true,
    );

    if (result?.files.isNotEmpty ?? false) {
      final chatConversationResponse = await IsmChatConfig.dbWrapper!
          .getConversation(conversationId: conversationId);
      if (chatConversationResponse == null && !_controller.isTemporaryChat) {
        _controller.conversation =
            await _controller.commonController.createConversation(
                conversation: _controller.conversation!,
                userId: [userId],
                metaData: _controller.conversation?.metaData,
                searchableTags: [
                  IsmChatConfig.communicationConfig.userConfig.userName ??
                      conversationController.userDetails?.userName ??
                      '',
                  _controller.conversation?.chatName ?? ''
                ]);
        conversationId = _controller.conversation?.conversationId ?? '';
        unawaited(
            _controller.getConverstaionDetails(conversationId: conversationId));
      }
      final resultFiles = result?.files ?? [];

      for (var x in resultFiles) {
        var sizeMedia = kIsWeb
            ? IsmChatUtility.formatBytes(
                int.parse((x.bytes?.length ?? 0).toString()),
              )
            : await IsmChatUtility.fileToSize(File(x.path ?? ''));

        bytes = Uint8List.fromList(x.bytes as List<int>);
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
                size: bytes.length,
                name: nameWithExtension,
                mimeType: x.extension,
                mediaUrl: kIsWeb ? (bytes).toString() : x.path,
                mediaId: sentAt.toString(),
                extension: x.extension,
              )
            ],
            deliveredToAll: false,
            messageId: '',
            deviceId: _controller._deviceConfig.deviceId ?? '',
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
          await Get.dialog(
            const IsmChatAlertDialogBox(
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

      if (!_controller.isTemporaryChat) {
        await IsmChatConfig.dbWrapper!
            .saveMessage(documentMessage, IsmChatDbBox.pending);
        if (kIsWeb && Responsive.isWeb(Get.context!)) {
          _controller.updateLastMessagOnCurrentTime(documentMessage);
        }
      }

      var notificationTitle =
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '';
      if (await IsmChatProperties
              .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
              ?.call(Get.context!,
                  Get.find<IsmChatPageController>().conversation!) ??
          true) {
        await ismPostMediaUrl(
          imageAndFile: false,
          bytes: bytes,
          createdAt: sentAt,
          ismChatChatMessageModel: documentMessage,
          mediaId: sentAt.toString(),
          mediaType: IsmChatMediaType.file.value,
          nameWithExtension: nameWithExtension ?? '',
          notificationBody: IsmChatStrings.sentDoc,
          notificationTitle: notificationTitle,
          isTemporaryChat: _controller.isTemporaryChat,
          thumbnailNameWithExtension: thumbnailNameWithExtension,
          thumbnailMediaId: thumbnailMediaId,
          thumbnailBytes: thumbnailBytes,
          thumbanilMediaType: IsmChatMediaType.image.value,
        );
      }
    }
  }

  Future<void> sendVideo({
    File? file,
    bool isThumbnail = false,
    File? thumbnailFiles,
    required String conversationId,
    required String userId,
    WebMediaModel? webMediaModel,
    String? caption,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
              conversation: _controller.conversation!,
              userId: [userId],
              metaData: _controller.conversation?.metaData,
              searchableTags: [
                IsmChatConfig.communicationConfig.userConfig.userName ??
                    conversationController.userDetails?.userName ??
                    '',
                _controller.conversation?.chatName ?? ''
              ]);
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }
    IsmChatMessageModel? videoMessage;
    String? nameWithExtension;
    Uint8List? bytes;
    Uint8List? thumbnailBytes;
    String? thumbnailNameWithExtension;
    String? thumbnailMediaId;
    String? mediaId;

    String? extension;
    File? thumbnailFile;
    MediaInfo? videoCopress;
    var sentAt = DateTime.now().millisecondsSinceEpoch;

    if (webMediaModel == null) {
      IsmChatUtility.showLoader();
      videoCopress = await VideoCompress.compressVideo(file!.path,
          quality: VideoQuality.MediumQuality, includeAudio: true);
      thumbnailFile = isThumbnail
          ? thumbnailFiles!
          : await VideoCompress.getFileThumbnail(file.path,
              quality: 50, // default(100)
              position: -1 // default(-1)
              );
      if (videoCopress != null) {
        IsmChatUtility.closeLoader();
        bytes = videoCopress.file!.readAsBytesSync();
        thumbnailBytes = thumbnailFile.readAsBytesSync();
        thumbnailNameWithExtension = thumbnailFile.path.split('/').last;
        thumbnailMediaId =
            thumbnailNameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
        nameWithExtension = file.path.split('/').last;
        mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
        extension = nameWithExtension.split('.').last;
      }
    } else {
      bytes = webMediaModel.platformFile.bytes;
      thumbnailBytes = webMediaModel.thumbnailBytes;
      thumbnailNameWithExtension = '$sentAt.png';
      thumbnailMediaId = '$sentAt';
      nameWithExtension = webMediaModel.platformFile.name;
      mediaId = '$sentAt';
      extension = webMediaModel.platformFile.extension;
    }

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
            thumbnailUrl: webMediaModel != null
                ? thumbnailBytes.toString()
                : thumbnailFile?.path,
            size: bytes?.length ?? 0,
            name: nameWithExtension,
            mimeType: extension,
            mediaUrl: webMediaModel != null
                ? webMediaModel.platformFile.path
                : videoCopress?.file?.path,
            mediaId: mediaId,
            extension: extension,
          )
        ],
        deliveredToAll: false,
        messageId: '',
        deviceId: _controller._deviceConfig.deviceId ?? '',
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
          captionMessage: caption,
          replyMessage: _controller.isreplying
              ? IsmChatReplyMessageModel(
                  forMessageType: IsmChatCustomMessageType.video,
                  parentMessageMessageType:
                      _controller.replayMessage?.customType,
                  parentMessageInitiator: _controller.replayMessage?.sentByMe,
                  parentMessageBody:
                      _controller.getMessageBody(_controller.replayMessage),
                  parentMessageUserId:
                      _controller.replayMessage?.senderInfo?.userId,
                  parentMessageUserName:
                      _controller.replayMessage?.senderInfo?.userName ?? '',
                )
              : null,
        ));

    _controller.messages.add(videoMessage);
    _controller.isreplying = false;

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(videoMessage, IsmChatDbBox.pending);

      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(videoMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';
    await ismPostMediaUrl(
      imageAndFile: false,
      bytes: bytes,
      createdAt: sentAt,
      ismChatChatMessageModel: videoMessage,
      mediaId: mediaId ?? '',
      mediaType: IsmChatMediaType.video.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: IsmChatStrings.video,
      thumbnailNameWithExtension: thumbnailNameWithExtension,
      thumbnailMediaId: thumbnailMediaId,
      thumbnailBytes: thumbnailBytes,
      thumbanilMediaType: IsmChatMediaType.image.value,
      notificationTitle: notificationTitle,
      isTemporaryChat: _controller.isTemporaryChat,
    );
  }

  Future<void> sendImage({
    required String conversationId,
    required String userId,
    File? imagePath,
    WebMediaModel? webMediaModel,
    String? caption,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }
    IsmChatMessageModel? imageMessage;
    String? nameWithExtension;
    Uint8List? bytes;
    String? mediaId;
    String? extension;
    File? compressedFile;
    var sentAt = DateTime.now().millisecondsSinceEpoch;
    if (webMediaModel == null) {
      compressedFile = await FlutterNativeImage.compressImage(
        imagePath?.path ?? '',
        quality: 60,
        percentage: 70,
      );
      bytes = compressedFile.readAsBytesSync();
      nameWithExtension = compressedFile.path.split('/').last;
      mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
      extension = nameWithExtension.split('.').last;
    } else {
      bytes = webMediaModel.platformFile.bytes;
      nameWithExtension = webMediaModel.platformFile.name;
      mediaId = sentAt.toString();
      extension = webMediaModel.platformFile.extension;
    }

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
          thumbnailUrl:
              kIsWeb ? webMediaModel?.platformFile.path : compressedFile?.path,
          size: kIsWeb ? webMediaModel?.platformFile.size : bytes!.length,
          name: nameWithExtension,
          mimeType: 'image/jpeg',
          mediaUrl:
              kIsWeb ? webMediaModel?.platformFile.path : compressedFile?.path,
          mediaId: mediaId,
          extension: extension,
        )
      ],
      deliveredToAll: false,
      messageId: '',
      deviceId: _controller._deviceConfig.deviceId ?? '',
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
        captionMessage: caption,
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

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(imageMessage, IsmChatDbBox.pending);

      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(imageMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';
    await ismPostMediaUrl(
      bytes: bytes,
      createdAt: sentAt,
      ismChatChatMessageModel: imageMessage,
      mediaId: mediaId,
      mediaType: IsmChatMediaType.image.value,
      nameWithExtension: nameWithExtension ?? '',
      notificationBody: IsmChatStrings.sentImage,
      imageAndFile: true,
      notificationTitle: notificationTitle,
      isTemporaryChat: _controller.isTemporaryChat,
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
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
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
      deviceId: _deviceConfig.deviceId ?? '',
      messageType: IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId: '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      metaData: IsmChatMetaData(
        captionMessage: caption,
      ),
    );

    _controller.messages.add(imageMessage);
    _controller.isreplying = false;
    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(imageMessage, IsmChatDbBox.pending);

      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(imageMessage);
      }
    }
    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';
    sendMessage(
      metaData: imageMessage.metaData,
      deviceId: imageMessage.deviceId ?? '',
      body: imageMessage.body,
      customType: imageMessage.customType?.value,
      createdAt: imageMessage.sentAt,
      conversationId: imageMessage.conversationId ?? '',
      messageType: imageMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentImage,
      notificationTitle: notificationTitle,
      attachments: imageMessage.attachments != null
          ? [imageMessage.attachments!.first.toMap().removeNullValues()]
          : null,
      isTemporaryChat: _controller.isTemporaryChat,
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
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
              conversation: _controller.conversation!,
              userId: [userId],
              metaData: _controller.conversation?.metaData,
              searchableTags: [
                IsmChatConfig.communicationConfig.userConfig.userName ??
                    conversationController.userDetails?.userName ??
                    '',
                _controller.conversation?.chatName ?? ''
              ]);
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }
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
      deviceId: _controller._deviceConfig.deviceId ?? '',
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

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(locationMessage, IsmChatDbBox.pending);

      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(locationMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';
    sendMessage(
      metaData: locationMessage.metaData,
      deviceId: locationMessage.deviceId ?? '',
      body: locationMessage.body,
      customType: locationMessage.customType?.value,
      createdAt: locationMessage.sentAt,
      conversationId: locationMessage.conversationId ?? '',
      messageType: locationMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentLocation,
      notificationTitle: notificationTitle,
      attachments: locationMessage.attachments != null
          ? [locationMessage.attachments!.first.toMap().removeNullValues()]
          : null,
      isTemporaryChat: _controller.isTemporaryChat,
      parentMessageId: locationMessage.parentMessageId,
    );
  }

  void sendContact({
    required String conversationId,
    required String userId,
    required List<Contact> contacts,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );

      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }

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
      deviceId: _controller._deviceConfig.deviceId ?? '',
      metaData: IsmChatMetaData(
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

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(contactMessage, IsmChatDbBox.pending);
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';
    sendMessage(
      metaData: contactMessage.metaData,
      deviceId: contactMessage.deviceId ?? '',
      body: contactMessage.body,
      customType: contactMessage.customType?.value,
      createdAt: contactMessage.sentAt,
      conversationId: contactMessage.conversationId ?? '',
      messageType: contactMessage.messageType?.value ?? 0,
      notificationBody: IsmChatStrings.sentContact,
      notificationTitle: notificationTitle,
      isTemporaryChat: _controller.isTemporaryChat,
      parentMessageId: contactMessage.parentMessageId,
    );
  }

  void sendTextMessage({
    required String conversationId,
    required String userId,
    bool pushNotifications = true,
    required int sentAt,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null && !_controller.isTemporaryChat) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        isGroup: _controller.conversation?.isCreateGroupFromOutSide ?? false,
        userId: [userId],
        metaData: _controller.conversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      conversationId = _controller.conversation?.conversationId ?? '';
      unawaited(
          _controller.getConverstaionDetails(conversationId: conversationId));
    }

    var textMessage = IsmChatMessageModel(
      body: _controller.chatInputController.text.trim(),
      conversationId: conversationId,
      senderInfo: _controller.currentUser,
      customType: _controller.isreplying
          ? IsmChatCustomMessageType.reply
          : IsmChatCustomMessageType.text,
      deliveredToAll: false,
      deviceId: _controller._deviceConfig.deviceId ?? '',
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

    if (!_controller.isTemporaryChat) {
      await IsmChatConfig.dbWrapper!
          .saveMessage(textMessage, IsmChatDbBox.pending);
      if (kIsWeb && Responsive.isWeb(Get.context!)) {
        _controller.updateLastMessagOnCurrentTime(textMessage);
      }
    }

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            conversationController.userDetails?.userName ??
            '';

    sendMessage(
      isTemporaryChat: _controller.isTemporaryChat,
      metaData: textMessage.metaData,
      deviceId: textMessage.deviceId ?? '',
      body: textMessage.body,
      customType: textMessage.customType?.value,
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
    required Uint8List? bytes,
    required bool? imageAndFile,
    required String mediaId,
    String? thumbnailNameWithExtension,
    String? thumbnailMediaId,
    int? thumbanilMediaType,
    Uint8List? thumbnailBytes,
    bool isTemporaryChat = false,
  }) async {
    try {
      PresignedUrlModel? presignedUrlModel;
      if (_controller.isTemporaryChat) {
        presignedUrlModel = await _controller.commonController.getPresignedUrl(
          isLoading: false,
          mediaExtension:
              ismChatChatMessageModel.attachments?.first.extension ?? '',
          userIdentifier:
              IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
        );
      } else {
        presignedUrlModel = await commonController.postMediaUrl(
          conversationId: ismChatChatMessageModel.conversationId ?? '',
          nameWithExtension: nameWithExtension,
          mediaType: mediaType,
          mediaId: mediaId,
        );
      }

      var mediaUrlPath = '';
      var thumbnailUrlPath = '';
      if (presignedUrlModel != null) {
        var mediaUrl = await commonController.updatePresignedUrl(
          presignedUrl: _controller.isTemporaryChat
              ? presignedUrlModel.presignedUrl
              : presignedUrlModel.mediaPresignedUrl,
          bytes: bytes,
          isLoading: false,
        );
        if (mediaUrl == 200) {
          mediaUrlPath = presignedUrlModel.mediaUrl ?? '';
          mediaId = _controller.isTemporaryChat
              ? mediaId
              : presignedUrlModel.mediaId ?? '';
        }
      }
      if (!imageAndFile!) {
        PresignedUrlModel? presignedUrlModel;
        if (_controller.isTemporaryChat) {
          presignedUrlModel =
              await _controller.commonController.getPresignedUrl(
            isLoading: false,
            mediaExtension: thumbnailNameWithExtension?.split('.').last ?? '',
            userIdentifier:
                IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
          );
        } else {
          presignedUrlModel = await commonController.postMediaUrl(
            conversationId: ismChatChatMessageModel.conversationId ?? '',
            nameWithExtension: thumbnailNameWithExtension ?? '',
            mediaType: thumbanilMediaType ?? 0,
            mediaId: thumbnailMediaId ?? '',
          );
        }

        if (presignedUrlModel != null) {
          var mediaUrl = await commonController.updatePresignedUrl(
            presignedUrl: _controller.isTemporaryChat
                ? presignedUrlModel.presignedUrl
                : presignedUrlModel.thumbnailPresignedUrl,
            bytes: thumbnailBytes,
            isLoading: false,
          );
          if (mediaUrl == 200) {
            thumbnailUrlPath = _controller.isTemporaryChat
                ? presignedUrlModel.mediaUrl ?? ''
                : presignedUrlModel.thumbnailUrl ?? '';
          }
        }
      }
      if (mediaUrlPath.isNotEmpty) {
        var attachment = [
          AttachmentModel(
            thumbnailUrl: !imageAndFile ? thumbnailUrlPath : mediaUrlPath,
            size: ismChatChatMessageModel.attachments?.first.size ?? 0,
            name: ismChatChatMessageModel.attachments?.first.name,
            mimeType: ismChatChatMessageModel.attachments?.first.mimeType,
            mediaUrl: mediaUrlPath,
            mediaId: mediaId,
            extension: ismChatChatMessageModel.attachments?.first.extension,
            attachmentType:
                ismChatChatMessageModel.attachments?.first.attachmentType,
          ).toMap().removeNullValues()
        ];

        sendMessage(
          body: ismChatChatMessageModel.body,
          conversationId: ismChatChatMessageModel.conversationId!,
          createdAt: createdAt,
          deviceId: ismChatChatMessageModel.deviceId ?? '',
          messageType: ismChatChatMessageModel.messageType?.value ?? 0,
          notificationBody: notificationBody,
          notificationTitle: notificationTitle,
          attachments: attachment,
          customType: ismChatChatMessageModel.customType?.value,
          metaData: ismChatChatMessageModel.metaData,
          isTemporaryChat: isTemporaryChat,
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

  Future<void> sendBroadcastMessage(
      {required List<String> userIds,
      required bool showInConversation,
      required int messageType,
      required bool encrypted,
      required String deviceId,
      required String body,
      required String notificationBody,
      required String notificationTitle,
      required int createdAt,
      List<String>? searchableTags,
      IsmChatMetaData? metaData,
      Map<String, dynamic>? events,
      String? customType,
      List<Map<String, dynamic>>? attachments,
      bool isLoading = false}) async {
    var response = await _controller.viewModel.sendBroadcastMessage(
      attachments: attachments,
      customType: customType,
      events: events,
      metaData: metaData,
      searchableTags: searchableTags,
      userIds: userIds,
      showInConversation: true,
      messageType: 0,
      encrypted: true,
      deviceId: deviceId,
      body: body,
      notificationBody: notificationBody,
      notificationTitle: notificationTitle,
      isLoading: isLoading,
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
}
