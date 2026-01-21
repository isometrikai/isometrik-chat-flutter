part of '../chat_page_controller.dart';

/// Mixin for handling audio message sending in the chat page controller.
///
/// This mixin provides functionality for sending audio messages.
/// It depends on:
/// - `createConversation()` from send_message_core mixin
/// - `ismPostMediaUrl()` from send_message_media mixin
mixin IsmChatPageSendMessageAudioMixin {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Sends an audio message.
  ///
  /// [path] - Path to the audio file (for mobile platforms)
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [webMediaModel] - Web media model (for web platform)
  /// [duration] - Duration of the audio
  ///
  /// Note: This method requires `createConversation` and `ismPostMediaUrl`
  /// to be available through other mixins on the controller.
  void sendAudio({
    String? path,
    required String conversationId,
    required String userId,
    WebMediaModel? webMediaModel,
    Duration? duration,
  }) async {
    // Note: createConversation is provided by send_message_core mixin
    conversationId = await _controller.createConversation(
      conversationId: conversationId,
      userId: userId,
    );
    IsmChatMessageModel? audioMessage;
    String? nameWithExtension;
    Uint8List? bytes;
    String? mediaId;

    String? extension;
    final sentAt = DateTime.now().millisecondsSinceEpoch;
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

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Note: ismPostMediaUrl is provided by send_message_media mixin
    await _controller.ismPostMediaUrl(
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
}
