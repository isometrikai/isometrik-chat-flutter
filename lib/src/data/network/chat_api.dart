import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// ChatAPI class is a singleton class
///
/// It  will be used for API endpoint ants
class IsmChatAPI {
  IsmChatAPI._();

  static String get baseUrl =>
      IsmChatConfig.communicationConfig.projectConfig.chatApisBaseUrl ??
      'https://apis.isometrik.io';

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
  static String deliverStatus = '$chatStatus/delivery';
  static String chatMessages = '$baseUrl/chat/messages';
  static String chatMessagesCount = '$chatMessages/count';
  static String userchatMessages = '$chatMessages/user';

  static String readAllMessages = '$chatMessages/read';
  static String deleteMessagesForMe = '$chatMessages/self';
  static String deleteMessages = '$chatMessages/everyone';
  static String createPresignedurl = '$user/presignedurl/create';
  static String presignedUrls = '$chatMessages/presignedurls';

  static String chatIndicator = '$baseUrl/chat/indicator';
  static String typingIndicator = '$chatIndicator/typing';
  static String deliveredIndicator = '$chatIndicator/delivered';
  static String readIndicator = '$chatIndicator/read';
  static String reacton = '$baseUrl/chat/reaction';
  static String contactSyncPost =
      'https://admin-apis.isometrik.io/v1/contacts/sync';
  static String contactGet = 'https://admin-apis.isometrik.io/v1/contacts';

  /// Broadcast url
  static String chatGroupCasts = '$baseUrl/chat/groupcasts';
  static String chatGroupCast = '$baseUrl/chat/groupcast';
  static String chatGroupCastMember = '$chatGroupCast/members';
  static String chatGroupCastEligibleMember = '$chatGroupCast/eligible/members';
  static String chatGroupCastMessage = '$chatGroupCast/message';
  static String chatGroupCastMessages = '$chatGroupCast/messages';
  static String chatGroupCastDeleteEveryone = '$chatGroupCast/message/everyone';
  static String chatGroupCastDeleteSelf = '$chatGroupCast/message/self';
}
