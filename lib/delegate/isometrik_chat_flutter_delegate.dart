part of '../isometrik_chat_flutter.dart';

/// Main delegate class for IsmChat SDK.
///
/// This class uses mixins to organize functionality into focused modules:
/// - [IsmChatDelegateInitializationMixin]: SDK initialization and MQTT setup
/// - [IsmChatDelegateMqttMixin]: MQTT event handling and topic management
/// - [IsmChatDelegateUiMixin]: UI state management and view updates
/// - [IsmChatDelegateConversationMixin]: Conversation CRUD operations
/// - [IsmChatDelegateUserMixin]: User management (block/unblock, activity)
/// - [IsmChatDelegateMessageMixin]: Message operations
/// - [IsmChatDelegateCleanupMixin]: Database and resource cleanup
/// - [IsmChatDelegateNavigationMixin]: Navigation from outside chat context
/// - [IsmChatDelegateNotificationMixin]: Push notification handling
class IsmChatDelegate
    with
        IsmChatDelegateInitializationMixin,
        IsmChatDelegateMqttMixin,
        IsmChatDelegateUiMixin,
        IsmChatDelegateConversationMixin,
        IsmChatDelegateUserMixin,
        IsmChatDelegateMessageMixin,
        IsmChatDelegateCleanupMixin,
        IsmChatDelegateNavigationMixin,
        IsmChatDelegateNotificationMixin {
  const IsmChatDelegate();

  // Configuration & State Management
  static IsmChatCommunicationConfig? _config;
  IsmChatCommunicationConfig? get config => _config;

  static IsmChatConfig? _ismChatConfig;
  IsmChatConfig? get ismChatConfig => _ismChatConfig;

  static final RxString _unReadConversationCount = ''.obs;
  String get unReadConversationCount => _unReadConversationCount.value;
  set unReadConversationCount(String value) =>
      _unReadConversationCount.value = value;

  static final Rx<String?> _chatPageTag = Rx<String?>(null);
  String? get chatPageTag => _chatPageTag.value;
  set chatPageTag(String? value) => _chatPageTag.value = value;

  static final Rx<String?> _chatListPageTag = Rx<String?>(null);
  String? get chatListPageTag => _chatListPageTag.value;
  set chatListPageTag(String? value) => _chatListPageTag.value = value;
}
