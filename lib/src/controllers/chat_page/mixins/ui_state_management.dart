part of '../chat_page_controller.dart';

/// UI state management mixin for IsmChatPageController.
///
/// This mixin handles UI state toggles, dialogs, and UI-related operations.
mixin IsmChatPageUiStateManagementMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Toggles the emoji board visibility.
  void toggleEmojiBoard([
    bool? showEmoji,
    bool focusKeyboard = true,
  ]) {
    if (showEmoji ?? _controller.showEmojiBoard) {
      if (focusKeyboard) {
        _controller.messageFocusNode.requestFocus();
      }
    } else {
      IsmChatUtility.hideKeyboard();
    }
    _controller.showEmojiBoard = showEmoji ?? !_controller.showEmojiBoard;
  }

  /// Toggles the attachment panel visibility.
  void toggleAttachment() {
    _controller.showAttachment = !_controller.showAttachment;
  }

  /// Handles bottom attachment type selection.
  void onBottomAttachmentTapped(
    IsmChatAttachmentType attachmentType,
  ) async {
    switch (attachmentType) {
      case IsmChatAttachmentType.camera:
        final initialize = await _controller.initializeCamera();
        if (initialize) {
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context)
              ? _controller.isCameraView = true
              : IsmChatRoute.goToRoute(const IsmChatCameraView());
        }

        break;
      case IsmChatAttachmentType.gallery:
        _controller.webMedia.clear();
        _controller.getMedia();
        break;
      case IsmChatAttachmentType.document:
        _controller.sendDocument(
          conversationId: _controller.conversation?.conversationId ?? '',
          userId: _controller.conversation?.opponentDetails?.userId ?? '',
        );
        break;
      case IsmChatAttachmentType.location:
        _controller.textEditingController.clear();
        await IsmChatRoute.goToRoute(const IsmChatLocationWidget());
        break;
      case IsmChatAttachmentType.contact:
        _controller.contactList.clear();
        _controller.contactSelectedList.clear();
        _controller.textEditingController.clear();
        _controller.isSearchSelect = false;
        _controller.isLoadingContact = false;
        if (await IsmChatUtility.requestPermission(Permission.contacts)) {
          unawaited(IsmChatRoute.goToRoute(const IsmChatContactView()));

          var contacts = await FlutterContacts.getContacts(
              withProperties: true, withPhoto: true);
          for (var x in contacts) {
            if (x.phones.isNotEmpty) {
              if (!((x.phones.first.number.contains('@')) &&
                      (x.phones.first.number.contains('.com'))) &&
                  x.displayName.isNotEmpty) {
                final isContactContain = _controller.contactList.any((element) =>
                    element.contact.phones.first.number ==
                    x.phones.first.number);
                if (!isContactContain) {
                  _controller.contactList.add(
                    SelectedContact(isConotactSelected: false, contact: x),
                  );
                }
              }
            }
          }
          _controller.searchContactList = List.from(_controller.contactList);
          if (_controller.contactList.isEmpty) {
            _controller.isLoadingContact = true;
          }
          _controller.commonController.handleSorSelectedContact(_controller.contactList);
        }

        break;
    }
  }

  /// Shows the wallpaper selection dialog/bottom sheet.
  void addWallpaper() async {
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatPageDailog(
          child: ImsChatShowWallpaper(),
        ),
      );
    } else {
      await IsmChatContextWidget.showBottomsheetContext(
        content: const ImsChatShowWallpaper(),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IsmChatDimens.ten),
          ),
        ),
      );
    }
  }

  /// Shows the reaction user list dialog/bottom sheet.
  void showReactionUser(
      {required IsmChatMessageModel message,
      required String reactionType,
      required int index}) async {
    _controller.userReactionList.clear();
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatPageDailog(
          child: ImsChatShowUserReaction(
            message: message,
            reactionType: reactionType,
            index: index,
          ),
        ),
      );
    } else {
      await IsmChatContextWidget.showBottomsheetContext(
        content: ImsChatShowUserReaction(
          message: message,
          reactionType: reactionType,
          index: index,
        ),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
      );
    }
  }

  /// Shows or hides loader for mobile platforms.
  void showCloseLoaderForMoble({bool showLoader = true}) {
    final isMobile = !IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context);
    if (showLoader) {
      if (isMobile) {
        IsmChatUtility.showLoader();
      }
    } else {
      if (isMobile) {
        IsmChatUtility.closeLoader();
      }
    }
  }
}

