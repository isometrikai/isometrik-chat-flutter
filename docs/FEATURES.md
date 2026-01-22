# Features Documentation

**Last Updated:** January 21, 2026  
**SDK Version:** 1.0.0

## Overview

This document provides a comprehensive list of features available in the Isometrik Chat Flutter SDK, their status, platform compatibility, and known limitations.

## Feature Status Legend

- ✅ **Fully Supported** - Feature is fully implemented and working
- ⚠️ **Partially Supported** - Feature works but has limitations
- 🚧 **In Development** - Feature is being developed
- ❌ **Not Supported** - Feature is not available
- 📝 **Planned** - Feature is planned for future release

---

## Core Features

### 1. Real-Time Messaging ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Description:**
Real-time messaging using MQTT protocol for instant message delivery.

**Features:**
- Text messages
- Message delivery status (sent, delivered, read)
- Message timestamps
- Message search
- Message pagination

**Limitations:**
- None

---

### 2. Message Types ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Supported Message Types:**
- ✅ Text messages
- ✅ Image messages
- ✅ Video messages
- ✅ Audio/Voice messages
- ✅ File/Document messages
- ✅ Location messages
- ✅ Contact messages
- ✅ Reply messages
- ✅ Forward messages
- ✅ Admin/System messages

**Limitations:**
- File size limits may vary by platform
- Some file types may have platform-specific restrictions

---

### 3. Attachments ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Supported Attachment Types:**
- ✅ Images (JPEG, PNG, GIF, WebP)
- ✅ Videos (MP4, MOV, etc.)
- ✅ Audio files (MP3, WAV, etc.)
- ✅ Documents (PDF, DOC, DOCX, etc.)
- ✅ Location sharing
- ✅ Contact sharing

**Limitations:**
- Maximum file size depends on server configuration
- Web platform may have different file picker behavior
- Some file types may require platform-specific permissions

---

### 4. Conversations ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ One-to-one conversations
- ✅ Group conversations
- ✅ Broadcast messages (groupcasts)
- ✅ Conversation list
- ✅ Conversation search
- ✅ Conversation filtering
- ✅ Unread message count
- ✅ Last message preview
- ✅ Conversation metadata

**Limitations:**
- None

---

### 5. Group Chat ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Create groups
- ✅ Add/remove members
- ✅ Group admin management
- ✅ Group title and image
- ✅ Leave group
- ✅ Group member list
- ✅ Group member search

**Limitations:**
- Maximum group size may be limited by server configuration

---

### 6. Broadcast Messages ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Send broadcast messages
- ✅ Broadcast member management
- ✅ Broadcast message history
- ✅ Broadcast eligible members

**Limitations:**
- Broadcast functionality may have server-side limitations

---

### 7. Message Reactions ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Add reactions to messages
- ✅ Remove reactions
- ✅ Multiple reaction types (emoji)
- ✅ Reaction count display
- ✅ See who reacted

**Supported Reactions:**
- Thumbs up/down
- Heart
- Laughing
- Crying
- Surprised
- And more (see `IsmChatEmoji` enum)

**Limitations:**
- None

---

### 8. Typing Indicators ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Real-time typing indicators
- ✅ Typing status display
- ✅ Multiple users typing support

**Limitations:**
- None

---

### 9. Message Status ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Sent status
- ✅ Delivered status
- ✅ Read status
- ✅ Read receipts
- ✅ Delivery receipts
- ✅ Read by all indicator

**Limitations:**
- None

---

### 10. Message Operations ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Reply to messages
- ✅ Forward messages
- ✅ Delete messages (for me / for everyone)
- ✅ Copy message text
- ✅ Select multiple messages
- ✅ Clear conversation
- ✅ Search messages

**Limitations:**
- Delete for everyone may have time restrictions
- Some operations may require admin permissions in groups

---

### 11. User Management ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ User profile management
- ✅ User online/offline status
- ✅ Last seen timestamp
- ✅ Block/unblock users
- ✅ User search
- ✅ User list retrieval

**Limitations:**
- None

---

### 12. Media Operations ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Image picker (camera/gallery)
- ✅ Video picker (camera/gallery)
- ✅ File picker
- ✅ Media compression
- ✅ Media preview
- ✅ Media upload progress

**Limitations:**
- Camera access requires platform-specific permissions
- Web platform uses different file picker mechanism
- Media compression may vary by platform

---

### 13. Voice Messages ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Record voice messages
- ✅ Play voice messages
- ✅ Voice message duration
- ✅ Voice message waveform

**Limitations:**
- Web platform requires microphone permissions
- Recording quality may vary by platform

---

### 14. Location Sharing ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Share current location
- ✅ Share custom location
- ✅ Location preview
- ✅ Open location in maps

**Limitations:**
- Requires location permissions
- Web platform may have different map integration

---

### 15. Contact Sharing ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Share contacts
- ✅ Contact preview
- ✅ Contact sync

