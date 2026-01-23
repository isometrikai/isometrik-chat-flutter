part of '../isometrik_chat_flutter.dart';

/// Properties mixin for IsmChat.
///
/// This mixin contains getters and setters for configuration and state properties.
mixin IsmChatPropertiesMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Gets the [IsmChatConfig] instance.
  IsmChatConfig? get ismChatConfig => _delegate.ismChatConfig;

  /// Gets the [IsmChatCommunicationConfig] instance.
  ///
  /// Throws an [AssertionError] if the MQTT controller has not been initialized.
  IsmChatCommunicationConfig? get config {
    assert(
      IsmChat._initialized,
      'IsmChat is not initialized, initialize it using IsmChat.initialize(config)',
    );
    return _delegate.config;
  }

  /// Gets the unread conversation messages.
  String get unReadConversationCount => _delegate.unReadConversationCount;

  /// Gets or sets the tag associated with the chat page.
  ///
  /// @return The current tag value, or null if not set.
  ///
  /// Example:
  /// ```dart
  /// print(chatPageTag); // prints the current tag value
  /// chatPageTag = 'new-tag'; // sets a new tag value
  /// ```
  String? get chatPageTag => _delegate.chatPageTag;
  set chatPageTag(String? value) => _delegate.chatPageTag = value;

  /// Gets or sets the tag associated with the chat list page.
  ///
  /// @return The current tag value, or null if not set.
  ///
  /// Example:
  /// ```dart
  /// print(chatListPageTag); // prints the current tag value
  /// chatListPageTag = 'new-tag'; // sets a new tag value
  /// ```
  String? get chatListPageTag => _delegate.chatListPageTag;
  set chatListPageTag(String? value) => _delegate.chatListPageTag = value;
}

