# Isometrik Chat Flutter SDK

## Introduction

`Isometrik Chat Flutter SDK` is a powerful package that provides comprehensive chat functionality for Flutter projects. It offers real-time messaging capabilities using MQTT protocol, extensive customization options, and robust user management features.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  isometrik_chat_flutter:
    git:
      url: https://github.com/isometrikai/isometrik-chat-flutter.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Platform Setup

For detailed setup instructions, please refer to the platform-specific guides and you need to add your project level platforms:

- [Android](./README_android.md)

- [iOS](./README_ios.md)

- [Web](./README_web.md)

## Basic Configuration

The Isometrik Chat Flutter SDK requires initial configuration for:

1. Account Configuration

   - Account ID
   - Project ID
   - Keyset ID
   - License key
   - App secret
   - User secret
   - MQTT host and port

2. Feature Configuration
   - Attachment types (image, video, location, contact, voice)
   - UI customization
   - Chat themes
   - Message bubble types

## Chat SDK Usage

The Isometrik Chat Flutter SDK supports various use cases to enhance your chat functionality:

1. Configuration : Set the configuration for account ID, project ID, keyset ID, license key, app secret, user secret, MQTT host, and port.
2. Attachments and Features: Specify the types of attachments and features you need in the chat.(e.g., image, video, location, contact, voice)
3. Customization: Customize the chat UI by setting the chat theme, chat bubble color, and message bubble type
4. User Management: Manage users by setting the user ID, user name, and user avatar.
5. Chat History: Retrieve chat history from local database of device with conversationId and opponentUserId.
6. Chat Message: Send chat messages with text, image, video, location, contact, and voice attachments.
7. Configuration Objects: Create configuration objects for the app and user.
8. Start a chat: you'll need to integrate the `IsmChatApp` widget into your application

```dart
IsmChatApp(
    context: context,
    chatPageProperties: chatPageProperties(),
    conversationProperties: conversationProperties(),
    chatTheme: chatTheme(),
    chatDarkTheme: chatDarkTheme(),
    loadingDialog: CircularProgressIndicator(),
    noChatSelectedPlaceholder: Text('No chat selected'),
    sideWidgetWidth: 300,
    fontFamily: 'OpenSans',
    conversationParser: (conversationData) () {
        // parse conversation data
    } ,
    conversationModifier: (conversationData) () {
        // modify conversation data
        } ,
);
```

##### Required Parameters

- `context`: The BuildContext of the application.
- `chatPageProperties`: The properties for the chat page.
- `conversationProperties`: The properties for the conversation.

##### Optional Parameters

- `chatTheme`: The light theme for the chat.
- `chatDarkTheme`: The dark theme for the chat.
- `loadingDialog`: A custom loading dialog widget.
- `noChatSelectedPlaceholder`: A custom widget to display when no chat is selected.
- `sideWidgetWidth`: The width of the side widget for web chat.
- `fontFamily`: The font family to use for the chat.
- `conversationParser`: A callback to parse conversation data from the API.
- `conversationModifier`: A callback to modify conversation data.

## Core Methods Documentation

9. Initialize Chat and MQTT: The initialize method sets up the necessary configurations for using the `Isometrik Chat Flutter SDK` in your Flutter project. This method must be called before using any other features of the Isometrik Chat Flutter SDK.And Manually initializes the MQTT (Message Queuing Telemetry Transport) protocol for real-time messaging. .

```dart
    IsmChat.i.initialize({
        required IsmChatCommunicationConfig communicationConfig,
        required GlobalKey<NavigatorState> kNavigatorKey,
        bool useDatabase = true,
        String databaseName = IsmChatStrings.dbname,
        NotificaitonCallback? showNotification,
        BuildContext? context,
         IsmMqttProperties? mqttProperties,
    })
```

11. Add listener for MQTT events: Adds a listener to handle MQTT events. This is useful for responding to real-time message updates and other events.

```dart
IsmChat.i.addEventListener( (listener){
     // Handle MQTT events
})
```

12. Remove MQTT listener events: Remove listener which you added addMqttListenerto handle MQTT events.

```dart
IsmChat.i.removeEventListener((event) {
    // Handle MQTT events
})
```

