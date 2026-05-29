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

    // Recompute lastMessageDetails from stored messages when needed.
    // This fixes cases after app restart where conversation.lastMessageDetails
    // falls back to "Conversation created" even though real messages exist in DB.
    final updatedConversations = <IsmChatConversationModel>[];
    for (final conv in dbConversations) {
      final messagesMap = conv.messages;
      final needsRecompute = (conv.lastMessageDetails == null) ||
          (conv.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.conversationCreated) ||
          (conv.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.block) ||
          (conv.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.unblock);

      if (!needsRecompute ||
          messagesMap == null ||
          messagesMap.isEmpty ||
          (conv.conversationId ?? '').isEmpty) {
        updatedConversations.add(conv);
        continue;
      }

      final messages = messagesMap.values.toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

      IsmChatMessageModel? lastReal;
      for (var i = messages.length - 1; i >= 0; i--) {
        final m = messages[i];
        if (m.customType == IsmChatCustomMessageType.date ||
            m.customType == IsmChatCustomMessageType.conversationCreated ||
            m.customType == IsmChatCustomMessageType.block ||
            m.customType == IsmChatCustomMessageType.unblock) {
          continue;
        }
        lastReal = m;
        break;
      }

      if (lastReal == null) {
        updatedConversations.add(conv);
        continue;
      }

      final base = conv.lastMessageDetails;
      final rebuilt = base != null
          ? base.copyWith(
              sentByMe: lastReal.sentByMe,
              senderId:
                  lastReal.senderInfo?.userId ?? lastReal.initiatorId ?? '',
              senderName: lastReal.senderInfo?.userName ??
                  lastReal.userName ??
                  lastReal.initiatorName ??
                  '',
              showInConversation: true,
              sentAt: lastReal.sentAt,
              messageType: lastReal.messageType?.value ?? 0,
              messageId: lastReal.messageId ?? '',
              conversationId:
                  lastReal.conversationId ?? conv.conversationId ?? '',
              body: lastReal.body,
              customType: lastReal.customType,
              action: lastReal.action,
              deliverCount: lastReal.deliveredTo?.length ?? 0,
              deliveredTo: lastReal.deliveredTo ?? const <MessageStatus>[],
              readCount: lastReal.readBy?.length ?? 0,
              readBy: lastReal.readBy ?? const <MessageStatus>[],
              initiatorId: lastReal.initiatorId,
              members:
                  lastReal.members?.map((e) => e.memberName ?? '').toList() ??
                      const <String>[],
              metaData: lastReal.metaData,
              audioOnly: lastReal.audioOnly,
              callDurations: lastReal.callDurations,
              meetingId: lastReal.meetingId,
              meetingType: lastReal.meetingType,
              isInvalidMessage: lastReal.isInvalidMessage,
            )
          : LastMessageDetails(
              showInConversation: true,
              sentAt: lastReal.sentAt,
              senderName: lastReal.senderInfo?.userName ??
                  lastReal.userName ??
                  lastReal.initiatorName ??
                  '',
              senderId:
                  lastReal.senderInfo?.userId ?? lastReal.initiatorId ?? '',
              messageType: lastReal.messageType?.value ?? 0,
              messageId: lastReal.messageId ?? '',
              conversationId:
                  lastReal.conversationId ?? conv.conversationId ?? '',
              body: lastReal.body,
              deliverCount: lastReal.deliveredTo?.length ?? 0,
              readCount: lastReal.readBy?.length ?? 0,
              sentByMe: lastReal.sentByMe,
              customType: lastReal.customType,
              members:
                  lastReal.members?.map((e) => e.memberName ?? '').toList() ??
                      const <String>[],
              action: lastReal.action,
              userId: lastReal.userId,
              initiatorId: lastReal.initiatorId,
              deliveredTo: lastReal.deliveredTo ?? const <MessageStatus>[],
              readBy: lastReal.readBy ?? const <MessageStatus>[],
              metaData: lastReal.metaData,
              audioOnly: lastReal.audioOnly,
              callDurations: lastReal.callDurations,
              meetingId: lastReal.meetingId,
              meetingType: lastReal.meetingType,
              isInvalidMessage: lastReal.isInvalidMessage,
            );

      final patched = conv.copyWith(
        lastMessageDetails: rebuilt,
        lastMessageSentAt: lastReal.sentAt,
      );
      updatedConversations.add(patched);
      // Persist so next restart also shows correct preview.
      await IsmChatConfig.dbWrapper?.saveConversation(conversation: patched);
    }

    _controller.conversations = updatedConversations;
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
      final rawSearchText = (searchTag ?? '').trim().toLowerCase();
      // Normalize multiple spaces so queries like "liam   theo" still match.
      final normalizedSearchText =
          rawSearchText.replaceAll(RegExp(r'\s+'), ' ');
      _controller.conversations = _controller.conversations.where((e) {
        // Use "contains" instead of "startsWith" so existing conversations
        // still match when the query appears mid-string (e.g., group titles).
        if (e.isGroup == true) {
          return (e.conversationTitle ?? '').toLowerCase().contains(
                    normalizedSearchText,
                  ) ||
              (e.searchableTags?.cast<String>().any(
                        (x) => x.toLowerCase().contains(normalizedSearchText),
                      ) ??
                  false);
        } else {
          final userName = (e.opponentDetails?.userName ?? '').toLowerCase();
          final firstName =
              (e.opponentDetails?.metaData?.firstName ?? '').toLowerCase();
          final lastName =
              (e.opponentDetails?.metaData?.lastName ?? '').toLowerCase();
          final identifier =
              (e.opponentDetails?.userIdentifier ?? '').toLowerCase();

          // Chat list usually displays "First Last". Support searching the same
          // string (and reverse order) in addition to username.
          final fullName = '$firstName $lastName'.trim();
          final fullNameRev = '$lastName $firstName'.trim();
          final normalizedFullName =
              fullName.replaceAll(RegExp(r'\s+'), ' ').trim();
          final normalizedFullNameRev =
              fullNameRev.replaceAll(RegExp(r'\s+'), ' ').trim();

          return userName.contains(normalizedSearchText) ||
              identifier.contains(normalizedSearchText) ||
              firstName.contains(normalizedSearchText) ||
              lastName.contains(normalizedSearchText) ||
              normalizedFullName.contains(normalizedSearchText) ||
              normalizedFullNameRev.contains(normalizedSearchText);
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

    // Always fallback to local filtering.
    //
    // Reason:
    // - Server-side search may not support searching by full name (first + last)
    //   even though UI displays it.
    // - If API returns empty for queries like "liam theo", we should still be able
    //   to match cached conversations locally.
    await _controller.getConversationsFromDB(
      searchTag: searchTag,
    );

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
      final response =
          await _controller.viewModel.deleteChat(conversationId ?? '');
      if (response?.hasError ?? true) return;
    }
    if (shouldUpdateLocal) {
      final isCurrentConversation =
          _controller.currentConversationId == conversationId;
      if (isCurrentConversation) {
        _controller.currentConversation = null;
        _controller.currentConversationId = '';
        _controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
        if (IsmChatUtility.chatPageControllerRegistered) {
          final chatPageController = IsmChatUtility.chatPageController;
          chatPageController
            ..messages.clear()
            ..conversation = null
            ..isMessageSeleted = false
            ..selectedMessage.clear()
            ..closeOverlay();
        }
      }
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
    return _controller.viewModel
        .clearAllMessages(conversationId, fromServer: fromServer);
  }

  /// Updates the current conversation with new details.
  ///
  /// `conversation`: The conversation model to update.
  Future<void> updateLocalConversation(
      IsmChatConversationModel conversation) async {
    _controller.currentConversation = conversation;
    _controller.currentConversationId = conversation.conversationId ?? '';

    // Save conversation to database to persist metadata and other changes
    await IsmChatConfig.dbWrapper?.saveConversation(conversation: conversation);
  }

  /// Updates a conversation's metadata on the server.
  ///
  /// `conversationId`: The ID of the conversation to update.
  /// `metaData`: The new metadata for the conversation.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool includeNullBlockedMessage = false,
    bool isLoading = false,
  }) async {
    final response = await _controller.viewModel.updateConversation(
      conversationId: conversationId,
      metaData: metaData,
      includeNullBlockedMessage: includeNullBlockedMessage,
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
