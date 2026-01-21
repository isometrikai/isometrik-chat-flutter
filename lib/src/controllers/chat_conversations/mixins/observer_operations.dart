part of '../chat_conversations_controller.dart';

/// Observer operations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to observer functionality including
/// joining and leaving observer roles, and retrieving observer users.
mixin IsmChatConversationsObserverOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Joins an observer to a conversation.
  ///
  /// `conversationId`: The ID of the conversation to join as an observer.
  ///  `isLoading`: Indicates if loading should be shown.
  Future<IsmChatResponseModel?> joinObserver(
          {required String conversationId, bool isLoading = false}) async =>
      await _controller.viewModel.joinObserver(
          conversationId: conversationId, isLoading: isLoading);

  /// Leaves an observer role in a conversation.
  ///
  /// `conversationId`: The ID of the conversation to leave.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> leaveObserver(
      {required String conversationId, bool isLoading = false}) async {
    final response = await _controller.viewModel.leaveObserver(
        conversationId: conversationId, isLoading: isLoading);
    if (response != null) {}
  }

  /// Retrieves users observing a conversation.
  ///
  /// `conversationId`: The ID of the conversation to get observers from.
  /// `skip`: Number of users to skip.
  /// `limit`: Maximum number of users to return.
  /// `isLoading`: Indicates if loading should be shown.
  /// `searchText`: Optional search term for filtering users.
  Future<List<UserDetails>> getObservationUser({
    required String conversationId,
    int skip = 0,
    int limit = 20,
    bool isLoading = false,
    String? searchText,
  }) async {
    final res = await _controller.viewModel.getObservationUser(
      conversationId: conversationId,
      isLoading: isLoading,
      limit: limit,
      searchText: searchText,
      skip: skip,
    );
    if (res != null) {
      return res;
    }
    return [];
  }
}

