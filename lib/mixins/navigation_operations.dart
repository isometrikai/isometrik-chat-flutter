part of '../isometrik_chat_flutter.dart';

/// Navigation operations mixin for IsmChat.
///
/// This mixin contains methods related to navigation from outside chat context.
mixin IsmChatNavigationOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Initiates a chat from outside the chat screen.
  ///
  /// This function allows you to start a chat with a user from anywhere in your app.
  /// It requires the user's name, user identifier, and user ID. You can also pass
  /// additional metadata, a callback to navigate to the chat screen, and more.
  ///
  /// Args:
  ///   - `profileImageUrl`: The URL of the user's profile image (optional).
  ///   - `name`: The user's name (required).
  ///   - `userIdentifier`: The user's identifier (required).
  ///   - `userId`: The user's ID (required).
  ///   - `metaData`: Additional metadata for the chat (optional).
  ///   - `onNavigateToChat`: A callback to navigate to the chat screen (optional).
  ///   - `duration`: The duration of the animation (optional, defaults to 500ms).
  ///   - `outSideMessage`: An outside message to display in the chat (optional).
  ///   - `storyMediaUrl`: The URL of the story media (optional).
  ///   - `pushNotifications`: Whether to enable push notifications (optional, defaults to true).
  ///   - `isCreateGroupFromOutSide`: Whether to create a group from outside (optional, defaults to false).
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.chatFromOutside(
  ///   name: 'John Doe',
  ///   userIdentifier: 'john.doe@example.com',
  ///   userId: '12345',
  ///   metaData: IsmChatMetaData(
  ///     title: 'Hello, World!',
  ///     description: 'This is a sample chat.',
  ///   ),
  ///   onNavigateToChat: (context, conversation) {
  ///     Navigator.push(
  ///       context,
  ///       MaterialPageRoute(builder: (context) => ChatScreen(conversation)),
  ///     );
  ///   },
  /// );
  /// ```
  Future<void> chatFromOutside({
    String profileImageUrl = '',
    required String name,
    required userIdentifier,
    required String userId,
    required bool online,
    IsmChatMetaData? metaData,
    ConversationVoidCallback? onNavigateToChat,
    ConversationVoidCallback? onConversationCreated,
    Duration duration = const Duration(milliseconds: 500),
    OutSideMessage? outSideMessage,
    String? storyMediaUrl,
    bool pushNotifications = true,
    bool isCreateGroupFromOutSide = false,
    String? conversationImageUrl,
    String? conversationTitle,
    String? customType,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
  }) async {
    assert(
      [name, userId].every((e) => e.isNotEmpty),
      '''Input Error: Please make sure that all required fields are filled out.
      Name, and userId cannot be empty.''',
    );
    if (isCreateGroupFromOutSide) {
      assert(
        [conversationImageUrl ?? '', conversationTitle ?? '']
            .every((e) => e.isNotEmpty),
        '''Input Error: Please make sure that all required fields are filled out.
      ConversationImageUrl, and ConversationTitle cannot be empty.''',
      );
    }

    await _delegate.chatFromOutside(
      name: name,
      userIdentifier: userIdentifier,
      online: online,
      userId: userId,
      duration: duration,
      isCreateGroupFromOutSide: isCreateGroupFromOutSide,
      outSideMessage: outSideMessage,
      metaData: metaData,
      onNavigateToChat: onNavigateToChat,
      profileImageUrl: profileImageUrl,
      pushNotifications: pushNotifications,
      storyMediaUrl: storyMediaUrl,
      conversationImageUrl: conversationImageUrl,
      conversationTitle: conversationTitle,
      customType: customType,
      conversationType: conversationType,
      onConversationCreated: onConversationCreated,
    );
  }

  /// Initiates a chat from outside the chat screen with a pre-existing conversation.
  ///
  /// This function allows you to start a conversation with a user from anywhere in your app,
  /// using an existing conversation model. It requires the conversation model, and optionally
  /// a callback to navigate to the chat conversation, a duration for the animation, and
  /// a flag to show a loader.
  ///
  /// Parameters:
  ///
  /// * `ismChatConversation`: The conversation model to use for the chat. (Required)
  /// * `onNavigateToChat`: A callback to navigate to the chat conversation.
  /// * `duration`: The duration of the animation to navigate to the chat conversation. (Default: 100ms)
  /// * `isShowLoader`: Whether to show a loader while navigating to the chat conversation. (Default: true)
  /// Example:
  ///
  /// ```dart
  /// IsmChatConversationModel conversation = IsmChatConversationModel(
  ///   id: '12345',
  ///   title: 'Hello from outside!',
  ///   description: 'This is a test message.',
  /// );
  ///
  /// await IsmChat.i.chatFromOutsideWithConversation(
  ///   ismChatConversation: conversation,
  ///   onNavigateToChat: (context, conversation) {
  ///     Navigator.push(
  ///       context,
  ///       MaterialPageRoute(builder: (context) => ChatScreen(conversation)),
  ///     );
  ///   },
  /// );
  /// ```
  ///
  Future<void> chatFromOutsideWithConversation({
    required IsmChatConversationModel ismChatConversation,
    void Function(BuildContext, IsmChatConversationModel)? onNavigateToChat,
    Duration duration = const Duration(milliseconds: 100),
    bool isShowLoader = true,
  }) async {
    await _delegate.chatFromOutsideWithConversation(
      ismChatConversation: ismChatConversation,
      duration: duration,
      isShowLoader: isShowLoader,
      onNavigateToChat: onNavigateToChat,
    );
  }

  /// Opens the conversation info screen for any user from outside the chat context.
  ///
  /// This function allows the host app to display conversation/contact info for any user
  /// without requiring an active chat session. Similar to [chatFromOutside], but for
  /// viewing conversation details instead of starting a chat.
  ///
  /// **Parameters:**
  /// - `profileImageUrl`: Profile image URL of the user (optional)
  /// - `name`: Display name of the user (required)
  /// - `userIdentifier`: Unique identifier for the user (email, phone, etc.) (required)
  /// - `userId`: Unique user ID (required)
  /// - `online`: Whether the user is currently online (required)
  /// - `metaData`: Optional metadata for the user
  /// - `conversationId`: Optional conversation ID. If provided, will use this directly.
  ///                     If not provided, will attempt to find/create conversation.
  /// - `isGroup`: Whether this is a group conversation (default: false)
  /// - `conversationImageUrl`: Optional conversation image URL for groups
  /// - `conversationTitle`: Optional conversation title for groups
  /// - `customType`: Optional custom type for the conversation
  /// - `conversationType`: Type of conversation (default: private)
  /// - `duration`: Duration for loader display (default: 500ms)
  /// - `isShowLoader`: Whether to show loader during initialization (default: true)
  ///
  /// **Example:**
  /// ```dart
  /// // Open conversation info for any user from outside
  /// await IsmChat.i.showConversationInfoFromOutside(
  ///   name: 'John Doe',
  ///   userIdentifier: 'john@example.com',
  ///   userId: 'user123',
  ///   online: true,
  ///   profileImageUrl: 'https://example.com/profile.jpg',
  /// );
  ///
  /// // Or with conversation ID
  /// await IsmChat.i.showConversationInfoFromOutside(
  ///   name: 'Jane Smith',
  ///   userIdentifier: 'jane@example.com',
  ///   userId: 'user456',
  ///   online: false,
  ///   conversationId: 'existing-conversation-id',
  /// );
  ///
  /// // For groups
  /// await IsmChat.i.showConversationInfoFromOutside(
  ///   name: 'Team Chat',
  ///   userIdentifier: 'team@example.com',
  ///   userId: 'group123',
  ///   online: true,
  ///   isGroup: true,
  ///   conversationTitle: 'My Team',
  ///   conversationImageUrl: 'https://example.com/group.jpg',
  /// );
  /// ```
  Future<void> showConversationInfoFromOutside({
    String profileImageUrl = '',
    required String name,
    required userIdentifier,
    required String userId,
    required bool online,
    IsmChatMetaData? metaData,
    String? conversationId,
    bool isGroup = false,
    String? conversationImageUrl,
    String? conversationTitle,
    String? customType,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
    Duration duration = const Duration(milliseconds: 500),
    bool isShowLoader = true,
  }) async {
    assert(
      [name, userId].every((e) => e.isNotEmpty),
      '''Input Error: Please make sure that all required fields are filled out.
      Name, and userId cannot be empty.''',
    );
    if (isGroup) {
      assert(
        [conversationImageUrl ?? '', conversationTitle ?? '']
            .every((e) => e.isNotEmpty),
        '''Input Error: Please make sure that all required fields are filled out.
      ConversationImageUrl, and ConversationTitle cannot be empty for groups.''',
      );
    }

    await _delegate.showConversationInfoFromOutside(
      name: name,
      userIdentifier: userIdentifier,
      userId: userId,
      online: online,
      profileImageUrl: profileImageUrl,
      metaData: metaData,
      conversationId: conversationId,
      isGroup: isGroup,
      conversationImageUrl: conversationImageUrl,
      conversationTitle: conversationTitle,
      customType: customType,
      conversationType: conversationType,
      duration: duration,
      isShowLoader: isShowLoader,
    );
  }
}

