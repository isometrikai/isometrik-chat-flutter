library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';

export 'package:mqtt_helper/mqtt_helper.dart';

export 'src/app/app.dart';
export 'src/controllers/controllers.dart';
export 'src/data/data.dart';
export 'src/models/models.dart';
export 'src/repositories/repositories.dart';
export 'src/res/properties/properties.dart';
export 'src/res/res.dart';
export 'src/utilities/utilities.dart';
export 'src/view_models/view_models.dart';
export 'src/views/views.dart';
export 'src/widgets/widgets.dart';

part 'isometrik_chat_flutter_delegate.dart';

/// The main class for interacting with the Isometrik Flutter Chat SDK.
class IsmChat {
  /// Factory constructor for creating a new instance of [IsmChat].
  factory IsmChat() => instance;

  /// Private constructor for creating a new instance of [IsmChat].
  IsmChat._(this._delegate);

  /// The delegate used by this instance of [IsmChat].
  final IsmChatDelegate _delegate;

  /// The static instance of [IsmChat].
  static IsmChat i = IsmChat._(const IsmChatDelegate());

  /// The static instance of [IsmChat].
  static IsmChat instance = i;

  /// Whether the MQTT controller has been initialized.
  static bool _initialized = false;

  /// Gets the [IsmChatConfig] instance.
  IsmChatConfig? get ismChatConfig => _delegate.ismChatConfig;

  /// Gets the [IsmChatCommunicationConfig] instance.
  ///
  /// Throws an [AssertionError] if the MQTT controller has not been initialized.
  IsmChatCommunicationConfig? get config {
    assert(
      _initialized,
      'IsmChat is not initialized, initialize it using IsmChat.initialize(config)',
    );
    return _delegate.config;
  }

  /// Gets the unread conversation messages.
  String get unReadConversationCount => _delegate.unReadConversationCount;

  Future<String?> getPlatformVersion() =>
      IsometrikChatFlutterPlatform.instance.getPlatformVersion();

  /// Initializes the MQTT controller.
  ///
  /// `communicationConfig` is the configuration for the MQTT communication.
  /// `useDatabase` is whether to use a database. Defaults to `true`.
  /// `databaseName` is the name of the database. Defaults to `IsmChatStrings.dbname`.
  /// `showNotification` is the callback for showing notifications.
  /// `context` is the build context.
  /// `mqttProperties` is whether to set up MQTT. Defaults to `true`.
  Future<void> initialize({
    required IsmChatCommunicationConfig communicationConfig,
    required GlobalKey<NavigatorState> kNavigatorKey,
    bool useDatabase = true,
    String databaseName = IsmChatStrings.dbname,
    NotificaitonCallback? showNotification,
    bool shouldPendingMessageSend = true,
    SendMessageCallback? sendPaidWalletMessage,
    IsmPaidWalletConfig? paidWalletConfig,
    ResponseCallback? paidWalletMessageApiResponse,
    SortingConversationCallback? sortingConversationWithIdentifier,
    ConnectionStateCallback? mqttConnectionStatus,
    ResponseCallback? chatInvalidate,
    IsmMqttProperties? mqttProperties,
    bool? isMonthFirst,
  }) async {
    if (sendPaidWalletMessage != null) {
      assert(paidWalletConfig != null,
          'isPadiWalletMessage = true, paidWalletConfig should be mandatory');
    }
    if (paidWalletMessageApiResponse != null) {
      assert(sendPaidWalletMessage != null && paidWalletConfig != null,
          'isPadiWalletMessage = true, paidWalletConfig should be mandatory for isPaidWalletMessageApiResponse callback');
    }

    await _delegate.initialize(
      kNavigatorKey: kNavigatorKey,
      communicationConfig: communicationConfig,
      useDatabase: useDatabase,
      showNotification: showNotification,
      databaseName: databaseName,
      shouldPendingMessageSend: shouldPendingMessageSend,
      sendPaidWalletMessage: sendPaidWalletMessage,
      paidWalletConfig: paidWalletConfig,
      paidWalletMessageApiResponse: paidWalletMessageApiResponse,
      sortConversationWithIdentifier: sortingConversationWithIdentifier,
      mqttConnectionStatus: mqttConnectionStatus,
      chatInvalidate: chatInvalidate,
      mqttProperties: mqttProperties,
      isMonthFirst: isMonthFirst,
    );
    _initialized = true;
  }

