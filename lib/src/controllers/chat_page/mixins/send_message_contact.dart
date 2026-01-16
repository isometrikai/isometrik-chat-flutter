import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

import '../chat_page_controller.dart';

/// Mixin for handling contact message sending in the chat page controller.
/// 
/// This mixin provides functionality for sending contact messages.
/// It depends on:
/// - `createConversation()` from send_message_core mixin
/// - `sendMessage()` from send_message_core mixin
mixin IsmChatPageSendMessageContactMixin on IsmChatPageController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this;

  /// Sends a contact message.
  /// 
  /// [conversationId] - ID of the conversation
  /// [userId] - ID of the user
  /// [contacts] - List of contacts to send
  /// 
  /// Note: This method requires `createConversation` and `sendMessage`
  /// to be available through other mixins on the controller.
  void sendContact({
    required String conversationId,
    required String userId,
    required List<Contact> contacts,
  }) async {
    // Note: createConversation is provided by send_message_core mixin
    conversationId = await createConversation(
        conversationId: conversationId, userId: userId);
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final contactMessage = IsmChatMessageModel(
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

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            _controller.conversationController.userDetails?.userName ??
            '';
    // Note: sendMessage is provided by send_message_core mixin
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
}

