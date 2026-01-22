part of '../isometrik_chat_flutter.dart';

/// Message operations mixin for IsmChat.
///
/// This mixin contains methods related to message operations.
mixin IsmChatMessageOperationsMixin {
  /// Gets the delegate instance.
  /// Access _delegate directly since we're in the same library (part of).
  IsmChatDelegate get _delegate => (this as dynamic)._delegate as IsmChatDelegate;

  /// Retrieves a list of chat messages from the API.
  ///
  /// This method fetches a list of chat messages from the API for a given
  /// `conversationId` and `lastMessageTimestamp`. It also allows specifying
  /// the `limit` and `skip` parameters for pagination, as well as an optional
  /// `searchText` for filtering messages.
  ///
  /// Parameters:
  /// - `conversationId`: The ID of the conversation to retrieve messages from.
  /// - `lastMessageTimestamp`: The timestamp of the last message to retrieve.
  /// - `limit`: The maximum number of messages to retrieve (default: 20).
  /// - `skip`: The number of messages to skip (default: 0).
  /// - `searchText`: An optional search text to filter messages by.
  /// - `isLoading`: Whether the operation is currently loading.
  ///
  /// Returns:
  /// A list of `IsmChatMessageModel` objects, or null if no messages are found.
  ///
  /// Example:
  /// ```dart
  /// final messages = await IsmChat.i.getMessagesFromApi(
  ///   conversationId: 'conversation123',
  ///   lastMessageTimestamp: 1643723400,
  ///   limit: 30,
  ///   skip: 10,
  ///   searchText: 'hello',
  /// );
  /// ```
  Future<List<IsmChatMessageModel>?> getMessagesFromApi({
    required String conversationId,
    required int lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
  }) async =>
      await _delegate.getMessagesFromApi(
        conversationId: conversationId,
        lastMessageTimestamp: lastMessageTimestamp,
        limit: limit,
        skip: skip,
        searchText: searchText,
        isLoading: isLoading,
      );

  /// Retrieves messages from the local database for a specific conversation.
  ///
  /// This method fetches all messages associated with the given conversation ID
  ///
  /// Parameters:
  /// - `conversationId`: The ID of the conversation to retrieve messages for.
  ///
  /// Returns:
  /// - Future<void>: A future that completes when the messages have been retrieved.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.getMessagesFromDB(conversationId: "conv123");
  /// ```
  Future<void> getMessagesFromDB({required String conversationId}) async =>
      await _delegate.getMessagesFromDB(conversationId: conversationId);

  /// Updates an existing message in the chat system.
  ///
  /// This method updates the content or properties of an existing message.
  ///
  /// Parameters:
  /// - `message`: The updated message model containing the new information.
  ///
  /// Returns:
  /// - Future<void>: A future that completes when the message has been updated.
  ///
  /// Example:
  /// ```dart
  /// final updatedMessage = IsmChatMessageModel();
  /// await IsmChat.i.updateMessage(message: updatedMessage);
  /// ```
  Future<void> updateMessage({required IsmChatMessageModel message}) async =>
      await _delegate.updateMessage(message: message);

  /// Updates the metadata of a specific message in a conversation.
  ///
  /// This method allows updating the metadata associated with a message,
  ///
  /// Parameters:
  /// - `messageId`: The ID of the message to update.
  /// - `conversationId`: The ID of the conversation containing the message.
  /// - `isOpponentMessage`: Whether the message is from the opponent. Defaults to false.
  /// - `metaData`: The new metadata to associate with the message. Can be null.
  ///
  /// Returns:
  /// - Future<void>: A future that completes when the metadata has been updated.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.updateMessageMetaData(
  ///   messageId: "msg123",
  ///   conversationId: "conv123",
  ///   isOpponentMessage: false,
  ///   metaData: IsmChatMetaData()
  /// );
  /// ```
  Future<void> updateMessageMetaData({
    required String messageId,
    required String conversationId,
    bool isOpponentMessage = false,
    IsmChatMetaData? metaData,
  }) async {
    await _delegate.updateMessageMetaData(
      messageId: messageId,
      conversationId: conversationId,
      isOpponentMessage: isOpponentMessage,
      metaData: metaData,
    );
  }

  /// Retrieves a message on the chat page.
  ///
  /// This method is used to fetch a message on the chat page. It can be used to
  /// retrieve a message from a broadcast or a regular chat.
  ///
  /// Args:
  ///   isBroadcast (bool): Whether the message is from a broadcast or not.
  ///       Defaults to false.
  ///
  /// Returns:
  ///   Future<void>: A future that completes when the message has been retrieved.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.getMessageOnChatPage(isBroadcast: true);
  /// ```
  Future<void> getMessageOnChatPage({
    bool isBroadcast = false,
  }) async =>
      await _delegate.getMessageOnChatPage(isBroadcast: isBroadcast);

  /// Retrieves the current list of messages in the active conversation.
  ///
  /// This method returns the messages from the currently active chat conversation.
  /// If there is no active ChatPageController or no active conversation,
  /// it returns an empty list.
  ///
  /// Returns:
  /// - List<IsmChatMessageModel> : A list of chat messages in the current conversation.
  ///   Returns an empty list if no messages exist or if there's no active conversation.
  ///
  /// Example:
  /// ```dart
  /// final messages = IsmChat.i.currentConversatonMessages();
  /// ```
  List<IsmChatMessageModel> currentConversatonMessages() =>
      _delegate.currentConversatonMessages();
}

