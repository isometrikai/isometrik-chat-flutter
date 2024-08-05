import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatBroadcastViewModel {
  IsmChatBroadcastViewModel(this._repository);

  final IsmChatBroadcastRepository _repository;

  Future<List<BroadcastModel>?> getBroadCast({
    List<String>? ids,
    String customType = '',
    String searchTag = '',
    int sort = -1,
    int skip = 0,
    int limit = 20,
    bool sortByCustomType = false,
    bool executionPending = false,
    bool isloading = false,
  }) async =>
      await _repository.getBroadcast(
        ids: ids ?? [],
        customType: customType,
        searchTag: searchTag,
        sort: sort,
        skip: skip,
        limit: limit,
        sortByCustomType: sortByCustomType,
        executionPending: executionPending,
        isloading: isloading,
      );

  Future<bool> deleteBroadcast({
    required String groupcastId,
    bool isloading = false,
  }) async {
    final response = await _repository.deleteBroadcast(
        groupcastId: groupcastId, isloading: isloading);
    if (response != null) {
      return true;
    }
    return false;
  }

  Future<bool> updateBroadcast({
    required String groupcastId,
    bool isloading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    String? groupcastTitle,
    String? groupcastImageUrl,
    String? customType,
  }) async {
    final response = await _repository.updateBroadcast(
      groupcastId: groupcastId,
      customType: customType,
      groupcastImageUrl: groupcastImageUrl,
      groupcastTitle: groupcastTitle,
      isloading: isloading,
      metaData: metaData,
      searchableTags: searchableTags,
    );
    if (response?.errorCode == 200) {
      return true;
    }
    return false;
  }

  Future<BroadcastMemberModel?> getBroadcastMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    List<String>? ids,
    String? searchTag,
    int sort = -1,
  }) async =>
      await _repository.getBroadcastMembers(
        groupcastId: groupcastId,
        ids: ids,
        isloading: isloading,
        limit: limit,
        searchTag: searchTag,
        skip: skip,
        sort: sort,
      );

  Future<IsmChatResponseModel?> deleteBroadcastMember({
    required String groupcastId,
    bool isloading = false,
    required List<String> members,
  }) async =>
      await _repository.deleteBroadcastMember(
        groupcastId: groupcastId,
        members: members,
        isloading: isloading,
      );

  Future<List<UserDetails>?> getEligibleMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    String? searchTag,
    int sort = 1,
  }) async =>
      await _repository.getEligibleMembers(
        groupcastId: groupcastId,
        isloading: isloading,
        limit: limit,
        searchTag: searchTag,
        skip: skip,
        sort: sort,
      );

  Future<IsmChatResponseModel?> addEligibleMembers({
    required String groupcastId,
    bool isloading = false,
    required List<Map<String, dynamic>> members,
  }) async =>
      await _repository.addEligibleMembers(
        groupcastId: groupcastId,
        members: members,
        isloading: isloading,
      );
}
