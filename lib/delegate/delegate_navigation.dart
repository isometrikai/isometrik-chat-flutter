part of '../isometrik_chat_flutter.dart';

/// Navigation and outside chat mixin for IsmChatDelegate.
///
/// This mixin contains methods related to navigating to conversations from outside
/// the chat context, such as from push notifications or external app triggers.
mixin IsmChatDelegateNavigationMixin {
  /// Opens the conversation info screen for any user from outside the chat context.
  ///
  /// This method allows the host app to display conversation/contact info for any user
  /// without requiring an active chat session. Similar to [chatFromOutside], but for
  /// viewing conversation details instead of starting a chat.
  ///
  /// **Parameters:**
  /// - `profileImageUrl`: Profile image URL of the user (optional)
  /// - `name`: Display name of the user
  /// - `userIdentifier`: Unique identifier for the user (email, phone, etc.)
  /// - `userId`: Unique user ID
  /// - `online`: Whether the user is currently online
  /// - `metaData`: Optional metadata for the user
  /// - `conversationId`: Optional conversation ID. If provided, will use this directly.
  ///                     If not provided, will attempt to find/create conversation.
  /// - `isGroup`: Whether this is a group conversation (default: false)
  /// - `conversationImageUrl`: Optional conversation image URL for groups
  /// - `conversationTitle`: Optional conversation title for groups
  /// - `customType`: Optional custom type for the conversation
  /// - `conversationType`: Type of conversation (default: private)
  /// - `duration`: Duration for loader display (default: 500ms)
  /// - `isShowLoader`: Whether to show loader during initialization (default: true)
  ///
  /// **Example:**
  /// ```dart
  /// await IsmChat.i.showConversationInfoFromOutside(
  ///   name: 'John Doe',
  ///   userIdentifier: 'john@example.com',
  ///   userId: 'user123',
  ///   online: true,
  /// );
  /// ```
  Future<void> showConversationInfoFromOutside({
    String profileImageUrl = '',
    required String name,
    required userIdentifier,
    required String userId,
    required bool online,
    IsmChatMetaData? metaData,
    String? conversationId,
    bool isGroup = false,
    String? conversationImageUrl,
    String? conversationTitle,
    String? customType,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
    Duration duration = const Duration(milliseconds: 500),
    bool isShowLoader = true,
  }) async {
    if (isShowLoader) {
      IsmChatUtility.showLoader();
    }

    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }

    // Wait for conversation controller to be ready
    while (!IsmChatUtility.conversationControllerRegistered) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await Future.delayed(duration);

    if (isShowLoader) {
      IsmChatUtility.closeLoader();
    }

    var conversationController = IsmChatUtility.conversationController;
    IsmChatConversationModel? conversation;

    // If conversationId is provided, try to get existing conversation
    final providedConversationId = conversationId;
    if (providedConversationId != null && providedConversationId.isNotEmpty) {
      conversation =
          conversationController.getConversation(providedConversationId);
      // Try to get from database
      conversation ??= await IsmChatConfig.dbWrapper
          ?.getConversation(providedConversationId);
    }

    // If conversation not found, try to find by userId
    if (conversation == null) {
      final foundConversationId =
          conversationController.getConversationId(userId);
      if (foundConversationId.isNotEmpty) {
        conversation =
            conversationController.getConversation(foundConversationId);
        conversation ??=
            await IsmChatConfig.dbWrapper?.getConversation(foundConversationId);
      }
    }

    // If still not found, create a temporary conversation model
    if (conversation == null) {
      final nameData = name.split(' ');
      var userDetails = UserDetails(
        userProfileImageUrl: profileImageUrl,
        userName: name,
        userIdentifier: userIdentifier,
        userId: userId,
        online: online,
        lastSeen: 0,
        metaData: IsmChatMetaData(
          profilePic: profileImageUrl,
          firstName: nameData.isNotEmpty ? nameData.first : '',
          lastName: nameData.length > 1 ? nameData.last : '',
        ),
      );

      final tempConversationId =
          conversationController.getConversationId(userId);
      conversation = IsmChatConversationModel(
        conversationId:
            tempConversationId.isNotEmpty ? tempConversationId : null,
        userIds: isGroup ? [userId] : null,
        messagingDisabled: false,
        conversationImageUrl: conversationImageUrl,
        conversationTitle: conversationTitle,
        isGroup: isGroup,
        opponentDetails: userDetails,
        unreadMessagesCount: 0,
        lastMessageDetails: null,
        lastMessageSentAt: 0,
        membersCount: isGroup ? 1 : null,
        conversationType: conversationType,
        metaData: metaData,
        customType: customType,
      );
    } else {
      // Update with provided metadata if available
      // conversation is guaranteed to be non-null here (we're in the else block)
      final existingConversation = conversation;
      final existingIsGroup = existingConversation.isGroup ?? false;
      final updatedIsGroup = isGroup || existingIsGroup;
      conversation = existingConversation.copyWith(
        metaData: metaData ?? existingConversation.metaData,
        conversationImageUrl:
            conversationImageUrl ?? existingConversation.conversationImageUrl,
        conversationTitle:
            conversationTitle ?? existingConversation.conversationTitle,
        isGroup: updatedIsGroup,
      );
    }

    // Ensure chat page controller is initialized
    if (!IsmChatUtility.chatPageControllerRegistered) {
      IsmChatPageBinding().dependencies();
      // Wait for controller to be ready
      while (!IsmChatUtility.chatPageControllerRegistered) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    // Set the conversation in chat page controller
    IsmChatUtility.chatPageController.conversation = conversation;

    // Update local conversation
    conversationController
      ..updateLocalConversation(conversation)
      ..currentConversation = conversation;

    // Navigate to conversation info view
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.coversationInfoView;
    } else {
      await IsmChatRoute.goToRoute(
        IsmChatConverstaionInfoView(
          conversationId: conversation.conversationId,
          conversation: conversation,
        ),
      );
    }
  }

  /// Initiates a chat conversation from outside the chat context.
  ///
  /// This method allows the host app to start a chat conversation with a user
  /// from anywhere in the app, such as from a user profile or contact list.
  Future<void> chatFromOutside({
    String profileImageUrl = '',
    required String name,
    required userIdentifier,
    required String userId,
    required bool online,
    IsmChatMetaData? metaData,
    ConversationVoidCallback? onNavigateToChat,
    ConversationVoidCallback? onConversationCreated,
    Duration duration = const Duration(milliseconds: 500),
    OutSideMessage? outSideMessage,
    String? storyMediaUrl,
    bool pushNotifications = true,
    bool isCreateGroupFromOutSide = false,
    String? conversationImageUrl,
    String? conversationTitle,
    String? customType,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
  }) async {
    IsmChatUtility.showLoader();

    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }

    await Future.delayed(duration);

    IsmChatUtility.closeLoader();
    var controller = IsmChatUtility.conversationController;
    var conversationId = controller.getConversationId(userId);
    IsmChatConversationModel? conversation;
    if (conversationId.isEmpty) {
      final nameData = name.split(' ');
      var userDetails = UserDetails(
        userProfileImageUrl: profileImageUrl,
        userName: name,
        userIdentifier: userIdentifier,
        userId: userId,
        online: online,
        lastSeen: 0,
        metaData: IsmChatMetaData(
          profilePic: profileImageUrl,
          firstName: nameData.first,
          lastName: nameData.length > 1 ? nameData.last : '',
        ),
      );
      conversation = IsmChatConversationModel(
        userIds: isCreateGroupFromOutSide ? [userId] : null,
        messagingDisabled: false,
        conversationImageUrl: conversationImageUrl,
        conversationTitle: conversationTitle,
        isGroup: isCreateGroupFromOutSide,
        opponentDetails: userDetails,
        unreadMessagesCount: 0,
        lastMessageDetails: null,
        lastMessageSentAt: 0,
        membersCount: 1,
        conversationType: conversationType,
        metaData: metaData,
        customType: customType,
        outSideMessage: outSideMessage,
        pushNotifications: pushNotifications,
      );
    } else {
      conversation = controller.conversations
          .firstWhere((e) => e.conversationId == conversationId);
      conversation = conversation.copyWith(
        metaData: metaData,
        outSideMessage: outSideMessage,
        pushNotifications: pushNotifications,
        isGroup: isCreateGroupFromOutSide,
      );
    }
    IsmChatConfig.onConversationCreated = onConversationCreated;

    (onNavigateToChat ?? IsmChatProperties.conversationProperties.onChatTap)
        ?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            conversation);
    controller.updateLocalConversation(conversation);
    if (storyMediaUrl == null) {
      await controller.goToChatPage();
    } else {
      await controller.replayOnStories(
        conversationId: conversationId,
        userDetails: conversation.opponentDetails!,
        caption: outSideMessage?.caption ?? '',
        sendPushNotification: pushNotifications,
        storyMediaUrl: storyMediaUrl,
      );
    }
  }

  /// Initiates a chat conversation from outside using an existing conversation model.
  ///
  /// This method allows the host app to navigate to a chat conversation using
  /// a pre-existing conversation model.
  Future<void> chatFromOutsideWithConversation({
    required IsmChatConversationModel ismChatConversation,
    void Function(BuildContext, IsmChatConversationModel)? onNavigateToChat,
    Duration duration = const Duration(milliseconds: 100),
    bool isShowLoader = true,
  }) async {
    if (isShowLoader) {
      IsmChatUtility.showLoader();

      await Future.delayed(duration);

      IsmChatUtility.closeLoader();
    }

    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }

    var controller = IsmChatUtility.conversationController;

    (onNavigateToChat ?? IsmChatProperties.conversationProperties.onChatTap)
        ?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            ismChatConversation);
    controller.updateLocalConversation(ismChatConversation);
    await controller.goToChatPage();
  }
}
