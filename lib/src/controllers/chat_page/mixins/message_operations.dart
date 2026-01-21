part of '../chat_page_controller.dart';

/// Message operations mixin for IsmChatPageController.
///
/// This mixin handles message selection, overlay display, reply functionality,
/// media preview, and message information operations.
mixin IsmChatPageMessageOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Handles reply tap on a message.
  void onReplyTap(IsmChatMessageModel message) {
    _controller.isreplying = true;
    _controller.replayMessage = message;
    _controller.messageFocusNode.requestFocus();
  }

  /// Handles menu item selection for a message.
  void onMenuItemSelected(
    IsmChatFocusMenuType menuType,
    IsmChatMessageModel message,
    BuildContext context,
  ) async {
    switch (menuType) {
      case IsmChatFocusMenuType.info:
        await _controller.getMessageInformation(message);

        break;
      case IsmChatFocusMenuType.reply:
        _controller.onReplyTap(message);
        break;
      case IsmChatFocusMenuType.forward:
        _controller.conversationController.forwardedList.clear();

        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          await IsmChatContextWidget.showDialogContext(
            content: IsmChatPageDailog(
              child: IsmChatForwardView(
                message: message,
                conversation: _controller.conversation!,
              ),
            ),
          );
        } else {
          await IsmChatRoute.goToRoute(IsmChatForwardView(
            message: message,
            conversation: _controller.conversation!,
          ));
        }

        break;
      case IsmChatFocusMenuType.copy:
        await Clipboard.setData(ClipboardData(text: message.body));
        IsmChatUtility.showToast('Message copied');
        break;
      case IsmChatFocusMenuType.delete:
        await _controller.showDialogForMessageDelete(message);
        break;
      case IsmChatFocusMenuType.selectMessage:
        _controller.selectedMessage.clear();
        _controller.isMessageSeleted = true;
        _controller.selectedMessage.add(message);
        break;
    }
  }

  /// Handles message selection/deselection.
  void onMessageSelect(IsmChatMessageModel ismChatChatMessageModel) {
    if (_controller.isMessageSeleted) {
      if (_controller.selectedMessage.contains(ismChatChatMessageModel)) {
        _controller.selectedMessage.removeWhere(
            (e) => e.messageId == ismChatChatMessageModel.messageId);
      } else {
        _controller.selectedMessage.add(ismChatChatMessageModel);
      }
      if (_controller.selectedMessage.isEmpty) {
        _controller.isMessageSeleted = false;
      }
    }
  }

  /// Shows overlay for message focus menu (mobile).
  Future<void> showOverlay(
    BuildContext context,
    IsmChatMessageModel message,
  ) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondary) {
          animation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          );

          return IsmChatFocusMenu(
            message,
            animation: animation,
          );
        },
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: IsmChatConstants.transitionDuration,
        reverseTransitionDuration: IsmChatConstants.transitionDuration,
      ),
    );
  }

  /// Shows overlay for message focus menu (web).
  Future<void> showOverlayWeb(
    BuildContext context,
    IsmChatMessageModel message,
    Animation<double> animation,
  ) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    // Get hight of Overlay widget which is rendor on message tap
    var overlayHeight = message.focusMenuList.length * IsmChatDimens.forty +
        (IsmChatProperties.chatPageProperties.features
                .contains(IsmChatFeature.reaction)
            ? IsmChatDimens.percentHeight(.1)
            : 0);

    var isOverFlowing =
        (overlayHeight + offset.dy) > (IsmChatDimens.percentHeight(1));
    var topPosition = offset.dy;
    if (isOverFlowing) {
      topPosition = (IsmChatDimens.percentHeight(1) - overlayHeight) -
          IsmChatDimens.twenty;
    }
    OverlayState? overlayState = Overlay.of(context);
    _controller.messageHoldOverlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: message.sentByMe ? null : offset.dx + size.width - 5,
        right: message.sentByMe ? 0 + size.width + 5 : null,
        top: topPosition.isNegative
            ? IsmChatProperties.chatPageProperties.header?.height?.call(
                    IsmChatConfig.kNavigatorKey.currentContext ??
                        IsmChatConfig.context,
                    IsmChatUtility.chatPageController.conversation!) ??
                IsmChatDimens.appBarHeight
            : topPosition,
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              );
              return IsmChatFocusMenu(
                message,
                animation: animation,
              );
            },
          ),
        ),
      ),
    );
    overlayState.insert(_controller.messageHoldOverlayEntry!);
  }

  /// Gets the display body text for a reply message.
  String getMessageBody(IsmChatMessageModel? replayMessage) {
    if (replayMessage?.customType == IsmChatCustomMessageType.location) {
      return IsmChatStrings.location;
    } else if (replayMessage?.customType == IsmChatCustomMessageType.contact) {
      return IsmChatStrings.contact;
    } else if (replayMessage?.customType ==
        IsmChatCustomMessageType.oneToOneCall) {
      return (replayMessage?.callDurations?.length != 1 ||
              replayMessage?.action == IsmChatActionEvents.meetingCreated.name)
          ? '${replayMessage?.meetingType == 0 ? 'Voice' : 'Video'} call'
          : 'Missed ${replayMessage?.meetingType == 0 ? 'voice' : 'video'} call';
    } else {
      return replayMessage?.body ?? '';
    }
  }

  /// Gets the parent message URL for display in reply preview.
  String? getParentMessageUrl(IsmChatMessageModel? replayMessage) {
    if (replayMessage == null) return null;
    final customType = replayMessage.customType;
    switch (customType) {
      case IsmChatCustomMessageType.audio:
      case IsmChatCustomMessageType.file:
        return replayMessage.attachments?.first.name;
      case IsmChatCustomMessageType.contact:
        return replayMessage.metaData?.contacts?.first.contactIdentifier;
      case IsmChatCustomMessageType.location:
      case IsmChatCustomMessageType.image:
        return replayMessage.attachments?.first.mediaUrl;
      case IsmChatCustomMessageType.video:
        return replayMessage.attachments?.first.thumbnailUrl;
      default:
        return replayMessage.body;
    }
  }

  /// Gets message information and displays it.
  Future<void> getMessageInformation(
    IsmChatMessageModel message,
  ) async {
    unawaited(Future.wait<dynamic>(
      [
        _controller.getMessageReadTime(message),
        _controller.getMessageDeliverTime(message),
      ],
    ));
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      _controller.conversationController.message = message;
      _controller.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.messgaeInfoView;
    } else {
      await IsmChatRoute.goToRoute(IsmChatMessageInfo(
        message: message,
        isGroup: _controller.conversation?.isGroup ?? false,
      ));
    }
  }

  /// Taps for media preview from a message.
  void tapForMediaPreview(IsmChatMessageModel message) async {
    if ([IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
        .contains(message.customType)) {
      final mediaList = _controller.messages
          .where((item) =>
              [IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
                  .contains(item.customType) &&
              !(IsmChatProperties.chatPageProperties.isShowMessageBlur
                      ?.call(
                          IsmChatConfig.kNavigatorKey.currentContext ??
                              IsmChatConfig.context,
                          item)
                      .shouldBlured ??
                  false))
          .toList();
      if (mediaList.isNotEmpty) {
        final selectedMediaIndex = mediaList.indexOf(message);
        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          {
            await IsmChatRoute.goToRoute(IsmWebMessageMediaPreview(
              previewData: {
                'mediaIndex': selectedMediaIndex,
                'messageData': mediaList,
                'mediaUserName': message.chatName,
                'initiated': message.sentByMe,
                'mediaTime': message.sentAt,
              },
            ));
          }
        } else {
          await IsmChatRoute.goToRoute(IsmMediaPreview(
            mediaIndex: selectedMediaIndex,
            messageData: mediaList,
            mediaUserName: message.chatName,
            initiated: message.sentByMe,
            mediaTime: message.sentAt,
          ));
        }
      }
    } else if (message.customType == IsmChatCustomMessageType.file) {
      var localPath = message.attachments?.first.mediaUrl;
      if (localPath == null) {
        return;
      }
      try {
        if (!kIsWeb) {
          final path = await IsmChatUtility.makeDirectoryWithUrl(
              urlPath: message.attachments?.first.mediaUrl ?? '',
              fileName: message.attachments?.first.name ?? '');

          if (path.path.isNotEmpty) {
            localPath = path.path;
          }
        }

        if (kIsWeb) {
          if (localPath.isValidUrl) {
            IsmChatBlob.fileDownloadWithUrl(localPath);
          } else {
            IsmChatBlob.fileDownloadWithBytes(
              localPath.strigToUnit8List,
              downloadName: message.attachments?.first.name,
            );
          }
        } else {
          await OpenFilex.open(localPath);
        }
      } catch (e) {
        IsmChatLog.error('$e');
      }
    } else if (message.customType == IsmChatCustomMessageType.audio) {
      await IsmChatContextWidget.showDialogContext(
        content: AudioPreview(
          message: message,
        ),
      );
    } else if (message.customType == IsmChatCustomMessageType.contact) {
      await IsmChatRoute.goToRoute(
        IsmChatContactsInfoView(
          contacts: message.contacts,
        ),
      );
    }
  }

  /// Taps for media preview from message metadata (reply).
  void tapForMediaPreviewWithMetaData(IsmChatMessageModel message) async {
    if ([IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
        .contains(message.metaData?.replyMessage?.parentMessageMessageType)) {
      final mediaList = _controller.messages
          .where((item) =>
              [IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
                  .contains(
                      item.metaData?.replyMessage?.parentMessageMessageType) &&
              !(IsmChatProperties.chatPageProperties.isShowMessageBlur
                      ?.call(
                          IsmChatConfig.kNavigatorKey.currentContext ??
                              IsmChatConfig.context,
                          item)
                      .shouldBlured ??
                  false))
          .toList();
      final selectedMediaIndex = mediaList.indexOf(message);
      if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
          IsmChatConfig.context)) {
        {
          await IsmChatRoute.goToRoute(IsmWebMessageMediaPreview(
            previewData: {
              'mediaIndex': selectedMediaIndex,
              'messageData': mediaList,
              'mediaUserName': message.chatName,
              'initiated': message.sentByMe,
              'mediaTime': message.sentAt
            },
          ));
        }
      } else {
        await IsmChatRoute.goToRoute(IsmMediaPreview(
          mediaIndex: selectedMediaIndex,
          messageData: mediaList,
          mediaUserName: message.chatName,
          initiated: message.sentByMe,
          mediaTime: message.sentAt,
        ));
      }
    } else if (message.metaData?.replyMessage?.parentMessageMessageType ==
        IsmChatCustomMessageType.file) {
      var localPath = message.attachments?.first.mediaUrl;
      if (localPath == null) {
        return;
      }
      try {
        if (!kIsWeb) {
          final path = await IsmChatUtility.makeDirectoryWithUrl(
              urlPath: message.attachments?.first.mediaUrl ?? '',
              fileName: message.attachments?.first.name ?? '');

          if (path.path.isNotEmpty) {
            localPath = path.path;
          }
        }

        if (kIsWeb) {
          if (localPath.isValidUrl) {
            IsmChatBlob.fileDownloadWithUrl(localPath);
          } else {
            IsmChatBlob.fileDownloadWithBytes(
              localPath.strigToUnit8List,
              downloadName: message.attachments?.first.name,
            );
          }
        } else {
          await OpenFilex.open(localPath);
        }
      } catch (e) {
        IsmChatLog.error('$e');
      }
    } else if (message.customType == IsmChatCustomMessageType.audio) {
      await IsmChatContextWidget.showDialogContext(
        content: AudioPreview(
          message: message,
        ),
      );
    } else if (message.metaData?.replyMessage?.parentMessageMessageType ==
        IsmChatCustomMessageType.contact) {
      await IsmChatRoute.goToRoute(
        IsmChatContactsInfoView(
          contacts: message.contacts,
        ),
      );
    }
  }
}

