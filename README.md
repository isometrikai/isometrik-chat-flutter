# Isometrik Flutter Chat SDK

`Isometrik Flutter Chat SDK` is a package to support chat functionality for flutter projects

## Setup

For detailed setup instructions, please refer to the platform-specific guides:

- [Android](./README_android.md)

- [iOS](./README_ios.md)

- [Web](./README_web.md)

## Initialization

Before using the Isometrik Flutter Chat SDK, you need to ensure the necessary initializations are done.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceConfig = Get.put(IsmChatDeviceConfig());
  deviceConfig.init();
  await IsometrikChat.initialize();
  await LocalNoticeService().setup();
  runApp(MyApp());
}
```

## Explanation

`Get.put(IsmChatDeviceConfig())`:
Registers IsmChatDeviceConfig with GetX for dependency injection. This step is crucial to configure device-specific settings needed for the chat functionality.

`deviceConfig.init()`:
Initializes the device configuration. This step ensures that all device-specific settings are applied before initializing the chat component.

`await IsometrikChat.initialize()`:
Initializes the Isometrik Flutter Chat SDK. This step sets up the core functionalities needed for the chat system to operate.

`await LocalNoticeService().setup()`:
Sets up the local notification service. This ensures that the app can handle in-app notifications properly.

## Usage

The Isometrik Flutter Chat SDK supports various use cases to enhance your chat functionality:

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
    fontFamily: 'Merriweather Sans',
    chatTheme: chatTheme(),
    communicationConfig: communicationConfig(),
    conversationProperties: IsmChatConversationProperties(
            // Your conversation properties configuration
    ),
    chatPageProperties: IsmChatPageProperties(
            // Your chat page properties configuration
    ),
)
```

9. Initialize MQTT from outside if you want: Manually initializes the MQTT (Message Queuing Telemetry Transport) protocol for real-time messaging. This can be done from outside the component if needed.

```dart
    IsmChatApp.initializeMqtt(
      IsmChatCommunicationConfig(),
    )
```

10. Add listener for MQTT events: Adds a listener to handle MQTT events. This is useful for responding to real-time message updates and other events.

```dart
IsmChatApp.addMqttListener((event) {
    // Handle MQTT events
})
```

11. Remove MQTT listener events: Remove listener which you added addMqttListenerto handle MQTT events.

```dart
IsmChatApp.removeMqttListener((event) {
    // Handle MQTT events
})
```

12. Get all conversations from the database: Retrieves all chat conversations stored in the database. This can be useful for loading conversation history when the app starts.

```dart
var conversations = await IsmChatApp.getAllConversations();
```

13. Update conversation with metadata:
    Updates a specific conversation with additional metadata. This can be used to store custom information related to the conversation.

```dart
var metadata = {'key': 'value'};
await IsmChatApp.updateConversationMeta(conversationId, metadata);

```

14. Chat from outside without conversation:
    Sends a chat message to a user without requiring an existing conversation. Useful for initiating new chats.

```dart
     await IsmChatApp.chatWithoutConversation(opponentId);
```

15. Chat from outside with conversation :Sends a chat message within an existing conversation. This is the standard way to continue chatting in an existing thread.

```dart
    await IsmChatApp.chatWithConversation(opponentId);
```

16. Block/Unblock : Allows users to manage their chat interactions by blocking unwanted user and unblocking them when necessary

```dart
await IsmChatApp.unblockUser({
    required String opponentId
}),

await IsmChatApp.blockUser({
    required String opponentId
})
```

17. Delete chat :
    Deletes a specific chat conversation. This is useful for allowing users to remove unwanted conversations.

```dart
await IsmChatApp.deleteChat(conversationId);
```

18. Logout : Logs out the current user from the chat component. This is important for ensuring the user's chat session is properly terminated.

```dart
await IsmChatApp.logout();
```
