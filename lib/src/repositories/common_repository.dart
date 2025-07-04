import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCommonRepository {
  final _apiWrapper = IsmChatApiWrapper();

  Future<IsmChatResponseModel?> updatePresignedUrl({
    String? presignedUrl,
    Uint8List? bytes,
    bool isLoading = false,
  }) async {
    try {
      var response = await _apiWrapper.put(
        presignedUrl ?? '',
        payload: bytes,
        headers: {},
        forAwsUpload: true,
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      return response;
    } catch (e, st) {
      IsmChatLog.error('Send Message $e', st);
      return null;
    }
  }

  // get Api for Presigned Url.....
  Future<PresignedUrlModel?> getPresignedUrl({
    required bool isLoading,
    required String userIdentifier,
    required String mediaExtension,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.createPresignedurl}?userIdentifier=$userIdentifier&mediaExtension=$mediaExtension',
        headers: IsmChatUtility.commonHeader(),
        showLoader: isLoading,
      );

      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);
      return PresignedUrlModel.fromMap(data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<({String messageId, IsmChatResponseModel respone})?> sendMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required String notificationBody,
    required String notificationTitle,
    String? parentMessageId,
    IsmChatMetaData? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final payload = {
        'showInConversation': showInConversation,
        'messageType': messageType,
        'encrypted': encrypted,
        'deviceId': deviceId,
        'conversationId': conversationId,
        'body': body,
        'parentMessageId': parentMessageId,
        'metaData': metaData?.toMap(),
        'events': events,
        'customType': customType,
        'attachments': attachments,
        'notificationBody': notificationBody,
        'notificationTitle': notificationTitle,
        'searchableTags': [body],
        'mentionedUsers': mentionedUsers
      }.removeNullValues();

      var response = await _apiWrapper.post(
        IsmChatAPI.sendMessage,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return (messageId: '', respone: response);
      }
      var data = jsonDecode(response.data);
      var messageId = data['messageId'] as String? ?? '';
      return (messageId: messageId, respone: response);
    } catch (e, st) {
      IsmChatLog.error('Send Message $e', st);
      return null;
    }
  }

  Future<(String, IsmChatResponseModel)?> sendPaidWalletMessage({
    required bool showInConversation,
    required int messageType,
    required bool encrypted,
    required String deviceId,
    required String conversationId,
    required String body,
    required String notificationBody,
    required String notificationTitle,
    String? parentMessageId,
    Map<String, dynamic>? metaData,
    List<Map<String, dynamic>>? mentionedUsers,
    Map<String, dynamic>? events,
    String? customType,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final payload = {
        'showInConversation': showInConversation,
        'messageType': messageType,
        'encrypted': encrypted,
        'deviceId': deviceId,
        'conversationId': conversationId,
        'body': body,
        'parentMessageId': parentMessageId,
        'metaData': metaData,
        'events': events,
        'customType': customType,
        'attachments': attachments,
        'notificationBody': notificationBody,
        'notificationTitle': notificationTitle,
        'searchableTags': [body],
        'mentionedUsers': mentionedUsers
      }.removeNullValues();
      var headers = IsmChatUtility.tokenCommonHeader();
      headers.addEntries(
        {'Authorization': IsmChatConfig.paidWalletModel?.authToken ?? ''}
            .entries,
      );
      var response = await _apiWrapper.post(
        IsmChatConfig.paidWalletModel?.apiUrl ?? '',
        payload: payload,
        headers: headers,
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);
      var messageId = data['data']['messageId'] as String? ?? '';
      return (messageId, response);
    } catch (e, st) {
      IsmChatLog.error('sendPaidWalletMessage $e', st);
      return null;
    }
  }

  Future<PresignedUrlModel?> postMediaUrl({
    required String conversationId,
    required String nameWithExtension,
    required int mediaType,
    required String mediaId,
    required bool isLoading,
  }) async {
    try {
      final payload = {
        'conversationId': conversationId,
        'attachments': [
          {
            'nameWithExtension': nameWithExtension,
            'mediaType': mediaType,
            'mediaId': mediaId
          }
        ]
      };
      var response = await _apiWrapper.post(
        IsmChatAPI.presignedUrls,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      var data = jsonDecode(response.data);

      return (data['presignedUrls'] as List)
          .map((e) => PresignedUrlModel.fromMap(e as Map<String, dynamic>))
          .toList()
          .first;
    } catch (e, st) {
      IsmChatLog.error('Media url $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> createConversation({
    required bool typingEvents,
    required bool readEvents,
    required bool pushNotifications,
    required List<String> members,
    required bool isGroup,
    required int conversationType,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    String? conversationTitle,
    String? conversationImageUrl,
    String? customType,
    bool isLoading = false,
  }) async {
    try {
      var payload = {
        'typingEvents': typingEvents,
        'readEvents': readEvents,
        'pushNotifications': pushNotifications,
        'members': members,
        'isGroup': isGroup,
        'conversationType': conversationType,
        'searchableTags': searchableTags,
        'metaData': metaData,
        'customType': customType,
        'conversationTitle': conversationTitle,
        'conversationImageUrl': conversationImageUrl,
      };
      var response = await _apiWrapper.post(IsmChatAPI.chatConversation,
          payload: payload,
          headers: IsmChatUtility.tokenCommonHeader(),
          showLoader: isLoading);
      if (response.hasError) {
        if (response.errorCode.toString().startsWith('4')) {
          var error = (jsonDecode(response.data) as Map)['error'] as String? ??
              'Error in creating conversation';
          await IsmChatUtility.showErrorDialog(
            error,
            onCancel: () {
              IsmChatRoute.goBack();
              IsmChatRoute.goBack();
            },
          );
        }
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Create converstaion $e', st);
      return null;
    }
  }

  Future<List<IsmChatMessageModel>?> getChatMessages({
    required String conversationId,
    int lastMessageTimestamp = 0,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
  }) async {
    try {
      String? url;
      if (searchText != null || searchText?.isNotEmpty == true) {
        url =
            '${IsmChatAPI.chatMessages}?conversationId=$conversationId&searchTag=$searchText&sort=-1&limit=$limit&skip=$skip';
      } else {
        url =
            '${IsmChatAPI.chatMessages}?conversationId=$conversationId&limit=$limit&skip=$skip&lastMessageTimestamp=$lastMessageTimestamp';
      }
      var response = await _apiWrapper.get(url,
          headers: IsmChatUtility.tokenCommonHeader(), showLoader: isLoading);
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);
      return (data['messages'] as List)
          .map((e) => IsmChatMessageModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('GetChatMessages $e, $st');
      return null;
    }
  }
}
