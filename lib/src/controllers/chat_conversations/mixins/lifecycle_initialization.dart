part of '../chat_conversations_controller.dart';

/// Lifecycle and initialization mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to controller lifecycle (onInit, onClose, dispose)
/// and initialization tasks like generating reaction lists.
mixin IsmChatConversationsLifecycleInitializationMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Initializes the controller, sets up internet connectivity, fetches user data, conversations, and background assets.
  @override
  onInit() async {
    super.onInit();
    _controller.intilizedContrller = false;
    _controller._isInterNetConnect();
    _generateReactionList();
    var users = await IsmChatConfig.dbWrapper?.userDetailsBox
        .get(IsmChatStrings.userData);
    if (users != null) {
      _controller.userDetails = UserDetails.fromJson(users);
    } else {
      await _controller.getUserData();
    }
    await _controller.getConversationsFromDB();
    await _controller.getChatConversations();
    if (Get.isRegistered<IsmChatMqttController>()) {
      final mqttController = Get.find<IsmChatMqttController>();
      await Future.wait([
        mqttController.getChatConversationsUnreadCount(),
        mqttController.getUserMessges(
          senderIds: [
            IsmChatConfig.communicationConfig.userConfig.userId.isNotEmpty
                ? IsmChatConfig.communicationConfig.userConfig.userId
                : _controller.userDetails?.userId ?? ''
          ],
        ),
      ]);
    }
    await _controller.getBackGroundAssets();
    unawaited(_controller.getBlockUser());
    _controller
      ..intilizedContrller = true
      ..scrollListener()
      ..sendPendingMessgae();
  }

  /// Cleans up resources when the controller is closed.
  @override
  void onClose() {
    onDispose();
    super.onClose();
  }

  /// Disposes of the controller and its resources.
  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  /// Custom dispose method to clean up specific resources.
  void onDispose() {
    _controller.conversationScrollController.dispose();
    _controller.searchConversationScrollController.dispose();
    _controller.connectivitySubscription?.cancel();
  }

  /// Generates a list of emoji reactions for the chat application.
  void _generateReactionList() {
    _controller.reactions
      ..clear()
      ..addAll(IsmChatEmoji.values
          .expand((typesOfEmoji) => defaultEmojiSet.expand((categoryEmoji) =>
              categoryEmoji.emoji
                  .where((emoji) => typesOfEmoji.emojiKeyword == emoji.name)))
          .toList());
  }
}
