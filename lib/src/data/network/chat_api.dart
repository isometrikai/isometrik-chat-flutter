import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// API endpoint constants for the chat SDK.
///
/// This class provides all API endpoint URLs used throughout the SDK.
/// It's a singleton-like class (private constructor) with static members
/// for easy access to endpoint strings.
///
/// **Architecture:**
/// - Singleton pattern: Private constructor prevents instantiation
/// - Static members: All endpoints are static for easy access
/// - Base URL: Configurable via [IsmChatConfig.communicationConfig]
///
/// **Usage:**
/// ```dart
/// final url = IsmChatAPI.sendMessage; // Returns full URL
/// final conversationsUrl = IsmChatAPI.getChatConversations;
/// ```
///
/// **Base URL:**
/// The base URL is determined from the communication config. If not provided,
/// it defaults to `https://apis.isometrik.ai`.
///
/// **See Also:**
/// - [IsmChatApiWrapper] - API wrapper for making HTTP calls
/// - [MODULE_DATA.md] - Data module documentation
/// - [ARCHITECTURE.md] - Architecture documentation
class IsmChatAPI {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is used as a namespace for API endpoints and should not
  /// be instantiated.
  IsmChatAPI._();

  /// Gets the base URL for all API endpoints.
  ///
  /// The base URL is retrieved from the communication config. If not set,
  /// it defaults to the production API URL.
  ///
  /// **Returns:**
  /// - `String`: The base URL for API endpoints.
  ///
  /// **Example:**
  /// ```dart
  /// final base = IsmChatAPI.baseUrl; // 'https://apis.isometrik.ai'
  /// ```
  static String get baseUrl =>
      IsmChatConfig.communicationConfig.projectConfig.chatApisBaseUrl ??
      'https://apis.isometrik.ai';

  static String user = '$baseUrl/chat/user';
  static String userDetails = '$baseUrl/chat/user/details';
  static String allUsers = '$baseUrl/chat/users';
  static String updateUsers = user;
  static String authenticate = '$allUsers/authenticate';
  static String chatConversation = '$baseUrl/chat/conversation';
  static String chatConversationClear = '$chatConversation/clear';
  static String chatConversationDelete = '$chatConversation/local';
  static String getChatConversations = '$baseUrl/chat/conversations';
  static String conversationDetails = '$chatConversation/details';
  static String conversationSetting = '$chatConversation/settings';
  static String getPublicAndOpenConversation =
      '${chatConversation}s/publicoropen';
  static String observer = '$chatConversation/observer';
  static String joinObserver = '$observer/join';
  static String leaveObserver = '$observer/leave';
  static String getObserver = '${observer}s';
  static String conversationUnreadCount = '${chatConversation}s/unread/count';
  static String conversationUnreadCountBulk = '$conversationUnreadCount/bulk';
  static String conversationCount = '${chatConversation}s/count';
  static String conversationMembers = '$chatConversation/members';
  static String eligibleMembers = '$chatConversation/eligible/members';
  static String leaveConversation = '$chatConversation/leave';
  static String joinConversation = '$chatConversation/join';
  static String conversationAdmin = '$chatConversation/admin';
  static String conversationTitle = '$chatConversation/title';
  static String conversationImage = '$chatConversation/image';
  static String blockUser = '$user/block';
  static String unblockUser = '$user/unblock';
  static String nonBlockUser = '$user/nonblock';
  static final String _profilePic = '$user/presignedurl';
  static String updateProfilePic = '$_profilePic/update';
  static String createProfilePic = '$_profilePic/create';
  static String sendMessage = '$baseUrl/chat/message';
  // static String sendBroadcastMessage = '$baseUrl/chat/message/broadcast';
  static String sendForwardMessage = '$baseUrl/chat/message/forward';
  static String chatStatus = '$sendMessage/status';
  static String readStatus = '$chatStatus/read';
  /// Delivery status endpoint.
  /// POST: Mark messages as delivered
  static String deliverStatus = '$chatStatus/delivery';

