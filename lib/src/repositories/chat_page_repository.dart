import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageRepository {
  final _apiWrapper = IsmChatApiWrapper();

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

  Future<List<IsmChatMessageModel>?> getBroadcastMessages({
    required String groupcastId,
    required bool hideNewConversationsForSender,
    required bool sendPushForNewConversationCreated,
    required bool notifyOnCompletion,
    required bool executionFinished,
    int lastMessageTimestamp = 0,
    int limit = 20,
    int skip = 0,
    int sort = -1,
    bool isLoading = false,
    List<String>? ids,
    String? searchText,
    String? messageTypes,
    String? customTypes,
    String? attachmentTypes,
    String? showInConversation,
    String? parentMessageId,
  }) async {
    try {
      String? url;
      if (searchText != null || searchText?.isNotEmpty == true) {
        url =
            '${IsmChatAPI.chatGroupCastMessages}?groupcastId=$groupcastId&searchTag=$searchText&sort=$sort&limit=$limit&skip=$skip';
      } else {
        url =
            '${IsmChatAPI.chatGroupCastMessages}?groupcastId=$groupcastId&sort=$sort&limit=$limit&skip=$skip&lastMessageTimestamp=$lastMessageTimestamp';
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
      IsmChatLog.error('GetBroadcastChatMessages $e, $st');
      return null;
    }
  }

  /// change group title
  Future<IsmChatResponseModel?> changeGroupTitle({
    required String conversationTitle,
    required String conversationId,
    required bool isLoading,
  }) async {
    try {
      var payload = {
        'conversationTitle': conversationTitle,
        'conversationId': conversationId
      };
      var response = await _apiWrapper.patch(
        IsmChatAPI.conversationTitle,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Change group title error  $e', st);
      return null;
    }
  }

  /// change group profile
  Future<IsmChatResponseModel?> changeGroupProfile({
    required String conversationImageUrl,
    required String conversationId,
    required bool isLoading,
  }) async {
    try {
      var payload = {
        'conversationImageUrl': conversationImageUrl,
        'conversationId': conversationId
      };
      var response = await _apiWrapper.patch(
        IsmChatAPI.conversationImage,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Change group profile  $e', st);
      return null;
    }
  }

  Future<void> readMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var payload = {'messageId': messageId, 'conversationId': conversationId};
      var response = await _apiWrapper.put(
        IsmChatAPI.readIndicator,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Read Message $e', st);
    }
  }

  /// Add members to a conversation
  Future<IsmChatResponseModel?> addMembers(
      {required List<String> memberList,
      required String conversationId,
      bool isLoading = false}) async {
    var payload = {'members': memberList, 'conversationId': conversationId};
    try {
      var response = await _apiWrapper.put(
        IsmChatAPI.conversationMembers,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Remove members $e', st);
      return null;
    }
  }

  /// Remove members from a conversation
  Future<IsmChatResponseModel?> removeMembers(
      String conversationId, String userId, bool? isLoading) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.conversationMembers}?conversationId=$conversationId&members=$userId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading ?? false,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Remove members $e', st);
      return null;
    }
  }

  /// Get eligible members to add to a conversation
  Future<List<UserDetails>?> getEligibleMembers({
    required String conversationId,
    bool isLoading = false,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.eligibleMembers}?conversationId=$conversationId&sort=1&limit=$limit&skip=$skip',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      var user = (data['conversationEligibleMembers'] as List)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
      return user;
    } catch (e, st) {
      IsmChatLog.error('Get eligible members $e', st);
      return null;
    }
  }

  /// Leave conversation
  Future<IsmChatResponseModel?> leaveConversation(
      String conversationId, bool? isLoading) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.leaveConversation}?conversationId=$conversationId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading ?? false,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Leave conversation $e', st);
      return null;
    }
  }

  /// Make admin api
  Future<IsmChatResponseModel?> makeAdmin(
      String memberId, String conversationId, bool? isLoading) async {
    var payload = {'memberId': memberId, 'conversationId': conversationId};
    try {
      var response = await _apiWrapper.put(
        IsmChatAPI.conversationAdmin,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading ?? false,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Make admin $e', st);
      return null;
    }
  }

  /// Remove member as admin from a conversation
  Future<IsmChatResponseModel?> removeAdmin(
      String conversationId, String memberId, bool? isLoading) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.conversationAdmin}?conversationId=$conversationId&memberId=$memberId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading ?? false,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Remove member as admin $e', st);
      return null;
    }
  }

  Future<void> notifyTyping({
    required String conversationId,
  }) async {
    try {
      var payload = {'conversationId': conversationId};
      var response = await _apiWrapper.post(
        IsmChatAPI.typingIndicator,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Typing Message $e', st);
    }
  }

  Future<ModelWrapper> getConverstaionDetails(
      {required String conversationId,
      String? ids,
      bool? includeMembers,
      int? membersSkip,
      int? membersLimit,
      bool? isLoading}) async {
    try {
      String? url;
      if (includeMembers == true) {
        url =
            '${IsmChatAPI.conversationDetails}/$conversationId?includeMembers=$includeMembers';
      } else {
        url = '${IsmChatAPI.conversationDetails}/$conversationId';
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading ?? false,
        showDailog: false,
      );

      if (response.hasError) {
        return ModelWrapper(data: null, statusCode: response.errorCode);
      }

      var data = jsonDecode(response.data) as Map<String, dynamic>;
      return ModelWrapper(
          data: IsmChatConversationModel.fromMap(
              data['conversationDetails'] as Map<String, dynamic>),
          statusCode: response.errorCode);
    } catch (e, st) {
      IsmChatLog.error('Chat user Details $e', st);
      return const ModelWrapper(data: null, statusCode: 1000);
    }
  }

  Future<IsmChatResponseModel?> blockUser(
      {required String opponentId, bool isLoading = false}) async {
    try {
      final payload = {'opponentId': opponentId};
      var response = await _apiWrapper.post(IsmChatAPI.blockUser,
          payload: payload,
          headers: IsmChatUtility.tokenCommonHeader(),
          showLoader: isLoading);
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Block user $e', st);
      return null;
    }
  }

  Future<void> readSingleMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var payload = {'messageId': messageId, 'conversationId': conversationId};
      var response = await _apiWrapper.put(
        IsmChatAPI.readIndicator,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Read message $e', st);
    }
  }

  Future<List<UserDetails>?> getMessageDeliverTime({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.deliverStatus}?conversationId=$conversationId&messageId=$messageId',
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);

      if (data['users'] == null) {
        return null;
      }

      return (data['users'] as List<dynamic>)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('Deliver message $e', st);
      return null;
    }
  }

  Future<List<UserDetails>?> getMessageReadTime({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.readStatus}?conversationId=$conversationId&messageId=$messageId',
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);

      if (data['users'] == null) {
        return null;
      }

      return (data['users'] as List<dynamic>)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('Read message $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> deleteMessageForMe({
    required String conversationId,
    required String messageIds,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.deleteMessagesForMe}?conversationId=$conversationId&messageIds=$messageIds',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Delete message $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> deleteMessageForEveryone({
    required String conversationId,
    required String messages,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.deleteMessages}?conversationId=$conversationId&messageIds=$messages',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }

      return response;
    } catch (e, st) {
      IsmChatLog.error('Delete everyone message $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> clearAllMessages({
    required String conversationId,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.chatConversationClear}?conversationId=$conversationId',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return response;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Clear chat $e', st);
      return null;
    }
  }

  Future<void> readAllMessages({
    required String conversationId,
    required int timestamp,
  }) async {
    try {
      var payload = {
        'timestamp': timestamp,
        'conversationId': conversationId,
      };
      var response = await _apiWrapper.put(
        IsmChatAPI.readAllMessages,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return;
      }
    } catch (e, st) {
      IsmChatLog.error('Read all message $e', st);
    }
  }

  Future<IsmChatResponseModel?> addReacton({required Reaction reaction}) async {
    try {
      var response = await _apiWrapper.post(
        IsmChatAPI.reacton,
        payload: reaction.toMap(),
        headers: IsmChatUtility.tokenCommonHeader(),
      );

      if (response.hasError && response.errorCode == 404) {
        await IsmChatUtility.showErrorDialog(
            'You have alreaday added reaction ');
        return null;
      }
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('Add reaction  $e', st);
      return null;
    }
  }

  Future<List<UserDetails>?> getReacton({required Reaction reaction}) async {
    try {
      var response = await _apiWrapper.get(
        '${IsmChatAPI.reacton}/${reaction.reactionType.value}?conversationId=${reaction.conversationId}&messageId=${reaction.messageId}&limit=20&skip=0',
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }

      var data = jsonDecode(response.data);

      if (data['reactions'] == null) {
        return null;
      }

      return (data['reactions'] as List<dynamic>)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('get user reaction  $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> deleteReacton(
      {required Reaction reaction}) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.reacton}/${reaction.reactionType.value}?conversationId=${reaction.conversationId}&messageId=${reaction.messageId}',
        payload: null,
        headers: IsmChatUtility.tokenCommonHeader(),
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('delete reaction  $e', st);
      return null;
    }
  }

  Future<List<IsmChatPrediction>?> getLocation({
    required String latitude,
    required String longitude,
    required String query,
  }) async {
    try {
      var response = await _apiWrapper.get(
        query.trim().isNotEmpty
            ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&name=$query&radius=1000000&key=${IsmChatConfig.communicationConfig.projectConfig.googleApiKey ?? IsmChatConstants.mapAPIKey}'
            : 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=500&key=${IsmChatConfig.communicationConfig.projectConfig.googleApiKey ?? IsmChatConstants.mapAPIKey}',
        headers: {},
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data);
      var latlgn = LatLng(double.parse(latitude), double.parse(longitude));
      var predictionList = (data['results'] as List)
          .map((e) => IsmChatPrediction.fromMap(
                e as Map<String, dynamic>,
                latlng: latlgn,
              ))
          .toList();
      predictionList.sort((a, b) => a.distance!.compareTo(b.distance!));
      return predictionList;
    } catch (e, st) {
      IsmChatLog.error('Location $e', st);
      return null;
    }
  }

  Future<IsmChatResponseModel?> sendBroadcastMessage(
      {required bool showInConversation,
      required bool sendPushForNewConversationCreated,
      required bool notifyOnCompletion,
      required bool hideNewConversationsForSender,
      required String groupcastId,
      required int messageType,
      required bool encrypted,
      required String deviceId,
      required String body,
      required String notificationBody,
      required String notificationTitle,
      List<String>? searchableTags,
      String? parentMessageId,
      IsmChatMetaData? metaData,
      Map<String, dynamic>? events,
      String? customType,
      List<Map<String, dynamic>>? attachments,
      List<Map<String, dynamic>>? mentionedUsers,
      bool isLoading = false}) async {
    try {
      final payload = {
        'showInConversation': showInConversation,
        'sendPushForNewConversationCreated': sendPushForNewConversationCreated,
        'searchableTags': searchableTags,
        'parentMessageId': parentMessageId,
        'notifyOnCompletion': notifyOnCompletion,
        'notificationBody': notificationBody,
        'notificationTitle': notificationTitle,
        'messageType': messageType,
        'metaData': metaData?.toMap(),
        if (!mentionedUsers.isNullOrEmpty) 'mentionedUsers': mentionedUsers,
        'hideNewConversationsForSender': hideNewConversationsForSender,
        'groupcastId': groupcastId,
        'events': events,
        'encrypted': encrypted,
        'deviceId': deviceId,
        'customType': customType,
        'body': body,
        'attachments': attachments,
      };

      var response = await _apiWrapper.post(
        IsmChatAPI.chatGroupCastMessage,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      return response;
    } catch (e, st) {
      IsmChatLog.error('Send broadcast Message $e', st);
      return null;
    }
  }

  Future<String?> createBroadcastConversation({
    bool isLoading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    required String groupcastTitle,
    required String groupcastImageUrl,
    String? customType,
    required List<String> membersId,
  }) async {
    try {
      final members = membersId
          .map(
            (e) => {
              'newConversationTypingEvents': true,
              'newConversationReadEvents': true,
              'newConversationPushNotificationsEvents': true,
              'newConversationMetadata': {},
              'newConversationCustomType': 'Broadcast',
              'memberId': e,
            },
          )
          .toList();
      final payload = {
        'searchableTags': searchableTags,
        'metaData': metaData,
        'members': members,
        'groupcastTitle': groupcastTitle,
        'groupcastImageUrl': groupcastImageUrl,
        'customType': customType,
      };
      var response = await _apiWrapper.post(
        IsmChatAPI.chatGroupCast,
        payload: payload,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isLoading,
      );
      if (response.hasError) {
        return null;
      }

      final data = jsonDecode(response.data) as Map<String, dynamic>;

      return data['groupcastId'] as String;
    } catch (e, st) {
      IsmChatLog.error('Send broadcast Message $e', st);
      return null;
    }
  }
}
