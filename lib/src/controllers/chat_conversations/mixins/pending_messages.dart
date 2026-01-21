part of '../chat_conversations_controller.dart';

/// Pending messages mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to sending pending messages that were
/// stored locally when the device was offline.
mixin IsmChatConversationsPendingMessagesMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Sends any pending messages stored in the local database.
  ///
  /// `conversationId`: The ID of the conversation to send pending messages for.
  void sendPendingMessgae({String conversationId = ''}) async {
    var messages = IsmChatMessages.from({});

    if (conversationId.isEmpty) {
      final pendingMessages =
          await IsmChatConfig.dbWrapper?.getAllPendingMessages();

      messages.addAll(pendingMessages ?? {});
    } else {
      messages = await IsmChatConfig.dbWrapper
              ?.getMessage(conversationId, IsmChatDbBox.pending) ??
          {};
    }
    if (messages.isEmpty) {
      return;
    }
    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.userDetails?.userName ??
            '';

    for (final x in messages.values) {
      List<Map<String, dynamic>>? attachments;
      if ([
        IsmChatCustomMessageType.image,
        IsmChatCustomMessageType.audio,
        IsmChatCustomMessageType.video,
        IsmChatCustomMessageType.file
      ].contains(x.customType)) {
        final attachment = x.attachments?.first;
        final bytes = File(attachment?.mediaUrl ?? '').readAsBytesSync();
        PresignedUrlModel? presignedUrlModel;
        presignedUrlModel = await _controller.commonController.postMediaUrl(
          conversationId: x.conversationId ?? '',
          nameWithExtension: attachment?.name ?? '',
          mediaType: attachment?.attachmentType?.value ?? 0,
          mediaId: attachment?.mediaId ?? '',
          isLoading: false,
          bytes: bytes,
        );

        var mediaUrlPath = '';
        if (presignedUrlModel != null) {
          var response = await _controller.commonController.updatePresignedUrl(
            presignedUrl: presignedUrlModel.mediaPresignedUrl,
            bytes: bytes,
            isLoading: false,
          );
          if (response == 200) {
            mediaUrlPath = presignedUrlModel.mediaUrl ?? '';
          }
        }
        var thumbnailUrlPath = '';
        if (IsmChatCustomMessageType.video == x.customType) {
          PresignedUrlModel? presignedUrlModel;
          final nameWithExtension = attachment?.thumbnailUrl?.split('/').last;
          final bytes = File(attachment?.thumbnailUrl ?? '').readAsBytesSync();
          presignedUrlModel = await _controller.commonController.postMediaUrl(
            conversationId: x.conversationId ?? '',
            nameWithExtension: nameWithExtension ?? '',
            mediaType: 0,
            mediaId: DateTime.now().millisecondsSinceEpoch.toString(),
            isLoading: false,
            bytes: bytes,
          );
          if (presignedUrlModel != null) {
            final response = await _controller.commonController.updatePresignedUrl(
              presignedUrl: presignedUrlModel.thumbnailPresignedUrl,
              bytes: bytes,
              isLoading: false,
            );
            if (response == 200) {
              thumbnailUrlPath = presignedUrlModel.thumbnailUrl ?? '';
            }
          }
        }
        if (mediaUrlPath.isNotEmpty) {
          attachments = [
            {
              'thumbnailUrl': IsmChatCustomMessageType.video == x.customType
                  ? thumbnailUrlPath
                  : mediaUrlPath,
              'size': attachment?.size,
              'name': attachment?.name,
              'mimeType': attachment?.mimeType,
              'mediaUrl': mediaUrlPath,
              'mediaId': attachment?.mediaId,
              'extension': attachment?.extension,
              'attachmentType': attachment?.attachmentType?.value,
            }
          ];
        }
      }
      final isMessageSent = await _controller.commonController.sendMessage(
        showInConversation: true,
        encrypted: x.customType == IsmChatCustomMessageType.text
            ? (IsmChatConfig.messageEncrypted ?? false)
            : false,
        events: {'updateUnreadCount': true, 'sendPushNotification': true},
        attachments: attachments,
        mentionedUsers: x.mentionedUsers?.map((e) => e.toMap()).toList(),
        metaData: x.metaData,
        messageType: x.messageType?.value ?? 0,
        customType: x.customType?.name ?? '',
        parentMessageId: x.parentMessageId,
        deviceId: x.deviceId ?? '',
        conversationId: x.conversationId ?? '',
        notificationBody: x.body,
        notificationTitle: notificationTitle,
        body: x.body,
        createdAt: x.sentAt,
        isBroadcast: IsmChatUtility.chatPageControllerRegistered
            ? IsmChatUtility.chatPageController.isBroadcast
            : false,
      );
      if (isMessageSent && IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (!controller.isBroadcast) {
          controller.didReactedLast = false;
          await controller.getMessagesFromDB(conversationId);
        }
      } else if (isMessageSent) {
        await _controller.getChatConversations();
      }
    }
  }
}

