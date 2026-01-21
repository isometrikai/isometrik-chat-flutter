part of '../isometrik_chat_flutter.dart';

/// UI/View management mixin for IsmChatDelegate.
///
/// This mixin contains methods related to UI state management, view updates,
/// and search functionality.
mixin IsmChatDelegateUiMixin {
  /// Shows the third column in the conversation view.
  void showThirdColumn() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.outSideView;
    }
  }

  /// Closes the third column in the conversation view.
  void clostThirdColumn() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
    }
  }

  /// Shows the block/unblock dialog if the user is blocked.
  void showBlockUnBlockDialog() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (!(controller.conversation?.isChattingAllowed == true)) {
        controller.showDialogCheckBlockUnBlock();
      }
    }
  }

  /// Changes the current conversation to null.
  void changeCurrentConversation() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.currentConversation = null;
    }
  }

  /// Updates the chat page controller by resetting the conversation.
  void updateChatPageController() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      var conversationModel = controller.conversation;
      controller
        ..conversation = null
        ..conversation = conversationModel;
    }
  }

  /// Sets the current conversation index.
  void currentConversationIndex({int index = 0}) {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.currentConversationIndex = index;
    }
  }

  /// Hides other views on chat page if not on the first conversation.
  void shouldShowOtherOnChatPage() {
    if (IsmChatUtility.conversationControllerRegistered) {
      final controller = IsmChatUtility.conversationController;
      if (controller.currentConversationIndex != 0) {
        controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      }
    }
  }

  /// Searches conversations based on the provided search value.
  ///
  /// Uses debouncing to avoid excessive API calls.
  Future<void> searchConversation({required String searchValue}) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      final controller = IsmChatUtility.conversationController;
      controller.debounce.run(() async {
        switch (searchValue.trim().isNotEmpty) {
          case true:
            await controller.getChatConversations(
              searchTag: searchValue,
            );
            break;
          default:
            await controller.getConversationsFromDB();
        }
      });
      controller.update();
    }
  }
}
