import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/res/properties/chat_properties.dart';

class IsmChatApp extends StatelessWidget {
  IsmChatApp({
    super.key,
    this.context,
    this.communicationConfig,
    this.chatPageProperties,
    this.conversationProperties,
    this.chatTheme,
    this.chatDarkTheme,
    this.loadingDialog,
    this.databaseName,
    this.useDataBase = true,
    this.noChatSelectedPlaceholder,
    this.sideWidgetWidth,
    this.isShowMqttConnectErrorDailog = false,
    this.fontFamily,
    this.conversationParser,
    this.conversationModifier,
  }) {
    assert(IsmChatConfig.isInitialized,
        'ChatHiveBox is not initialized\nYou are getting this error because the Database class is not initialized, to initialize ChatHiveBox class call IsometrikChat.initialize() before your runApp()');
    assert(IsmChatConfig.configInitilized || communicationConfig != null,
        '''communicationConfig of type IsmChatCommunicationConfig must be initialized
    1. Either initialize using IsmChatApp.initializeMqtt() by passing  communicationConfig.
    2. Or Pass  communicationConfig in IsmChatApp
    ''');

    // assert(
    //   (showAppBar && onSignOut != null) || (!showAppBar),
    //   'If showAppBar is set to true then a non-null callback must be passed to onSignOut parameter',
    // );

    IsmChatConfig.dbName = databaseName ?? IsmChatStrings.dbname;
    IsmChatConfig.fontFamily = fontFamily;
    IsmChatConfig.conversationParser = conversationParser;
    IsmChatProperties.loadingDialog = loadingDialog;

    IsmChatProperties.sideWidgetWidth = sideWidgetWidth;
    IsmChatProperties.noChatSelectedPlaceholder = noChatSelectedPlaceholder;
    if (communicationConfig != null) {
      IsmChatConfig.communicationConfig = communicationConfig!;
      IsmChatConfig.configInitilized = true;
    }
    IsmChatConfig.useDatabase = useDataBase;
    IsmChatConfig.context = context;
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();
    IsmChatConfig.isShowMqttConnectErrorDailog = isShowMqttConnectErrorDailog;
    IsmChatConfig.chatDarkTheme =
        chatDarkTheme ?? chatTheme ?? IsmChatThemeData.dark();

    if (chatPageProperties != null) {
      IsmChatProperties.chatPageProperties = chatPageProperties!;
    }
    if (conversationProperties != null) {
      IsmChatProperties.conversationProperties = conversationProperties!;
    }
    IsmChatProperties.conversationModifier = conversationModifier;
  }

  final BuildContext? context;

  final bool isShowMqttConnectErrorDailog;

  /// Required field
  ///
  /// This class takes sevaral parameters which are necessary to establish connection between `host` & `application`
  ///
  /// For details see:- [IsmChatCommunicationConfig]
  final IsmChatCommunicationConfig? communicationConfig;

  final IsmChatThemeData? chatTheme;

  final IsmChatThemeData? chatDarkTheme;

  /// Opitonal field
  ///
  /// loadingDialog takes a widget which override the classic [CircularProgressIndicator], and will be shown incase of api call or loading something
  final Widget? loadingDialog;

  /// databaseName is to be provided if you want to specify some name for the local database file.
  ///
  /// If not provided `isometrik_chat_flutter` will be used by default
  final String? databaseName;

  final bool useDataBase;

  final IsmChatConversationProperties? conversationProperties;
  final IsmChatPageProperties? chatPageProperties;

  ///  It is showing you have no tap any converstaion
  final Widget? noChatSelectedPlaceholder;

  final double? sideWidgetWidth;

  final String? fontFamily;

  final IsmChatConversationModifier? conversationModifier;

  /// This callback is to be used if you want to make certain changes while conversation data is being parsed from the API
  final ConversationParser? conversationParser;

