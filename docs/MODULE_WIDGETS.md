# Widgets Module Documentation

**Location**: `lib/src/widgets/`  
**Purpose**: Reusable UI components  
**Last Updated**: January 21, 2026

## Overview

The Widgets module contains reusable Flutter widgets used throughout the SDK. These widgets encapsulate common UI patterns and can be used across different views.

## Module Structure

```
widgets/
├── chat_image.dart              # Image display widget
├── file_widget.dart              # File display widget
├── input_field.dart              # Text input widget
├── app_bar.dart                  # Custom app bar
├── loading_dialog.dart           # Loading indicator
├── custom_snackbar.dart          # Snackbar widget
├── link_preview/                 # Link preview widgets
├── voice/                        # Voice message widgets
└── widgets.dart                  # Module exports
```

## Key Widgets

### 1. ChatImage

**File**: `chat_image.dart`

**Purpose**: Display chat images with caching and error handling

**Features**:
- Image caching
- Error handling
- Placeholder support
- Loading states

**Usage**:
```dart
ChatImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: 'assets/placeholder.png',
)
```

### 2. FileWidget

**File**: `file_widget.dart`

**Purpose**: Display file attachments

**Features**:
- File type icons
- File name display
- File size display
- Download functionality

**Usage**:
```dart
FileWidget(
  fileName: 'document.pdf',
  fileSize: 1024,
  onTap: () => downloadFile(),
)
```

### 3. InputField

**File**: `input_field.dart`

**Purpose**: Text input with chat-specific features

**Features**:
- Message input
- Emoji support
- Mention support
- Send button integration

**Usage**:
```dart
InputField(
  controller: textController,
  onSend: (text) => sendMessage(text),
)
```

### 4. LoadingDialog

**File**: `loading_dialog.dart`

**Purpose**: Loading indicator dialog

**Usage**:
```dart
showLoadingDialog();
// ... async operation
hideLoadingDialog();
```

### 5. CustomSnackbar

**File**: `custom_snackbar.dart`

**Purpose**: Custom snackbar notifications

**Usage**:
```dart
showCustomSnackbar(
  message: 'Message sent',
  type: SnackbarType.success,
);
```

### 6. LinkPreview

**Location**: `link_preview/`

**Purpose**: Preview links in messages

**Features**:
- URL preview
- Image preview
- Title and description
- Open in browser

### 7. Voice Widgets

**Location**: `voice/`

**Purpose**: Voice message recording and playback

**Features**:
- Voice recording
- Playback controls
- Waveform display
- Duration display

## Widget Categories

### Display Widgets
- `ChatImage` - Images
- `FileWidget` - Files
- `NoMessage` - Empty state

### Input Widgets
- `InputField` - Text input
- Voice recording widgets

### Navigation Widgets
- `AppBar` - Custom app bar
- `BottomSheetOption` - Bottom sheet

### Feedback Widgets
- `LoadingDialog` - Loading indicator
- `CustomSnackbar` - Notifications
- `AlertDialog` - Alerts

### Utility Widgets
- `RefreshHeadFooter` - Pull to refresh
- `ResponsiveBuilderView` - Responsive layout
- `TapHandler` - Tap handling

## Best Practices

1. **Reusability**: Design widgets to be reusable
2. **Composition**: Compose complex widgets from simple ones
3. **Documentation**: Document widget parameters
4. **Error Handling**: Handle edge cases gracefully
5. **Performance**: Optimize for performance (const constructors where possible)

## Usage Guidelines

1. **Import widgets**: Import from `widgets.dart`
2. **Customize**: Use parameters to customize behavior
3. **Compose**: Combine widgets to create complex UI
4. **Test**: Test widgets in isolation

## Related Documentation

- [Architecture Documentation](../ARCHITECTURE.md)
- [Views Module](./MODULE_VIEWS.md)