**Limitations:**
- Requires contacts permission
- Web platform may have limited contact access

---

### 16. Mentions ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Mention users in messages
- ✅ Mention suggestions
- ✅ Mention notifications
- ✅ Mention highlighting

**Limitations:**
- None

---

### 17. Search ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Search conversations
- ✅ Search messages
- ✅ Search users
- ✅ Search with filters

**Limitations:**
- Search performance may vary with large datasets

---

### 18. Offline Support ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Local database storage
- ✅ Offline message queue
- ✅ Automatic sync when online
- ✅ Offline conversation access

**Limitations:**
- Web platform uses IndexedDB (browser-dependent)
- Storage limits may vary by platform

---

### 19. Push Notifications ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Push notification support
- ✅ Custom notification handlers
- ✅ Notification payload handling
- ✅ Deep linking from notifications

**Limitations:**
- Requires platform-specific setup
- Web platform uses different notification API

---

### 20. UI Customization ✅

**Status:** ✅ Fully Supported  
**Platforms:** Android, iOS, Web

**Features:**
- ✅ Custom themes (light/dark)
- ✅ Custom colors
- ✅ Custom fonts
- ✅ Custom message bubbles
- ✅ Custom chat backgrounds
- ✅ Responsive design (web)

**Limitations:**
- Some customization options may be limited on certain platforms

---

### 21. Web Support ✅

**Status:** ✅ Fully Supported  
**Platforms:** Web

**Features:**
- ✅ Full web compatibility
- ✅ Responsive layout
- ✅ Multi-column layout
- ✅ Web-specific optimizations

**Limitations:**
- Some features may behave differently on web
- File picker uses browser API
- Camera/microphone require browser permissions

---

## Partially Supported Features

### 1. Media Download 📝

**Status:** 📝 Planned  
**Platforms:** Android, iOS, Web

**Description:**
Download media files to device storage.

**Current Status:**
- Feature is commented out in code
- Not currently available

**Planned For:**
- Future release

---

## Platform Compatibility Matrix

| Feature | Android | iOS | Web | Notes |
|---------|---------|-----|-----|-------|
| Text Messages | ✅ | ✅ | ✅ | Fully supported |
| Image Messages | ✅ | ✅ | ✅ | Fully supported |
| Video Messages | ✅ | ✅ | ✅ | Fully supported |
| Audio Messages | ✅ | ✅ | ✅ | Fully supported |
| File Messages | ✅ | ✅ | ✅ | Fully supported |
| Location Sharing | ✅ | ✅ | ✅ | Requires permissions |
| Contact Sharing | ✅ | ✅ | ⚠️ | Limited on web |
| Voice Recording | ✅ | ✅ | ⚠️ | Requires permissions |
| Camera Access | ✅ | ✅ | ⚠️ | Browser-dependent |
| Push Notifications | ✅ | ✅ | ⚠️ | Different APIs |
| Offline Storage | ✅ | ✅ | ✅ | IndexedDB on web |
| Group Chat | ✅ | ✅ | ✅ | Fully supported |
| Broadcast | ✅ | ✅ | ✅ | Fully supported |
| Reactions | ✅ | ✅ | ✅ | Fully supported |
| Typing Indicators | ✅ | ✅ | ✅ | Fully supported |
| Message Search | ✅ | ✅ | ✅ | Fully supported |
| Conversation Search | ✅ | ✅ | ✅ | Fully supported |

---

## Feature Flags

The SDK supports feature flags through `IsmChatFeature` enum:

```dart
enum IsmChatFeature {
  reply,              // ✅ Supported
  forward,            // ✅ Supported
  reaction,           // ✅ Supported
  chageWallpaper,     // ✅ Supported
  searchMessage,      // ✅ Supported
  showMessageStatus,  // ✅ Supported
  mentionMember,      // ✅ Supported
  clearChat,          // ✅ Supported
  deleteMessage,      // ✅ Supported
  copyMessage,        // ✅ Supported
  selectMessage,      // ✅ Supported
  emojiIcon,          // ✅ Supported
  audioMessage,       // ✅ Supported
  // mediaDownload,   // 📝 Planned (commented out)
}
```

---

## Known Limitations

1. **File Size Limits**: Maximum file size depends on server configuration
2. **Group Size**: Maximum group members may be limited by server
3. **Web Permissions**: Some features require explicit browser permissions
4. **Offline Storage**: Web uses IndexedDB (browser-dependent)
5. **Media Download**: Currently not available (planned feature)

---

## Related Documentation

- [KNOWN_ISSUES.md](./KNOWN_ISSUES.md) - Known issues and workarounds
- [ROADMAP.md](./ROADMAP.md) - Future feature roadmap
- [MODULE_CONTROLLERS.md](./MODULE_CONTROLLERS.md) - Controller features
- [MODULE_VIEWS.md](./MODULE_VIEWS.md) - UI features

---

**Last Updated:** January 21, 2026

