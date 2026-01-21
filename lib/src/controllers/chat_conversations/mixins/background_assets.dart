part of '../chat_conversations_controller.dart';

/// Background assets mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to loading and managing background
/// assets (images and colors) for chat conversations.
mixin IsmChatConversationsBackgroundAssetsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Fetches the list of asset files from a JSON file.
  Future<AssetsModel?> getAssetFilesList() async {
    final jsonString = await rootBundle.loadString(
        'packages/isometrik_chat_flutter/assets/assets_backgroundAssets.json');
    final filesList = jsonDecode(jsonString);
    if (filesList != null) {
      return AssetsModel.fromMap(filesList);
    }
    return null;
  }

  /// Retrieves background assets and populates the background image and color lists.
  Future<void> getBackGroundAssets() async {
    var assets = await getAssetFilesList();
    if (assets != null) {
      _controller.backgroundImage = assets.images;
      _controller.backgroundColor = assets.colors;
    }
  }
}

