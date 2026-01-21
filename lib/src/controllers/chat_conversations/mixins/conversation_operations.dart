part of '../chat_conversations_controller.dart';

/// Conversation operations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to conversation management including
/// fetching, updating, deleting, and searching conversations.
mixin IsmChatConversationsConversationOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Retrieves conversations from the local database and updates the observable list.
  ///
  /// `searchTag`: Optional search term for filtering conversations.
  Future<void> getConversationsFromDB({
    String? searchTag,
  }) async {
    final dbConversations =
        await IsmChatConfig.dbWrapper?.getAllConversations() ?? [];

    _controller.conversations.clear();
    if (dbConversations.isEmpty == true) {
      IsmChatProperties.conversationProperties.conversationListEmptyOrNot
          ?.call(dbConversations.isEmpty);
      return;
    }
    _controller.conversations = dbConversations;
    _controller.isConversationsLoading = false;
    if (_controller.conversations.length <= 1) {
      IsmChatProperties.conversationProperties.conversationListEmptyOrNot
          ?.call(_controller.conversations.isEmpty);
      return;
    }
    _controller.conversations.sort((a, b) => (b.lastMessageDetails?.sentAt ?? 0)
        .compareTo(a.lastMessageDetails?.sentAt ?? 0));
    final opponentEmptyData = <IsmChatConversationModel>[];
    final opponentData = <IsmChatConversationModel>[];
    for (var x in _controller.conversations) {
      if (x.isGroup == false && x.opponentDetails?.userId.isEmpty == true) {
        opponentEmptyData.add(x);
      } else {
        opponentData.add(x);
      }
    }
    opponentData.addAll(opponentEmptyData);
    _controller.conversations = opponentData;

    if (searchTag?.isNotEmpty == true) {
      final lowerSearchText = (searchTag ?? '').toLowerCase();
      _controller.conversations = _controller.conversations.where((e) {
        if (e.isGroup == true) {
          return (e.conversationTitle ?? '')
                  .toLowerCase()
                  .startsWith(lowerSearchText) ||
              (e.searchableTags?.cast<String>().any(
                        (x) => x.toLowerCase().startsWith(lowerSearchText),
                      ) ??
                  false);
        } else {
          return (e.opponentDetails?.userName ?? '')
                  .toLowerCase()
                  .startsWith(lowerSearchText) ||
              (e.opponentDetails?.metaData?.firstName ?? '')
                  .toLowerCase()
                  .startsWith(lowerSearchText) ||
              (e.opponentDetails?.metaData?.lastName ?? '')
                  .toLowerCase()
                  .startsWith(lowerSearchText);
        }
      }).toList();
    }

    if (IsmChatConfig.sortConversationWithIdentifier != null) {
      var target = IsmChatConfig.sortConversationWithIdentifier?.call();
      _controller.conversations.sort((a, b) {
        if (a.opponentDetails?.userIdentifier == target) {
          return -1;
        }
        if (b.opponentDetails?.userIdentifier == target) {
          return 1;
        }
        return -1;
      });
    }

    IsmChatProperties.conversationProperties.conversationListEmptyOrNot
        ?.call(_controller.conversations.isEmpty);
  }

  /// Fetches chat conversations from the server and updates the local
  ///
  /// `skip`: Number of conversations to skip.
  /// `origin`: The origin of the API call (e.g., refresh, load more).
  /// `searchTag`: Optional search term for filtering conversations.
  Future<void> getChatConversations({
    int skip = 0,
    ApiCallOrigin? origin,
    String? searchTag,
  }) async {
    if (_controller.conversations.isEmpty) {
      _controller.isConversationsLoading = true;
    }
    var chats = await _controller.viewModel.getChatConversations(
      skip: skip,
      searchTag: searchTag,
    );

    if (IsmChatProperties.conversationModifier != null) {
      chats = await Future.wait(
        chats.map(
          (e) async => await IsmChatProperties.conversationModifier!(e),
        ),
      );
      await Future.wait(
        chats.map(
          (e) async =>
              await IsmChatConfig.dbWrapper?.createAndUpdateConversation(e),
        ),
      );
    }

    if (origin == ApiCallOrigin.referesh) {
      _controller.refreshController.refreshCompleted(
        resetFooterState: true,
      );
      _controller.refreshControllerOnEmptyList.refreshCompleted(
        resetFooterState: true,
      );
    } else if (origin == ApiCallOrigin.loadMore) {
      if (chats.isEmpty) {
        _controller.refreshController.loadNoData();
        _controller.refreshControllerOnEmptyList.loadNoData();
      } else {
        _controller.refreshController.loadComplete();
        _controller.refreshControllerOnEmptyList.loadComplete();
      }
    }

    if (chats.isEmpty && searchTag != null) {
      _controller.conversations.clear();
    } else {
      await _controller.getConversationsFromDB(
        searchTag: searchTag,
      );
    }

    if (_controller.conversations.isEmpty) {
      _controller.isConversationsLoading = false;
    }
  }

  /// Fetches search results for chat conversations.
  ///
  /// `skip`: Number of conversations to skip.
  /// `origin`: The origin of the API call (e.g., refresh, load more).
  /// `chatLimit`: Maximum number of chat results to return.
  Future<void> getChatSearchConversations({
    int skip = 0,
    ApiCallOrigin? origin,
    int chatLimit = 20,
  }) async {
    if (_controller.searchConversationList.isEmpty) {
      _controller.isConversationsLoading = true;
    }

    final response = await _controller.viewModel.getChatConversations(
      skip: skip,
      chatLimit: chatLimit,
    );

    _controller.searchConversationList = response;

    if (origin == ApiCallOrigin.referesh) {
      _controller.searchConversationrefreshController.refreshCompleted(
        resetFooterState: true,
      );
    } else if (origin == ApiCallOrigin.loadMore) {
      _controller.searchConversationrefreshController.loadComplete();
    }
    _controller.isConversationsLoading = false;
  }

  /// Retrieves the conversation ID for a given user ID.
  ///
  /// `userId`: The ID of the user to find the conversation for.
  String getConversationId(String userId) {
    final conversation = _controller.conversations.firstWhere(
        (element) => element.opponentDetails?.userId == userId,
        orElse: IsmChatConversationModel.new);

    if (conversation.conversationId == null) {
      return '';
    }
    return conversation.conversationId ?? '';
  }

  /// Retrieves a conversation model based on the conversation ID.
  ///
  /// `conversationId`: The ID of the conversation to retrieve.
  IsmChatConversationModel? getConversation(String conversationId) {
    final conversation = _controller.conversations.firstWhere(
        (element) => element.conversationId == conversationId,
        orElse: IsmChatConversationModel.new);

    if (conversation.conversationId == null) {
      return null;
    }
    return conversation;
  }

  /// Deletes a chat based on the conversation ID
  ///
  /// `conversationId`: The ID of the conversation to delete.
  /// `deleteFromServer`: Indicates if the chat should be deleted from the server.
  /// `shouldUpdateLocal`: Indicates if the local database should be updated.
  Future<void> deleteChat(
    String? conversationId, {
    bool deleteFromServer = true,
    bool shouldUpdateLocal = true,
  }) async {
    if (conversationId.isNullOrEmpty) return;

    if (deleteFromServer) {
      final response = await _controller.viewModel.deleteChat(conversationId ?? '');
      if (response?.hasError ?? true) return;
    }
    if (shouldUpdateLocal) {
      await IsmChatConfig.dbWrapper?.removeConversation(conversationId ?? '');
      await _controller.getConversationsFromDB();
      if (deleteFromServer) {
        await _controller.getChatConversations();
      }
    }
  }

  /// Clears all messages in a conversation.
  ///
  /// `conversationId`: The ID of the conversation to clear messages from.
  ///  `fromServer`: Indicates if the clear action should be performed on the server.
  Future<void> clearAllMessages(String? conversationId,
      {bool fromServer = true}) async {
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }
    return _controller.viewModel.clearAllMessages(conversationId, fromServer: fromServer);
  }

  /// Updates the current conversation with new details.
  ///
  /// `conversation`: The conversation model to update.
  void updateLocalConversation(IsmChatConversationModel conversation) {
    _controller.currentConversation = conversation;
    _controller.currentConversationId = conversation.conversationId ?? '';
  }

  /// Updates a conversation's metadata on the server.
  ///
  /// `conversationId`: The ID of the conversation to update.
  /// `metaData`: The new metadata for the conversation.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool isLoading = false,
  }) async {
    final response = await _controller.viewModel.updateConversation(
      conversationId: conversationId,
      metaData: metaData,
      isLoading: isLoading,
    );
    if (response?.hasError == false) {
      await _controller.getChatConversations();
    }
  }

  /// Updates the settings of a conversation.
  ///
  /// `conversationId`: The ID of the conversation to update.
  /// `events`: The events to update in the conversation.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async {
    await _controller.viewModel.updateConversationSetting(
      conversationId: conversationId,
      events: events,
      isLoading: isLoading,
    );
  }

  /// Filters suggestions based on the search query.
  ///
  /// `query`: The search query to filter suggestions.
  void onSearch(String query) {
    if (query.trim().isEmpty) {
      _controller.suggestions = _controller.conversations;
    } else {
      _controller.suggestions = _controller.conversations
          .where(
            (e) =>
                e.chatName.didMatch(query) ||
                e.lastMessageDetails!.body.didMatch(query),
          )
          .toList();
    }
  }
}

