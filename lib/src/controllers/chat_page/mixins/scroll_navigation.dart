part of '../chat_page_controller.dart';

/// Scroll and navigation mixin for IsmChatPageController.
///
/// This mixin handles scroll listeners, scroll operations,
/// and navigation-related functionality.
mixin IsmChatPageScrollNavigationMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  ScrollPosition? get _messagesScrollPosition {
    final positions = _controller.messagesScrollController.positions;
    if (positions.isEmpty) return null;
    return positions.last;
  }

  ScrollPosition? get _searchScrollPosition {
    final positions = _controller.searchMessageScrollController.positions;
    if (positions.isEmpty) return null;
    return positions.last;
  }

  /// Sets up scroll listeners for messages and search.
  void _scrollListener() async {
    if (!_controller.hasAttachedMessagesScrollListener) {
      _controller.hasAttachedMessagesScrollListener = true;
      _controller.messagesScrollController.addListener(
        () async {
          if (_controller.holdController?.isCompleted == true &&
              _controller.messageHoldOverlayEntry != null) {
            _controller.closeOverlay();
          }
          if (_controller.showAttachment) {
            await _controller.fabAnimationController?.reverse();
            if (_controller.fabAnimationController?.isDismissed == true) {
              _controller.attchmentOverlayEntry?.remove();
              // attchmentOverlayEntry = null;
            }
            _controller.showAttachment = false;
          }

          final position = _messagesScrollPosition;
          if (position != null &&
              position.pixels.toInt() == position.maxScrollExtent.toInt()) {
            _controller.canCallCurrentApi = false;
            await _controller.getMessagesFromAPI(forPagination: true);
          }

          // Keep keyboard focus while scrolling/sending; only collapse emoji panel.
          if (_controller.showEmojiBoard) {
            _controller.showEmojiBoard = false;
          }

          final offset = position?.pixels ?? 0;
          _controller.showDownSideButton =
              IsmChatDimens.percentHeight(1) * 0.3 < offset;
        },
      );
    }

    if (!_controller.hasAttachedSearchScrollListener) {
      _controller.hasAttachedSearchScrollListener = true;
      _controller.searchMessageScrollController.addListener(
        () {
          final position = _searchScrollPosition;
          if (position != null &&
              position.pixels.toInt() == position.maxScrollExtent.toInt()) {
            _controller.searchedMessages(
              _controller.textEditingController.text,
              fromScrolling: true,
            );
          }
        },
      );
    }
  }

  /// Sets up input controllers and focus node listeners.
  void _intputAndFocustNode() {
    if (IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.audioMessage)) {
      _controller.chatInputController.addListener(() {
        _controller.showSendButton = _controller.chatInputController.text.isNotEmpty;
      });
    } else {
      _controller.showSendButton = true;
    }

    _controller.messageFocusNode.addListener(
      () {
        if (_controller.messageFocusNode.hasFocus) {
          _controller.showEmojiBoard = false;
        }
        IsmChatProperties.chatPageProperties.meessageFieldFocusNode?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            _controller.conversation!,
            _controller.messageFocusNode.hasFocus);
      },
    );
  }

  /// Initializes animation controllers for hold gestures.
  void _startAnimated() {
    _controller.holdController = AnimationController(
      vsync: _controller,
      duration: IsmChatConstants.transitionDuration,
    );
    _controller.holdAnimation = CurvedAnimation(
      parent: _controller.holdController!,
      curve: Curves.easeInOutCubic,
    );
  }

  /// Closes the message overlay.
  void closeOverlay() async {
    if (_controller.holdController != null && _controller.messageHoldOverlayEntry != null) {
      await _controller.holdController?.reverse();
      if (_controller.holdController?.isDismissed == true) {
        _controller.messageHoldOverlayEntry?.remove();
        _controller.messageHoldOverlayEntry = null;
      }
    }
    _controller.closeAttachmentOverlayForWeb();
  }

  /// Closes the attachment overlay for web.
  void closeAttachmentOverlayForWeb() async {
    if (_controller.fabAnimationController != null && _controller.attchmentOverlayEntry != null) {
      await _controller.fabAnimationController?.reverse();
      if (_controller.fabAnimationController?.isDismissed == true &&
          _controller.attchmentOverlayEntry != null) {
        try {
          _controller.attchmentOverlayEntry?.remove();
          _controller.attchmentOverlayEntry = null;
          _controller.showAttachment = !_controller.showAttachment;
        } catch (_) {}
      }
    }
  }

  /// Scrolls to the bottom of the messages list.
  Future<void> scrollDown() async {
    if (!IsmChatUtility.chatPageControllerRegistered) {
      return;
    }
    await _controller.messagesScrollController.animateTo(
      0,
      duration: IsmChatConfig.animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Scrolls to the message with the specified id.
  void scrollToMessage(String messageId, {Duration? duration}) async {
    if (_controller.indexedMessageList[messageId] != null) {
      await _controller.messagesScrollController.scrollToIndex(
        _controller.indexedMessageList[messageId]!,
        duration: duration ?? IsmChatConfig.animationDuration,
        preferPosition: AutoScrollPosition.middle,
      );
    } else {
      await _controller.getMessagesFromAPI(forPagination: true);
    }
  }
}
