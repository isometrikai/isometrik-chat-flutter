part of '../chat_page_controller.dart';

/// Scroll and navigation mixin for IsmChatPageController.
///
/// This mixin handles scroll listeners, scroll operations,
/// and navigation-related functionality.
mixin IsmChatPageScrollNavigationMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// How close to the oldest edge (maxScrollExtent on a reverse list) before
  /// we request the next page of older messages.
  static const double _olderMessagesLoadThresholdPx = 80;

  DateTime? _lastOlderMessagesRequestAt;

  ScrollPosition? get _messagesScrollPosition {
    final positions = _controller.messagesScrollController.positions;
    if (positions.length == 1) return positions.first;
    // Multiple attached views (stacked chat routes) — prefer the last attached
    // one, but pagination should prefer [handleMessagesScrollNotification].
    if (positions.isEmpty) return null;
    return positions.last;
  }

  ScrollPosition? get _searchScrollPosition {
    final positions = _controller.searchMessageScrollController.positions;
    if (positions.isEmpty) return null;
    return positions.length == 1 ? positions.first : positions.last;
  }

  /// Sets up scroll listeners for messages and search.
  ///
  /// Pagination for the main message list is primarily driven by
  /// [handleMessagesScrollNotification] on the visible [ListView] so stacked
  /// chat pages (shared [messagesScrollController]) still load older messages
  /// correctly when returning to a lower route.
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
            }
            _controller.showAttachment = false;
          }

          // Keep keyboard focus while scrolling/sending; only collapse emoji panel.
          if (_controller.showEmojiBoard) {
            _controller.showEmojiBoard = false;
          }

          final position = _messagesScrollPosition;
          if (position == null) return;

          _controller.showDownSideButton =
              IsmChatDimens.percentHeight(1) * 0.3 < position.pixels;

          // Fallback pagination when only one scroll view is attached.
          if (_controller.messagesScrollController.positions.length == 1) {
            _maybeLoadOlderMessages(position.pixels, position.maxScrollExtent);
          }
        },
      );
    }

    if (!_controller.hasAttachedSearchScrollListener) {
      _controller.hasAttachedSearchScrollListener = true;
      _controller.searchMessageScrollController.addListener(
        () {
          final position = _searchScrollPosition;
          if (position == null) return;
          if (position.pixels >=
              position.maxScrollExtent - _olderMessagesLoadThresholdPx) {
            _controller.searchedMessages(
              _controller.textEditingController.text,
              fromScrolling: true,
            );
          }
        },
      );
    }
  }

  /// Handles scroll metrics from the *visible* messages [ListView].
  ///
  /// Prefer this over [ScrollController.position] when chat pages are stacked:
  /// the shared controller can be attached to more than one list, and
  /// `.position` / the wrong `positions` entry will skip older-message loads.
  bool handleMessagesScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification ||
        notification is ScrollEndNotification) {
      if (_controller.holdController?.isCompleted == true &&
          _controller.messageHoldOverlayEntry != null) {
        _controller.closeOverlay();
      }
      if (_controller.showAttachment) {
        unawaited(_dismissAttachmentOnScroll());
      }
      if (_controller.showEmojiBoard) {
        _controller.showEmojiBoard = false;
      }

      final metrics = notification.metrics;
      _controller.showDownSideButton =
          IsmChatDimens.percentHeight(1) * 0.3 < metrics.pixels;
      _maybeLoadOlderMessages(metrics.pixels, metrics.maxScrollExtent);
    }
    return false;
  }

  Future<void> _dismissAttachmentOnScroll() async {
    await _controller.fabAnimationController?.reverse();
    if (_controller.fabAnimationController?.isDismissed == true) {
      _controller.attchmentOverlayEntry?.remove();
    }
    _controller.showAttachment = false;
  }

  void _maybeLoadOlderMessages(double pixels, double maxScrollExtent) {
    // Reverse list: older history is toward maxScrollExtent.
    if (pixels < maxScrollExtent - _olderMessagesLoadThresholdPx) {
      return;
    }
    final now = DateTime.now();
    final last = _lastOlderMessagesRequestAt;
    if (last != null && now.difference(last) < const Duration(milliseconds: 400)) {
      return;
    }
    _lastOlderMessagesRequestAt = now;
    unawaited(_controller.getMessagesFromAPI(forPagination: true));
  }

  /// Sets up input controllers and focus node listeners.
  void _intputAndFocustNode() {
    if (IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.audioMessage)) {
      _controller.chatInputController.addListener(() {
        _controller.showSendButton =
            _controller.chatInputController.text.isNotEmpty;
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
    if (_controller.holdController != null &&
        _controller.messageHoldOverlayEntry != null) {
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
    if (_controller.fabAnimationController != null &&
        _controller.attchmentOverlayEntry != null) {
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
    final scrollController = _controller.messagesScrollController;
    if (scrollController.positions.length != 1) {
      return;
    }
    await scrollController.animateTo(
      0,
      duration: IsmChatConfig.animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }

  /// Scrolls to the message with the specified id.
  void scrollToMessage(String messageId, {Duration? duration}) async {
    if (_controller.indexedMessageList[messageId] != null) {
      final scrollController = _controller.messagesScrollController;
      if (scrollController.positions.length != 1) {
        return;
      }
      await scrollController.scrollToIndex(
        _controller.indexedMessageList[messageId]!,
        duration: duration ?? IsmChatConfig.animationDuration,
        preferPosition: AutoScrollPosition.middle,
      );
    } else {
      await _controller.getMessagesFromAPI(forPagination: true);
    }
  }
}
