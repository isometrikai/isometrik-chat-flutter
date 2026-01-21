part of '../chat_conversations_controller.dart';

/// Scroll listeners mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to scroll listeners for pagination
/// of conversations and search results.
mixin IsmChatConversationsScrollListenersMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Adds scroll listeners to manage pagination for conversations and search results.
  void scrollListener() async {
    _controller.conversationScrollController.addListener(
      () async {
        if (_controller.conversationScrollController.offset.toInt() ==
            _controller.conversationScrollController.position.maxScrollExtent.toInt()) {
          await _controller.getChatConversations(
            skip: _controller.conversations.length.pagination(),
          );
        }
      },
    );
    _controller.searchConversationScrollController.addListener(
      () async {
        if (_controller.searchConversationScrollController.offset.toInt() ==
            _controller.searchConversationScrollController.position.maxScrollExtent
                .toInt()) {
          await _controller.getChatConversations(
            skip: _controller.searchConversationList.length.pagination(),
          );
        }
      },
    );
  }
}

