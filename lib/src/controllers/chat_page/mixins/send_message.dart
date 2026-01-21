part of '../chat_page_controller.dart';

/// Main send message mixin that acts as a wrapper.
///
/// This mixin serves as the primary interface for message sending functionality.
/// The actual implementations are provided by the following specialized mixins:
/// - [IsmChatPageSendMessageCoreMixin] - Core message sending (sendMessage, sendTextMessage, etc.)
/// - [IsmChatPageSendMessageMediaMixin] - Media messages (images, videos)
/// - [IsmChatPageSendMessageAudioMixin] - Audio messages
/// - [IsmChatPageSendMessageDocumentMixin] - Document messages
/// - [IsmChatPageSendMessageLocationMixin] - Location messages
/// - [IsmChatPageSendMessageContactMixin] - Contact messages
/// - [IsmChatPageSendMessageBroadcastMixin] - Broadcast messages
/// - [IsmChatPageSendMessageReactionsMixin] - Reactions
///
/// All methods have been extracted to their respective mixin files for better
/// code organization and maintainability.
mixin IsmChatPageSendMessageMixin on GetxController {
  /// Gets the controller instance.
  /// 
  /// This getter attempts to use the current instance (this) first,
  /// and falls back to GetX lookup if needed. This prevents errors
  /// when the controller is accessed before it's fully registered in GetX.
  ///
  /// Note: This getter may be referenced by external code that uses
  /// this mixin type, so it's kept for backward compatibility.
  // ignore: unused_element
  IsmChatPageController get _controller {
    // If this is already an IsmChatPageController, use it directly
    // This prevents the "controller not found" error during initialization
    if (this is IsmChatPageController) {
      return this as IsmChatPageController;
    }
    // Fallback to GetX lookup for cases where mixin might be used elsewhere
    return IsmChatUtility.chatPageController;
  }
}
