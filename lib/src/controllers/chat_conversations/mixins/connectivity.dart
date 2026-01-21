part of '../chat_conversations_controller.dart';

/// Connectivity mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to internet connectivity monitoring
/// and handling pending messages when connectivity is restored.
mixin IsmChatConversationsConnectivityMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Sets up connectivity listener to monitor internet connection changes.
  void _isInterNetConnect() {
    _controller.connectivity = Connectivity();
    _controller.connectivitySubscription =
        _controller.connectivity?.onConnectivityChanged.listen((event) {
      _sendPendingMessage();
    });
  }

  /// Sends any pending messages if the internet is available.
  void _sendPendingMessage() async {
    if (await IsmChatUtility.isNetworkAvailable) {
      if (_controller.currentConversation?.conversationId?.isNotEmpty == true) {
        {
          _controller.sendPendingMessgae(
              conversationId: _controller.currentConversation?.conversationId ?? '');
        }
      }
    }
  }
}

