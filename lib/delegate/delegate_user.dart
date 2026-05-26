part of '../isometrik_chat_flutter.dart';

/// User management mixin for IsmChatDelegate.
///
/// This mixin contains methods related to user operations such as blocking/unblocking,
/// getting blocked users, and updating user activity timestamps.
mixin IsmChatDelegateUserMixin {
  /// Gets current user data.
  ///
  /// Returns [UserDetails] on success, otherwise `null`.
  Future<Map<String, dynamic>?> getUserData({bool isLoading = false}) async {
    final repository = IsmChatConversationsRepository();
    final data = await repository.getIsometrikUserData(isLoading: isLoading);
    return data;
  }

  /// Updates current user's metadata.
  ///
  /// Returns `true` if update succeeds, otherwise `false`.
  Future<bool> updateUser({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    Map<String, dynamic>? metaData,
    bool isLoading = false,
  }) async {
    final repository = IsmChatConversationsRepository();
    final updatedUser = await repository.updateUserData(
      userProfileImageUrl: userProfileImageUrl,
      userName: userName,
      userIdentifier: userIdentifier,
      metaData: metaData,
      isloading: isLoading,
    );
    return updatedUser != null;
  }

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
}
