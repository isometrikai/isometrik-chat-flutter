part of '../isometrik_chat_flutter.dart';

/// Update operations mixin for IsmChat.
///
/// This mixin contains methods related to chat page updates.
mixin IsmChatUpdateOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Updates the current chat page by refreshing conversation details and messages.
  ///
  /// This method performs two main operations:
  /// 1. Retrieves the latest conversation details
  /// 2. Fetches the latest messages for the current conversation
  ///
  /// The method will only execute if there is a registered ChatPageController.
  ///
  /// Returns:
  /// - Future<void> : A Future that completes when both operations are finished.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.updateChatPage();
  /// ```
  Future<void> updateChatPage() async => await _delegate.updateChatPage();
}

