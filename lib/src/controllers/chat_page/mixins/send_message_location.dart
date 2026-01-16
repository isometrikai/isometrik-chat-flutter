import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

import '../chat_page_controller.dart';

/// Mixin for handling location message sending in the chat page controller.
/// 
/// This mixin provides functionality for sending location messages.
/// It depends on:
/// - `createConversation()` from send_message_core mixin
/// - `sendMessage()` from send_message_core mixin
mixin IsmChatPageSendMessageLocationMixin on IsmChatPageController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this;

  /// Sends a location message.
  /// 
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  /// [placeId] - Google Places ID
  /// [locationName] - Name of the location
  /// [locationSubName] - Sub-name/address of the location
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// 
  /// Note: This method requires `createConversation` and `sendMessage`
  /// to be available through other mixins on the controller.
  void sendLocation({
    required double latitude,
    required double longitude,
    required String placeId,
    required String locationName,
    required String locationSubName,
    required String conversationId,
    required String userId,
  }) async {
    // Note: createConversation is provided by send_message_core mixin
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final locationMessage = IsmChatMessageModel(
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

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Note: sendMessage is provided by send_message_core mixin
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
}

