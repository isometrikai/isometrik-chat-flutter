part of '../chat_page_controller.dart';

mixin IsmChatGroupAdminMixin on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  /// Add members to a conversation
  Future<void> addMembers(
      {required List<String> memberIds, bool isLoading = false}) async {
    var conversationId = _controller.conversation!.conversationId!;
    var response = await _controller.viewModel.addMembers(
        memberList: memberIds,
        conversationId: conversationId,
        isLoading: isLoading);
    if (response?.hasError ?? true) {
      return;
    }
    await _controller.getConverstaionDetails(
      conversationId: conversationId,
      includeMembers: true,
      isLoading: false,
    );
    await _controller.getMessagesFromAPI();
  }

  /// change group title
  Future<void> changeGroupTitle({
    required String conversationTitle,
    required String conversationId,
    required bool isLoading,
  }) async {
    var response = await _controller.viewModel.changeGroupTitle(
      conversationTitle: conversationTitle,
      conversationId: conversationId,
      isLoading: isLoading,
    );
    if (response?.hasError ?? true) {
      return;
    } else {
      _controller.conversation = _controller.conversation
          ?.copyWith(conversationTitle: conversationTitle);
      _controller.update();
      await _controller.getMessagesFromAPI(
          lastMessageTimestamp: _controller.messages.last.sentAt);
      unawaited(_controller.conversationController.getChatConversations());
      IsmChatUtility.showToast('Group title changed successfully!');
    }
  }

  /// change group profile
  Future<void> changeGroupProfile({
    required String conversationImageUrl,
    required String conversationId,
    required bool isLoading,
  }) async {
    var response = await _controller.viewModel.changeGroupProfile(
        conversationImageUrl: conversationImageUrl,
        conversationId: conversationId,
        isLoading: isLoading);
    if (response?.hasError ?? true) {
      return;
    } else {
      _controller.conversation = _controller.conversation
          ?.copyWith(conversationImageUrl: conversationImageUrl);
      _controller.update();
      await _controller.getMessagesFromAPI(
          lastMessageTimestamp: _controller.messages.last.sentAt);
      unawaited(_controller.conversationController.getChatConversations());
      IsmChatUtility.showToast('Group profile changed successfully!');
    }
  }

  ///Remove members from conversation
  Future<void> removeMember(String userId) async {
    var conversationId = _controller.conversation!.conversationId!;
    var response = await _controller.viewModel.removeMember(
      conversationId: conversationId,
      userId: userId,
    );

    if (response?.hasError ?? true) {
      return;
    }
    await _controller.getConverstaionDetails(
      conversationId: conversationId,
      includeMembers: true,
      isLoading: false,
    );
    await _controller.getMessagesFromAPI();
  }

  ///Remove members from conversation
  Future<void> getEligibleMembers(
      {required String conversationId,
      bool isLoading = false,
      int limit = 20,
      int skip = 0}) async {
    if (_controller.canCallCurrentApi) return;
    _controller.canCallCurrentApi = true;

    var response = await _controller.viewModel.getEligibleMembers(
        conversationId: conversationId,
        isLoading: isLoading,
        limit: limit,
        skip: _controller.groupEligibleUser.length.pagination());
    if (response == null) {
      return;
    }
    var users = response;
    _controller.groupEligibleUser.addAll(List.from(users)
        .map((e) => SelectedMembers(
              isUserSelected: false,
              userDetails: e as UserDetails,
              isBlocked: false,
            ))
        .toList());
    _controller.groupEligibleUser.sort((a, b) => a.userDetails.userName
        .toLowerCase()
        .compareTo(b.userDetails.userName.toLowerCase()));
    _controller.groupEligibleUserDuplicate =
        List.from(_controller.groupEligibleUser);
    _controller.canCallCurrentApi = false;
    _handleList(_controller.groupEligibleUser);
  }

  void _handleList(List<SelectedMembers> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      var tag = list[i].userDetails.userName[0].toUpperCase();
      if (RegExp('[A-Z]').hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = '#';
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(_controller.groupEligibleUser);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_controller.groupEligibleUser);
  }

  ///Remove members from conversation
  Future<bool> leaveConversation(String conversationId) async {
    var response =
        await _controller.viewModel.leaveConversation(conversationId, true);

    if (response?.hasError ?? true) {
      return false;
    }
    return true;
  }

  /// make admin
  Future<void> makeAdmin(
    String memberId,
    String userName, [
    bool updateConversation = true,
  ]) async {
    var conversationId = _controller.conversation!.conversationId!;

    var response = await _controller.viewModel
        .makeAdmin(memberId: memberId, conversationId: conversationId);
    if (response?.hasError ?? true) {
      return;
    }
    if (updateConversation) {
      IsmChatUtility.showToast('You has made $userName a admin of this group',
          timeOutInSec: 2);
      await _controller.getConverstaionDetails(
        conversationId: conversationId,
        includeMembers: true,
        isLoading: false,
      );
    }
  }

  ///Remove member as admin from conversation
  Future<void> removeAdmin(String memberId, String userName) async {
    var conversationId = _controller.conversation!.conversationId!;
    var response = await _controller.viewModel.removeAdmin(
      conversationId: conversationId,
      memberId: memberId,
    );

    if (response?.hasError ?? true) {
      return;
    }
    IsmChatUtility.showToast('You has removed $userName a admin of this group',
        timeOutInSec: 2);
    await _controller.getConverstaionDetails(
      conversationId: conversationId,
      includeMembers: true,
      isLoading: false,
    );
  }
}
