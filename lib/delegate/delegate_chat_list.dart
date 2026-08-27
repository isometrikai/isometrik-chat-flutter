part of '../isometrik_chat_flutter.dart';

/// Chat-list actions for a host-app custom Messages screen.
///
/// Used when [IsmChatConversationProperties.conversationScreenBuilder]
/// replaces the default conversation UI. No-ops if the conversations
/// controller is not registered.
mixin IsmChatDelegateChatListMixin {
  IsmChatConversationsController? get _conversations {
    if (!IsmChatUtility.conversationControllerRegistered) {
      return null;
    }
    return IsmChatUtility.conversationController;
  }

  /// Filtered conversation list shown on the chat list (respects
  /// [IsmChatConversationProperties.conversationPredicate]).
  List<IsmChatConversationModel> get chatListConversations =>
      _conversations?.userConversations ?? const [];

  /// Whether the chat list is in its initial loading state.
  bool get isChatListLoading => _conversations?.isConversationsLoading ?? false;

  /// Pull-to-refresh (same path as the SDK list refresh).
  Future<void> refreshChatList() async {
    final controller = _conversations;
    if (controller == null) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    controller.searchConversationTEC.clear();
    await controller.getChatConversations(
      origin: ApiCallOrigin.referesh,
    );
    if (Get.isRegistered<IsmChatMqttController>()) {
      await Get.find<IsmChatMqttController>().getChatConversationsUnreadCount();
    }
  }

  /// Load the next page of conversations.
  Future<void> loadMoreChatList() async {
    final controller = _conversations;
    if (controller == null) {
      return;
    }
    await controller.getChatConversations(
      skip: controller.conversations.length.pagination(),
      origin: ApiCallOrigin.loadMore,
    );
  }

  /// Search conversations by [query]. Empty / whitespace clears search.
  Future<void> searchChatList(String query) async {
    final controller = _conversations;
    if (controller == null) {
      return;
    }
    final trimmed = query.trim();
    controller.searchConversationTEC.text = query;
    if (trimmed.isEmpty) {
      await controller.getChatConversations(
        origin: ApiCallOrigin.referesh,
      );
      return;
    }
    await controller.getChatConversations(
      searchTag: trimmed,
    );
  }

  /// Opens a conversation using the same path as the SDK list tap
  /// (mobile route push / web split pane).
  Future<void> openConversation(IsmChatConversationModel conversation) async {
    final controller = _conversations;
    if (controller == null) {
      return;
    }
    await controller.updateLocalConversation(conversation);
    await controller.goToChatPage();
  }
}