  /// Listens for MQTT events.
  ///
  /// data is the data to listen for.
  /// `showNotification` is the callback for showing notifications.
  ///,
  /// Throws an [AssertionError] if the MQTT controller has not been initialized.
  Future<void> listenMqttEvent(
    EventModel event, {
    NotificaitonCallback? showNotification,
  }) async {
    assert(_initialized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChatApp is called''');
    await _delegate.listenMqttEvent(
      event: event,
      showNotification: showNotification,
    );
  }

  /// Adds a listener for MQTT events with a specific event model.
  ///
  /// This function must be called after initializing the MQTT controller using
  /// `initialize`. The listener will be called with an `EventModel` object
  /// containing the event data.
  ///
  /// Example:
  /// ```dart
  /// StreamSubscription<EventModel> subscription = IsmChat.i.addEventListener((event) {
  ///   print('Received MQTT event: ${event.type}');
  /// });
  ///
  StreamSubscription<EventModel> addEventListener(
      Function(EventModel) listener) {
    assert(_initialized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChat is called''');
    return _delegate.addEventListener(listener);
  }

  /// Removes a listener for MQTT events with a specific event model.
  ///
  /// This function must be called after initializing the MQTT controller using
  /// `initialize`. The listener to be removed must be the same instance that was
  /// added using `addEventListener`.
  ///
  /// Example:
  /// ```dart
  /// void myListener(EventModel event) {
  ///   print('Received MQTT event: ${event.type}');
  /// }
  ///
  /// // Add the listener
  /// StreamSubscription<EventModel> subscription = IsmChat.i.addEventListener(myListener);
  ///
  /// // Remove the listener
  /// await IsmChat.i.removeEventListener(myListener);
  ///
  Future<void> removeEventListener(Function(EventModel) listener) async {
    assert(_initialized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChat.initialize() or add listener after IsmChat is called''');
    await _delegate.removeEventListener(listener);
  }

  /// Shows the third column in the web flow.
  ///
  /// This function should only be used in the web flow and not in the mobile flow.
  /// It is also necessary to call the `outSideView` callback widget in `IsmChatConversationProperties`.
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.showThirdColumn();
  /// ```
  void showThirdColumn() => _delegate.showThirdColumn();

  /// Closes the third column in the web flow.
  ///
  /// This function should only be used in the web flow and not in the mobile flow.
  /// It is also necessary to call the `outSideView` callback widget in `IsmChatConversationProperties`.
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.clostThirdColumn();
  /// ```
  void clostThirdColumn() => _delegate.clostThirdColumn();

  /// Call this function for showing Block un Block Dialog
  ///
  /// Example:
  /// ```dart
  ///  IsmChat.i.showBlockUnBlockDialog();
  /// ```
  void showBlockUnBlockDialog() => _delegate.showBlockUnBlockDialog();

  /// Call this function to assign null on the current conversation.
  ///
  /// This function is used to reset the current conversation.
  ///
  /// Example:
  /// ```dart
  /// // Reset the current conversation
  ///  IsmChat.i.changeCurrentConversation();
  /// ```
  void changeCurrentConversation() => _delegate.changeCurrentConversation();

  /// Call this function to update the chat page controller.
  ///
  /// This function is used to refresh the chat page controller, which can be useful after making changes to the conversation list.
  ///
  /// Example:
  /// ```dart
  /// // Update the chat page controller after deleting a conversation
  /// IsmChat.i.updateChatPageController();
  /// ```
  void updateChatPageController() => _delegate.updateChatPageController();

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

  /// Call this function to get the list of non-blocked users.
  ///
  /// This function retrieves the list of users who are not blocked and returns a list of `SelectedMembers` objects.
  ///
  /// Example:
  /// ```dart
  /// // Get the list of non-blocked users
  /// List<SelectedMembers>? nonBlockedUsers = await IsmChat.i.getNonBlockUserList();
  /// ```
  Future<List<SelectedMembers>?> getNonBlockUserList() async =>
      await _delegate.getNonBlockUserList();

  /// Get all conversations of the current user.
  ///
  /// This property retrieves all conversations of the current user and returns a list of `IsmChatConversationModel` objects.
  ///
  /// Example:
  /// ```dart
  /// // Get all conversations of the current user
  /// List<IsmChatConversationModel> conversations = await IsmChat.i.userConversations;
  /// ```
  Future<List<IsmChatConversationModel>> get userConversations async =>
      await _delegate.userConversations;

  /// Get the total count of unread conversations.
  ///
  /// This property retrieves the total count of unread conversations and returns an integer value.
  ///
  /// Example:
  /// ```dart
  /// // Get the total count of unread conversations
  /// int count = await IsmChat.i.unreadCount;
  /// print('Total unread conversations: $count');
  /// ```
  Future<int> get unreadCount async => await _delegate.unreadCount;

  /// Log out the current user and clear local data.
  ///
  /// This function logs out the current user and clears all local data stored in the app.
  ///
  /// Example:
  /// ```dart
  /// // Log out the current user
  /// await IsmChat.i.logout();
  /// ```
  Future<void> logout() async => await _delegate.logout();

  /// Clear all local chat data stored in the database.
  ///
  /// This function clears all local chat data stored in the database, removing all conversations, messages, and other related data.
  ///
  /// Example:
  /// ```dart
  /// // Clear all local chat data
  /// await IsmChat.i.clearChatLocalDb();
  /// ```
  Future<void> clearChatLocalDb() async => _delegate.clearChatLocalDb();

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
  Future<void> updateConversation(
          {required String conversationId,
          required IsmChatMetaData metaData}) async =>
      await _delegate.updateConversation(
          conversationId: conversationId, metaData: metaData);

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
          conversationId: conversationId, events: events, isLoading: isLoading);

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

  /// Unblock a user.
  ///
  /// This function unblocks a user. It returns a future that resolves to void.
  ///
  /// Parameters:
  /// [opponentId]: The ID of the user to unblock.
  /// [includeMembers]: Whether to include the user's members in the response. Defaults to false.
  /// [isLoading]: Whether the unblock operation is currently loading. Defaults to false.
  /// [fromUser]: Whether the unblock operation is initiated by the user. Defaults to false.
  ///
  /// Returns:
  /// A future that resolves to void when the unblock operation is complete.
  ///
  /// Example:
  /// ```dart
  /// // Unblock a user
  /// await IsmChat.i.unblockUser(
  ///   opponentId: 'user_id',
  ///   includeMembers: true,
  /// );
  /// print('User unblocked successfully');
  /// ```
  Future<void> unblockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
  }) async =>
      await _delegate.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );

  /// Blocks a user with the specified ID.
  ///
  /// This method delegates the blocking operation to the `_delegate`.
  ///
  /// * `opponentId`: The ID of the user to block.
  /// * `includeMembers`: Whether to include members of the blocked user in the blocking operation.
  /// * `isLoading`: Whether the blocking operation is currently in progress.
  /// * `fromUser`: Whether the blocking operation is initiated by the user.
  ///
  /// Returns a Future that completes when the blocking operation is finished.
  ///
  /// /// Example:
  /// ```dart
  /// // Block a user
  /// await IsmChat.i.blockUser(
  ///   opponentId: 'user123',
  ///   includeMembers: true,
  ///   isLoading: false,
  ///   fromUser: true
  /// );
  /// print('User Blocked successfully');
  /// ```
  Future<void> blockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async =>
      await _delegate.blockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );

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
  Future<bool> deleteChatFormDB(String isometrickChatId,
      {String conversationId = ''}) async {
    assert(
      isometrickChatId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      isometrickChatId cannot be empty.''',
    );
    return await _delegate.deleteChatFormDB(isometrickChatId,
        conversationId: conversationId);
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
  Future<void> exitGroup(
      {required int adminCount, required bool isUserAdmin}) async {
    await _delegate.exitGroup(adminCount: adminCount, isUserAdmin: isUserAdmin);
  }

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

  /// Gets or sets the tag associated with this object.
  ///
  /// @return The current tag value, or null if not set.
  ///
  /// Example:
  /// ```dart
  /// print(tag); // prints the current tag value
  /// tag = 'new-tag'; // sets a new tag value
  /// ```
  String? get chatPageTag => _delegate.chatPageTag;
  set chatPageTag(String? value) => _delegate.chatPageTag = value;

  /// Gets or sets the tag associated with this object.
  ///
  /// @return The current tag value, or null if not set.
  ///
  /// Example:
  /// ```dart
  /// print(tag); // prints the current tag value
  /// tag = 'new-tag'; // sets a new tag value
  /// ```
  String? get chatListPageTag => _delegate.chatListPageTag;
  set chatListPageTag(String? value) => _delegate.chatListPageTag = value;

  /// Subscribes to the given list of topics in an MQTT broker.
  /// which is responsible for communicating with the MQTT broker.
  ///
  /// Example:
  /// ```dart
  /// var topics = ['sports', 'politics', 'technology'];
  /// IsmChat.i.subscribeTopics(topics);
  /// ```
  ///
  /// @param topics The list of topics to subscribe to. In MQTT, topics are used to
  ///   filter incoming messages from the broker. Each topic is a string that may
  ///   contain wildcards (+ or #) to match multiple topics.
  void subscribeTopics(List<String> topic) {
    _delegate.subscribeTopics(topic);
  }

  /// Unsubscribes from the given list of topics in an MQTT broker.
  /// which is responsible for communicating with the MQTT broker.
  ///
  /// Example:
  /// ```dart
  /// var topics = ['sports', 'politics', 'technology'];
  /// IsmChat.i.unsubscribeTopics(topics);
  /// ```
  ///
  /// @param topics The list of topics to unsubscribe from. Unsubscribing from a
  ///   topic stops the client from receiving messages from the broker for that
  ///   topic.
  void unSubscribeTopics(List<String> topic) {
    _delegate.unSubscribeTopics(topic);
  }

  /// Retrieves a list of blocked users for the current user.
  ///
  /// This method fetches the list of users that have been blocked by the current user.
  ///
  /// Parameters:
  /// - `isLoading` : Optional boolean parameter to control whether to show a loading indicator
  ///   during the API call. Defaults to false.
  ///
  /// Returns:
  /// - Future<List<UserDetails>> : A Future that resolves to a list of UserDetails objects
  ///   representing the blocked users. Returns an empty list if no blocked users are found
  ///   or if there's an error.
  ///
  /// Example:
  /// ```dart
  /// final blockedUsers = await IsmChat.i.getBlockUser(isLoading: true);
  /// ```
  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async =>
      await _delegate.getBlockUser(isLoading: isLoading);

  /// Updates the current chat page by refreshing conversation details and messages.
  ///
  /// This method performs two main operations:
  /// 1. Retrieves the latest conversation details
  /// 2. Fetches the latest messages for the current conversation
  ///
  /// The method will only execute if there is a registered ChatPageController.
  ///
  /// Returns:
  /// - Future<void> : A Future that completes when both operations are finished.
  ///
  /// Example:
  /// ```dart
  /// await IsmChat.i.updateChatPage();
  /// ```
  Future<void> updateChatPage() async => await _delegate.updateChatPage();

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

  /// Sets the current conversation index in the chat interface.
  ///
  /// This method updates the index of the currently active conversation in the chat interface.
  ///
  /// Parameters:
  /// - `index`: The index of the conversation to set as current. Defaults to 0.
  ///
  /// Example:
  /// ```dart
  /// IsmChat.i.currentConversationIndex(index: 2);
  /// ```
  void currentConversationIndex({int index = 0}) =>
      _delegate.currentConversationIndex(index: index);

  /// Determines whether to show other elements on the chat page.
  ///
  /// UI elements should be displayed on the chat page.
  ///
  /// Example:
  /// ```dart
  /// IsmChat.i.shouldShowOtherOnChatPage();
  /// ```
  void shouldShowOtherOnChatPage() => _delegate.shouldShowOtherOnChatPage();

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

  /// Deletes the conversation controller from memory.
  ///
  /// This method removes the IsmChatConversationsController instance from the
  /// GetX dependency injection system. This is typically used for cleanup
  /// operations when you want to free up memory or reset the conversation state.
  ///
  /// The method safely handles the deletion by:
  /// - Checking if the controller is registered before attempting deletion
  /// - Using force deletion to ensure complete removal
  /// - Catching and logging any errors that occur during deletion
  ///
  /// Returns:
  /// - Future<void>: A Future that completes when the controller has been
  ///   successfully deleted from memory.
  ///
  /// Example:
  /// ```dart
  /// // Clean up conversation controller when logging out
  /// await IsmChat.i.deleteConversationController();
  /// ```
  Future<void> deleteConversationController() async =>
      await _delegate.deleteConversationController();

  /// Deletes the chat page controller from memory.
  ///
  /// This method removes the IsmChatPageController instance from the
  /// GetX dependency injection system. This is typically used for cleanup
  /// operations when you want to free up memory or reset the chat page state.
  ///
  /// The method safely handles the deletion by:
  /// - Checking if the controller is registered before attempting deletion
  /// - Using force deletion to ensure complete removal
  /// - Catching and logging any errors that occur during deletion
  ///
  /// Returns:
  /// - Future<void>: A Future that completes when the controller has been
  ///   successfully deleted from memory.
  ///
  /// Example:
  /// ```dart
  /// // Clean up chat page controller when navigating away
  /// await IsmChat.i.deleteChatPageController();
  /// ```
  Future<void> deleteChatPageController() async =>
      await _delegate.deleteChatPageController();
}
