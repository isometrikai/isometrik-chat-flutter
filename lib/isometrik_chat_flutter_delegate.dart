part of 'isometrik_chat_flutter.dart';

class IsmChatDelegate {
  const IsmChatDelegate();

  static IsmChatCommunicationConfig? _config;

  IsmChatCommunicationConfig? get config => _config;

  static IsmChatConfig? _ismChatConfig;

  IsmChatConfig? get ismChatConfig => _ismChatConfig;

  static final RxString _unReadConversationCount = ''.obs;
  String get unReadConversationCount => _unReadConversationCount.value;
  set unReadConversationCount(String value) =>
      _unReadConversationCount.value = value;

  static final Rx<String?> _chatPageTag = Rx<String?>(null);
  String? get chatPageTag => _chatPageTag.value;
  set chatPageTag(String? value) => _chatPageTag.value = value;

  static final Rx<String?> _chatListPageTag = Rx<String?>(null);
  String? get chatListPageTag => _chatListPageTag.value;
  set chatListPageTag(String? value) => _chatListPageTag.value = value;

  Future<void> initialize(
      {required IsmChatCommunicationConfig communicationConfig,
      required GlobalKey<NavigatorState> kNavigatorKey,
      bool useDatabase = true,
      NotificaitonCallback? showNotification,
      String databaseName = IsmChatStrings.dbname,
      bool shouldPendingMessageSend = true,
      SendMessageCallback? sendPaidWalletMessage,
      IsmPaidWalletConfig? paidWalletConfig,
      ResponseCallback? paidWalletMessageApiResponse,
      SortingConversationCallback? sortConversationWithIdentifier,
      ConnectionStateCallback? mqttConnectionStatus,
      ResponseCallback? chatInvalidate,
      IsmMqttProperties? mqttProperties,
      bool? isMonthFirst,
      bool messageEncrypted = false,
      NotificationBodyCallback? notificationBody}) async {
    IsmChatConfig.kNavigatorKey = kNavigatorKey;
    IsmChatConfig.messageEncrypted = messageEncrypted;
    IsmChatConfig.notificationBody = notificationBody;
    IsmChatConfig.dbName = databaseName;
    IsmChatConfig.useDatabase = !kIsWeb && useDatabase;
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.mqttConnectionStatus = mqttConnectionStatus;
    IsmChatConfig.sortConversationWithIdentifier =
        sortConversationWithIdentifier;
    IsmChatConfig.shouldPendingMessageSend = shouldPendingMessageSend;
    IsmChatConfig.sendPaidWalletMessage = sendPaidWalletMessage;
    IsmChatConfig.paidWalletModel = paidWalletConfig;
    IsmChatConfig.paidWalletMessageApiResponse = paidWalletMessageApiResponse;
    IsmChatConfig.chatInvalidate = chatInvalidate;
    IsmChatConfig.isMonthFirst = isMonthFirst;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.dbWrapper = await IsmChatDBWrapper.create();
    await _initializeMqtt(
      config: communicationConfig,
      mqttProperties: mqttProperties ?? IsmMqttProperties(),
    );
  }

