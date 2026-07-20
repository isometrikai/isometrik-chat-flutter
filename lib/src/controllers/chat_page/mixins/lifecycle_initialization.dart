part of '../chat_page_controller.dart';

/// Lifecycle and initialization mixin for IsmChatPageController.
///
/// This mixin handles controller lifecycle methods, initialization,
/// and cleanup operations.
mixin IsmChatPageLifecycleInitializationMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  @override
  void onInit() {
    super.onInit();
    // Message/conversation loading is triggered from [IsmChatPageView.initState]
    // (mobile route push) and [goToChatPage] (web). The GetX controller survives
    // pop/push, so onInit alone only runs once and is not enough on re-open.
  }

  @override
  void onClose() {
    _controller._dispose();
    super.onClose();
  }

  @override
  void dispose() {
    _controller._dispose();
    super.dispose();
  }

  /// Initializes the chat page controller.
  ///
  /// Sets up all necessary components including:
  /// - Input controllers
  /// - Audio recorder
  /// - Reaction list
  /// - Animations
  /// - Scroll listeners
  /// - Conversation data
  void startInit({
    bool isBroadcasts = false,
  }) async {
    final generation = ++_controller.chatOpenGeneration;
    _controller
      ..chatInputController.clear()
      ..recordVoice = AudioRecorder()
      ..isActionAllowed = false
      .._generateReactionList()
      .._startAnimated()
      .._scrollListener()
      .._intputAndFocustNode();

    if (_controller.conversationController.currentConversation != null) {
      _controller
        .._currentUser()
        // Always take the *latest* selection from the conversations controller.
        // A late details-API response for an exited group must not leave the
        // chat page stuck on that old conversationId.
        ..conversation = _controller.conversationController.currentConversation
        ..isActionAllowed = false
        ..isCoverationApiDetails = true
        ..canCallCurrentApi = false
        ..isMessagesLoading = true;
      // Reset previous chat data before loading another conversation to avoid
      // cross-chat message leakage when controller is reused (e.g. web/tab).
      // Without this, old messages can flash/show in a newly opened chat.
      _controller.messages.clear();
      // Allow UI to render before heavy operations
      await Future.delayed(Duration.zero);
      if (generation != _controller.chatOpenGeneration) return;
      // Re-sync after the yield — another async path may have updated the
      // selected conversation while we were waiting.
      final selected =
          _controller.conversationController.currentConversation;
      if (selected != null &&
          selected.conversationId !=
              _controller.conversation?.conversationId) {
        _controller.conversation = selected;
      }
      try {
        final arguments = Get.arguments as Map<String, dynamic>? ?? {};
        _controller.isBroadcast =
            arguments['isBroadcast'] as bool? ?? isBroadcasts;
      } catch (_) {}
      // Check conversation customType to determine if it's a broadcast
      if (_controller.conversation?.customType == IsmChatStrings.broadcast) {
        _controller.isBroadcast = true;
      }

      // Set isBroadcast from arguments if not already set
      if (!_controller.isBroadcast) {
        _controller.isBroadcast = isBroadcasts;
      }

      if (_controller.conversation?.conversationId?.isNotEmpty == true) {
        await _controller.callFunctionsWithConversationId(
          _controller.conversation?.conversationId ?? '',
          openGeneration: generation,
        );
      } else {
        await _controller.callFunctions();
      }
      if (generation != _controller.chatOpenGeneration) return;
      // Attempt to flush any pending (clock) messages whenever a chat opens.
      // Previously this only happened on connectivity change; with stable network
      // a stuck pending message would never retry.
      unawaited(
        _controller.conversationController.sendPendingMessgae(
          conversationId: _controller.conversation?.conversationId ?? '',
        ),
      );
      await _controller.sendWithOutSideMessage();
      unawaited(_controller.updateUnreadMessgaeCount());
    }
  }

  /// Disposes of all resources used by the controller.
  void _dispose() {
    if (_controller.areCamerasInitialized) {
      try {
        _controller._frontCameraController.dispose();
        _controller._backCameraController.dispose();
        _controller.cameraController.dispose();
      } catch (_) {}
    }
    _controller.conversationDetailsApTimer?.cancel();
    _controller.messagesScrollController.dispose();
    _controller.searchMessageScrollController.dispose();
    _controller.attchmentOverlayEntry?.dispose();
    _controller.messageHoldOverlayEntry?.dispose();
    _controller.attchmentOverlayEntry?.dispose();
    _controller.fabAnimationController?.dispose();
    _controller.holdController?.dispose();
    _controller.ifTimerMounted();
  }

  /// Sets up the current user details from configuration.
  void _currentUser() {
    _controller.currentUser = UserDetails(
      userProfileImageUrl:
          IsmChatConfig.communicationConfig.userConfig.userProfile ?? '',
      userName: IsmChatConfig.communicationConfig.userConfig.userName ?? '',
      userIdentifier:
          IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
      userId: IsmChatConfig.communicationConfig.userConfig.userId,
      online: false,
      lastSeen: 0,
    );
  }

  /// Generates the list of available reactions/emojis.
  void _generateReactionList() async {
    _controller.reactions
      ..clear()
      ..addAll(
        IsmChatEmoji.values
            .expand((typesOfEmoji) => defaultEmojiSet.expand((categoryEmoji) =>
                categoryEmoji.emoji
                    .where((emoji) => typesOfEmoji.emojiKeyword == emoji.name)))
            .toList(),
      );
  }

  /// Gets the background asset (color/image) for the conversation.
  void _getBackGroundAsset() {
    final assets =
        _controller.conversationController.userDetails?.metaData?.assetList ??
            [];
    final asset = assets
        .where((e) => e.keys.contains(_controller.conversation?.conversationId))
        .toList();
    if (asset.isNotEmpty) {
      _controller.backgroundColor = asset.first.values.first.color!;
      _controller.backgroundImage = asset.first.values.first.imageUrl!;
    } else {
      _controller.backgroundColor = '';
      _controller.backgroundImage =
          IsmChatProperties.chatPageProperties.backgroundImageUrl ?? '';
    }
  }

  /// Calls initialization functions when conversation ID is available.
  Future<void> callFunctionsWithConversationId(
    String conversationId, {
    int? openGeneration,
  }) async {
    _controller._getBackGroundAsset();
    if (!_controller.isBroadcast) {
      await _controller.getMessagesFromDB(conversationId);
      if (openGeneration != null &&
          openGeneration != _controller.chatOpenGeneration) {
        return;
      }
      // Do not block message sync on conversation-details. After leaving one
      // group and opening another, a slow/stale details request used to
      // delay `getMessagesFromAPI`, and a stuck `canCallCurrentApi` from the
      // previous chat could skip the fetch entirely — empty screen until re-open.
      await Future.wait([
        _controller.getConverstaionDetails(),
        _controller.getMessagesFromAPI(),
      ]);
      if (openGeneration != null &&
          openGeneration != _controller.chatOpenGeneration) {
        return;
      }
      await _controller.getMessageForStatus();
      await _controller.readAllMessages();
      _controller.checkUserStatus();
    } else {
      await _controller.getBroadcastMessages(
          isBroadcast: _controller.isBroadcast);
      _controller.isMessagesLoading = false;
    }
  }

  /// Calls initialization functions when conversation ID is not available.
  Future<void> callFunctions() async {
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      _controller.messages.clear();
    }
    if (_controller.conversation?.isGroup ?? false) {
      _controller.conversation =
          await _controller.commonController.createConversation(
        conversation: _controller.conversation!,
        conversationType: _controller.conversation?.conversationType ??
            IsmChatConversationType.private,
        userId: [],
        metaData: _controller.conversation?.metaData,
        isGroup: true,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              _controller.conversationController.userDetails?.userName ??
              '',
          _controller.conversation?.chatName ?? ''
        ],
      );
      IsmChatConfig.onConversationCreated?.call(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
        _controller.conversation,
      );

      await _controller.getConverstaionDetails();
      await _controller.getMessagesFromAPI();
      _controller.checkUserStatus();
    } else {
      if (_controller.messages.isEmpty) {
        _controller.messages.add(
          IsmChatMessageModel(
            body: '',
            customType: IsmChatCustomMessageType.conversationCreated,
            sentAt: DateTime.now().millisecondsSinceEpoch,
            sentByMe: true,
          ),
        );
        _controller.messages = _controller.commonController
            .sortMessages(_controller.filterMessages(_controller.messages));
      }
    }
    _controller.isMessagesLoading = false;
  }

  /// Sends messages that were queued from outside the chat context.
  Future<void> sendWithOutSideMessage() async {
    if (_controller.conversation?.outSideMessage != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_controller.conversation?.outSideMessage?.aboutText != null) {
        _controller.sendAboutTextMessage(
          conversationId: _controller.conversation?.conversationId ?? '',
          userId: _controller.conversation?.opponentDetails?.userId ?? '',
          outSideMessage: _controller.conversation?.outSideMessage,
          pushNotifications:
              _controller.conversation?.pushNotifications ?? true,
        );
      } else if (!(_controller
              .conversation?.outSideMessage?.imageUrl.isNullOrEmpty ==
          true)) {
        await _controller.sendMessageWithImageUrl(
          conversationId: _controller.conversation?.conversationId ?? '',
          userId: _controller.conversation?.opponentDetails?.userId ?? '',
          caption: _controller.conversation?.outSideMessage?.caption,
          imageUrl: _controller.conversation?.outSideMessage?.imageUrl ?? '',
        );
      } else if (!(_controller
              .conversation?.outSideMessage?.messageFromOutSide.isNullOrEmpty ==
          true)) {
        _controller.chatInputController.text =
            _controller.conversation?.outSideMessage?.messageFromOutSide ?? '';
        if (_controller.chatInputController.text.isNotEmpty) {
          _controller.sendTextMessage(
            conversationId: _controller.conversation?.conversationId ?? '',
            userId: _controller.conversation?.opponentDetails?.userId ?? '',
            pushNotifications:
                _controller.conversation?.pushNotifications ?? true,
          );
        }
      }
    }
  }

  /// Periodically calls the conversation details API to keep conversation data up-to-date.
  ///
  /// The interval is configurable via [IsmChatPageProperties.conversationDetailsApiInterval]
  /// and defaults to 1 minute if not specified.
  ///
  /// The timer automatically cancels if:
  /// - The chat page controller is no longer registered
  /// - The conversation ID is null or empty
  void checkUserStatus() {
    // Get the configurable interval from properties, defaulting to 1 minute
    final interval =
        IsmChatProperties.chatPageProperties.conversationDetailsApiInterval;

    _controller.conversationDetailsApTimer = Timer.periodic(
      interval,
      (Timer t) {
        if (!IsmChatUtility.chatPageControllerRegistered) {
          t.cancel();
          _controller.conversationDetailsApTimer?.cancel();
        }
        if (_controller.conversation?.conversationId != null ||
            _controller.conversation?.conversationId?.isNotEmpty == true) {
          _controller.getConverstaionDetails();
        }
      },
    );
  }

  /// Checks if the conversation details API timer is mounted and cancels it if active.
  void ifTimerMounted() {
    final isTimer = _controller.conversationDetailsApTimer == null
        ? false
        : _controller.conversationDetailsApTimer!.isActive;
    if (isTimer) {
      _controller.conversationDetailsApTimer!.cancel();
    }
  }
}
