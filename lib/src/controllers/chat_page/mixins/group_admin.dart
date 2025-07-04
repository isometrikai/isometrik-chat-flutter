part of '../chat_page_controller.dart';

mixin IsmChatGroupAdminMixin on GetxController {
  IsmChatPageController get _controller => IsmChatUtility.chatPageController;

  /// This variable use for get all method and varibles from IsmChatCommonController
  IsmChatCommonController get _commonController =>
      Get.find<IsmChatCommonController>();

  /// Add members to a conversation
  Future<void> addMembers(
      {required List<String> memberIds, bool isLoading = false}) async {
    final conversationId = _controller.conversation?.conversationId ?? '';
    final response = await _controller.viewModel.addMembers(
        memberList: memberIds,
        conversationId: conversationId,
        isLoading: isLoading);
    if (response?.hasError ?? true) {
      return;
    }
    await _controller.getConverstaionDetails(
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
    final response = await _controller.viewModel.changeGroupTitle(
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
    final response = await _controller.viewModel.changeGroupProfile(
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
    final response = await _controller.viewModel.removeMember(
      conversationId: _controller.conversation?.conversationId ?? '',
      userId: userId,
    );

    if (response?.hasError ?? true) {
      return;
    }
    await _controller.getConverstaionDetails(
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

    final response = await _controller.viewModel.getEligibleMembers(
        conversationId: conversationId,
        isLoading: isLoading,
        limit: limit,
        skip: _controller.groupEligibleUser.length.pagination());
    if (response == null) {
      return;
    }
    final users = response;
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

    _commonController.handleSorSelectedMembers(_controller.groupEligibleUser);
  }

  /// Remove members from conversation
  Future<bool> leaveConversation(String conversationId) async {
    final response =
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
    final response = await _controller.viewModel.makeAdmin(
        memberId: memberId,
        conversationId: _controller.conversation?.conversationId ?? '');
    if (response?.hasError ?? true) {
      return;
    }
    if (updateConversation) {
      IsmChatUtility.showToast('You has made $userName a admin of this group',
          timeOutInSec: 2);
      await _controller.getConverstaionDetails(
        isLoading: false,
      );
    }
  }

  ///Remove member as admin from conversation
  Future<void> removeAdmin(String memberId, String userName) async {
    final response = await _controller.viewModel.removeAdmin(
      conversationId: _controller.conversation?.conversationId ?? '',
      memberId: memberId,
    );

    if (response?.hasError ?? true) {
      return;
    }
    IsmChatUtility.showToast('You has removed $userName a admin of this group',
        timeOutInSec: 2);
    await _controller.getConverstaionDetails(
      isLoading: false,
    );
  }
}
