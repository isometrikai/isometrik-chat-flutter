part of 'isometrik_chat_flutter.dart';

class IsmChatDelegate {
  const IsmChatDelegate();

  static IsmChatCommunicationConfig? _config;

  IsmChatCommunicationConfig? get config => _config;

  static IsmChatConfig? _ismChatConfig;

  IsmChatConfig? get ismChatConfig => _ismChatConfig;

  static final RxString _unReadConversationMessages = ''.obs;
  String get unReadConversationMessages => _unReadConversationMessages.value;
  set unReadConversationMessages(String value) =>
      _unReadConversationMessages.value = value;

  static final RxBool _isMqttConnected = false.obs;
  bool get isMqttConnected => _isMqttConnected.value;
  set isMqttConnected(bool value) => _isMqttConnected.value = value;

  static final Rx<String?> _tag = Rx<String?>(null);
  String? get tag => _tag.value;
  set tag(String? value) => _tag.value = value;

  Future<void> initialize(
    IsmChatCommunicationConfig config, {
    bool useDatabase = true,
    NotificaitonCallback? showNotification,
    BuildContext? context,
    String databaseName = IsmChatStrings.dbname,
    bool shouldSetupMqtt = false,
    List<String>? topics,
    List<String>? topicChannels,
  }) async {
    _config = config;
    IsmChatConfig.context = context;
    IsmChatConfig.dbName = databaseName;
    IsmChatConfig.useDatabase = !kIsWeb && useDatabase;
    IsmChatConfig.communicationConfig = config;
    IsmChatConfig.shouldSetupMqtt = shouldSetupMqtt;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.dbWrapper = await IsmChatDBWrapper.create();
    await _initializeMqtt(
      config: _config,
      shouldSetupMqtt: shouldSetupMqtt,
      topics: topics,
      topicChannels: topicChannels,
    );
  }

  Future<void> _initializeMqtt({
    IsmChatCommunicationConfig? config,
    required bool shouldSetupMqtt,
    List<String>? topics,
    List<String>? topicChannels,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    if (!shouldSetupMqtt) {
      await Get.find<IsmChatMqttController>().setup(
        config: config,
        topics: topics,
        topicChannels: topicChannels,
      );
    }
  }

  Future<void> listenMqttEvent({
    required EventModel event,
    NotificaitonCallback? showNotification,
  }) async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      IsmChatConfig.showNotification = showNotification;
      await Get.find<IsmChatMqttController>().onMqttEvent(
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
    var mqttController = Get.find<IsmChatMqttController>();
    mqttController.eventListeners.remove(listener);
    await mqttController.eventStreamController.stream.drain();
    for (var listener in mqttController.eventListeners) {
      mqttController.eventStreamController.stream.listen(listener);
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

  Future<IsmChatConversationModel?> getConverstaionDetails({
    required String conversationId,
    bool? includeMembers,
    required bool isLoading,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      return await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
          .getConverstaionDetails(
              conversationId: conversationId,
              includeMembers: includeMembers,
              isLoading: isLoading);
    }
    return null;
  }

  Future<void> unblockUser({
    required String opponentId,
    required bool includeMembers,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag).unblockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: true,
      );
    }
  }

  Future<void> blockUser({
    required String opponentId,
    required bool includeMembers,
    required bool isLoading,
    required bool fromUser,
  }) async {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag).blockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
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
        conversationId: controller.conversation?.conversationId ?? '',
        lastMessageTimestamp: controller.messages.isNotEmpty
            ? controller.messages.last.sentAt
            : 0,
      );
    }
  }

  Future<void> logout() async {
    await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
    await Future.wait([
      Get.delete<IsmChatConversationsController>(force: true),
      Get.delete<IsmChatCommonController>(force: true),
      Get.delete<IsmChatMqttController>(force: true),
    ]);
  }

  Future<void> clearChatLocalDb() async {
    await IsmChatConfig.dbWrapper?.clearChatLocalDb();
  }

  Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
  }) async {
    await Get.find<IsmChatConversationsController>().deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
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

    await Future.delayed(duration);

    IsmChatUtility.closeLoader();

    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    var controller = Get.find<IsmChatConversationsController>();
    var conversationId = controller.getConversationId(userId);
    IsmChatConversationModel? conversation;
    if (conversationId.isEmpty) {
      var userDetails = UserDetails(
        userProfileImageUrl: profileImageUrl,
        userName: name,
        userIdentifier: userIdentifier,
        userId: userId,
        online: false,
        lastSeen: 0,
        metaData: IsmChatMetaData(
          profilePic: profileImageUrl,
          firstName: name.split(' ').first,
          lastName: name.split(' ').last,
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
}
