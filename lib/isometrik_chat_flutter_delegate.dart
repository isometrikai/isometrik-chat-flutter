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
      final controller = IsmChatUtility.conversationController;
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.outSideView;
    }
  }

  void clostThirdColumn() {
    if (IsmChatUtility.conversationControllerRegistered) {
      final controller = IsmChatUtility.conversationController;
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
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
      final controller = IsmChatUtility.conversationController;
      controller.currentConversation = null;
    }
  }

  void updateChatPageController() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      var conversationModel = controller.conversation;
      controller.conversation = null;
      controller.conversation = conversationModel;
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
