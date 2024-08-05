import 'dart:convert';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatBroadcastRepository {
  final _apiWrapper = IsmChatApiWrapper();

  Future<List<BroadcastModel>?> getBroadcast({
    required List<String> ids,
    required String customType,
    required String searchTag,
    required int sort,
    required int skip,
    required int limit,
    required bool sortByCustomType,
    required bool executionPending,
    bool isloading = false,
  }) async {
    try {
      var response = await _apiWrapper.get(
        IsmChatAPI.chatGroupCasts,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
      );
      if (response.hasError) {
        return null;
      }
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      return (data['groupcasts'] as List)
          .map((e) => BroadcastModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('updateUserDataError $e', st);
    }
    return null;
  }

  Future<IsmChatResponseModel?> deleteBroadcast({
    required String groupcastId,
    bool isloading = false,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.chatGroupCast}?groupcastId=$groupcastId',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
        payload: {},
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('delete broadcast  $e', st);
    }
    return null;
  }

  Future<IsmChatResponseModel?> updateBroadcast({
    required String groupcastId,
    bool isloading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    String? groupcastTitle,
    String? groupcastImageUrl,
    String? customType,
  }) async {
    try {
      final payload = {
        if (!groupcastTitle.isNullOrEmpty) 'groupcastTitle': groupcastTitle,
        if (metaData != null) 'metaData': metaData,
        'groupcastId': groupcastId,
      };
      var response = await _apiWrapper.patch(
        IsmChatAPI.chatGroupCast,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
        payload: payload,
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('update broadcast  $e', st);
    }
    return null;
  }

  Future<BroadcastMemberModel?> getBroadcastMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    List<String>? ids,
    String? searchTag,
    int sort = -1,
  }) async {
    try {
      String? url;
      if (searchTag.isNullOrEmpty) {
        url =
            '${IsmChatAPI.chatGroupCastMember}?groupcastId=$groupcastId&sort=$sort&skip=$skip&limit=$limit';
      } else {
        url =
            '${IsmChatAPI.chatGroupCastMember}?groupcastId=$groupcastId&searchTag=$searchTag&sort=$sort&skip=$skip&limit=$limit';
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
      );
      if (response.hasError) {
        return null;
      }
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return BroadcastMemberModel.fromMap(data);
    } catch (e, st) {
      IsmChatLog.error('broadcast members  $e', st);
    }
    return null;
  }

  Future<IsmChatResponseModel?> deleteBroadcastMember({
    required String groupcastId,
    bool isloading = false,
    required List<String> members,
  }) async {
    try {
      var response = await _apiWrapper.delete(
        '${IsmChatAPI.chatGroupCastMember}?groupcastId=$groupcastId&members=${members.join(',')}',
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
        payload: {},
      );
      if (response.hasError) {
        return null;
      }
      return response;
    } catch (e, st) {
      IsmChatLog.error('delete broadcast member  $e', st);
    }
    return null;
  }

  Future<List<UserDetails>?> getEligibleMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    String? searchTag,
    int sort = 1,
  }) async {
    try {
      String? url;
      if (searchTag.isNullOrEmpty) {
        url =
            '${IsmChatAPI.chatGroupCastEligibleMember}?groupcastId=$groupcastId&sort=$sort&skip=$skip&limit=$limit';
      } else {
        url =
            '${IsmChatAPI.chatGroupCastEligibleMember}?groupcastId=$groupcastId&searchTag=$searchTag&sort=$sort&skip=$skip&limit=$limit';
      }
      var response = await _apiWrapper.get(
        url,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
      );
      if (response.hasError) {
        return null;
      }
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return (data['groupcastEligibleMembers'] as List)
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmChatLog.error('broadcast members  $e', st);
    }
    return null;
  }

  Future<IsmChatResponseModel?> addEligibleMembers({
    required String groupcastId,
    bool isloading = false,
    required List<Map<String, dynamic>> members,
  }) async {
    try {
      final payload = {
        'members': members,
        'groupcastId': groupcastId,
      };
      var response = await _apiWrapper.put(
        IsmChatAPI.chatGroupCastMember,
        headers: IsmChatUtility.tokenCommonHeader(),
        showLoader: isloading,
        payload: payload,
      );
      if (response.hasError) {
        return null;
      }

      return response;
    } catch (e, st) {
      IsmChatLog.error('add broadcast members  $e', st);
    }
    return null;
  }
}
