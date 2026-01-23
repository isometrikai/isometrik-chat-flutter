part of '../isometrik_chat_flutter.dart';

/// Conversation operations mixin for IsmChat.
///
/// This mixin contains methods related to conversation CRUD operations.
/// It provides functionality for managing conversations including creating,
/// reading, updating, deleting, and searching conversations.
///
/// **Key Responsibilities:**
/// - Conversation CRUD operations
/// - Conversation search and filtering
/// - Conversation metadata management
/// - Conversation settings management
/// - Conversation counts and statistics
///
/// **Usage:**
/// ```dart
/// // Get all conversations
/// final conversations = await IsmChat.i.getAllConversationFromDB();
///
/// // Update conversation
/// await IsmChat.i.updateConversation(
///   conversationId: 'conv123',
///   metaData: IsmChatMetaData(title: 'New Title'),
/// );
/// ```
///
/// **See Also:**
/// - [IsmChatConversationModel] - Conversation data model
/// - [MODULE_CONTROLLERS.md] - Controllers documentation
mixin IsmChatConversationOperationsMixin {
  /// Gets the delegate instance.
  ///
  /// This getter provides access to the [IsmChatDelegate] instance.
  /// Since this mixin is `part of` the main library, we can access
  /// the private `_delegate` field through a dynamic cast.
  ///
  /// **Returns:**
  /// - [IsmChatDelegate]: The delegate instance that handles implementation.
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Call this function to get all conversation list from the local database.
  ///
  /// This function retrieves all conversations from the local database and returns a list of `IsmChatConversationModel` objects.
  ///
  /// Example:
  /// ```dart
  /// // Get all conversations from the local database
  /// List<IsmChatConversationModel>? conversations = await IsmChat.i.getAllConversationFromDB();
  /// ```
  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async =>
      await _delegate.getAllConversationFromDB();

  /// Retrieve all conversations from the local database.
  ///
  /// This function retrieves all conversations from the local database and updates the conversation list.
  ///
  /// Example:
  /// ```dart
  /// // Retrieve all conversations from the local database
  /// await IsmChat.i.getChatConversation();
  /// ```
  Future<void> getChatConversation() async =>
      await _delegate.getChatConversation();

  /// Update a conversation with new metadata.
  ///
  /// This function updates a conversation with new metadata. It requires the conversation ID and the new metadata.
  ///
  /// Parameters:
  /// [conversationId]: The ID of the conversation to update.
  /// [metaData]: The new metadata to update the conversation with.
  ///
  /// Example:
  /// ```dart
  /// // Update a conversation with new metadata
  /// await IsmChat.i.updateConversation(
  ///   conversationId: 'conversation_id',
  ///   metaData: IsmChatMetaData(title: 'New Title'),
  /// );
  /// ```
  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
  }) async =>
      await _delegate.updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  /// Update the settings of a conversation.
  ///
  /// This function updates the settings of a conversation. It requires the conversation ID and the new events.
  ///
  /// Parameters:
  /// [conversationId]: The ID of the conversation to update.
  /// [events]: The new events to update the conversation with.
  /// [isLoading]: Whether the conversation is currently loading. Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// // Update the settings of a conversation
  /// await IsmChat.i.updateConversationSetting(
  ///   conversationId: 'conversation_id',
  ///   events: IsmChatEvents(read: true, unread: false),
  /// );
  /// ```
  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async =>
      await _delegate.updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  /// Get the total count of conversations.
  ///
  /// This function retrieves the total count of conversations. It returns a future that resolves to an integer representing the count.
  ///
  /// Parameters:
  /// [isLoading]: Whether the conversation count is currently loading. Defaults to false.
  ///
  /// Returns:
  /// A future that resolves to an integer representing the total count of conversations.
  ///
  /// Example:
  /// ```dart
  /// // Get the total count of conversations
  /// int conversationCount = await IsmChat.i.getChatConversationsCount();
  /// print('Total conversations: $conversationCount');
  /// ```
  Future<int> getChatConversationsCount({
    bool isLoading = false,
  }) async =>
      await _delegate.getChatConversationsCount(isLoading: isLoading);

  /// Get the total count of messages in a conversation.
  ///
  /// This function retrieves the total count of messages in a conversation. It returns a future that resolves to an integer representing the count.
  ///
  /// Parameters:
  /// [isLoading]: Whether the message count is currently loading. Defaults to false.
  /// [converationId]: The ID of the conversation to get the message count for.
  /// [senderIds]: A list of sender IDs to filter the messages by.
  /// [senderIdsExclusive]: Whether to only include messages from the specified sender IDs. Defaults to false.
  /// [lastMessageTimestamp]: The timestamp of the last message to include in the count. Defaults to 0.
  ///
  /// Returns:
  /// A future that resolves to an integer representing the total count of messages in the conversation.
  ///
  /// Example:
  /// ```dart
  /// // Get the total count of messages in a conversation
  /// int messageCount = await IsmChat.i.getChatConversationsMessageCount(
  ///   converationId: 'conversation_id',
  ///   senderIds: ['sender_id_1', 'sender_id_2'],
  /// );
  /// print('Total messages: $messageCount');
  /// ```
  Future<int> getChatConversationsMessageCount({
    bool isLoading = false,
    required String converationId,
    required List<String> senderIds,
    bool senderIdsExclusive = false,
    int lastMessageTimestamp = 0,
  }) async =>
      await _delegate.getChatConversationsMessageCount(
        converationId: converationId,
        senderIds: senderIds,
        isLoading: isLoading,
        lastMessageTimestamp: lastMessageTimestamp,
        senderIdsExclusive: senderIdsExclusive,
      );

  /// Get the details of a conversation.
  ///
  /// This function retrieves the details of a conversation. It returns a future that resolves to an `IsmChatConversationModel` object.
  ///
  /// Parameters:
  /// [conversationId]: The ID of the conversation to get the details for.
  /// [includeMembers]: Whether to include the conversation members in the response. Defaults to null.
  /// [isLoading]: Whether the conversation details are currently loading. Defaults to false.
  ///
  /// Returns:
  /// A future that resolves to an `IsmChatConversationModel` object representing the conversation details.
  ///
  /// Example:
  /// ```dart
  /// // Get the details of a conversation
  /// IsmChatConversationModel? conversationDetails = await IsmChat.i.getConverstaionDetails(
  ///   conversationId: 'conversation_id',
  ///   includeMembers: true,
  /// );
  /// print('Conversation details: $conversationDetails');
  /// ```
  Future<IsmChatConversationModel?> getConverstaionDetails({
    bool isLoading = false,
  }) async =>
      await _delegate.getConverstaionDetails(
        isLoading: isLoading,
      );

  /// Deletes a chat with the specified conversation ID.
  ///
  /// This method delegates the deletion operation to the [_delegate].
  ///
  /// * `conversationId`: The ID of the conversation to delete.
  /// * `deleteFromServer`: Whether to delete the conversation from the server. Defaults to `true`.
  ///
  /// Returns a Future that completes when the deletion operation is finished.
  ///
  /// Example:
  ///
  /// ```dart
  /// await IsmChat.i.deleteChat('conversation123', deleteFromServer: true);
  /// ```
  Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
    bool shouldUpdateLocal = true,
  }) async {
    assert(
      conversationId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      conversationId cannot be empty.''',
    );
    await _delegate.deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
      shouldUpdateLocal: shouldUpdateLocal,
    );
  }

  /// Deletes a chat from the database with the specified Isometrick chat ID.
  ///
  /// This method delegates the deletion operation to the `_delegate`.
  ///
  /// * `isometrickChatId`: The ID of the Isometrick chat to delete.
  /// * `conversationId`: The ID of the conversation to delete. Defaults to an empty string.
  ///
  /// Returns a Future that completes with a boolean indicating whether the deletion was successful.
  ///
  /// Example:
  ///
  /// ```dart
  /// bool isDeleted = await IsmChat.i.deleteChatFormDB('isometrickChat123', conversationId: 'conversation123');
  /// ```
  Future<bool> deleteChatFormDB(
    String isometrickChatId, {
    String conversationId = '',
  }) async {
    assert(
      isometrickChatId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      isometrickChatId cannot be empty.''',
    );
    return await _delegate.deleteChatFormDB(
      isometrickChatId,
      conversationId: conversationId,
    );
  }

  /// Exits a group with the specified admin count and user admin status.
  ///
  /// This method delegates the exit operation to the [_delegate].
  ///
  /// * `adminCount`: The number of admins in the group.
  /// * `isUserAdmin`: Whether the user is an admin in the group.
  ///
  /// Returns a Future that completes when the exit operation is finished.
  ///
  /// Example:
  ///
  /// ```dart
  /// await IsmChat.i.exitGroup(adminCount: 2, isUserAdmin: true);
  /// ```
  Future<void> exitGroup({
    required int adminCount,
    required bool isUserAdmin,
  }) async =>
      await _delegate.exitGroup(
        adminCount: adminCount,
        isUserAdmin: isUserAdmin,
      );

  /// Clears all messages in a conversation with the specified ID.
  ///
  /// This method delegates the clearing operation to the [_delegate].
  ///
  /// * `conversationId`: The ID of the conversation to clear messages from.
  /// * `fromServer`: Whether to clear messages from the server. Defaults to `true`.
  ///
  /// Returns a Future that completes when the clearing operation is finished.
  ///
  /// Example:
  ///
  /// ```dart
  /// await IsmChat.i.clearAllMessages('conversation123', fromServer: true);
  /// ```
  Future<void> clearAllMessages(
    String conversationId, {
    bool fromServer = true,
  }) async {
    assert(
      conversationId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      conversationId cannot be empty.''',
    );
    await _delegate.clearAllMessages(conversationId, fromServer: fromServer);
  }

  /// Retrieves a conversation by its ID.
  ///
  /// @param conversationId The ID of the conversation to retrieve.
  /// @return A future that resolves to the conversation model, or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final conversation = await IsmChat.i.getConversation(conversationId: 'conversation-123');
  /// ```
  Future<IsmChatConversationModel?> getConversation({
    required String conversationId,
  }) async =>
      _delegate.getConversation(conversationId: conversationId);

  /// Fetches a list of chat conversations from the API.
  ///
  /// This method retrieves conversations with pagination support and search capabilities.
  ///
  /// Parameters:
  /// - skip : Number of conversations to skip (for pagination). Defaults to 0.
  /// - limit : Maximum number of conversations to retrieve. Defaults to 20.
  /// - searchTag : Optional search string to filter conversations.
  /// - includeConversationStatusMessagesInUnreadMessagesCount : Boolean flag to determine
  ///   whether to include status messages in unread count. Defaults to false.
  ///
  /// Returns:
  /// - Future<List<IsmChatConversationModel>> : A Future that resolves to a list of
  ///   conversation models.
  ///
  /// Example:
  /// ```dart
  /// final conversations = await IsmChat.i.getChatConversationApi(
  ///   skip: 0,
  ///   limit: 20,
  ///   searchTag: "John",
  ///   includeConversationStatusMessagesInUnreadMessagesCount: false,
  /// );
  /// ```
  Future<List<IsmChatConversationModel>> getChatConversationApi({
    int skip = 0,
    int limit = 20,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async =>
      await _delegate.getChatConversationApi(
        skip: skip,
        limit: limit,
        searchTag: searchTag,
        includeConversationStatusMessagesInUnreadMessagesCount:
            includeConversationStatusMessagesInUnreadMessagesCount,
      );

  /// Retrieves the count of unread messages across all conversations.
  ///
  /// This method fetches the total number of conversations that have unread messages
  /// for the current user.
  ///
  /// Parameters:
  /// - `isLoading` : Optional boolean parameter to control whether to show a loading indicator
  ///   during the API call. Defaults to false.
  ///
  /// Returns:
  /// - Future<void> : A Future that completes when the unread count has been retrieved
  ///   and updated in the system.
  ///
  /// Example:
  /// ```dart
  /// await  IsmChat.i.getChatConversationsUnreadCount(isLoading: true);
  /// ```
  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async =>
      await _delegate.getChatConversationsUnreadCount(isLoading: isLoading);

  /// Searches for conversations based on the provided search value.
  ///
  /// This method performs a search operation on conversations using the given search value.
  ///
  /// Parameters:
  /// - `searchValue`: The text to search for in conversations.
  ///
  /// Returns:
  /// - Future<void>: A future that completes when the search operation is finished.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.searchConversation(searchValue: "John");
  /// ```
  Future<void> searchConversation({required String searchValue}) async =>
      await _delegate.searchConversation(searchValue: searchValue);

  /// Retrieves chat conversations from the local database.
  ///
  /// This method fetches conversations stored locally on the device's database.
  /// It's useful for displaying offline conversation history or when you need
  /// to access conversations without making a network request.
  ///
  /// Parameters:
  /// - `searchTag`: Optional search string to filter conversations by title or content.
  ///   If provided, only conversations matching this search term will be returned.
  ///   If null or empty, all local conversations will be retrieved.
  ///
  /// Returns:
  /// - Future<void>: A Future that completes when the local conversations have been
  ///   retrieved and updated in the conversation controller.
  ///
  /// Example:
  /// ```dart
  /// // Get all local conversations
  /// await IsmChat.i.getChatConversationFromLocal();
  ///
  /// // Get local conversations matching a search term
  /// await IsmChat.i.getChatConversationFromLocal(searchTag: "John");
  /// ```
  Future<void> getChatConversationFromLocal({
    String? searchTag,
  }) async =>
      await _delegate.getChatConversationFromLocal(searchTag: searchTag);
}

