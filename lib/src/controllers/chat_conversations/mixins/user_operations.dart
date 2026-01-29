part of '../chat_conversations_controller.dart';

/// User operations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to user data management, profile updates,
/// image uploads, and user blocking/unblocking operations.
mixin IsmChatConversationsUserOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Fetches user data from the server and updates the local database.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> getUserData({bool isLoading = false}) async {
    final user = await _controller.viewModel.getUserData(isLoading: isLoading);
    if (user != null) {
      _controller.userDetails = user;
      if (!kIsWeb) {
        if (_controller.userDetails?.metaData?.assetList?.isNotEmpty == true) {
          final assetList = _controller.userDetails?.metaData?.assetList?.toList() ?? [];
          final indexOfAsset = assetList
              .indexWhere((e) => e.values.first.srNoBackgroundAssset == 100);
          if (indexOfAsset != -1) {
            final pathName = assetList[indexOfAsset]
                    .values
                    .first
                    .imageUrl
                    ?.split('/')
                    .last ??
                '';
            final filePath = await IsmChatUtility.makeDirectoryWithUrl(
                urlPath: assetList[indexOfAsset].values.first.imageUrl ?? '',
                fileName: pathName);
            assetList[indexOfAsset] = {
              '${assetList[indexOfAsset].keys}': IsmChatBackgroundModel(
                color: assetList[indexOfAsset].values.first.color,
                isImage: assetList[indexOfAsset].values.first.isImage,
                imageUrl: filePath.path,
                srNoBackgroundAssset:
                    assetList[indexOfAsset].values.first.srNoBackgroundAssset,
              )
            };
          }
          _controller.userDetails = _controller.userDetails?.copyWith(
              metaData: _controller.userDetails?.metaData?.copyWith(assetList: assetList));
        }
      }

      await IsmChatConfig.dbWrapper?.userDetailsBox
          .put(IsmChatStrings.userData, _controller.userDetails?.toJson() ?? '');
    }
  }

  /// Updates user data on the server.
  ///
  /// `userProfileImageUrl`: The URL of the user's profile image.
  ///  `userName`: The user's name.
  /// `userIdentifier`: The user's identifier.
  /// `metaData`: Additional metadata for the user.
  /// `isloading`: Indicates if loading should be shown.
  Future<void> updateUserData({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    Map<String, dynamic>? metaData,
    bool isloading = false,
  }) async {
    await _controller.viewModel.updateUserData(
      userProfileImageUrl: userProfileImageUrl,
      userName: userName,
      userIdentifier: userIdentifier,
      metaData: metaData,
      isloading: isloading,
    );
  }

  /// Updates the user's profile image.
  ///
  /// `source`: The source of the image to upload.
  void updateUserDetails(ImageSource source) async {
    IsmChatRoute.goBack();
    final imageUrl = await _controller.ismUploadImage(source);
    if (imageUrl.isNotEmpty) {
      await _controller.updateUserData(
        userProfileImageUrl: imageUrl,
        isloading: true,
      );
      await _controller.getUserData(
        isLoading: true,
      );
    }
  }

  /// Uploads an image and returns the URL of the uploaded image.
  ///
  /// `imageSource`: The source of the image to upload.
  Future<String> ismUploadImage(ImageSource imageSource) async {
    var file = await IsmChatUtility.pickMedia(imageSource);
    if (file.isEmpty) {
      return '';
    }

    Uint8List? bytes;
    String? extension;
    if (kIsWeb) {
      bytes = await file.first?.readAsBytes();
      extension = 'jpg';
    } else {
      bytes = await file.first?.readAsBytes();
      extension = file.first?.path.split('.').last;
    }
    return await _controller.getPresignedUrl(
      extension!,
      bytes!,
      true,
    );
  }

  /// Changes the profile image for a group.
  ///
  /// `imageSource`: The source of the image to upload.
  Future<void> ismChangeImage(ImageSource imageSource) async {
    var file = await IsmChatUtility.pickMedia(imageSource);
    if (file.isEmpty) {
      return;
    }

    final bytes = await file.first?.readAsBytes();
    final fileExtension = file.first?.path.split('.').last;
    await _controller.getPresignedUrl(fileExtension ?? '', bytes ?? Uint8List(0));
  }

  /// Retrieves a presigned URL for uploading media.
  ///
  ///  `mediaExtension`: The extension of the media file.
  ///  `bytes`: The bytes of the media file.
  ///  `isLoading`: Indicates if loading should be shown.
  Future<String> getPresignedUrl(
    String mediaExtension,
    Uint8List bytes, [
    bool isLoading = false,
  ]) async {
    final response = await _controller.commonController.getPresignedUrl(
        isLoading: true,
        userIdentifier: _controller.userDetails?.userIdentifier ?? '',
        mediaExtension: mediaExtension,
        bytes: bytes);

    if (response == null) {
      return '';
    }
    final responseCode = await _controller.commonController.updatePresignedUrl(
      presignedUrl: response.presignedUrl,
      bytes: bytes,
      isLoading: isLoading,
    );
    if (responseCode == 200) {
      _controller.profileImage = response.mediaUrl ?? '';
    }
    return _controller.profileImage;
  }

  /// Unblocks a user based on their opponent ID
  ///
  /// `opponentId`: The ID of the user to unblock.
  /// `isLoading`: Indicates if loading should be shown.
  /// `fromUser` : Indicates if the unblock action is initiated by the user.
  Future<bool> unblockUser({
    required String opponentId,
    required bool isLoading,
    bool fromUser = false,
  }) async {
    final data = await _controller.viewModel.unblockUser(
      opponentId: opponentId,
      isLoading: isLoading,
    );
    if (data?.hasError ?? true) {
      return false;
    }
    unawaited(_controller.getBlockUser());
    // IsmChatUtility.showToast(IsmChatStrings.unBlockedSuccessfully);
    if (fromUser) {
      return false;
    }
    return true;
  }

  ///  Unblocks a user for web-based chat.
  ///
  /// `opponentId`: The ID of the user to unblock.
  void unblockUserForWeb(String opponentId) {
    if (IsmChatUtility.chatPageControllerRegistered) {
      var conversationId = _controller.getConversationId(opponentId);
      final chatPageController = IsmChatUtility.chatPageController;
      if (conversationId == chatPageController.conversation?.conversationId) {
        chatPageController.unblockUser(
          opponentId: opponentId,
          isLoading: false,
          userBlockOrNot: true,
        );
      }
    }
  }

  /// Retrieves a list of blocked users.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async {
    final users = await _controller.viewModel.getBlockUser(
      skip: 0,
      limit: 20,
      isLoading: isLoading,
    );
    if (users != null) {
      _controller.blockUsers = users.users;
    } else {
      _controller.blockUsers = [];
    }
    return _controller.blockUsers;
  }
}