13. This method is use to listen for MQTT events, which are typically messages or notifications received in real-time through the MQTT protocol.Call this method when assuming that the MQTT connection is already established.

```dart
    final eventModel = EventModel();
    IsmChat.i.listenMqttEvent(
        event: eventModel,
        showNotification: (notification) {
        // Handle notification display
        },
    );
```

14. `Only For Web`: This method is use when you need to ensure that the third column is visible or not in web flow. Their visibility based on user actions or web flow state.

```dart
    // Show the third column if needed
    IsmChat.i.showThirdColumn();

     // Close the third column if needed
     IsmChat.i.clostThirdColumn();
```

15. `Only For Web`: This method use to assign null on the current conversation.

```dart
    IsmChat.i.changeCurrentConversation();
```

16. `Only For Web`: This method use to update the chat page controller.

```dart
    IsmChat.i.updateChatPageController();
```

17. This method use for showing Block un Block Dialog

```dart
    IsmChat.i.showBlockUnblockDialog();
```

18. This method use for retrieves all conversations from the local database and returns a list of `IsmChatConversationModel` objects.

```dart
    final conversations = await IsmChat.i.getAllConversationFromDB();
```

19. This methid use for retrieves the list of users who are not blocked and returns a list of `SelectedMembers` objects.

```dart
    final selectedMembers = await IsmChat.i.getNonBlockUserList();
```

20. This property retrieves all conversations of the current user and returns a list of `IsmChatConversationModel` objects.

```dart
    final conversations = await IsmChat.i.userConversations;
```

21. This property retrieves the total count of unread conversations and returns an integer value.

```dart
     final unreadCount = await IsmChat.i.unreadCount;
```

22. This method use for clears all local chat data stored in the database, removing all conversations, messages, and other related data.

```dart
    await IsmChat.i.clearChatLocalDb();
```

23. This method use for retrieves all conversations from the local database and updates the conversation list.

```dart
    await IsmChat.i.getChatConversation();
```

24. Update conversation with metadata:
    Updates a specific conversation with additional metadata. This can be used to store custom information related to the conversation.

```dart

    await IsmChat.i.updateConversation(
        conversationId: 'conversation_id',
        metaData: IsmChatMetaData(title: 'New Title'),
    );
```

25. This method use for updates the settings of a conversation. It requires the conversation ID and the new events.

```dart
    await IsmChat.i.updateConversationSetting(
    conversationId: 'conversation_id',
    events: IsmChatEvents(read: true, unread: false),
    );
```

26. This method use for retrieves the total count of conversations. It returns a future that resolves to an integer representing the count.

```dart
    int conversationCount = await IsmChat.i.getChatConversationsCount();
```

27. This method use for retrieves the total count of messages in a conversation. It returns a future that resolves to an integer representing the count.

```dart
    int messageCount = await IsmChat.i.getChatConversationsMessageCount(
    converationId: 'conversation_id',
    senderIds: ['sender_id_1', 'sender_id_2'],
    );
```

28. This method use for retrieves the details of a conversation. It returns a future that resolves to an `IsmChatConversationModel` object.

```dart
    IsmChatConversationModel? conversationDetails = await IsmChat.i.getConverstaionDetails(
    conversationId: 'conversation_id',
    includeMembers: true,
    );
```

29. Block/Unblock : Allows users to manage their chat interactions by blocking unwanted user and unblocking them when necessary

```dart
await IsmChat.i.unblockUser({
    required String opponentId
}),

await IsmChat.i.blockUser({
    required String opponentId
})
```

30. This method use for fetch a list of chat messages from the API for a given `conversationId` and `lastMessageTimestamp`. It also allows specifying the `limit` and `skip` parameters for pagination, as well as an optional `searchText` for filtering messages.

```dart
final messages = await IsmChat.i.getMessagesFromApi(
  conversationId: 'conversation123',
  lastMessageTimestamp: 0,
  limit: 20,
  skip: 0,
  searchText: '',
);
```

31. Delete chat : Deletes a specific chat conversation. This is useful for allowing users to remove unwanted conversations.

```dart
await IsmChat.i.deleteChat(conversationId);
```

32. This method use for deletes a chat from the database with the specified Isometrick chat ID.

```dart
   bool isDeleted = await IsmChat.i.deleteChatFormDB('isometrickChat123', conversationId: 'conversation123');
```