  Future<void> _initializeMqtt({
    required IsmChatCommunicationConfig config,
    required IsmMqttProperties mqttProperties,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    IsmChatConfig.shouldSetupMqtt = mqttProperties.shouldSetupMqtt;
    await Get.find<IsmChatMqttController>().setup(
      config: config,
      mqttProperties: mqttProperties,
    );
  }

  Future<void> listenMqttEvent({
    required EventModel event,
    NotificaitonCallback? showNotification,
  }) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      IsmChatConfig.showNotification = showNotification;
      Get.find<IsmChatMqttController>().onMqttEvent(
        event: event,
      );
    }
  }

  StreamSubscription<EventModel> addEventListener(
      Function(EventModel) listener) {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmChatMqttController>();
    mqttController.eventListeners.add(listener);
    return mqttController.eventStreamController.stream.listen(listener);
  }

  Future<void> removeEventListener(Function(EventModel) listener) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      var mqttController = Get.find<IsmChatMqttController>();
      mqttController.eventListeners.remove(listener);
      await mqttController.eventStreamController.stream.drain();
      for (var listener in mqttController.eventListeners) {
        mqttController.eventStreamController.stream.listen(listener);
      }
    }
  }

  void showThirdColumn() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.outSideView;
    }
  }

  void clostThirdColumn() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
    }
  }

  void showBlockUnBlockDialog() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (!(controller.conversation?.isChattingAllowed == true)) {
        controller.showDialogCheckBlockUnBlock();
      }
    }
  }

  void changeCurrentConversation() {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.currentConversation = null;
    }
  }

  void updateChatPageController() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      var conversationModel = controller.conversation;
      controller
        ..conversation = null
        ..conversation = conversationModel;
    }
  }

  Future<List<IsmChatConversationModel>?> getAllConversationFromDB() async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      return await Get.find<IsmChatMqttController>().getAllConversationFromDB();
    }
    return null;
  }

  Future<List<SelectedMembers>?> getNonBlockUserList() async {
    if (IsmChatUtility.conversationControllerRegistered) {
      return await IsmChatUtility.conversationController.getNonBlockUserList();
    }
    return null;
  }

  Future<List<IsmChatConversationModel>> get userConversations =>
      getAllConversationFromDB().then((conversations) => (conversations ?? [])
          .where(
              IsmChatProperties.conversationProperties.conversationPredicate ??
                  (_) => true)
          .toList());

  Future<int> get unreadCount =>
      userConversations.then((value) => value.unreadCount);

  Future<void> updateConversation(
          {required String conversationId,
          required IsmChatMetaData metaData}) async =>
      await IsmChatUtility.conversationController.updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    required bool isLoading,
  }) async =>
      await IsmChatUtility.conversationController.updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  Future<void> getChatConversation() async {
    if (IsmChatUtility.conversationControllerRegistered) {
      await IsmChatUtility.conversationController.getChatConversations();
    }
  }

  Future<void> getChatConversationFromLocal({
    String? searchTag,
  }) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      await IsmChatUtility.conversationController
          .getConversationsFromDB(searchTag: searchTag);
    }
  }

  Future<List<IsmChatConversationModel>> getChatConversationApi({
    int skip = 0,
    int limit = 20,
    String? searchTag,
    bool includeConversationStatusMessagesInUnreadMessagesCount = false,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return [];
    return await Get.find<IsmChatMqttController>().getChatConversationApi(
      skip: skip,
      limit: limit,
      searchTag: searchTag,
      includeConversationStatusMessagesInUnreadMessagesCount:
          includeConversationStatusMessagesInUnreadMessagesCount,
    );
  }

  Future<int> getChatConversationsCount({
    required bool isLoading,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return 0;
    final count = await Get.find<IsmChatMqttController>()
        .getChatConversationsCount(isLoading: isLoading);
    return int.tryParse(count) ?? 0;
  }

  Future<void> getChatConversationsUnreadCount({
    bool isLoading = false,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return;
    await Get.find<IsmChatMqttController>().getChatConversationsUnreadCount(
      isLoading: isLoading,
    );
  }

  Future<int> getChatConversationsMessageCount({
    required bool isLoading,
    required String converationId,
    required List<String> senderIds,
    required bool senderIdsExclusive,
    required int lastMessageTimestamp,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return 0;
    final count = await Get.find<IsmChatMqttController>()
        .getChatConversationsMessageCount(
      isLoading: isLoading,
      converationId: converationId,
      senderIds: senderIds,
      lastMessageTimestamp: lastMessageTimestamp,
      senderIdsExclusive: senderIdsExclusive,
    );
    return int.tryParse(count) ?? 0;
  }

  Future<IsmChatConversationModel?> getConverstaionDetails({
    required bool isLoading,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      return await IsmChatUtility.chatPageController.getConverstaionDetails(
        isLoading: isLoading,
      );
    }
    return null;
  }

  Future<void> unblockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: true,
      );
    }
  }

  Future<void> blockUser({
    required String opponentId,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.blockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: false,
      );
    }
  }

  Future<List<IsmChatMessageModel>?> getMessagesFromApi({
    required String conversationId,
    required int lastMessageTimestamp,
    required int limit,
    required int skip,
    String? searchText,
    required bool isLoading,
  }) async {
    if (Get.isRegistered<IsmChatCommonController>()) {
      return await Get.find<IsmChatCommonController>().getChatMessages(
        conversationId: conversationId,
        lastMessageTimestamp: lastMessageTimestamp,
        limit: limit,
        skip: skip,
        searchText: searchText,
        isLoading: isLoading,
      );
    }
    return null;
  }

  Future<void> getMessageOnChatPage({
    bool isBroadcast = false,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      await controller.getMessagesFromAPI(
        isBroadcast: isBroadcast,
        lastMessageTimestamp: controller.messages.isNotEmpty
            ? controller.messages.last.sentAt
            : 0,
      );
    }
  }

  Future<void> logout() async {
    try {
      await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
      await Future.wait([
        Get.delete<IsmChatConversationsController>(
            tag: IsmChat.i.chatListPageTag, force: true),
        Get.delete<IsmChatCommonController>(force: true),
        Get.delete<IsmChatMqttController>(force: true),
      ]);
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }

  Future<void> disconnectMQTT() async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      final mqttController = Get.find<IsmChatMqttController>();
      if (mqttController.connectionState == IsmChatConnectionState.connected) {
        mqttController.mqttHelper.disconnect();
      }
    }
  }

  Future<void> clearChatLocalDb() async {
    await IsmChatConfig.dbWrapper?.clearChatLocalDb();
  }

  Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
    bool shouldUpdateLocal = true,
  }) async {
    await IsmChatUtility.conversationController.deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
      shouldUpdateLocal: shouldUpdateLocal,
    );
  }

  Future<bool> deleteChatFormDB(String isometrickChatId,
          {String conversationId = ''}) async =>
      await Get.find<IsmChatMqttController>()
          .deleteChatFormDB(isometrickChatId, conversationId: conversationId);

  Future<void> exitGroup(
      {required int adminCount, required bool isUserAdmin}) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.leaveGroup(
        adminCount: adminCount,
        isUserAdmin: isUserAdmin,
      );
    }
  }

  Future<void> clearAllMessages(
    String conversationId, {
    bool fromServer = true,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.clearAllMessages(
        conversationId,
        fromServer: fromServer,
      );
    }
  }

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
      if (conversation == null) {
        // Try to get from database
        conversation = await IsmChatConfig.dbWrapper
            ?.getConversation(providedConversationId);
      }
    }

    // If conversation not found, try to find by userId
    if (conversation == null) {
      final foundConversationId =
          conversationController.getConversationId(userId);
      if (foundConversationId.isNotEmpty) {
        conversation =
            conversationController.getConversation(foundConversationId);
        if (conversation == null) {
          conversation = await IsmChatConfig.dbWrapper
              ?.getConversation(foundConversationId);
        }
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

    final chatPageController = IsmChatUtility.chatPageController;

    // Set the conversation in chat page controller
    chatPageController.conversation = conversation;

    // Update local conversation
    conversationController.updateLocalConversation(conversation);
    conversationController.currentConversation = conversation;

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

  Future<IsmChatConversationModel?> getConversation({
    required String conversationId,
  }) async {
    if (!IsmChatUtility.conversationControllerRegistered) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
      await Future.delayed(const Duration(seconds: 2));
    }
    var controller = IsmChatUtility.conversationController;
    final conversation = controller.getConversation(conversationId);
    if (conversation != null) {
      controller.updateLocalConversation(conversation);
    }
    return conversation;
  }

  /// Handles notification tap/payload and navigates to the chat conversation.
  ///
  /// This method should be called when a push notification is tapped.
  /// It extracts the conversationId from the notification data and navigates to that conversation.
  ///
  /// Parameters:
  /// - `notificationData`: The notification payload data (Map<String, dynamic>)
  ///   Expected to contain 'conversationId' key
  ///
  /// Example:
  /// ```dart
  /// // In your notification tap handler
  /// FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  ///   IsmChat.i.handleNotificationPayload(message.data);
  /// });
  /// ```
  Future<void> handleNotificationPayload(
    dynamic notificationData,
  ) async {
    try {
      Map<String, dynamic> payload;

      // Handle both Map and JSON string payloads
      if (notificationData is Map<String, dynamic>) {
        payload = notificationData;
      } else if (notificationData is String) {
        try {
          payload = json.decode(notificationData) as Map<String, dynamic>;
        } catch (e) {
          IsmChatLog.error(
              'handleNotificationPayload: Could not parse JSON string: $e');
          return;
        }
      } else {
        IsmChatLog.error(
            'handleNotificationPayload: Invalid payload type: ${notificationData.runtimeType}');
        return;
      }

      // Extract conversationId from notification data
      // Try direct key first, then try parsing as message object
      var conversationId = payload['conversationId'] as String?;

      // If not found directly, try to parse as message and extract conversationId
      if ((conversationId == null || conversationId.isEmpty) &&
          payload.isNotEmpty) {
        try {
          final message = IsmChatMessageModel.fromMap(payload);
          conversationId = message.conversationId;
          IsmChatLog.info(
              'handleNotificationPayload: Extracted conversationId from message: $conversationId');
        } catch (e) {
          IsmChatLog.error(
              'handleNotificationPayload: Could not parse message from payload: $e');
        }
      }

      // If still not found, log error and return
      if (conversationId == null || conversationId.isEmpty) {
        IsmChatLog.error(
            'handleNotificationPayload: conversationId not found in notification data. Available keys: ${payload.keys.toList()}');
        // Try to create conversation from sender info if available
        if (payload.containsKey('senderInfo')) {
          try {
            final message = IsmChatMessageModel.fromMap(payload);
            final senderInfo = message.senderInfo;
            if (senderInfo != null && senderInfo.userId.isNotEmpty) {
              IsmChatLog.info(
                  'handleNotificationPayload: Creating conversation from sender info');
              await chatFromOutside(
                name: senderInfo.userName,
                userIdentifier: senderInfo.userIdentifier,
                userId: senderInfo.userId,
                online: senderInfo.online ?? false,
                profileImageUrl: senderInfo.userProfileImageUrl,
              );
              return;
            }
          } catch (e) {
            IsmChatLog.error(
                'handleNotificationPayload: Error creating conversation from sender info: $e');
          }
        }
        return;
      }

      // Ensure controllers are initialized
      if (!IsmChatUtility.conversationControllerRegistered) {
        IsmChatCommonBinding().dependencies();
        IsmChatConversationsBinding().dependencies();
        // Wait for controller to be ready
        while (!IsmChatUtility.conversationControllerRegistered) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      final conversationController = IsmChatUtility.conversationController;

      // Try to get conversation from local database first
      var conversation = conversationController.getConversation(conversationId);

      // If not found locally, try to get from database
      if (conversation == null) {
        conversation =
            await IsmChatConfig.dbWrapper?.getConversation(conversationId);
      }

      // If still not found, try to create from message data if available
      if (conversation == null && notificationData.containsKey('senderInfo')) {
        try {
          final message = IsmChatMessageModel.fromMap(notificationData);
          final senderInfo = message.senderInfo;
          if (senderInfo != null && senderInfo.userId.isNotEmpty) {
            await chatFromOutside(
              name: senderInfo.userName,
              userIdentifier: senderInfo.userIdentifier,
              userId: senderInfo.userId,
              online: senderInfo.online ?? false,
              profileImageUrl: senderInfo.userProfileImageUrl,
            );
            return;
          }
        } catch (e) {
          IsmChatLog.error('Error creating conversation from message: $e');
        }
      }

      // If conversation found, navigate to it
      if (conversation != null) {
        conversationController.updateLocalConversation(conversation);
        conversationController.currentConversation = conversation;

        // Call onChatTap callback if available
        IsmChatProperties.conversationProperties.onChatTap?.call(
          IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
          conversation,
        );

        // Navigate to chat page
        await conversationController.goToChatPage();
      } else {
        IsmChatLog.error(
            'handleNotificationPayload: Could not find or create conversation for id: $conversationId');
      }
    } catch (e, stackTrace) {
      IsmChatLog.error(
          'handleNotificationPayload error: $e\nStackTrace: $stackTrace');
    }
  }

  void subscribeTopics(List<String> topic) {
    if (Get.isRegistered<IsmChatMqttController>()) {
      Get.find<IsmChatMqttController>().subscribeTopics(topic);
    }
  }

  void unSubscribeTopics(List<String> topic) {
    if (Get.isRegistered<IsmChatMqttController>()) {
      Get.find<IsmChatMqttController>().unSubscribeTopics(topic);
    }
  }

  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      return await IsmChatUtility.conversationController
          .getBlockUser(isLoading: isLoading);
    } else {
      return [];
    }
  }

  Future<void> updateChatPage() async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      await controller.getConverstaionDetails();
      await controller.getMessagesFromAPI();
    }
  }

  List<IsmChatMessageModel> currentConversatonMessages() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      return controller.messages;
    }
    return [];
  }

  void currentConversationIndex({int index = 0}) {
    if (IsmChatUtility.conversationControllerRegistered) {
      IsmChatUtility.conversationController.currentConversationIndex = index;
    }
  }

  void shouldShowOtherOnChatPage() {
    if (IsmChatUtility.conversationControllerRegistered) {
      final controller = IsmChatUtility.conversationController;
      if (controller.currentConversationIndex != 0) {
        controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      }
    }
  }

  Future<void> searchConversation({required String searchValue}) async {
    if (IsmChatUtility.conversationControllerRegistered) {
      final controller = IsmChatUtility.conversationController;
      controller.debounce.run(() async {
        switch (searchValue.trim().isNotEmpty) {
          case true:
            await controller.getChatConversations(
              searchTag: searchValue,
            );
            break;
          default:
            await controller.getConversationsFromDB();
        }
      });
      controller.update();
    }
  }

  /// Updates the lastActiveTimestamp in user metadata.
  ///
  /// This method should be called periodically (e.g., every 30 seconds) from outside the SDK
  /// to update the user's last active timestamp. It updates the metadata's customMetaData
  /// with the current timestamp.
  ///
  /// - `isLoading`: Whether to show a loading indicator. Defaults to false.
  ///
  /// Example usage from home screen:
  /// ```dart
  /// Timer.periodic(Duration(seconds: 30), (timer) {
  ///   IsmChat.i.updateLastActiveTimestamp();
  /// });
  /// ```
  Future<void> updateLastActiveTimestamp({bool isLoading = false}) async {
    try {
      // Create repository instance directly
      final repository = IsmChatConversationsRepository();

      // Get current user data from database first
      UserDetails? currentUser;
      var userDataJson = await IsmChatConfig.dbWrapper?.userDetailsBox
          .get(IsmChatStrings.userData);

      if (userDataJson != null) {
        currentUser = UserDetails.fromJson(userDataJson);
      }

      // If user details not in database, fetch from API
      if (currentUser == null) {
        currentUser = await repository.getUserData(isLoading: false);
      }

      if (currentUser == null) {
        IsmChatLog.error(
            'Cannot update lastActiveTimestamp: User data not available');
        return;
      }

      // Get existing metadata or create new one
      final existingMetaData = currentUser.metaData ?? IsmChatMetaData();

      // Get existing customMetaData or create new map
      final existingCustomMetaData = Map<String, dynamic>.from(
        existingMetaData.customMetaData ?? {},
      );

      // Update lastActiveTimestamp with current timestamp in milliseconds
      existingCustomMetaData['lastActiveTimestamp'] =
          DateTime.now().millisecondsSinceEpoch;

      // Create updated metadata with new customMetaData
      final updatedMetaData = existingMetaData.copyWith(
        customMetaData: existingCustomMetaData,
      );

      // Update user data directly using repository
      await repository.updateUserData(
        metaData: updatedMetaData.toMap(),
        isloading: isLoading,
      );

      IsmChatLog.info(
          'Updated lastActiveTimestamp: ${existingCustomMetaData['lastActiveTimestamp']}');
    } catch (e, st) {
      IsmChatLog.error('Error updating lastActiveTimestamp: $e', st);
    }
  }

  Future<void> getMessagesFromDB({required String conversationId}) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.getMessagesFromDB(conversationId);
    }
  }

  Future<void> updateMessage({
    required IsmChatMessageModel message,
  }) async {
    final converations = await IsmChat.i.getAllConversationFromDB() ?? [];
    IsmChatConversationModel? conversation;
    for (var i in converations) {
      if (i.conversationId != message.conversationId) continue;
      conversation = i;
      break;
    }
    if (conversation != null) {
      final messages = conversation.messages ?? {};
      messages[message.key] = message;
      var dbConversations = await IsmChatConfig.dbWrapper
          ?.getConversation(message.conversationId ?? '');
      if (dbConversations != null) {
        dbConversations = dbConversations.copyWith(messages: messages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }
    }
    await getMessagesFromDB(conversationId: message.conversationId ?? '');
  }

  Future<void> updateMessageMetaData({
    required String messageId,
    required String conversationId,
    bool isOpponentMessage = false,
    IsmChatMetaData? metaData,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.updateMessage(
        messageId: messageId,
        conversationId: conversationId,
        isOpponentMessage: isOpponentMessage,
        metaData: metaData,
      );
    }
  }

  Future<void> deleteChatPageController() async {
    try {
      if (IsmChatUtility.chatPageControllerRegistered) {
        await Get.delete<IsmChatPageController>(
            tag: IsmChat.i.chatPageTag, force: true);
      }
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }

  Future<void> deleteConversationController() async {
    try {
      if (IsmChatUtility.conversationControllerRegistered) {
        await Get.delete<IsmChatConversationsController>(
            tag: IsmChat.i.chatListPageTag, force: true);
      }
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }
}
