part of '../isometrik_chat_flutter.dart';

/// Public chat-list actions for host-app custom Messages UI.
///
/// Pair with [IsmChatConversationProperties.conversationScreenBuilder].
/// Default chat-list UI is unchanged when that builder is omitted.
mixin IsmChatChatListOperationsMixin {
  IsmChatDelegate get _delegate =>
      (this as dynamic)._delegate as IsmChatDelegate;

  /// Filtered conversation list for the chat-list screen.
  ///
  /// Rebuild with `GetX` / `Obx` on [IsmChatConversationsController]
  /// (`tag: IsmChat.i.chatListPageTag`) to pick up MQTT / refresh updates.
  List<IsmChatConversationModel> get chatListConversations =>
      _delegate.chatListConversations;

  /// Whether the chat list is loading.
  bool get isChatListLoading => _delegate.isChatListLoading;

  /// Refresh the conversation list (pull-to-refresh).
  ///
  /// ```dart
  /// await IsmChat.i.refreshChatList();
  /// ```
  Future<void> refreshChatList() => _delegate.refreshChatList();

  /// Load more conversations (pagination).
  Future<void> loadMoreChatList() => _delegate.loadMoreChatList();

  /// Search conversations. Pass empty string to clear.
  Future<void> searchChatList(String query) => _delegate.searchChatList(query);

  /// Open a conversation (mobile push / web split pane).
  ///
  /// ```dart
  /// await IsmChat.i.openConversation(conversation);
  /// ```
  Future<void> openConversation(IsmChatConversationModel conversation) =>
      _delegate.openConversation(conversation);
}
