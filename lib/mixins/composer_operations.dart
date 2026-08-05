part of '../isometrik_chat_flutter.dart';

/// Public composer actions for host-app custom bottom UI.
///
/// Pair with [IsmChatPageProperties.messageFieldBuilder]. Default chat UI is
/// unchanged when that builder is omitted.
mixin IsmChatComposerOperationsMixin {
  IsmChatDelegate get _delegate =>
      (this as dynamic)._delegate as IsmChatDelegate;

  /// Current open chat conversation, or null if chat page is not open.
  IsmChatConversationModel? get currentChatConversation =>
      _delegate.currentChatConversation;

  /// SDK text controller. Bind your [TextField] to this, or pass text into
  /// [sendComposerText].
  TextEditingController? get chatInputController =>
      _delegate.chatInputController;

  /// Focus node for the composer field.
  FocusNode? get chatInputFocusNode => _delegate.chatInputFocusNode;

  /// Whether a reply is in progress.
  bool get isChatReplying => _delegate.isChatReplying;

  /// Message being replied to, if any.
  IsmChatMessageModel? get chatReplyMessage => _delegate.chatReplyMessage;

  /// Whether the current user may send in this chat.
  bool get isChattingAllowed => _delegate.isChattingAllowed;

  /// Sends the composer text through the same path as the default send button.
  ///
  /// Pass [text] or leave it empty to use [chatInputController].
  ///
  /// ```dart
  /// await IsmChat.i.sendComposerText(text: 'Hello');
  /// ```
  Future<bool> sendComposerText({String? text}) =>
      _delegate.sendComposerText(text: text);

  /// Opens the SDK attachment sheet (camera, gallery, document, …).
  ///
  /// ```dart
  /// await IsmChat.i.openComposerAttachments(context);
  /// ```
  Future<void> openComposerAttachments([BuildContext? context]) =>
      _delegate.openComposerAttachments(context);

  /// Skips the sheet and runs one attachment type (e.g. gallery).
  Future<void> selectComposerAttachment(
    IsmChatAttachmentType type, {
    BuildContext? context,
  }) =>
      _delegate.selectComposerAttachment(type, context: context);

  /// Call from your [TextField.onChanged] for typing indicators and mentions.
  void onComposerTextChanged(String text) =>
      _delegate.onComposerTextChanged(text);

  /// Sends a typing indicator only.
  void notifyComposerTyping() => _delegate.notifyComposerTyping();

  /// Clears the reply preview.
  void cancelComposerReply() => _delegate.cancelComposerReply();

  /// Shows or hides the SDK emoji board under the composer.
  void toggleComposerEmojiBoard([bool? show]) =>
      _delegate.toggleComposerEmojiBoard(show);

  /// Shows the block / unblock dialog when chatting is not allowed.
  void showComposerBlockDialog() => _delegate.showComposerBlockDialog();
}
