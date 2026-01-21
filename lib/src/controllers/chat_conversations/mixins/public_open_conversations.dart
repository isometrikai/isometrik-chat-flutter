part of '../chat_conversations_controller.dart';

/// Public and open conversations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to public and open conversation management
/// including fetching, initializing, and joining conversations.
mixin IsmChatConversationsPublicOpenConversationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Initializes the public and open conversation state.
  ///
  /// `conversationType`: The type of conversation to initialize.
  void intiPublicAndOpenConversation(
      IsmChatConversationType conversationType) async {
    _controller.publicAndOpenConversation.clear();
    _controller.isLoadResponse = false;
    _controller.showSearchField = false;
    _controller.callApiOrNot = true;
    await _controller.getPublicAndOpenConversation(
      conversationType: conversationType.value,
    );
  }

  /// Fetches public and open conversations based on specified parameters.
  ///
  /// `conversationType`: The type of conversation to fetch.
  /// `searchTag`: Optional search term for filtering conversations.
  /// `sort`: Sorting order.
  /// `skip`: Number of conversations to skip.
  /// `limit`: Maximum number of conversations to return.
  Future<void> getPublicAndOpenConversation({
    required int conversationType,
    String? searchTag,
    int sort = 1,
    int skip = 0,
    int limit = 20,
  }) async {
    if (!_controller.callApiOrNot) return;
    _controller.callApiOrNot = false;
    final response = await _controller.viewModel.getPublicAndOpenConversation(
      searchTag: searchTag,
      sort: sort,
      skip: skip,
      limit: limit,
      conversationType: conversationType,
    );
    if (response == null || response.isEmpty) {
      _controller.isLoadResponse = true;
      _controller.publicAndOpenConversation = [];
      return;
    }
    _controller.publicAndOpenConversation.addAll(response);
    _controller.callApiOrNot = true;
  }

  /// Joins a conversation based on its ID.
  ///
  /// `conversationId`: The ID of the conversation to join.
  /// `isloading`: Indicates if loading should be shown.
  Future<void> joinConversation({
    required String conversationId,
    bool isloading = false,
  }) async {
    final response = await _controller.viewModel.joinConversation(
        conversationId: conversationId, isLoading: isloading);
    if (response != null) {
      IsmChatRoute.goBack();
      await _controller.getChatConversations();
    }
  }
}

