import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

import '../chat_page_controller.dart';

/// Mixin for handling message reactions in the chat page controller.
/// 
/// This mixin provides functionality for adding reactions to messages.
/// It is separated from the main send_message mixin to improve code organization
/// and maintainability.
mixin IsmChatPageSendMessageReactionsMixin on GetxController {
  /// Gets the controller instance.
  /// 
  /// This getter attempts to use the current instance (this) first,
  /// and falls back to GetX lookup if needed. This prevents errors
  /// when the controller is accessed before it's fully registered in GetX.
  IsmChatPageController get _controller {
    // If this is already an IsmChatPageController, use it directly
    // This prevents the "controller not found" error during initialization
    if (this is IsmChatPageController) {
      return this as IsmChatPageController;
    }
    // Fallback to GetX lookup for cases where mixin might be used elsewhere
    return IsmChatUtility.chatPageController;
  }

  /// Adds a reaction to a message.
  /// 
  /// [reaction] - The reaction to add, containing messageId and emoji information.
  /// 
  /// Returns a Future that completes when the reaction has been added.
  /// If the messageId is empty, the method returns immediately without doing anything.
  Future<void> addReacton({required Reaction reaction}) async {
    if (reaction.messageId.isEmpty) {
      return;
    }
    final response = await _controller.viewModel.addReacton(reaction: reaction);
    if (response != null && !response.hasError) {
      await _controller.conversationController.getChatConversations();
    }
  }
}

