part of '../chat_page_controller.dart';

mixin IsmChatShowDialogMixin on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  void showDialogForClearChatAndDeleteGroup({isGroupDelete = false}) async {
    if (!isGroupDelete) {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.deleteAllMessage,
          actionLabels: const [IsmChatStrings.clearChat],
          callbackActions: [
            () => _controller.clearAllMessages(
                  _controller.conversation?.conversationId ?? '',
                  fromServer: _controller.conversation?.lastMessageDetails
                                  ?.customType ==
                              IsmChatCustomMessageType.removeMember &&
                          _controller
                                  .conversation?.lastMessageDetails?.userId ==
                              IsmChatConfig
                                  .communicationConfig.userConfig.userId
                      ? false
                      : true,
                ),
          ],
        ),
      );
    } else {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.deleteThiGroup,
          actionLabels: const [IsmChatStrings.deleteGroup],
          callbackActions: [
            () => _controller.conversationController.deleteChat(
                  _controller.conversation?.conversationId ?? '',
                  deleteFromServer: false,
                ),
          ],
        ),
      );
      Get.back();
    }
  }

  /// function to show dialog for changing the group title
  void showDialogForChangeGroupTitle() async {
    _controller.groupTitleController.text = _controller.conversation!.chatName;
    await Get.dialog(IsmChatAlertDialogBox(
      title: IsmChatStrings.enterNewGroupTitle,
      content: TextFormField(
        controller: _controller.groupTitleController,
      ),
      actionLabels: const [IsmChatStrings.okay],
      callbackActions: [
        () => _controller.changeGroupTitle(
            conversationTitle: _controller.groupTitleController.text,
            conversationId: _controller.conversation?.conversationId ?? '',
            isLoading: true),
      ],
    ));
  }

  /// function to show dialog for changing the group profile
  Future<void> showDialogForChangeGroupProfile() async {
    if (kIsWeb) {
      await _controller.conversationController
          .ismChangeImage(ImageSource.gallery);
      await _controller.changeGroupProfile(
          conversationImageUrl: _controller.conversationController.profileImage,
          conversationId: _controller.conversation?.conversationId ?? '',
          isLoading: true);
    } else {
      await Get.bottomSheet(
        const ProfileChange(),
        isDismissible: false,
        elevation: 0,
      );
    }
  }

  void showDialogForBlockUnBlockUser(
    bool userBlockOrNot, [
    bool includeMembers = false,
  ]) async {
    await Get.dialog(
      IsmChatAlertDialogBox(
        title: userBlockOrNot
            ? IsmChatStrings.doWantUnBlckUser
            : IsmChatStrings.doWantBlckUser,
        actionLabels: [
          userBlockOrNot ? IsmChatStrings.unblock : IsmChatStrings.block,
        ],
        callbackActions: [
          () {
            userBlockOrNot
                ? _controller.unblockUser(
                    opponentId:
                        _controller.conversation?.opponentDetails?.userId ?? '',
                    includeMembers: includeMembers,
                    isLoading: true,
                    userBlockOrNot: userBlockOrNot,
                  )
                : _controller.blockUser(
                    opponentId:
                        _controller.conversation?.opponentDetails?.userId ?? '',
                    includeMembers: includeMembers,
                    isLoading: true,
                    userBlockOrNot: userBlockOrNot,
                  );
          },
        ],
      ),
    );
  }

  void showDialogCheckBlockUnBlock() async {
    if (_controller.conversation?.isBlockedByMe ?? false) {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.youBlockUser,
          actionLabels: const [IsmChatStrings.unblock],
          callbackActions: [
            () => _controller.unblockUser(
                opponentId:
                    _controller.conversation?.opponentDetails?.userId ?? '',
                isLoading: true,
                userBlockOrNot: true),
          ],
        ),
      );
    } else {
      await Get.dialog(
        const IsmChatAlertDialogBox(
          title: IsmChatStrings.cannotBlock,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  Future<void> showDialogForMessageDelete(IsmChatMessageModel message,
      {bool fromMediaPrivew = false}) async {
    if (message.sentByMe) {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.deleteMessage,
          actionLabels: const [
            IsmChatStrings.deleteForEvery,
            IsmChatStrings.deleteForMe,
          ],
          callbackActions: [
            () => _controller.deleteMessageForEveryone([message]),
            () => _controller.deleteMessageForMe([message]),
          ],
        ),
      );
      if (fromMediaPrivew) Get.back();
    } else {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title:
              '${IsmChatStrings.deleteFromUser} ${_controller.conversation?.opponentDetails?.userName}',
          actionLabels: const [IsmChatStrings.deleteForMe],
          callbackActions: [
            () => _controller.deleteMessageForMe([message]),
          ],
        ),
      );
      if (fromMediaPrivew) Get.back();
    }
  }

  void showDialogForDeleteMultipleMessage(
      bool sentByMe, List<IsmChatMessageModel> messages) async {
    if (sentByMe) {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.deleteMessage,
          actionLabels: const [
            IsmChatStrings.deleteForEvery,
            IsmChatStrings.deleteForMe,
          ],
          callbackActions: [
            () => _controller.deleteMessageForEveryone(messages),
            () => _controller.deleteMessageForMe(messages),
          ],
          onCancel: () {
            Get.back<void>();
            _controller.selectedMessage.clear();
            _controller.isMessageSeleted = false;
          },
        ),
      );
    } else {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title:
              '${IsmChatStrings.deleteFromUser} ${_controller.conversation?.opponentDetails?.userName}',
          actionLabels: const [IsmChatStrings.deleteForMe],
          callbackActions: [
            () => _controller.deleteMessageForMe(messages),
          ],
          onCancel: () {
            Get.back<void>();
            _controller.selectedMessage.clear();
            _controller.isMessageSeleted = false;
          },
        ),
      );
    }
  }

  Future<void> handleBlockUnblock([bool includeMembers = false]) async {
    if (_controller.conversation?.isBlockedByMe ?? false) {
      // This means chatting is not allowed and user has blocked the opponent
      showDialogForBlockUnBlockUser(true, includeMembers);
      return;
    }
    if (_controller.conversation?.isChattingAllowed ?? false) {
      // This means chatting is allowed i.e. no one is blocked
      showDialogForBlockUnBlockUser(false, includeMembers);
      return;
    }

    // This means chatting is not allowed and opponent has blocked the user
    await Get.dialog(
      const IsmChatAlertDialogBox(
        title: IsmChatStrings.cannotBlock,
        cancelLabel: 'Okay',
      ),
    );
  }

  Future<void> showDialogExitButton([bool askToLeave = false]) async {
    var adminCount = _controller.groupMembers.where((e) => e.isAdmin).length;
    var isUserAdmin = _controller.groupMembers.any((e) =>
        e.userId == IsmChatConfig.communicationConfig.userConfig.userId &&
        e.isAdmin);
    if (adminCount == 1 && !askToLeave && isUserAdmin) {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: IsmChatStrings.areYouSure,
          content: const Text(IsmChatStrings.youAreOnlyAdmin),
          contentTextStyle: IsmChatStyles.w400Grey14,
          actionLabels: const [IsmChatStrings.exit],
          callbackActions: [
            () => showDialogExitButton(true),
          ],
          cancelLabel: IsmChatStrings.assignAdmin,
        ),
      );
    } else {
      await Get.dialog(
        IsmChatAlertDialogBox(
          title: 'Exit ${_controller.conversation?.chatName ?? ''}?',
          content: const Text(
            'Only group admins will be notified that you left the group',
          ),
          contentTextStyle: IsmChatStyles.w400Grey14,
          actionLabels: const ['Exit'],
          callbackActions: [
            () async => await _controller.leaveGroup(
                  adminCount: adminCount,
                  isUserAdmin: isUserAdmin,
                )
          ],
        ),
      );
    }
  }
}
