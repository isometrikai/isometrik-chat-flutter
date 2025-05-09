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

  static final Rx<String?> _tag = Rx<String?>(null);
  String? get tag => _tag.value;
  set tag(String? value) => _tag.value = value;

  Future<void> initialize(
    IsmChatCommunicationConfig config, {
    bool useDatabase = true,
    NotificaitonCallback? showNotification,
    BuildContext? context,
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
  }) async {
    _config = config;
    IsmChatConfig.context = context;
    IsmChatConfig.dbName = databaseName;
    IsmChatConfig.useDatabase = !kIsWeb && useDatabase;
    IsmChatConfig.communicationConfig = config;
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
      config: _config,
      mqttProperties: mqttProperties ?? IsmMqttProperties(),
    );
  }

  Future<void> _initializeMqtt({
    IsmChatCommunicationConfig? config,
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
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.outSideView;
    }
  }

  void clostThirdColumn() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
    }
  }

  void showBlockUnBlockDialog() {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      final controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      if (!(controller.conversation?.isChattingAllowed == true)) {
        controller.showDialogCheckBlockUnBlock();
      }
    }
  }

  void changeCurrentConversation() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.currentConversation = null;
    }
  }

  void updateChatPageController() {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      final controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
      var conversationModel = controller.conversation!;
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
    if (Get.isRegistered<IsmChatConversationsController>()) {
      return await Get.find<IsmChatConversationsController>()
          .getNonBlockUserList();
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
      await Get.find<IsmChatConversationsController>().updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    required bool isLoading,
  }) async =>
      await Get.find<IsmChatConversationsController>()
          .updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  Future<void> getChatConversation() async {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
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
    required isLoading,
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

  Future<IsmChatConversationModel?> getConverstaionDetails({
    required bool isLoading,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      return await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
          .getConverstaionDetails(
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
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag).unblockUser(
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
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag).blockUser(
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
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      final controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
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
        Get.delete<IsmChatConversationsController>(force: true),
        Get.delete<IsmChatCommonController>(force: true),
        Get.delete<IsmChatMqttController>(force: true),
      ]);
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
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
    await Get.find<IsmChatConversationsController>().deleteChat(
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
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag).leaveGroup(
        adminCount: adminCount,
        isUserAdmin: isUserAdmin,
      );
    }
  }

  Future<void> clearAllMessages(
    String conversationId, {
    bool fromServer = true,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
          .clearAllMessages(
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
    void Function(BuildContext, IsmChatConversationModel)? onNavigateToChat,
    Duration duration = const Duration(milliseconds: 500),
    OutSideMessage? outSideMessage,
    String? storyMediaUrl,
    bool pushNotifications = true,
    bool isCreateGroupFromOutSide = false,
  }) async {
    assert(
      [name, userId].every((e) => e.isNotEmpty),
      '''Input Error: Please make sure that all required fields are filled out.
      Name, and userId cannot be empty.''',
    );

    IsmChatUtility.showLoader();

    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }

    await Future.delayed(duration);

    IsmChatUtility.closeLoader();

    var controller = Get.find<IsmChatConversationsController>();
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
        userIds: isCreateGroupFromOutSide
            ? [userId, IsmChatConfig.communicationConfig.userConfig.userId]
            : null,
        messagingDisabled: false,
        conversationImageUrl: profileImageUrl,
        isGroup: false,
        opponentDetails: userDetails,
        unreadMessagesCount: 0,
        lastMessageDetails: null,
        lastMessageSentAt: 0,
        membersCount: 1,
        metaData: metaData,
        outSideMessage: outSideMessage,
        isCreateGroupFromOutSide: isCreateGroupFromOutSide,
        pushNotifications: pushNotifications,
      );
    } else {
      conversation = controller.conversations
          .firstWhere((e) => e.conversationId == conversationId);
      conversation = conversation.copyWith(
        metaData: metaData,
        outSideMessage: outSideMessage,
        isCreateGroupFromOutSide: isCreateGroupFromOutSide,
        pushNotifications: pushNotifications,
      );
    }

    (onNavigateToChat ?? IsmChatProperties.conversationProperties.onChatTap)
        ?.call(Get.context!, conversation);
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

    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }

    var controller = Get.find<IsmChatConversationsController>();

    (onNavigateToChat ?? IsmChatProperties.conversationProperties.onChatTap)
        ?.call(Get.context!, ismChatConversation);
    controller.updateLocalConversation(ismChatConversation);
    await controller.goToChatPage();
  }

  Future<void> createGroupFromOutside({
    required String conversationImageUrl,
    required String conversationTitle,
    required List<String> userIds,
    IsmChatConversationType conversationType = IsmChatConversationType.private,
    IsmChatMetaData? metaData,
    void Function(BuildContext, IsmChatConversationModel)? onNavigateToChat,
    Duration duration = const Duration(milliseconds: 500),
    bool pushNotifications = true,
  }) async {
    assert(
      conversationTitle.isNotEmpty && userIds.isNotEmpty,
      '''Input Error: Please make sure that all required fields are filled out.
      conversationTitle, and userIds cannot be empty.''',
    );

    IsmChatUtility.showLoader();

    await Future.delayed(duration);

    IsmChatUtility.closeLoader();

    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    var controller = Get.find<IsmChatConversationsController>();

    var conversation = IsmChatConversationModel(
        messagingDisabled: false,
        userIds: userIds,
        conversationTitle: conversationTitle,
        conversationImageUrl: conversationImageUrl,
        isGroup: true,
        opponentDetails: controller.userDetails,
        unreadMessagesCount: 0,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        createdByUserName:
            IsmChatConfig.communicationConfig.userConfig.userName ??
                controller.userDetails?.userName ??
                '',
        lastMessageDetails: LastMessageDetails(
          sentByMe: true,
          showInConversation: true,
          sentAt: DateTime.now().millisecondsSinceEpoch,
          senderName: '',
          messageType: 0,
          messageId: '',
          conversationId: '',
          body: '',
        ),
        lastMessageSentAt: 0,
        conversationType: conversationType,
        membersCount: userIds.length,
        pushNotifications: pushNotifications);

    (onNavigateToChat ?? IsmChatProperties.conversationProperties.onChatTap)
        ?.call(Get.context!, conversation);
    controller.updateLocalConversation(conversation);
    await controller.goToChatPage();
  }

  Future<IsmChatConversationModel?> getConversation({
    required String conversationId,
  }) async {
    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
      await Future.delayed(const Duration(seconds: 2));
    }
    var controller = Get.find<IsmChatConversationsController>();
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
    if (Get.isRegistered<IsmChatConversationsController>()) {
      return await Get.find<IsmChatConversationsController>()
          .getBlockUser(isLoading: isLoading);
    } else {
      return [];
    }
  }

  Future<void> updateChatPage() async {
    if (Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();
      await controller.getConverstaionDetails();
      await controller.getMessagesFromAPI();
    }
  }

  List<IsmChatMessageModel> currentConversatonMessages() {
    if (Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();
      return controller.messages;
    }
    return [];
  }

  void currentConversationIndex({int index = 0}) {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      Get.find<IsmChatConversationsController>().currentConversationIndex =
          index;
    }
  }

  void shouldShowOtherOnChatPage() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      if (controller.currentConversationIndex != 0) {
        controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      }
    }
  }

  Future<void> getMessagesFromDB({required String conversationId}) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().getMessagesFromDB(conversationId);
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
      messages[message.messageId ?? ''] = message;
      var dbConversations = await IsmChatConfig.dbWrapper
          ?.getConversation(conversationId: message.conversationId);
      if (dbConversations != null) {
        dbConversations = dbConversations.copyWith(messages: messages);
        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: conversation);
      }
    }
    await getMessagesFromDB(conversationId: message.conversationId ?? '');
  }

  Future<void> searchConversation({required String searchValue}) async {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
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
}
