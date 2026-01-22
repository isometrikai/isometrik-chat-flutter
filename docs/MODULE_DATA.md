# Data Module Documentation

**Location**: `lib/src/data/`  
**Purpose**: Data access layer (API and Database)  
**Last Updated**: January 21, 2026

## Overview

The Data module provides the data access layer for the SDK, including network API calls and local database operations. This module abstracts data sources from the rest of the application.

## Module Structure

```
data/
├── network/                  # Network/API layer
│   ├── chat_api.dart         # API client
│   ├── chat_api_wrapper.dart # API wrapper
│   └── network.dart          # Module exports
├── database/                 # Database layer
│   ├── db_wrapper.dart       # Database wrapper
│   └── database.dart         # Module exports
└── data.dart                 # Module exports
```

## Components

### 1. Network Layer

**Location**: `network/`

#### ChatApi

**File**: `chat_api.dart`

**Purpose**: REST API client

**Key Methods**:
- `sendMessage()` - Send message API
- `getMessages()` - Get messages API
- `getConversations()` - Get conversations API
- `createConversation()` - Create conversation API
- `updateConversation()` - Update conversation API
- `deleteConversation()` - Delete conversation API
- `uploadFile()` - Upload file API
- And more...

**Usage**:
```dart
final api = ChatApi();
final response = await api.sendMessage(
  conversationId: 'conv123',
  message: 'Hello',
);
```

#### ChatApiWrapper

**File**: `chat_api_wrapper.dart`

**Purpose**: API wrapper with error handling and retry logic

**Features**:
- Error handling
- Retry logic
- Request/response logging
- Token management

### 2. Database Layer

**Location**: `database/`

#### DbWrapper

**File**: `db_wrapper.dart`

**Purpose**: Database abstraction

**Key Methods**:
- `saveConversation()` - Save conversation
- `getConversations()` - Get conversations
- `saveMessage()` - Save message
- `getMessages()` - Get messages
- `deleteConversation()` - Delete conversation
- `clearDatabase()` - Clear all data
- And more...

**Usage**:
```dart
final db = DbWrapper();
await db.saveConversation(conversation);
final conversations = await db.getConversations();
```

## Data Flow

### API Flow

```
Repository
    ↓
ChatApiWrapper (error handling)
    ↓
ChatApi (HTTP client)
    ↓
REST API Server
```

### Database Flow

```
Repository
    ↓
DbWrapper (abstraction)
    ↓
SQLite Database
```

## Error Handling

### API Errors

- Network errors
- HTTP errors (4xx, 5xx)
- Timeout errors
- Parsing errors

### Database Errors

- Database connection errors
- Query errors
- Constraint violations

## Caching Strategy

- **Conversations**: Cached in database
- **Messages**: Cached in database
- **User Data**: Cached in database
- **Media**: Cached locally

## Offline Support

- **Local Storage**: All data stored locally
- **Sync**: Sync when online
- **Queue**: Queue operations when offline

## Best Practices

1. **Error Handling**: Handle all errors gracefully
2. **Retry Logic**: Implement retry for network operations
3. **Caching**: Cache frequently accessed data
4. **Offline Support**: Support offline operations
5. **Type Safety**: Use strong types, avoid `dynamic`

## Dependencies

- **HTTP Client**: For API calls
- **SQLite**: For local database
- **Models**: Data models for serialization

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Repositories Module](./MODULE_REPOSITORIES.md)
- [Models Module](./MODULE_MODELS.md)

