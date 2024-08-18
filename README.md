# Isometrik Chat Flutter SDK

`Isometrik Chat Flutter SDK` is a package to support chat functionality for flutter projects

## Setup

For detailed setup instructions, please refer to the platform-specific guides and you need to add your project level platforms:

- [Android](./README_android.md)

- [iOS](./README_ios.md)

- [Web](./README_web.md)

## Initialization

Before using the Isometrik Chat Flutter SDK, you need to ensure the necessary initializations are done.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNoticeService().setup();
  runApp(MyApp());
}
```

## Explanation

`await LocalNoticeService().setup()`:
Sets up the local notification service. This ensures that the app can handle in-app notifications properly.

## Usage

The Isometrik Chat Flutter SDK supports various use cases to enhance your chat functionality:

1. Configuration : Set the configuration for account ID, project ID, keyset ID, license key, app secret, user secret, MQTT host, and port.
2. Attachments and Features: Specify the types of attachments and features you need in the chat.(e.g., image, video, location, contat, voice)
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

9. Initialize Chat and MQTT: The initialize method sets up the necessary configurations for using the `Isometrik Chat Flutter SDK` in your Flutter project. This method must be called before using any other features of the Isometrik Chat Flutter SDK.And Manually initializes the MQTT (Message Queuing Telemetry Transport) protocol for real-time messaging. .

```dart
    IsmChat.i.initialize(
        IsmChatCommunicationConfig communicationConfig, {
        bool useDatabase = true,
        String databaseName = IsmChatStrings.dbname,
        NotificaitonCallback? showNotification,
        BuildContext? context,
        bool shouldSetupMqtt = false,
    })
```

10. Add listener for MQTT events: Adds a listener to handle MQTT events. This is useful for responding to real-time message updates and other events.

```dart
IsmChat.i.addEventListener( (listener){
     // Handle MQTT events
})
```

11. Remove MQTT listener events: Remove listener which you added addMqttListenerto handle MQTT events.

```dart
IsmChat.i.removeEventListener((event) {
    // Handle MQTT events
})
```

12. This method is use to listen for MQTT events, which are typically messages or notifications received in real-time through the MQTT protocol.Call this method when assuming that the MQTT connection is already established.

```dart
    final eventModel = EventModel();
    IsmChat.i.listenMqttEvent(
        event: eventModel,
        showNotification: (notification) {
        // Handle notification display
        },
    );
```

13. `Only For Web`: This method is use when you need to ensure that the third column is visible or not in web flow. Their visibility based on user actions or web flow state.

```dart
    // Show the third column if needed
    IsmChat.i.showThirdColumn();

     // Close the third column if needed
     IsmChat.i.clostThirdColumn();
```

14. `Only For Web`: This method use to assign null on the current conversation.

```dart
    IsmChat.i.changeCurrentConversation();
```

15. `Only For Web`: This method use to update the chat page controller.

```dart
    IsmChat.i.updateChatPageController();
```

16. This method use for showing Block un Block Dialog

```dart
    IsmChat.i.showBlockUnblockDialog();
```

17. This method use for retrieves all conversations from the local database and returns a list of `IsmChatConversationModel` objects.

```dart
    final conversations = await IsmChat.i.getAllConversationFromDB();
```

18. This methid use for retrieves the list of users who are not blocked and returns a list of `SelectedMembers` objects.

```dart
    final selectedMembers = await IsmChat.i.getNonBlockUserList();
```

19. This property retrieves all conversations of the current user and returns a list of `IsmChatConversationModel` objects.

```dart
    final conversations = await IsmChat.i.userConversations;
```

20. This property retrieves the total count of unread conversations and returns an integer value.

```dart
     final unreadCount = await IsmChat.i.unreadCount;
```

21. This method use for clears all local chat data stored in the database, removing all conversations, messages, and other related data.

```dart
    await IsmChat.i.clearChatLocalDb();
```

22. This method use for retrieves all conversations from the local database and updates the conversation list.

```dart
    await IsmChat.i.getChatConversation();
```

23. Update conversation with metadata:
    Updates a specific conversation with additional metadata. This can be used to store custom information related to the conversation.

```dart

    await IsmChat.i.updateConversation(
        conversationId: 'conversation_id',
        metaData: IsmChatMetaData(title: 'New Title'),
    );
```

24. This method use for updates the settings of a conversation. It requires the conversation ID and the new events.

```dart
    await IsmChat.i.updateConversationSetting(
    conversationId: 'conversation_id',
    events: IsmChatEvents(read: true, unread: false),
    );
```

25. This method use for retrieves the total count of conversations. It returns a future that resolves to an integer representing the count.

```dart
    int conversationCount = await IsmChat.i.getChatConversationsCount();
```

26. This method use for retrieves the total count of messages in a conversation. It returns a future that resolves to an integer representing the count.

```dart
    int messageCount = await IsmChat.i.getChatConversationsMessageCount(
    converationId: 'conversation_id',
    senderIds: ['sender_id_1', 'sender_id_2'],
    );
```

27. This method use for retrieves the details of a conversation. It returns a future that resolves to an `IsmChatConversationModel` object.

```dart
    IsmChatConversationModel? conversationDetails = await IsmChat.i.getConverstaionDetails(
    conversationId: 'conversation_id',
    includeMembers: true,
    );
```

28. Block/Unblock : Allows users to manage their chat interactions by blocking unwanted user and unblocking them when necessary

```dart
await IsmChat.i.unblockUser({
    required String opponentId
}),

await IsmChat.i.blockUser({
    required String opponentId
})
```

29. This method use for fetch a list of chat messages from the API for a given `conversationId` and `lastMessageTimestamp`. It also allows specifying the `limit` and `skip` parameters for pagination, as well as an optional `searchText` for filtering messages.

```dart
final messages = await IsmChat.i.getMessagesFromApi(
  conversationId: 'conversation123',
  lastMessageTimestamp: 0,
  limit: 20,
  skip: 0,
  searchText: '',
);
```

30. Delete chat : Deletes a specific chat conversation. This is useful for allowing users to remove unwanted conversations.

```dart
await IsmChat.i.deleteChat(conversationId);
```

31. This method use for deletes a chat from the database with the specified Isometrick chat ID.

```dart
   bool isDeleted = await IsmChat.i.deleteChatFormDB('isometrickChat123', conversationId: 'conversation123');
```

32. This method use for all messages in a conversation with the specified ID.

```dart
   await IsmChat.i.clearAllMessages('conversation123', fromServer: true);
```

33. Exits a group with the specified admin count and user admin status.

```dart
  await IsmChat.i.exitGroup(adminCount: 2, isUserAdmin: true);
```

34. This function allows you to start a chat with a user from anywhere in your app. It requires the user's name, user identifier, and user ID. You can also pass additional metadata, a callback to navigate to the chat screen, and more.

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

35. This function allows you to start a conversation with a user from anywhere in your app, using an existing conversation model. It requires the conversation model, and optionally a callback to navigate to the chat conversation, a duration for the animation, and a flag to show a loader.

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

36. This function allows you to create a group chat with multiple users from anywhere in your app. It requires the conversation image URL, conversation title, and a list of user IDs. You can also optionally provide the conversation type, additional metadata, a callback to navigate to the chat conversation, and more.

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

37. This method is used to fetch a message on the chat page. It can be used to retrieve a message from a broadcast or a regular chat.

```dart
    await IsmChat.i.getMessageOnChatPage(isBroadcast: true);
```

38. Logout : This method use logs out the current user and clears all local data stored in the app. This is important for ensuring the user's chat session is properly terminated.

```dart
    await IsmChat.i.logout();
```