  /// Call this function for show outside widget
  ///
  ///  `You must use in web flow`
  ///
  ///  `You must call  outSideView callback widget in IsmChatConversationProperties`
  ///
  /// Don't use in mobile flow because this function work on web flow
  static void showThirdColumn() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.outSideView;
    }
  }

  /// Call this function for close outside widget
  ///
  ///  `You must use in web flow `
  ///
  ///  `You must call  outSideView callback widget in IsmChatConversationProperties`
  ///
  /// Don't use in mobile flow because this function work on web flow
  static void clostThirdColumn() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
    }
  }

  /// Call this funcation for showing Block un Block Dialog
  static void showBlockUnBlockDialog() {
    if (Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();
      if (!(controller.conversation?.isChattingAllowed == true)) {
        controller.showDialogCheckBlockUnBlock();
      }
    }
  }

  /// Call this function for assign null on current conversation
  static void changeCurrentConversation() {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      final controller = Get.find<IsmChatConversationsController>();
      controller.currentConversation = null;
    }
  }

  /// Call this function for Get all Conversation List
  static void updateChatPageController() {
    if (Get.isRegistered<IsmChatPageController>()) {
      final controller = Get.find<IsmChatPageController>();
      var conversationModel = controller.conversation!;
      controller.conversation = null;
      controller.conversation = conversationModel;
    }
  }

  /// Call this function for Get all Conversation List from DB
  static Future<List<IsmChatConversationModel>?>
      getAllConversationFromDB() async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      return await Get.find<IsmChatMqttController>().getAllConversationFromDB();
    }
    return null;
  }

  /// Call this function for t all user List
  static Future<List<SelectedForwardUser>?> getNonBlockUserList() async {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      return await Get.find<IsmChatConversationsController>()
          .getNonBlockUserList();
    }
    return null;
  }

  /// Call this funcation for get all conversation list with conversation predicate
  static Future<List<IsmChatConversationModel>> get userConversations =>
      getAllConversationFromDB().then((conversations) => (conversations ?? [])
          .where(
              IsmChatProperties.conversationProperties.conversationPredicate ??
                  (_) => true)
          .toList());

  /// Call this funcation for get all conversation unreadCount with predicate
  static Future<int> get unreadCount =>
      userConversations.then((value) => value.unreadCount);

  /// Call this function for update conversation Details in meta data
  static Future<void> updateConversation(
          {required String conversationId,
          required IsmChatMetaData metaData}) async =>
      await Get.find<IsmChatConversationsController>().updateConversation(
        conversationId: conversationId,
        metaData: metaData,
      );

  /// Call this function for update conversation setting in meta data
  static Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async =>
      await Get.find<IsmChatConversationsController>()
          .updateConversationSetting(
        conversationId: conversationId,
        events: events,
        isLoading: isLoading,
      );

  /// Call this function for Get Conversation List with store local db When on click
  static Future<void> getChatConversation() async {
    if (Get.isRegistered<IsmChatConversationsController>()) {
      await Get.find<IsmChatConversationsController>().getChatConversations();
    }
  }

  /// Call this function for Get  conversations count
  /// You can call this funcation after MQTT controller intilized
  static Future<int> getChatConversationsCount({
    bool isLoading = false,
  }) async {
    if (!Get.isRegistered<IsmChatMqttController>()) return 0;
    final count = await Get.find<IsmChatMqttController>()
        .getChatConversationsCount(isLoading: isLoading);
    return int.tryParse(count) ?? 0;
  }

  /// Call this function for Get  conversations message count
  /// You can call this funcation after MQTT controller intilized
  static Future<int> getChatConversationsMessageCount({
    bool isLoading = false,
    required String converationId,
    required List<String> senderIds,
    bool senderIdsExclusive = false,
    int lastMessageTimestamp = 0,
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

  static Future<IsmChatConversationModel?> getConverstaionDetails({
    required String conversationId,
    bool? includeMembers,
    // String? ids,
    // int? membersSkip,
    // int? membersLimit,
    bool? isLoading,
  }) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      return await Get.find<IsmChatPageController>().getConverstaionDetails(
        conversationId: conversationId,
        includeMembers: includeMembers,
      );
    }
    return null;
  }

  /// Call this function for unblock user form out side
  static Future<void> unblockUser({
    required String opponentId,
    bool includeMembers = false,
    bool isLoading = false,
    bool fromUser = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().unblockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: true,
      );
    }
  }

  /// Call this function for block user form out side
  static Future<void> blockUser({
    required String opponentId,
    bool includeMembers = false,
    bool isLoading = false,
    bool fromUser = false,
  }) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().blockUser(
        opponentId: opponentId,
        includeMembers: includeMembers,
        isLoading: isLoading,
        fromUser: fromUser,
        userBlockOrNot: false,
      );
    }
  }

  /// Call this funcation for get messages for perticular conversation with api
  static Future<List<IsmChatMessageModel>?> getMessagesFromApi({
    required String conversationId,
    required int lastMessageTimestamp,
    int limit = 20,
    int skip = 0,
    String? searchText,
    bool isLoading = false,
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

  /// Call this function on SignOut to delete the data stored locally in the Local Database
  static Future<void> logout() async {
    await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
    await Future.wait([
      Get.delete<IsmChatConversationsController>(force: true),
      Get.delete<IsmChatCommonController>(force: true),
      Get.delete<IsmChatMqttController>(force: true),
    ]);
  }

  /// Call this function for clear the data stored locally in the Local Database
  static Future<void> clearChatLocalDb() async {
    await IsmChatConfig.dbWrapper?.clearChatLocalDb();
  }

  /// Call this function on to delete chat with and local the data stored locally in the Local Database
  ///
  /// [deleteFromServer] - is a `boolean` parameter which signifies whether or not to delete the chat from server
  ///
  /// The chat will be deleted locally in all cases
  static Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
  }) async {
    assert(
      conversationId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      conversationId cannot be empty.''',
    );
    await Get.find<IsmChatConversationsController>().deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
    );
  }

  /// Call this function on to delete chat the data stored locally in the Local Database
  ///
  /// The chat will be deleted locally in all cases
  static Future<bool> deleteChatFormDB(String isometrickChatId) async {
    assert(
      isometrickChatId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      isometrickChatId cannot be empty.''',
    );
    return await Get.find<IsmChatMqttController>().deleteChatFormDB(
      isometrickChatId,
    );
  }

  /// Call this function on to Exit Group the data stored locally in the Local Database and server
  ///
  /// The chat will be deleted locally in all cases
  static Future<void> exitGroup(
      {required int adminCount, required bool isUserAdmin}) async {
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().leaveGroup(
        adminCount: adminCount,
        isUserAdmin: isUserAdmin,
      );
    }
  }

  /// Call this function on to clearMessages the data stored locally in the Local Database and server
  ///
  /// The chat will be deleted locally in all cases
  static Future<void> clearAllMessages(
    String conversationId, {
    bool fromServer = true,
  }) async {
    assert(
      conversationId.isNotEmpty,
      '''Input Error: Please make sure that required fields are filled out.
      conversationId cannot be empty.''',
    );
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().clearAllMessages(
        conversationId,
        fromServer: fromServer,
      );
    }
  }

  /// Call this funcation for the initialize mqtt
  static void initializeMqtt(
    IsmChatCommunicationConfig communicationConfig, {
    IsmChatThemeData? chatTheme,
    IsmChatThemeData? chatDarkTheme,
    String? notificationIconPath,
    BuildContext? context,
    void Function(
      String,
      String,
      String,
    )? showNotification,
    bool isShowMqttConnectErrorDailog = false,
    bool isMqttInitializedFromOutSide = false,
  }) {
    IsmChatConfig.chatLightTheme = chatTheme ?? IsmChatThemeData.light();
    IsmChatConfig.chatDarkTheme =
        chatDarkTheme ?? chatTheme ?? IsmChatThemeData.dark();
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.isMqttInitializedFromOutSide = isMqttInitializedFromOutSide;
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatLog.info(
          'IsmMQttController initiliazing fron {initializeMqtt} function');
      IsmChatMqttBinding().dependencies();
      IsmChatLog.info(
          'IsmMQttController initiliazing success fron {initializeMqtt} function ');
    }
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.notificationIconPath = notificationIconPath;
    IsmChatConfig.context = context;
    IsmChatConfig.isShowMqttConnectErrorDailog = isShowMqttConnectErrorDailog;
  }

  /// Call this funcation for the initialize mqtt
  static void initializeMqttFromOutSide(
    IsmChatCommunicationConfig communicationConfig, {
    String? notificationIconPath,
    void Function(
      String,
      String,
      String,
    )? showNotification,
  }) {
    IsmChatConfig.communicationConfig = communicationConfig;
    IsmChatConfig.configInitilized = true;
    IsmChatConfig.isMqttInitializedFromOutSide = true;
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatLog.info(
          'IsmMQttController initiliazing fron {initializeMqtt} function');
      IsmChatMqttBinding().dependencies();
      IsmChatLog.info(
          'IsmMQttController initiliazing success fron {initializeMqtt} function ');
    }
    IsmChatConfig.showNotification = showNotification;
    IsmChatConfig.notificationIconPath = notificationIconPath;
  }

  /// Call this function for Listen MQTT Evnet from OutSide
  /// [IsmChatConfig.configInitilized] this variable must be true
  /// You can call this funcation after MQTT controller intilized
  static Future<void> listenMqttEventFromOutSide({
    required Map<String, dynamic> payload,
    void Function(
      String,
      String,
      String,
    )? showNotification,
  }) async {
    assert(IsmChatConfig.configInitilized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChatApp.initializeMqtt() or add listener after IsmChatApp is called''');
    if (Get.isRegistered<IsmChatMqttController>()) {
      IsmChatConfig.showNotification = showNotification;
      await Get.find<IsmChatMqttController>().onMqttEvent(
        payload: payload,
      );
    }
  }

  /// Call this funcation on to listener for mqtt events
  ///
  /// [IsmChatConfig.configInitilized] this variable must be true
  ///
  /// You can call this funcation after initialize mqtt [initializeMqtt] funcation
  static StreamSubscription<Map<String, dynamic>> addListener(
      Function(Map<String, dynamic>) listener) {
    assert(IsmChatConfig.configInitilized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChatApp.initializeMqtt() or add listener after IsmChatApp is called''');
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmChatMqttController>();
    mqttController.actionListeners.add(listener);
    return mqttController.actionStreamController.stream.listen(listener);
  }

  /// Call this funcation on to remove listener for mqtt events
  ///
  /// [IsmChatConfig.configInitilized] this variable must be true
  ///
  /// You can call this funcation after initialize mqtt [initializeMqtt] funcation
  static Future<void> removeListener(
      Function(Map<String, dynamic>) listener) async {
    assert(IsmChatConfig.configInitilized,
        '''MQTT Controller must be initialized before adding listener.
    Either call IsmChatApp.initializeMqtt() or add listener after IsmChatApp is called''');
    var mqttController = Get.find<IsmChatMqttController>();
    mqttController.actionListeners.remove(listener);
    await mqttController.actionStreamController.stream.drain();
    for (var listener in mqttController.actionListeners) {
      mqttController.actionStreamController.stream.listen(listener);
    }
  }

  /// This function can be used to directly go to chatting page and start chatting from anywhere in the app
  ///
  /// Follow the following steps :-
  /// 1. Navigate to the Screen/View where `IsmChatApp` is used as the root widget for `Chat` module
  /// 2. Call this function by providing all the required data (must add `await` keyword as this is a Future)
  ///
  /// * `userId` - UserID of the user coming from backend APIs (`Required`)
  /// * `name` - The name to be displayed (`Required`)
  /// * `userIdentifier` - UserIdentifier of the user (`Required`)
  /// * `profileImageUrl` - The image url of the user (`Optional`)
  /// * `duration` - The duration for which the loading dialog will be displayed, this is to make sure all the controllers and variables are initialized before executing any statement and/or calling the APIs for data. (default `Duration(milliseconds: 500)`)
  /// * `onNavigateToChat` - This function will be executed to navigate to the specific chat screen of the selected user. If not provided, the `onChatTap` callback will be used which is passed to `IsmChatApp`.
  static Future<void> chatFromOutside({
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
    controller.navigateToMessages(conversation);
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

  /// This function can be used to directly go to chatting page and start chatting from anywhere in the app
  ///
  /// Follow the following steps :-
  /// 1. Navigate to the Screen/View where `IsmChatApp` is used as the root widget for `Chat` module
  /// 2. Call this function by providing all the required data (must add `await` keyword as this is a Future)
  ///
  /// * `ismChatConversation` - Conversation of the user coming from backend APIs (`Required`)
  /// * `duration` - The duration for which the loading dialog will be displayed, this is to make sure all the controllers and variables are initialized before executing any statement and/or calling the APIs for data. (default `Duration(milliseconds: 500)`)
  /// * `onNavigateToChat` - This function will be executed to navigate to the specific chat screen of the selected user. If not provided, the `onChatTap` callback will be used which is passed to `IsmChatApp`.
  static Future<void> chatFromOutsideWithConversation({
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
    controller.navigateToMessages(ismChatConversation);
    await controller.goToChatPage();
  }

  /// This function can be used to directly go to chatting page and start group chat from anywhere in the app
  ///
  /// Follow the following steps :-
  /// 1. Navigate to the Screen/View where `IsmChatApp` is used as the root widget for `Chat` module
  /// 2. Call this function by providing all the required data (must add `await` keyword as this is a Future)
  ///
  /// * `userIds` - UserIDs of the user coming from backend APIs (`Required`)
  /// * `conversationTitle` - The conversationTitle to be displayed (`Required`)
  /// * `email` - Email of the user (`Required`)
  /// * `profileImageUrl` - The image url of the user (`Optional`)
  /// * `duration` - The duration for which the loading dialog will be displayed, this is to make sure all the controllers and variables are initialized before executing any statement and/or calling the APIs for data. (default `Duration(milliseconds: 500)`)
  /// * `onNavigateToChat` - This function will be executed to navigate to the specific chat screen of the selected user. If not provided, the `onChatTap` callback will be used which is passed to `IsmChatApp`.
  static Future<void> createGroupFromOutside({
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
    controller.navigateToMessages(conversation);
    await controller.goToChatPage();
  }

  /// This variable use for store conversation unread count value
  /// This variable update when call api UnreadConverstaion on every action in chat
  static final RxString _unReadConversationMessages = ''.obs;
  static String get unReadConversationMessages =>
      _unReadConversationMessages.value;
  static set unReadConversationMessages(String value) =>
      _unReadConversationMessages.value = value;

  /// This variable use for mqtt connected or not
  /// This variable update when mqtt connection on app initlized
  static final RxBool _isMqttConnected = false.obs;
  static bool get isMqttConnected => _isMqttConnected.value;
  static set isMqttConnected(bool value) => _isMqttConnected.value = value;

  @override
  Widget build(BuildContext context) => const IsmChatConversations();
}
