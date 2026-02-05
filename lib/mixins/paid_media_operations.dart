part of '../isometrik_chat_flutter.dart';

/// Paid media operations mixin for IsmChat.
///
/// This mixin provides access to paid media delegate callback.
mixin IsmChatPaidMediaOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate =>
      (this as dynamic)._delegate as IsmChatDelegate;

  /// Gets or sets the callback for handling paid media when user clicks send.
  ///
  /// This callback is invoked when user clicks send button with selected media
  /// (images or videos) and paid media handling is enabled. The delegate should
  /// show paid/free screen and send message from outside SDK.
  PaidMediaSendCallback? get onPaidMediaSend => _delegate.onPaidMediaSend;
  set onPaidMediaSend(PaidMediaSendCallback? value) =>
      _delegate.onPaidMediaSend = value;
}
