part of '../isometrik_chat_flutter.dart';

/// Paid media handling mixin for IsmChatDelegate.
///
/// This mixin provides delegate method for handling paid media (images/videos)
/// outside the SDK. It allows the host app to intercept media sending to
/// show paid/free screen and send messages from outside the SDK.
mixin IsmChatDelegatePaidMediaMixin {
  /// Callback for handling paid media when user clicks send.
  ///
  /// This callback is invoked when user clicks send button with selected media
  /// (images or videos) and paid media handling is enabled. The host app can
  /// use this to show paid/free screen and send the message from outside SDK.
  ///
  /// Parameters:
  /// - [BuildContext] - The current build context
  /// - [IsmChatConversationModel] - The current conversation
  /// - [List<WebMediaModel>] - The selected media (images and/or videos)
  ///
  /// Returns:
  /// - `true` if the delegate handled the media (SDK will not proceed with normal sending)
  /// - `false` if the SDK should proceed with normal media sending
  PaidMediaSendCallback? onPaidMediaSend;
}
