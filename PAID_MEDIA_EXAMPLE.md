# Paid Media Handling Example

This guide shows how to handle paid media functionality in your app outside the SDK.

## Overview

When `enablePaidMediaHandling` is enabled, the SDK will call your delegate callback when the user clicks send with selected media (images/videos). You can then:
1. Show a paid/free screen
2. Upload media to your server
3. Send the message from outside the SDK
4. The message will appear in the chat UI

## Step 1: Enable Paid Media Handling

```dart
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

// When creating your chat page properties
final chatPageProperties = IsmChatPageProperties(
  enablePaidMediaHandling: true, // Enable the feature
  // ... other properties
);
```

## Step 2: Set Up the Delegate Callback

```dart
// In your app initialization (e.g., main.dart or app setup)
IsmChat.i.onPaidMediaSend = (context, conversation, media) async {
  // This is called when user clicks send with selected media
  
  // Show your paid/free screen
  final shouldSend = await _showPaidFreeScreen(context, media);
  
  if (shouldSend) {
    // Upload and send media from outside SDK
    await _handlePaidMedia(context, conversation, media);
    
    // Return true - SDK won't send, we handled it
    return true;
  }
  
  // Return false - let SDK proceed with normal sending
  return false;
};
```

## Step 3: Show Paid/Free Screen

```dart
Future<bool> _showPaidFreeScreen(
  BuildContext context,
  List<WebMediaModel> media,
) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Send ${media.length} media file(s)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Send as Paid'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Send as Free'),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
        ],
      ),
    ),
  ) ?? false;
}
```

## Step 4: Handle Media Upload and Send

```dart
Future<void> _handlePaidMedia(
  BuildContext context,
  IsmChatConversationModel? conversation,
  List<WebMediaModel> media,
) async {
  if (conversation == null) return;

  final conversationId = conversation.conversationId ?? '';
  final userId = conversation.opponentDetails?.userId ?? '';

  // Process each media file
  for (var mediaItem in media) {
    if (mediaItem.isVideo) {
      // Upload video to your server
      final videoUrl = await _uploadVideo(mediaItem);
      
      // Send video message using SDK
      await _sendVideoMessage(
        conversationId: conversationId,
        userId: userId,
        videoUrl: videoUrl,
      );
    } else {
      // Upload image to your server
      final imageUrl = await _uploadImage(mediaItem);
      
      // Send image message using SDK
      // Note: You'll need to use the chat page controller's sendMessageWithImageUrl
      // or create the message manually and use IsmChat.i.sendMessage
      await _sendImageMessage(
        conversationId: conversationId,
        userId: userId,
        imageUrl: imageUrl,
        caption: mediaItem.caption,
      );
    }
  }
}

// Upload image to your server
Future<String> _uploadImage(WebMediaModel media) async {
  final bytes = media.platformFile.bytes;
  
  // TODO: Implement your upload logic
  // Example: Upload to S3, Firebase Storage, your API, etc.
  
  // For demonstration:
  // final response = await http.post(
  //   Uri.parse('https://your-api.com/upload'),
  //   body: bytes,
  // );
  // return response.body; // URL of uploaded image
  
  return 'https://your-server.com/images/${media.platformFile.name}';
}

// Upload video to your server
Future<String> _uploadVideo(WebMediaModel media) async {
  final bytes = media.platformFile.bytes;
  
  // TODO: Implement your upload logic
  // Similar to image upload but for video
  
  return 'https://your-server.com/videos/${media.platformFile.name}';
}

// Send image message
Future<void> _sendImageMessage({
  required String conversationId,
  required String userId,
  required String imageUrl,
  String? caption,
}) async {
  // Use SDK's sendMessage method with image attachment
  await IsmChat.i.sendMessage(
    conversationId: conversationId,
    userId: userId,
    body: 'Image',
    customType: IsmChatCustomMessageType.image.value,
    attachments: [
      {
        'mediaUrl': imageUrl,
        'thumbnailUrl': imageUrl,
        'attachmentType': IsmChatMediaType.image.value,
        'name': imageUrl.split('/').last,
        'extension': imageUrl.split('.').last,
        'mimeType': 'image/jpeg',
        'size': 0, // Set actual size if available
      }
    ],
    metaData: caption != null ? {'caption': caption} : null,
  );
}

// Send video message
Future<void> _sendVideoMessage({
  required String conversationId,
  required String userId,
  required String videoUrl,
}) async {
  // Use SDK's sendMessage method with video attachment
  await IsmChat.i.sendMessage(
    conversationId: conversationId,
    userId: userId,
    body: 'Video',
    customType: IsmChatCustomMessageType.video.value,
    attachments: [
      {
        'mediaUrl': videoUrl,
        'thumbnailUrl': videoUrl, // You may want to generate a thumbnail
        'attachmentType': IsmChatMediaType.video.value,
        'name': videoUrl.split('/').last,
        'extension': videoUrl.split('.').last,
        'mimeType': 'video/mp4',
        'size': 0, // Set actual size if available
      }
    ],
  );
}
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Setup paid media handling
    _setupPaidMedia();
    
    return MaterialApp(
      // ... your app
    );
  }

  void _setupPaidMedia() {
    IsmChat.i.onPaidMediaSend = (context, conversation, media) async {
      // Show paid/free screen
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Send ${media.length} media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Send as Paid'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Send as Free'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      );

      if (result == true && conversation != null) {
        // Upload and send
        for (var item in media) {
          final url = await _uploadToServer(item);
          if (item.isVideo) {
            await _sendVideoMessage(
              conversationId: conversation.conversationId ?? '',
              userId: conversation.opponentDetails?.userId ?? '',
              videoUrl: url,
            );
          } else {
            await _sendImageMessage(
              conversationId: conversation.conversationId ?? '',
              userId: conversation.opponentDetails?.userId ?? '',
              imageUrl: url,
              caption: item.caption,
            );
          }
        }
        return true; // We handled it
      }

      return false; // Let SDK handle it
    };
  }

  Future<String> _uploadToServer(WebMediaModel media) async {
    // Your upload logic here
    return 'https://your-server.com/${media.platformFile.name}';
  }
}
```

## Key Points

1. **Enable the feature**: Set `enablePaidMediaHandling: true` in `IsmChatPageProperties`
2. **Set the callback**: Assign `IsmChat.i.onPaidMediaSend` with your handler
3. **Return true**: If you handled the media sending, return `true` to prevent SDK from sending
4. **Return false**: If you want SDK to handle it normally, return `false`
5. **Send from outside**: Use SDK's `sendMessage` method with attachments to send the message so it appears in the UI

## Notes

- The callback receives all selected media (images and videos)
- You can filter or process them as needed
- Make sure to upload media to your server before sending
- Use SDK's send methods to ensure messages appear in the chat UI
- The delegate is called before any upload happens in the SDK
