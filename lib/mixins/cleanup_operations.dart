part of '../isometrik_chat_flutter.dart';

/// Cleanup operations mixin for IsmChat.
///
/// This mixin contains methods related to database and resource cleanup.
mixin IsmChatCleanupOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Log out the current user and clear local data.
  ///
  /// This function logs out the current user and clears all local data stored in the app.
  ///
  /// Example:
  /// ```dart
  /// // Log out the current user
  /// await IsmChat.i.logout();
  /// ```
  Future<void> logout() async => await _delegate.logout();

  /// Clear all local chat data stored in the database.
  ///
  /// This function clears all local chat data stored in the database, removing all conversations, messages, and other related data.
  ///
  /// Example:
  /// ```dart
  /// // Clear all local chat data
  /// await IsmChat.i.clearChatLocalDb();
  /// ```
  Future<void> clearChatLocalDb() async => _delegate.clearChatLocalDb();

  /// Deletes the conversation controller from memory.
  ///
  /// This method removes the IsmChatConversationsController instance from the
  /// GetX dependency injection system. This is typically used for cleanup
  /// operations when you want to free up memory or reset the conversation state.
  ///
  /// The method safely handles the deletion by:
  /// - Checking if the controller is registered before attempting deletion
  /// - Using force deletion to ensure complete removal
  /// - Catching and logging any errors that occur during deletion
  ///
  /// Returns:
  /// - Future<void>: A Future that completes when the controller has been
  ///   successfully deleted from memory.
  ///
  /// Example:
  /// ```dart
  /// // Clean up conversation controller when logging out
  /// await IsmChat.i.deleteConversationController();
  /// ```
  Future<void> deleteConversationController() async =>
      await _delegate.deleteConversationController();

  /// Deletes the chat page controller from memory.
  ///
  /// This method removes the IsmChatPageController instance from the
  /// GetX dependency injection system. This is typically used for cleanup
  /// operations when you want to free up memory or reset the chat page state.
  ///
  /// The method safely handles the deletion by:
  /// - Checking if the controller is registered before attempting deletion
  /// - Using force deletion to ensure complete removal
  /// - Catching and logging any errors that occur during deletion
  ///
  /// Returns:
  /// - Future<void>: A Future that completes when the controller has been
  ///   successfully deleted from memory.
  ///
  /// Example:
  /// ```dart
  /// // Clean up chat page controller when navigating away
  /// await IsmChat.i.deleteChatPageController();
  /// ```
  Future<void> deleteChatPageController() async =>
      await _delegate.deleteChatPageController();
}

