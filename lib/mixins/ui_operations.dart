part of '../isometrik_chat_flutter.dart';

/// UI operations mixin for IsmChat.
///
/// This mixin contains methods related to UI state management and view updates.
mixin IsmChatUiOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Shows the third column in the web flow.
  ///
  /// This function should only be used in the web flow and not in the mobile flow.
  /// It is also necessary to call the `outSideView` callback widget in `IsmChatConversationProperties`.
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.showThirdColumn();
  /// ```
  void showThirdColumn() => _delegate.showThirdColumn();

  /// Closes the third column in the web flow.
  ///
  /// This function should only be used in the web flow and not in the mobile flow.
  /// It is also necessary to call the `outSideView` callback widget in `IsmChatConversationProperties`.
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.clostThirdColumn();
  /// ```
  void clostThirdColumn() => _delegate.clostThirdColumn();

  /// Call this function for showing Block un Block Dialog
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.showBlockUnBlockDialog();
  /// ```
  void showBlockUnBlockDialog() => _delegate.showBlockUnBlockDialog();

  /// Call this function to assign null on the current conversation.
  ///
  /// This function is used to reset the current conversation.
  ///
  /// Example:
  /// ```dart
  /// // Reset the current conversation
  ///  IsmChat.i.changeCurrentConversation();
  /// ```
  void changeCurrentConversation() => _delegate.changeCurrentConversation();

  /// Call this function to update the chat page controller.
  ///
  /// This function is used to refresh the chat page controller, which can be useful after making changes to the conversation list.
  ///
  /// Example:
  /// ```dart
  /// // Update the chat page controller after deleting a conversation
  /// IsmChat.i.updateChatPageController();
  /// ```
  void updateChatPageController() => _delegate.updateChatPageController();

  /// Determines whether to show other elements on the chat page.
  ///
  /// UI elements should be displayed on the chat page.
  ///
  /// Example:
  /// ```dart
  /// IsmChat.i.shouldShowOtherOnChatPage();
  /// ```
  void shouldShowOtherOnChatPage() => _delegate.shouldShowOtherOnChatPage();

  /// Sets the current conversation index in the chat interface.
  ///
  /// This method updates the index of the currently active conversation in the chat interface.
  ///
  /// Parameters:
  /// - `index`: The index of the conversation to set as current. Defaults to 0.
  ///
  /// Example:
  /// ```dart
  /// IsmChat.i.currentConversationIndex(index: 2);
  /// ```
  void currentConversationIndex({int index = 0}) =>
      _delegate.currentConversationIndex(index: index);
}