33. This method use for all messages in a conversation with the specified ID.

```dart
   await IsmChat.i.clearAllMessages('conversation123', fromServer: true);
```

34. Exits a group with the specified admin count and user admin status.

```dart
  await IsmChat.i.exitGroup(adminCount: 2, isUserAdmin: true);
```

35. This function allows you to start a chat with a user from anywhere in your app. It requires the user's name, user identifier, and user ID. You can also pass additional metadata, a callback to navigate to the chat screen, and more.

```dart
    await IsmChat.i.chatFromOutside(
    name: 'John Doe',
    userIdentifier: 'john.doe@example.com',
    userId: '12345',
    metaData: IsmChatMetaData(
        title: 'Hello, World!',
        description: 'This is a sample chat.',
    ),
    onNavigateToChat: (context, conversation) {},
    );
```

36. This function allows you to start a conversation with a user from anywhere in your app, using an existing conversation model. It requires the conversation model, and optionally a callback to navigate to the chat conversation, a duration for the animation, and a flag to show a loader.

```dart
    IsmChatConversationModel conversation = IsmChatConversationModel(
    id: '12345',
    title: 'Hello from outside!',
    description: 'This is a test message.',
    );

    await IsmChat.i.chatFromOutsideWithConversation(
    ismChatConversation: conversation,
    onNavigateToChat: (context, conversation) {},
    );
```

37. This function allows you to create a group chat with multiple users from anywhere in your app. It requires the conversation image URL, conversation title, and a list of user IDs. You can also optionally provide the conversation type, additional metadata, a callback to navigate to the chat conversation, and more.

```dart
     await IsmChat.i.createGroupFromOutside(
    conversationImageUrl: 'https://example.com/conversation_image.jpg',
    conversationTitle: 'Group Chat',
    userIds: ['12345', '67890'],
    metaData: IsmChatMetaData(
        title: 'Hello from outside!',
        description: 'This is a test message.',
    ),
    onNavigateToChat: (context, conversation) {},
    );
```

38. This method is used to fetch a message on the chat page. It can be used to retrieve a message from a broadcast or a regular chat.

```dart
    await IsmChat.i.getMessageOnChatPage(isBroadcast: true);
```

39. Logout : This method use logs out the current user and clears all local data stored in the app. This is important for ensuring the user's chat session is properly terminated.

```dart
    await IsmChat.i.logout();
```

40. Retrieves a specific conversation by its ID.

```dart
final conversation = await IsmChat.i.getConversation(conversationId: 'conversation-123');
```

41. Subscribe to multiple MQTT topics for receiving messages.

```dart
IsmChat.i.subscribeTopics(['sports', 'politics', 'technology']);
```

42. Unsubscribe from MQTT topics to stop receiving messages.

```dart
IsmChat.i.unSubscribeTopics(['sports', 'politics', 'technology']);
```

43. Retrieves a list of users blocked by the current user.

```dart
final blockedUsers = await IsmChat.i.getBlockUser(isLoading: true);
```

44. Refreshes the current chat page by updating conversation details and messages.

```dart
await IsmChat.i.updateChatPage();
```

45. Retrieves the list of messages in the currently active conversation.

```dart
final messages = IsmChat.i.currentConversatonMessages();
```

46. Fetches a paginated list of chat conversations with search capabilities.

```dart
final conversations = await IsmChat.i.getChatConversationApi(
  skip: 0,
  limit: 20,
  searchTag: "John",
  includeConversationStatusMessagesInUnreadMessagesCount: false,
);
```

47. Retrieves the count of conversations with unread messages.

```dart
await IsmChat.i.getChatConversationsUnreadCount(isLoading: true);
```

48. Get or set a tag associated with the chat instance.

```dart
// Get current tag
print(IsmChat.i.tag);

// Set new tag
IsmChat.i.tag = 'new-tag';
```

<!-- ## Contributing

We welcome contributions to the Isometrik Chat Flutter SDK! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## License

This project is licensed under the [LICENSE NAME] - see the LICENSE file for details.

## Support

For support:
- Email: support@isometrik.com
- Documentation: [Link to documentation]
- Issue Tracker: [Link to issue tracker] -->
