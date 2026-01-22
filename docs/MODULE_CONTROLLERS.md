# Controllers Module Documentation

**Location**: `lib/src/controllers/`  
**Purpose**: GetX controllers for state management and business logic  
**Last Updated**: January 21, 2026

## Overview

The Controllers module contains all GetX controllers that manage application state and coordinate between the UI layer and data layer. Controllers use the mixin pattern extensively to organize functionality into focused, reusable components.

## Module Structure

```
controllers/
├── chat_page/              # Chat page controller (98 lines, 25 mixins)
├── chat_conversations/    # Conversations controller (56 lines, 15 mixins)
├── mqtt/                  # MQTT controller (13 mixins)
├── chat_broadcast/        # Broadcast controller
├── common/                # Common/shared controller
└── controllers.dart       # Module exports
```

## Components

### 1. Chat Page Controller

**File**: `chat_page/chat_page_controller.dart`  
**Size**: 98 lines (reduced from 2,038 lines - 95.2% reduction)  
**Mixins**: 25 mixins

**Responsibilities**:
- Message sending and receiving
- UI state management
- Media operations (camera, gallery)
- Scroll navigation
- Contact and group operations
- Message management (delete, forward, etc.)
- Block/unblock functionality

**Key Mixins**:
- `SendMessageMixin` - Message sending logic
- `GetMessageMixin` - Message retrieval
- `UiStateManagementMixin` - UI state
- `CameraOperationsMixin` - Camera functionality
- `MediaOperationsMixin` - Media handling
- `ScrollNavigationMixin` - Scroll management
- And 19 more...

**Usage**:
```dart
final controller = Get.find<IsmChatPageController>();
await controller.sendMessage(text: 'Hello');
```

### 2. Chat Conversations Controller

**File**: `chat_conversations/chat_conversations_controller.dart`  
**Size**: 56 lines (reduced from 1,989 lines - 97.2% reduction)  
**Mixins**: 15 mixins

**Responsibilities**:
- Conversation list management
- Search and filtering
- Group operations
- Story operations
- Connectivity management
- Conversation CRUD operations

**Key Mixins**:
- `IsmChatConversationsVariablesMixin` - State variables
- `IsmChatConversationsLifecycleInitializationMixin` - Lifecycle
- `IsmChatConversationsConnectivityMixin` - Network connectivity
- `IsmChatConversationsSearchMixin` - Search functionality
- `IsmChatConversationsGroupOperationsMixin` - Group operations
- And 10 more...

**Usage**:
```dart
final controller = Get.find<IsmChatConversationsController>();
await controller.getChatConversation();
```

### 3. MQTT Controller

**File**: `mqtt/mqtt_controller.dart`  
**Mixins**: 13 mixins (via `IsmChatMqttEventMixin`)

**Responsibilities**:
- MQTT connection management
- Event processing and routing
- Message handling
- Typing indicators
- Group operations
- Conversation operations
- Message status (delivered, read)
- Reactions
- Block/unblock events
- Broadcast messages
- Observer operations
- Call events

**Key Mixins**:
- `IsmChatMqttEventVariablesMixin` - State variables
- `IsmChatMqttEventProcessingMixin` - Event routing
- `IsmChatMqttEventMessageHandlersMixin` - Message handling
- `IsmChatMqttEventMessageStatusMixin` - Status updates
- `IsmChatMqttEventTypingEventsMixin` - Typing indicators
- And 8 more...

**Usage**:
```dart
final controller = Get.find<IsmChatMqttController>();
controller.onMqttEvent(event: event);
```

### 4. Chat Broadcast Controller

**File**: `chat_broadcast/chat_broadcast_controller.dart`

**Responsibilities**:
- Broadcast message management
- Broadcast member management

### 5. Common Controller

**File**: `common/common_controller.dart`

**Responsibilities**:
- Shared functionality across controllers
- Common state management

## Design Patterns

### Mixin Pattern

All controllers use mixins to organize functionality:
- Each mixin has a single responsibility
- Mixins are `part of` the controller file
- Controllers compose multiple mixins using `with` clause

### GetX Pattern

- Controllers extend `GetxController`
- Reactive state using `.obs` variables
- Dependency injection via `Get.find<T>()`
- Bindings for controller initialization

## State Management

### Reactive Variables

```dart
final _messages = <Message>[].obs;
List<Message> get messages => _messages;
```

### Update UI

```dart
_messages.value = newMessages; // Automatically updates UI
```

## Lifecycle

Controllers follow GetX lifecycle:
- `onInit()` - Called when controller is created
- `onReady()` - Called after first frame
- `onClose()` - Called when controller is disposed

## Testing

Controllers can be tested by:
1. Mocking dependencies (repositories, view models)
2. Testing individual mixins in isolation
3. Testing reactive state updates
4. Testing lifecycle methods

## Best Practices

1. **Keep controllers thin**: Business logic in mixins, not controllers
2. **Use reactive variables**: For state that needs UI updates
3. **Dispose resources**: Cancel subscriptions in `onClose()`
4. **Single responsibility**: Each mixin should have one purpose
5. **Document dependencies**: Comment which mixins depend on others

## Dependencies

- **ViewModels**: Controllers use view models for business logic
- **Repositories**: Controllers use repositories for data access
- **Models**: Controllers work with data models
- **GetX**: For state management and dependency injection

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Refactoring Progress](../REFACTORING_PROGRESS.md)
- [Chat Page Controller Refactoring](../REFACTORING_CHAT_PAGE_CONTROLLER.md)
- [Conversations Controller Refactoring](../REFACTORING_CHAT_CONVERSATIONS_CONTROLLER.md)

