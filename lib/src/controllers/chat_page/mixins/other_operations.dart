part of '../chat_page_controller.dart';

/// Other operations mixin for IsmChatPageController.
///
/// This mixin handles various miscellaneous operations like leaving groups,
/// location operations, reactions, user details, timers, and audio recording.
mixin IsmChatPageOtherOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Starts the recording timer.
  void startTimer() {
    _controller.forRecordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      var seconds = _controller.myDuration.inSeconds + 1;
      _controller.myDuration = Duration(seconds: seconds);
    });
  }

  /// Leaves a group conversation.
  Future<void> leaveGroup({
    required int adminCount,
    required bool isUserAdmin,
  }) async {
    if (adminCount == 1 && isUserAdmin) {
      final members = _controller.groupMembers.where((e) => !e.isAdmin).toList();
      final member = members[Random().nextInt(members.length)];
      await _controller.makeAdmin(member.userId, member.userName, false);
    }
    final didLeft = await _controller.leaveConversation(_controller.conversation!.conversationId!);
    if (didLeft) {
      IsmChatRoute.goBack(); // to Chat Page
      IsmChatRoute.goBack(); // to Conversation Page
      await Future.wait([
        IsmChatConfig.dbWrapper!
            .removeConversation(_controller.conversation!.conversationId!),
        _controller.conversationController.getChatConversations(),
      ]);
    }
  }

  /// Gets location predictions based on latitude, longitude, and search keyword.
  Future<void> getLocation(
      {required String latitude,
      required String longitude,
      String searchKeyword = ''}) async {
    _controller.predictionList.clear();
    _controller.isLocaionSearch = true;
    final response = await _controller.viewModel.getLocation(
      latitude: latitude,
      longitude: longitude,
      searchKeyword: searchKeyword,
    );
    _controller.isLocaionSearch = false;
    if (response == null || response.isEmpty) {
      return;
    }
    _controller.predictionList = response;
  }

  /// Deletes a reaction from a message.
  Future<void> deleteReacton({required Reaction reaction}) async {
    var response = await _controller.viewModel.deleteReacton(reaction: reaction);
    if (response != null && !response.hasError) {
      await _controller.conversationController.getChatConversations();
    }
  }

  /// Shows user details.
  Future<void> showUserDetails(UserDetails userDetails,
      {bool fromMessagePage = true}) async {
    final conversationId = _controller.conversationController.getConversationId(
      userDetails.userId,
    );
    final conversationUser =
        await IsmChatConfig.dbWrapper!.getConversation(conversationId);
    UserDetails? user;
    if (conversationUser != null) {
      user = conversationUser.opponentDetails;
    } else {
      user = userDetails;
    }
    _controller.conversationController.contactDetails = user;
    _controller.conversationController.userConversationId = conversationId;
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      _controller.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.userInfoView;
    } else {
      await IsmChatRoute.goToRoute(
        IsmChatUserInfo(
          conversationId: conversationId,
          user: user!,
          fromMessagePage: fromMessagePage,
        ),
      );
    }
  }

  /// Checks if an audio encoder is supported.
  Future<bool> isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _controller.recordVoice.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatAlertDialogBox(
          title: '${encoder.name} is not supported on this platform.',
          cancelLabel: IsmChatStrings.okay,
        ),
      );
    }
    return isSupported;
  }

  /// Deletes the current recording.
  void recordDelete() {
    _controller.isEnableRecordingAudio = false;
    _controller.showSendButton = false;
    _controller.forRecordTimer?.cancel();
    _controller.seconds = 0;
  }

  /// Plays or pauses voice recording.
  Future<void> recordPlayPauseVoice() async {
    if (await _controller.recordVoice.isPaused()) {
      await _controller.recordVoice.resume();
      _controller.isRecordPlay = true;
      _controller.forRecordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _controller.seconds++;
      });
    } else {
      await _controller.recordVoice.pause();
      _controller.isRecordPlay = false;
      _controller.forRecordTimer?.cancel();
    }
  }
}

