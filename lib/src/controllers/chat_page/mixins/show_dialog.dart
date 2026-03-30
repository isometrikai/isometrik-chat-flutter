part of '../chat_page_controller.dart';

mixin IsmChatShowDialogMixin on GetxController {
  /// Gets the controller instance.
  ///
  /// This getter attempts to use the current instance (this) first,
  /// and falls back to GetX lookup if needed. This prevents errors
  /// when the controller is accessed before it's fully registered in GetX.
  IsmChatPageController get _controller {
    // If this is already an IsmChatPageController, use it directly
    // This prevents the "controller not found" error during initialization
    if (this is IsmChatPageController) {
      return this as IsmChatPageController;
    }
    // Fallback to GetX lookup for cases where mixin might be used elsewhere
    return IsmChatUtility.chatPageController;
  }

  void showDialogForClearChatAndDeleteGroup(
      {bool isGroupDelete = false}) async {
    if (!isGroupDelete) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title: IsmChatStrings.clearAllMessages,
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
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
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
      IsmChatRoute.goBack();
    }
  }

  /// function to show dialog for changing the group title
  void showDialogForChangeGroupTitle() async {
    _controller.groupTitleController.text =
        _controller.conversation?.chatName ?? '';
    await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
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
      await IsmChatContextWidget.showBottomsheetContext(
        content: const ProfileChange(),
        isDismissible: true,
        elevation: 0,
        backgroundColor: IsmChatColors.transparent,
      );
    }
  }

  void showDialogForBlockUnBlockUser(
    bool userBlockOrNot, [
    bool includeMembers = false,
  ]) async {
    await IsmChatContextWidget.showDialogContext(
      content: IsmChatAlertDialogBox(
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
                    isLoading: true,
                    userBlockOrNot: userBlockOrNot,
                  )
                : _controller.blockUser(
                    opponentId:
                        _controller.conversation?.opponentDetails?.userId ?? '',
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
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
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
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatAlertDialogBox(
          title: IsmChatStrings.cannotBlock,
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
  }

  Future<void> showDialogForMessageDelete(IsmChatMessageModel message,
      {bool fromMediaPrivew = false}) async {
    // If user taps delete from the focus menu on a media tile (image/video),
    // delete must affect the whole grouped media grid, not only the first tile.
    final groupedMediaMessages = _getGroupedMediaMessagesForDeletion(message);

    if (message.sentByMe) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title: IsmChatStrings.deleteMessage,
          actionLabels: const [
            IsmChatStrings.deleteForEvery,
            IsmChatStrings.deleteForMe,
          ],
          callbackActions: [
            () => _controller.deleteMessageForEveryone(
                  _toUniqueMessageMap(groupedMediaMessages),
                ),
            () => _controller.deleteMessageForMe(
                  _toUniqueMessageMap(groupedMediaMessages),
                ),
          ],
        ),
      );
      if (fromMediaPrivew) IsmChatRoute.goBack();
    } else {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title:
              '${IsmChatStrings.deleteFromUser} ${_controller.conversation?.opponentDetails?.userName}',
          actionLabels: const [IsmChatStrings.deleteForMe],
          callbackActions: [
            () => _controller.deleteMessageForMe(
                  _toUniqueMessageMap(groupedMediaMessages),
                ),
          ],
        ),
      );
      if (fromMediaPrivew) IsmChatRoute.goBack();
    }
  }

  /// Groups media messages (image/video) so actions like delete
  /// apply to the whole media grid batch.
  List<IsmChatMessageModel> _getGroupedMediaMessagesForDeletion(
    IsmChatMessageModel message,
  ) {
    final isImage = message.customType == IsmChatCustomMessageType.image;
    final isVideo = message.customType == IsmChatCustomMessageType.video;
    if (!isImage && !isVideo) {
      return [message];
    }

    final allMessages = _controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();
    if (allMessages.isEmpty) return [message];

    // Match the clicked message reliably (avoid `message.key` collisions).
    int currentIndex = allMessages.indexWhere((m) {
      final msgIdA = (m.messageId ?? '').trim();
      final msgIdB = (message.messageId ?? '').trim();
      if (msgIdA.isNotEmpty && msgIdB.isNotEmpty) {
        return msgIdA == msgIdB;
      }

      final attA =
          m.attachments?.isNotEmpty == true ? m.attachments!.first : null;
      final attB = message.attachments?.isNotEmpty == true
          ? message.attachments!.first
          : null;
      return m.sentAt == message.sentAt &&
          m.sentByMe == message.sentByMe &&
          m.customType == message.customType &&
          (attA?.thumbnailUrl ?? '') == (attB?.thumbnailUrl ?? '') &&
          (attA?.mediaUrl ?? '') == (attB?.mediaUrl ?? '');
    });

    if (currentIndex == -1) return [message];

    final currentMessage = allMessages[currentIndex];
    final sentByMe = currentMessage.sentByMe;
    const timeWindow = 10000; // 10 seconds in milliseconds.
    final groupedMessages = <IsmChatMessageModel>[];

    var groupStartIndex = currentIndex;
    for (var i = currentIndex; i >= 0; i--) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;
      if (!msgIsImage && !msgIsVideo) break;
      if (msg.sentByMe != sentByMe) break;

      final timeDiff = (msg.sentAt - currentMessage.sentAt).abs();
      if (timeDiff > timeWindow) break;
      groupStartIndex = i;
    }

    for (var i = groupStartIndex; i < allMessages.length; i++) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;
      if (!msgIsImage && !msgIsVideo) break;
      if (msg.sentByMe != sentByMe) break;

      final timeDiff = (msg.sentAt - allMessages[groupStartIndex].sentAt).abs();
      if (timeDiff > timeWindow && groupedMessages.isNotEmpty) break;
      groupedMessages.add(msg);
    }

    return groupedMessages.length >= 2 ? groupedMessages : [message];
  }

  /// Converts a list of messages into a map with unique keys.
  /// Keys are only for map uniqueness; delete APIs use `messageId`.
  IsmChatMessages _toUniqueMessageMap(List<IsmChatMessageModel> messages) {
    final map = <String, IsmChatMessageModel>{};
    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final messageId = msg.messageId ?? '';
      final uniqueKey = messageId.isNotEmpty ? messageId : '${msg.key}-$i';
      map[uniqueKey] = msg;
    }
    return map;
  }

  void showDialogForDeleteMultipleMessage(bool sentByMe,
      bool messageDeletedForEveryone, IsmChatMessages messages) async {
    final messageCount = messages.length;
    final titleText = messageCount > 1
        ? '${IsmChatStrings.delete} $messageCount ${IsmChatStrings.messages.toLowerCase()} ?'
        : IsmChatStrings.deleteMessage;

    if (sentByMe && !messageDeletedForEveryone) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title: titleText,
          actionLabels: const [
            IsmChatStrings.deleteForEvery,
            IsmChatStrings.deleteForMe,
          ],
          callbackActions: [
            () => _controller.deleteMessageForEveryone(messages),
            () => _controller.deleteMessageForMe(messages),
          ],
          onCancel: () {
            IsmChatRoute.goBack<void>();
            _controller.selectedMessage.clear();
            _controller.isMessageSeleted = false;
          },
        ),
      );
    } else {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title: messageDeletedForEveryone
              ? titleText
              : '${IsmChatStrings.deleteFromUser} ${_controller.conversation?.opponentDetails?.userName}',
          actionLabels: const [IsmChatStrings.deleteForMe],
          callbackActions: [
            () => _controller.deleteMessageForMe(messages),
          ],
          onCancel: () {
            IsmChatRoute.goBack<void>();
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

    // This means chatting is allowed i.e. no one is blocked
    showDialogForBlockUnBlockUser(false, includeMembers);

    // if (_controller.conversation?.isChattingAllowed ?? false) {
    // This means chatting is allowed i.e. no one is blocked
    // showDialogForBlockUnBlockUser(false, includeMembers);
    // return;
    // }

    // This means chatting is not allowed and opponent has blocked the user
    // await IsmChatContextWidget.showDialogContext(
    //   content: const IsmChatAlertDialogBox(
    //     title: IsmChatStrings.cannotBlock,
    //     cancelLabel: 'Okay',
    //   ),
    // );
  }

  Future<void> showDialogExitButton([bool askToLeave = false]) async {
    var adminCount = _controller.groupMembers.where((e) => e.isAdmin).length;
    var isUserAdmin = _controller.groupMembers.any((e) =>
        e.userId == IsmChatConfig.communicationConfig.userConfig.userId &&
        e.isAdmin);
    if (adminCount == 1 && !askToLeave && isUserAdmin) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
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
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
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
