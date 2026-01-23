# Views Module Documentation

**Location**: `lib/src/views/`  
**Purpose**: UI screens and pages  
**Last Updated**: January 21, 2026

## Overview

The Views module contains all Flutter UI screens (pages) for the chat SDK. Views are built using Flutter widgets and follow the GetX pattern for state management.

## Module Structure

```
views/
├── chat_page/              # Chat page UI (76 files)
├── chat_conversations/     # Conversations list UI (25 files)
├── chat_broadcast/         # Broadcast UI (5 files)
└── views.dart              # Module exports
```

## Components

### 1. Chat Page Views

**Location**: `chat_page/`

**Purpose**: Individual chat conversation screen

**Key Files**:
- `chat_page_view.dart` - Main chat page
- Message list components
- Input field components
- Media picker components
- Attachment components
- And 70+ more UI components

**Features**:
- Message display
- Message input
- Media sharing
- File attachments
- Voice messages
- Location sharing
- Message reactions
- Reply functionality
- Message forwarding

**Usage**:
```dart
Get.to(() => ChatPageView(conversation: conversation));
```

### 2. Chat Conversations Views

**Location**: `chat_conversations/`

**Purpose**: Conversation list screen

**Key Files**:
- `chat_conversations_view.dart` - Main conversations list
- Conversation item components
- Search components
- Filter components
- Group creation components
- And 20+ more UI components

**Features**:
- Conversation list display
- Search conversations
- Create new conversations
- Group creation
- Conversation filtering
- Unread count display

**Usage**:
```dart
Get.to(() => ChatConversationsView());
```

### 3. Chat Broadcast Views

**Location**: `chat_broadcast/`

**Purpose**: Broadcast message screens

**Key Files**:
- Broadcast list view
- Broadcast creation view
- Broadcast member management

## Design Patterns

### GetX Pattern

Views use GetX for:
- **State Management**: Reactive state from controllers
- **Navigation**: `Get.to()`, `Get.back()`
- **Dependency Injection**: `Get.find<T>()`
- **Bindings**: Controller initialization

### Widget Composition

Views are composed of smaller widgets:
- Reusable components
- Custom widgets
- Material/Cupertino widgets

## State Management

Views observe controller state:

```dart
Obx(() => Text(controller.messageCount.toString()))
```

## Navigation

Views use GetX navigation:

```dart
// Navigate to
Get.to(() => ChatPageView(conversation: conv));

// Navigate back
Get.back();

// Navigate with replacement
Get.off(() => ChatPageView(conversation: conv));
```

## Best Practices

1. **Keep views thin**: Business logic in controllers
2. **Reusable widgets**: Extract common UI into widgets
3. **Reactive updates**: Use `Obx()` for reactive state
4. **Error handling**: Show user-friendly error messages
5. **Loading states**: Show loading indicators during async operations

## Dependencies

- **Controllers**: Views depend on GetX controllers
- **Widgets**: Views use reusable widgets
- **Models**: Views display model data

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Widgets Module](./MODULE_WIDGETS.md)
- [Controllers Module](./MODULE_CONTROLLERS.md)

