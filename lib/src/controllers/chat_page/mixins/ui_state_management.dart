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
        _controller.mediaProcessingGeneration++;
        _controller.isProcessingMedia = false;
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
        // Avoid re-entrancy: if a previous permission/contact fetch is still
        // running, ignore the tap. This prevents the attachment from appearing
        // "stuck" after a failed attempt + back navigation.
        if (_controller.isFetchingContacts) return;

        _controller.isFetchingContacts = true;
        _controller.contactList.clear();
        _controller.contactSelectedList.clear();
        _controller.textEditingController.clear();
        _controller.isSearchSelect = false;
        _controller.isLoadingContact = false; // false => show loader in UI
        try {
          // Prefer flutter_contacts permission flow (plugin requirement on iOS).
          // Fall back to permission_handler for legacy behavior.
          final granted =
              await FlutterContacts.requestPermission(readonly: true) ||
                  await IsmChatUtility.requestPermission(Permission.contacts);
          if (!granted) {
            // If the permission is blocked (user hit "Don't allow" previously),
            // show a guided dialog that takes them to Settings.
            await IsmChatUtility.showSettingsDialogIfPermanentlyDenied(
              Permission.contacts,
              title: IsmChatStrings.contactsPermissionBlockedTitle,
              message: IsmChatStrings.contactsPermissionBlockedMessage,
            );
            return;
          }

          unawaited(IsmChatRoute.goToRoute(const IsmChatContactView()));

          final contacts = await FlutterContacts.getContacts(
            withProperties: true,
            withPhoto: true,
          );
          for (final x in contacts) {
            if (x.phones.isEmpty) continue;
            final number = x.phones.first.number;
            final isEmailLike = number.contains('@') && number.contains('.com');
            if (isEmailLike || x.displayName.isEmpty) continue;

            final isContactContain = _controller.contactList.any(
              (element) => element.contact.phones.first.number == number,
            );
            if (!isContactContain) {
              _controller.contactList.add(
                SelectedContact(isConotactSelected: false, contact: x),
              );
            }
          }
        } catch (e, st) {
          IsmChatLog.error('Contact picker failed: $e', st);
        } finally {
          _controller.searchContactList = List.from(_controller.contactList);
          if (_controller.contactList.isEmpty) {
            // true => show "no contacts" state in contact screen
            _controller.isLoadingContact = true;
          }
          _controller.commonController
              .handleSorSelectedContact(_controller.contactList);
          _controller.isFetchingContacts = false;
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

  /// Opens the same attachment sheet as the default composer paperclip.
  Future<void> openAttachmentPicker(BuildContext context) async {
    if (!(_controller.conversation?.isChattingAllowed == true)) {
      _controller.showDialogCheckBlockUnBlock();
      return;
    }
    if (!(await IsmChatProperties.chatPageProperties.isSendMediaAllowed
            ?.call(context, _controller.conversation) ??
        true)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final attachmentCardTheme =
        IsmChatThemeResolver.attachmentCardFromConfig(context);
    final selectedAttachment = await showModalBottomSheet<IsmChatAttachmentType>(
      context: context,
      builder: (context) => const IsmChatAttachmentCard(),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: attachmentCardTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(IsmChatDimens.twentyFour),
        ),
      ),
    );
    if (selectedAttachment != null) {
      _controller.onBottomAttachmentTapped(selectedAttachment);
    }
  }

  /// Typing + mention handling used by the default field and host composers.
  void handleComposerTextChanged(String text) {
    if (_controller.chatInputController.text != text) {
      _controller.chatInputController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if ((_controller.conversation?.conversationId?.isNotEmpty ?? false) &&
        _controller.conversation?.customType != IsmChatStrings.broadcast) {
      _controller.notifyTyping();
      if (IsmChatProperties.chatPageProperties.features
          .contains(IsmChatFeature.mentionMember)) {
        _controller.showMentionsUserList(text);
      }
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

