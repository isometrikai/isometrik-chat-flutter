part of '../isometrik_chat_flutter.dart';

/// User management mixin for IsmChatDelegate.
///
/// This mixin contains methods related to user operations such as blocking/unblocking,
/// getting blocked users, and updating user activity timestamps.
mixin IsmChatDelegateUserMixin {
  /// Unblocks a user.
  Future<void> unblockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: true,
      );
    }
  }

  /// Blocks a user.
  Future<void> blockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.blockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: false,
      );
    }
  }

  /// Gets the list of blocked users.
  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      return await IsmChatUtility.conversationController
          .getBlockUser(isLoading: isLoading);
    } else {
      return [];
    }
  }

  /// Updates the lastActiveTimestamp in user metadata.
  ///
  /// This method should be called periodically (e.g., every 30 seconds) from outside the SDK
  /// to update the user's last active timestamp. It updates the metadata's customMetaData
  /// with the current timestamp.
  ///
  /// - `isLoading`: Whether to show a loading indicator. Defaults to false.
  ///
  /// Example usage from home screen:
  /// ```dart
  /// Timer.periodic(Duration(seconds: 30), (timer) {
  ///   IsmChat.i.updateLastActiveTimestamp();
  /// });
  /// ```
  Future<void> updateLastActiveTimestamp({bool isLoading = false}) async {
    try {
      // Create repository instance directly
      final repository = IsmChatConversationsRepository();

      // Get current user data from database first
      UserDetails? currentUser;
      var userDataJson = await IsmChatConfig.dbWrapper?.userDetailsBox
          .get(IsmChatStrings.userData);

      if (userDataJson != null) {
        currentUser = UserDetails.fromJson(userDataJson);
      }

      // If user details not in database, fetch from API
      currentUser ??= await repository.getUserData(isLoading: false);

      if (currentUser == null) {
        IsmChatLog.error(
            'Cannot update lastActiveTimestamp: User data not available');
        return;
      }

      // Get existing metadata or create new one
      final existingMetaData = currentUser.metaData ?? IsmChatMetaData();

      // Get existing customMetaData or create new map
      final existingCustomMetaData = Map<String, dynamic>.from(
        existingMetaData.customMetaData ?? {},
      );

      // Update lastActiveTimestamp with current timestamp in milliseconds
      existingCustomMetaData['lastActiveTimestamp'] =
          DateTime.now().millisecondsSinceEpoch;

      // Create updated metadata with new customMetaData
      final updatedMetaData = existingMetaData.copyWith(
        customMetaData: existingCustomMetaData,
      );

      // Update user data directly using repository
      await repository.updateUserData(
        metaData: updatedMetaData.toMap(),
        isloading: isLoading,
      );

      IsmChatLog.info(
          'Updated lastActiveTimestamp: ${existingCustomMetaData['lastActiveTimestamp']}');
    } catch (e, st) {
      IsmChatLog.error('Error updating lastActiveTimestamp: $e', st);
    }
  }
}
