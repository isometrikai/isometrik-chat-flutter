part of '../isometrik_chat_flutter.dart';

/// Composer actions for a host-app custom chat input bar.
///
/// Used when [IsmChatPageProperties.messageFieldBuilder] replaces the default
/// typing area. No-ops if the chat page is not open.
mixin IsmChatDelegateComposerMixin {
  IsmChatPageController? get _page {
    if (!IsmChatUtility.chatPageControllerRegistered) {
      return null;
    }
    return IsmChatUtility.chatPageController;
  }

  IsmChatConversationModel? get currentChatConversation =>
      _page?.conversation;

  TextEditingController? get chatInputController => _page?.chatInputController;

  FocusNode? get chatInputFocusNode => _page?.messageFocusNode;

  bool get isChatReplying => _page?.isreplying == true;

  IsmChatMessageModel? get chatReplyMessage => _page?.replayMessage;

  bool get isChattingAllowed => _page?.conversation?.isChattingAllowed == true;

  Future<bool> sendComposerText({String? text}) async {
    final controller = _page;
    if (controller == null) {
      return false;
    }
    return controller.trySendTextFromComposer(text: text);
  }

  Future<void> openComposerAttachments([BuildContext? context]) async {
    final controller = _page;
    if (controller == null) {
      return;
    }
    final ctx = context ??
        IsmChatConfig.kNavigatorKey.currentContext ??
        IsmChatConfig.context;
    await controller.openAttachmentPicker(ctx);
  }

  Future<void> selectComposerAttachment(
    IsmChatAttachmentType type, {
    BuildContext? context,
  }) async {
    final controller = _page;
    if (controller == null) {
      return;
    }
    if (!(controller.conversation?.isChattingAllowed == true)) {
      controller.showDialogCheckBlockUnBlock();
      return;
    }
    final ctx = context ??
        IsmChatConfig.kNavigatorKey.currentContext ??
        IsmChatConfig.context;
    if (!(await IsmChatProperties.chatPageProperties.isSendMediaAllowed
            ?.call(ctx, controller.conversation) ??
        true)) {
      return;
    }
    controller.onBottomAttachmentTapped(type);
  }

  void onComposerTextChanged(String text) {
    _page?.handleComposerTextChanged(text);
  }

  void notifyComposerTyping() {
    _page?.notifyTyping();
  }

  void cancelComposerReply() {
    final controller = _page;
    if (controller == null) {
      return;
    }
    controller.isreplying = false;
  }

  void toggleComposerEmojiBoard([bool? show]) {
    _page?.toggleEmojiBoard(show);
  }

  void showComposerBlockDialog() {
    _page?.showDialogCheckBlockUnBlock();
  }
}
