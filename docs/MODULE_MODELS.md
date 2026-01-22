# Models Module Documentation

**Location**: `lib/src/models/`  
**Purpose**: Data models and structures  
**Last Updated**: January 21, 2026

## Overview

The Models module contains all data structures used throughout the SDK. Models represent entities like conversations, messages, users, and various chat-related data.

## Module Structure

```
models/
├── chat_conversation_model.dart    # Conversation data model
├── chat_message_model.dart         # Message data model
├── user_details_model.dart         # User information
├── mqtt_models/                    # MQTT-related models
│   ├── mqtt_action_model.dart
│   ├── mqtt_user_model.dart
│   └── mqtt_models.dart
├── location_models/                 # Location-related models
├── attachment_model.dart            # File attachments
├── reaction_model.dart              # Message reactions
├── typing_model.dart                # Typing indicators
└── models.dart                      # Module exports
```

## Key Models

### 1. IsmChatConversationModel

**File**: `chat_conversation_model.dart`

**Purpose**: Represents a chat conversation

**Key Properties**:
- `id` - Conversation ID
- `title` - Conversation title
- `messages` - List of messages
- `members` - Conversation members
- `lastMessage` - Last message details
- `unreadCount` - Unread message count
- `conversationType` - Type (private, group, broadcast)

**Usage**:
```dart
final conversation = IsmChatConversationModel(
  id: 'conv123',
  title: 'Chat Room',
  conversationType: IsmChatConversationType.group,
);
```

### 2. IsmChatMessageModel

**File**: `chat_message_model.dart`

**Purpose**: Represents a chat message

**Key Properties**:
- `messageId` - Unique message ID
- `conversationId` - Parent conversation ID
- `message` - Message content
- `senderInfo` - Sender details
- `messageType` - Type (text, image, file, etc.)
- `timestamp` - Message timestamp
- `status` - Delivery status
- `reactions` - Message reactions
- `replyMessage` - Reply reference

**Usage**:
```dart
final message = IsmChatMessageModel(
  messageId: 'msg123',
  conversationId: 'conv123',
  message: 'Hello!',
  messageType: IsmChatMessageType.text,
);
```

### 3. UserDetails

**File**: `user_details_model.dart`

**Purpose**: User information

**Key Properties**:
- `userId` - User ID
- `name` - User name
- `profileImageUrl` - Profile image
- `online` - Online status
- `lastSeen` - Last seen timestamp

### 4. IsmChatMqttActionModel

**File**: `mqtt_models/mqtt_action_model.dart`

**Purpose**: MQTT action events

**Key Properties**:
- `action` - Action type
- `conversationId` - Related conversation
- `userDetails` - User who performed action
- `timestamp` - Action timestamp

### 5. MessageReaction

**File**: `reaction_model.dart`

**Purpose**: Message reactions (emojis)

**Key Properties**:
- `reaction` - Reaction emoji
- `userId` - User who reacted
- `messageId` - Message ID

## Model Categories

### Core Models
- `IsmChatConversationModel` - Conversations
- `IsmChatMessageModel` - Messages
- `UserDetails` - Users

### MQTT Models
- `IsmChatMqttActionModel` - MQTT actions
- `IsmChatMqttUserModel` - MQTT user data

### UI Models
- `HeaderModel` - Header data
- `PopupItemModel` - Popup menu items
- `BottomSheetAttachmentModel` - Attachment options

### Media Models
- `AttachmentModel` - File attachments
- `PlatformFileModel` - Platform files
- `WebMediaModel` - Web media

### Location Models
- Location-related models for location sharing

### Metadata Models
- `IsmChatMetaData` - Custom metadata
- `ContactMetadataModel` - Contact metadata

## Serialization

Models support JSON serialization/deserialization:

```dart
// From JSON
final conversation = IsmChatConversationModel.fromMap(jsonMap);

// To JSON
final json = conversation.toMap();
```

## Best Practices

1. **Immutable where possible**: Use `final` for properties
2. **Null safety**: Use nullable types appropriately
3. **Validation**: Validate data in constructors
4. **Documentation**: Document all public properties
5. **Equality**: Implement `==` and `hashCode` for comparison

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Controllers Module](./MODULE_CONTROLLERS.md)

