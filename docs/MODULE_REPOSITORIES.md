# Repositories Module Documentation

**Location**: `lib/src/repositories/`  
**Purpose**: Data access abstraction layer  
**Last Updated**: January 21, 2026

## Overview

The Repositories module provides an abstraction layer between controllers and data sources (API, Database). This pattern allows for easy testing, swapping implementations, and maintaining clean separation of concerns.

## Module Structure

```
repositories/
├── chat_page_repository.dart           # Message operations
├── chat_conversations_repository.dart  # Conversation operations
├── mqtt_repository.dart                # MQTT operations
├── chat_broadcast_repository.dart      # Broadcast operations
├── common_repository.dart              # Shared operations
└── repositories.dart                   # Module exports
```

## Components

### 1. Chat Page Repository

**File**: `chat_page_repository.dart`

**Purpose**: Message-related data operations

**Key Methods**:
- `sendMessage()` - Send a message
- `getMessages()` - Retrieve messages
- `updateMessage()` - Update message
- `deleteMessage()` - Delete message
- `forwardMessage()` - Forward message
- `uploadMedia()` - Upload media files

**Usage**:
```dart
final repository = ChatPageRepository();
await repository.sendMessage(
  conversationId: 'conv123',
  message: 'Hello',
);
```

### 2. Chat Conversations Repository

**File**: `chat_conversations_repository.dart`

**Purpose**: Conversation-related data operations

**Key Methods**:
- `getConversations()` - Get conversation list
- `getConversation()` - Get single conversation
- `createConversation()` - Create new conversation
- `updateConversation()` - Update conversation
- `deleteConversation()` - Delete conversation
- `searchConversations()` - Search conversations

**Usage**:
```dart
final repository = ChatConversationsRepository();
final conversations = await repository.getConversations();
```

### 3. MQTT Repository

**File**: `mqtt_repository.dart`

**Purpose**: MQTT connection and operations

**Key Methods**:
- `connect()` - Connect to MQTT broker
- `disconnect()` - Disconnect from broker
- `subscribe()` - Subscribe to topics
- `unsubscribe()` - Unsubscribe from topics
- `publish()` - Publish message

**Usage**:
```dart
final repository = MqttRepository();
await repository.connect(config);
```

### 4. Chat Broadcast Repository

**File**: `chat_broadcast_repository.dart`

**Purpose**: Broadcast message operations

**Key Methods**:
- `sendBroadcast()` - Send broadcast message
- `getBroadcasts()` - Get broadcast list
- `getBroadcastMembers()` - Get broadcast members

### 5. Common Repository

**File**: `common_repository.dart`

**Purpose**: Shared operations across repositories

**Key Methods**:
- Common API calls
- Shared error handling
- Utility methods

## Design Pattern

### Repository Pattern

Repositories abstract data access:
- **Controllers** depend on repositories (not directly on API/Database)
- **Repositories** handle data source details
- Easy to **mock** for testing
- Can **swap** implementations (e.g., mock repository for tests)

## Data Sources

Repositories interact with:

1. **API Layer** (`lib/src/data/network/`)
   - REST API calls
   - HTTP requests/responses
   - Error handling

2. **Database Layer** (`lib/src/data/database/`)
   - Local SQLite database
   - Caching
   - Offline support

## Error Handling

Repositories handle errors consistently:

```dart
try {
  final result = await apiCall();
  return result;
} catch (e) {
  // Log error
  // Transform to domain error
  // Re-throw or return error result
}
```

## Testing

Repositories can be easily mocked:

```dart
class MockChatPageRepository extends ChatPageRepository {
  @override
  Future<void> sendMessage(...) async {
    // Mock implementation
  }
}
```

## Best Practices

1. **Single Responsibility**: Each repository handles one domain
2. **Error Handling**: Consistent error handling across repositories
3. **Async Operations**: All data operations are async
4. **Documentation**: Document all public methods
5. **Type Safety**: Use strong types, avoid `dynamic`

## Dependencies

- **API Layer**: `ChatApi`, `ChatApiWrapper`
- **Database Layer**: `DbWrapper`
- **Models**: Data models for requests/responses

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Data Module](./MODULE_DATA.md)
- [Controllers Module](./MODULE_CONTROLLERS.md)

