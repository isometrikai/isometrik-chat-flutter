part of '../chat_page_controller.dart';

/// Mixin for handling document message sending in the chat page controller.
///
/// This mixin provides functionality for sending document (PDF) messages.
/// It depends on:
/// - `createConversation()` from send_message_core mixin
/// - `ismPostMediaUrl()` from send_message_media mixin
mixin IsmChatPageSendMessageDocumentMixin {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Sends a document (PDF) message.
  ///
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  ///
  /// Opens a file picker to select PDF files and sends them as messages.
  /// Note: This method requires `createConversation` and `ismPostMediaUrl`
  /// to be available through other mixins on the controller.
  void sendDocument({
    required String conversationId,
    required String userId,
  }) async {
    if (await IsmChatProperties
            .chatPageProperties.messageAllowedConfig?.isMessgeAllowed
            ?.call(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context,
                IsmChatUtility.chatPageController.conversation!,
                IsmChatCustomMessageType.file,
                _controller.chatInputController.text.trim()) ??
        true) {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result?.files.isNotEmpty ?? false) {
        // Note: createConversation is provided by send_message_core mixin
        conversationId = await _controller.createConversation(
            conversationId: conversationId, userId: userId);
        for (final file in result!.files) {
          await _sendPickedDocumentFile(
            conversationId: conversationId,
            file: file,
          );
        }
      }
    }
  }

  /// Builds and uploads one picked PDF as a chat message.
  Future<void> _sendPickedDocumentFile({
    required String conversationId,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes;
    final sizeMedia = kIsWeb
        ? IsmChatUtility.formatBytes(
            int.parse((bytes?.length ?? 0).toString()),
          )
        : await IsmChatUtility.fileToSize(File(file.path ?? ''));
    if (!sizeMedia.size()) {
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatAlertDialogBox(
          title: IsmChatStrings.youCanNotSend,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
      return;
    }

    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final mediaId = sentAt.toString();
    final bytesForPdf = Uint8List.fromList(bytes ?? []);
    final document = kIsWeb
        ? await PdfDocument.openData(bytesForPdf)
        : await PdfDocument.openFile(file.path ?? '');
    final page = await document.getPage(1);
    final pdfImage = await page.render(
      width: page.width,
      height: page.height,
      backgroundColor: '#ffffff',
    );
    await page.close();
    await document.close();

    final thumbnailBytes = pdfImage?.bytes;
    final thumbnailNameWithExtension = pdfImage?.format.toString();
    final thumbnailMediaId = mediaId;
    final nameWithExtension = file.name;

    final documentMessage = IsmChatMessageModel(
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
          mimeType: file.extension,
          mediaUrl: kIsWeb ? (bytes).toString() : file.path,
          mediaId: mediaId,
          extension: file.extension,
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
        replyMessage: _controller.isreplying
            ? IsmChatReplyMessageModel(
                forMessageType: IsmChatCustomMessageType.file,
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
      ),
    );

    _controller.messages.add(documentMessage);
    unawaited(_controller.scrollDown());
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

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Note: ismPostMediaUrl is provided by send_message_media mixin
    await _controller.ismPostMediaUrl(
      imageAndFile: false,
      bytes: bytes ?? Uint8List(0),
      createdAt: sentAt,
      ismChatChatMessageModel: documentMessage,
      mediaId: mediaId,
      mediaType: IsmChatMediaType.file.value,
      nameWithExtension: nameWithExtension,
      notificationBody: IsmChatStrings.sentDoc,
      notificationTitle: notificationTitle,
      thumbnailNameWithExtension: thumbnailNameWithExtension,
      thumbnailMediaId: thumbnailMediaId,
      thumbnailBytes: thumbnailBytes,
      thumbanilMediaType: IsmChatMediaType.image.value,
    );
  }
}
