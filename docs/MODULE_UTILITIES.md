# Utilities Module Documentation

**Location**: `lib/src/utilities/`  
**Purpose**: Helper functions and utilities  
**Last Updated**: January 21, 2026

## Overview

The Utilities module contains helper functions, extensions, enums, and utility classes used throughout the SDK. These utilities provide common functionality that doesn't belong to a specific domain.

## Module Structure

```
utilities/
├── chat_log.dart              # Logging utility
├── debouncer.dart             # Debounce functionality
├── enums.dart                 # Enumerations
├── typedef.dart               # Type definitions
├── utility.dart               # General utilities
├── show_context.dart          # Context utilities
├── config/                    # Configuration
│   ├── chat_config.dart
│   └── config.dart
├── extensions/                # Dart extensions
│   ├── string_extensions.dart
│   ├── date_extensions.dart
│   └── ... (10 files)
└── utilities.dart             # Module exports
```

## Components

### 1. Chat Log

**File**: `chat_log.dart`

**Purpose**: Centralized logging

**Features**:
- Log levels (debug, info, warning, error)
- Console output
- File logging (optional)

**Usage**:
```dart
IsmChatLog.debug('Debug message');
IsmChatLog.error('Error message', error: e);
```

### 2. Debouncer

**File**: `debouncer.dart`

**Purpose**: Debounce function calls

**Usage**:
```dart
final debouncer = Debouncer(duration: Duration(seconds: 1));
debouncer.run(() => performSearch());
```

### 3. Enums

**File**: `enums.dart`

**Purpose**: Common enumerations

**Key Enums**:
- `IsmChatMessageType` - Message types
- `IsmChatConversationType` - Conversation types
- `IsmChatMessageStatus` - Message status
- `IsmChatActionEvents` - MQTT action events

### 4. Type Definitions

**File**: `typedef.dart`

**Purpose**: Common type definitions

**Key Typedefs**:
- `NotificaitonCallback` - Notification callback
- `SendMessageCallback` - Send message callback
- `ResponseCallback` - API response callback
- `ConversationVoidCallback` - Conversation callback

### 5. Extensions

**Location**: `extensions/`

**Purpose**: Dart extensions for common types

**Key Extensions**:
- `StringExtensions` - String utilities
- `DateExtensions` - Date formatting
- `ListExtensions` - List utilities
- `BuildContextExtensions` - Context utilities
- And more...

**Usage**:
```dart
'Hello'.capitalize(); // String extension
DateTime.now().formatDate(); // Date extension
```

### 6. Configuration

**Location**: `config/`

**Purpose**: SDK configuration

**Key Files**:
- `chat_config.dart` - Chat configuration
- `config.dart` - General configuration

## Utility Categories

### Logging
- `IsmChatLog` - Centralized logging

### Timing
- `Debouncer` - Debounce operations
- `Throttler` - Throttle operations

### Type Utilities
- Extensions for String, Date, List, etc.
- Type definitions
- Enumerations

### Context Utilities
- `show_context.dart` - Context helpers

### General Utilities
- `utility.dart` - Miscellaneous utilities

## Best Practices

1. **Pure Functions**: Keep utilities as pure functions when possible
2. **Documentation**: Document all public utilities
3. **Testing**: Test utilities thoroughly
4. **Reusability**: Design utilities to be reusable
5. **Performance**: Optimize for performance

## Usage Guidelines

1. **Import utilities**: Import from `utilities.dart`
2. **Use extensions**: Leverage extensions for cleaner code
3. **Logging**: Use `IsmChatLog` for all logging
4. **Debouncing**: Use debouncer for search/input operations

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)