  // ==================== Messages Endpoints ====================

  /// Messages endpoint.
  /// GET: Retrieve messages
  static String chatMessages = '$baseUrl/chat/messages';

  /// Messages status endpoint.
  /// GET: Get message status information
  static String chatMessagesStatus = '$chatMessages/status';

  /// Messages count endpoint.
  /// GET: Get message count
  static String chatMessagesCount = '$chatMessages/count';

  /// User messages endpoint.
  /// GET: Get messages for a specific user
  static String userchatMessages = '$chatMessages/user';

  /// Read all messages endpoint.
  /// POST: Mark all messages as read
  static String readAllMessages = '$chatMessages/read';

  /// Delete messages for me endpoint.
  /// DELETE: Delete messages for current user only
  static String deleteMessagesForMe = '$chatMessages/self';

  /// Delete messages for everyone endpoint.
  /// DELETE: Delete messages for all users
  static String deleteMessages = '$chatMessages/everyone';

  // ==================== Presigned URL Endpoints ====================

  /// Create presigned URL endpoint.
  /// POST: Create presigned URL for file upload
  static String createPresignedurl = '$user/presignedurl/create';

  /// Presigned URLs endpoint.
  /// GET: Get presigned URLs for messages
  static String presignedUrls = '$chatMessages/presignedurls';

  // ==================== Indicator Endpoints ====================

  /// Chat indicator endpoint.
  /// Base endpoint for typing, delivery, and read indicators
  static String chatIndicator = '$baseUrl/chat/indicator';

  /// Typing indicator endpoint.
  /// POST: Send typing indicator
  static String typingIndicator = '$chatIndicator/typing';

  /// Delivered indicator endpoint.
  /// POST: Send delivered indicator
  static String deliveredIndicator = '$chatIndicator/delivered';

  /// Read indicator endpoint.
  /// POST: Send read indicator
  static String readIndicator = '$chatIndicator/read';

  // ==================== Reaction Endpoints ====================

  /// Reaction endpoint.
  /// POST/DELETE: Add or remove message reactions
  static String reacton = '$baseUrl/chat/reaction';

  // ==================== Contact Endpoints ====================

  /// Contact sync endpoint.
  /// POST: Sync contacts with server
  /// Note: Uses external admin API endpoint
  static String contactSyncPost =
      'https://admin-apis.isometrik.io/v1/contacts/sync';

  /// Get contacts endpoint.
  /// GET: Retrieve contacts
  /// Note: Uses external admin API endpoint
  static String contactGet = 'https://admin-apis.isometrik.io/v1/contacts';

  // ==================== Broadcast/Groupcast Endpoints ====================

  /// Groupcasts endpoint.
  /// GET: Get list of groupcasts (broadcasts)
  static String chatGroupCasts = '$baseUrl/chat/groupcasts';

  /// Groupcast endpoint.
  /// GET/POST/DELETE: Groupcast operations
  static String chatGroupCast = '$baseUrl/chat/groupcast';

  /// Groupcast members endpoint.
  /// GET/POST/DELETE: Manage groupcast members
  static String chatGroupCastMember = '$chatGroupCast/members';

  /// Groupcast eligible members endpoint.
  /// GET: Get eligible members for groupcast
  static String chatGroupCastEligibleMember = '$chatGroupCast/eligible/members';

  /// Groupcast message endpoint.
  /// POST: Send message to groupcast
  static String chatGroupCastMessage = '$chatGroupCast/message';

  /// Groupcast messages endpoint.
  /// GET: Get messages from groupcast
  static String chatGroupCastMessages = '$chatGroupCast/messages';

  /// Delete groupcast message for everyone endpoint.
  /// DELETE: Delete message for all recipients
  static String chatGroupCastDeleteEveryone = '$chatGroupCast/message/everyone';

  /// Delete groupcast message for self endpoint.
  /// DELETE: Delete message for current user only
  static String chatGroupCastDeleteSelf = '$chatGroupCast/message/self';
}
