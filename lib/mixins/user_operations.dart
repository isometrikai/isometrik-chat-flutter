part of '../isometrik_chat_flutter.dart';

/// User operations mixin for IsmChat.
///
/// This mixin contains methods related to user management (block/unblock, activity).
mixin IsmChatUserOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Call this function to get the list of non-blocked users.
  ///
  /// This function retrieves the list of users who are not blocked and returns a list of `SelectedMembers` objects.
  ///
  /// Example:
  /// ```dart
  /// // Get the list of non-blocked users
  /// List<SelectedMembers>? nonBlockedUsers = await IsmChat.i.getNonBlockUserList();
  /// ```
  Future<List<SelectedMembers>?> getNonBlockUserList() async =>
      await _delegate.getNonBlockUserList();

  /// Get all conversations of the current user.
  ///
  /// This property retrieves all conversations of the current user and returns a list of `IsmChatConversationModel` objects.
  ///
  /// Example:
  /// ```dart
  /// // Get all conversations of the current user
  /// List<IsmChatConversationModel> conversations = await IsmChat.i.userConversations;
  /// ```
  Future<List<IsmChatConversationModel>> get userConversations async =>
      await _delegate.userConversations;

  /// Get the total count of unread conversations.
  ///
  /// This property retrieves the total count of unread conversations and returns an integer value.
  ///
  /// Example:
  /// ```dart
  /// // Get the total count of unread conversations
  /// int count = await IsmChat.i.unreadCount;
  /// print('Total unread conversations: $count');
  /// ```
  Future<int> get unreadCount async => await _delegate.unreadCount;

  /// Unblock a user.
  ///
  /// This function unblocks a user. It returns a future that resolves to void.
  ///
  /// Parameters:
  /// [opponentId]: The ID of the user to unblock.
  /// [includeMembers]: Whether to include the user's members in the response. Defaults to false.
  /// [isLoading]: Whether the unblock operation is currently loading. Defaults to false.
  /// [fromUser]: Whether the unblock operation is initiated by the user. Defaults to false.
  ///
  /// Returns:
  /// A future that resolves to void when the unblock operation is complete.
  ///
  /// Example:
  /// ```dart
  /// // Unblock a user
  /// await IsmChat.i.unblockUser(
  ///   opponentId: 'user_id',
  ///   includeMembers: true,
  /// );
  /// print('User unblocked successfully');
  /// ```
  Future<void> unblockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
  }) async =>
      await _delegate.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );

  /// Blocks a user with the specified ID.
  ///
  /// This method delegates the blocking operation to the `_delegate`.
  ///
  /// * `opponentId`: The ID of the user to block.
  /// * `includeMembers`: Whether to include members of the blocked user in the blocking operation.
  /// * `isLoading`: Whether the blocking operation is currently in progress.
  /// * `fromUser`: Whether the blocking operation is initiated by the user.
  ///
  /// Returns a Future that completes when the blocking operation is finished.
  ///
  /// /// Example:
  /// ```dart
  /// // Block a user
  /// await IsmChat.i.blockUser(
  ///   opponentId: 'user123',
  ///   includeMembers: true,
  ///   isLoading: false,
  ///   fromUser: true
  /// );
  /// print('User Blocked successfully');
  /// ```
  Future<void> blockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async =>
      await _delegate.blockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );

  /// Retrieves a list of blocked users for the current user.
  ///
  /// This method fetches the list of users that have been blocked by the current user.
  ///
  /// Parameters:
  /// - `isLoading` : Optional boolean parameter to control whether to show a loading indicator
  ///   during the API call. Defaults to false.
  ///
  /// Returns:
  /// - Future<List<UserDetails>> : A Future that resolves to a list of UserDetails objects
  ///   representing the blocked users. Returns an empty list if no blocked users are found
  ///   or if there's an error.
  ///
  /// Example:
  /// ```dart
  /// final blockedUsers = await IsmChat.i.getBlockUser(isLoading: true);
  /// ```
  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async =>
      await _delegate.getBlockUser(isLoading: isLoading);

  /// Updates the lastActiveTimestamp in user metadata.
  ///
  /// This method should be called periodically (e.g., every 30 seconds) from outside the SDK
  /// to update the user's last active timestamp. It updates the metadata's customMetaData
  /// with the current timestamp.
  ///
  /// **Parameters:**
  /// - `isLoading`: Whether to show a loading indicator. Defaults to false.
  ///
  /// **Example usage from home screen:**
  /// ```dart
  /// // Set up a timer to update every 30 seconds
  /// Timer.periodic(Duration(seconds: 30), (timer) {
  ///   IsmChat.i.updateLastActiveTimestamp();
  /// });
  ///
  /// // Or call it manually
  /// await IsmChat.i.updateLastActiveTimestamp(isLoading: false);
  /// ```
  ///
  /// **Note:** This method updates the `lastActiveTimestamp` key in the user's metadata
  /// `customMetaData` field via the PATCH `/chat/user` API endpoint.
  Future<void> updateLastActiveTimestamp({bool isLoading = false}) async =>
      await _delegate.updateLastActiveTimestamp(isLoading: isLoading);
}

