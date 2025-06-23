import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmChatConversationsController extends GetxController {
  IsmChatConversationsController(this._viewModel);
  final IsmChatConversationsViewModel _viewModel;

  /// This variable use for type group name of group chat
  TextEditingController addGrouNameController = TextEditingController();

  /// This variable use for type user name for searching feature
  TextEditingController userSearchNameController = TextEditingController();

  /// This variable use for type global for searching feature
  TextEditingController globalSearchController = TextEditingController();

  /// This variable use for store login user name
  TextEditingController userNameController = TextEditingController();

  /// This variable use for store login user email
  TextEditingController userEmailController = TextEditingController();

  /// This variable use for store  for searching feature
  TextEditingController searchConversationTEC = TextEditingController();

  /// This variable use for get all method and varibles from IsmChatCommonController
  IsmChatCommonController get commonController =>
      Get.find<IsmChatCommonController>();

  /// This variable use for store conversation details
  final _conversations = <IsmChatConversationModel>[].obs;
  List<IsmChatConversationModel> get conversations => _conversations;
  set conversations(List<IsmChatConversationModel> value) =>
      _conversations.value = value;

  /// This variable use for store conversation details
  final _searchConversationList = <IsmChatConversationModel>[].obs;
  List<IsmChatConversationModel> get searchConversationList =>
      _searchConversationList;
  set searchConversationList(List<IsmChatConversationModel> value) =>
      _searchConversationList.value = value;

  /// This variable use for store public and open conversation details
  final _publicAndOpenConversation = <IsmChatConversationModel>[].obs;
  List<IsmChatConversationModel> get publicAndOpenConversation =>
      _publicAndOpenConversation;
  set publicAndOpenConversation(List<IsmChatConversationModel> value) =>
      _publicAndOpenConversation.value = value;

  /// This variable use for store suggestions list on chat page view
  final _suggestions = <IsmChatConversationModel>[].obs;
  List<IsmChatConversationModel> get suggestions => _suggestions;
  set suggestions(List<IsmChatConversationModel> value) =>
      _suggestions.value = value;

  /// This variable use for store true or false
  ///
  /// Show loader on chat list view
  final RxBool _isConversationsLoading = true.obs;
  bool get isConversationsLoading => _isConversationsLoading.value;
  set isConversationsLoading(bool value) =>
      _isConversationsLoading.value = value;

  /// This variabel use for store user details which is login or signup
  final Rx<UserDetails?> _userDetails = Rx<UserDetails?>(null);
  UserDetails? get userDetails => _userDetails.value;
  set userDetails(UserDetails? value) => _userDetails.value = value;

  /// This variabel use for store sended contact details
  final Rx<UserDetails?> _contactDetails = Rx<UserDetails?>(null);
  UserDetails? get contactDetails => _contactDetails.value;
  set contactDetails(UserDetails? value) => _contactDetails.value = value;

  /// This variabel use for store userConversationId
  final Rx<String?> _userConversationId = ''.obs;
  String? get userConversationId => _userConversationId.value;
  set userConversationId(String? value) => _userConversationId.value = value;

  /// This variabel use for store currentConversation
  final Rx<IsmChatConversationModel?> _currentConversation =
      Rx<IsmChatConversationModel?>(null);
  IsmChatConversationModel? get currentConversation =>
      _currentConversation.value;
  set currentConversation(IsmChatConversationModel? value) {
    _currentConversation.value = value;
  }

  /// This variabel use for store refreshcontroller on chat list
  final refreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );

  /// This variabel use for store refreshcontroller on chat empty list
  final refreshControllerOnEmptyList = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );

  /// This variabel use for store refreshcontroller on search conversation list
  final searchConversationrefreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );

  /// This variabel user for store user list data
  ///
  /// This list use for show new user and forward user
  final _forwardedList = <SelectedMembers>[].obs;
  List<SelectedMembers> get forwardedList => _forwardedList;
  set forwardedList(List<SelectedMembers> value) {
    _forwardedList.value = value;
  }

  /// This variable use for store selected user list
  ///
  /// When user selcte on new user  and forward user
  final _selectedUserList = <UserDetails>[].obs;
  List<UserDetails> get selectedUserList => _selectedUserList;
  set selectedUserList(List<UserDetails> value) {
    _selectedUserList.value = value;
  }

  /// This variabel use for store user list data with duplicate
  ///
  /// This list use for only searching time any user
  final _forwardedListDuplicat = <SelectedMembers>[].obs;
  List<SelectedMembers> get forwardedListDuplicat => _forwardedListDuplicat;
  set forwardedListDuplicat(List<SelectedMembers> value) {
    _forwardedListDuplicat.value = value;
  }

  /// This variable use for store block user list
  final _blockUsers = <UserDetails>[].obs;
  List<UserDetails> get blockUsers => _blockUsers;
  set blockUsers(List<UserDetails> value) => _blockUsers.value = value;

  /// This variable use for  store profile image url
  ///
  /// When user add profile pic or update profile pic
  final RxString _profileImage = ''.obs;
  String get profileImage => _profileImage.value;
  set profileImage(String value) {
    _profileImage.value = value;
  }

  /// This variabel use for store bool value with api calling and response
  ///
  /// If calling api `true` after response `false`
  final RxBool _isLoadResponse = false.obs;
  bool get isLoadResponse => _isLoadResponse.value;
  set isLoadResponse(bool value) => _isLoadResponse.value = value;

  /// This variable use for store bool value
  ///
  /// When click search icon set `true` then show search textfiled
  final RxBool _showSearchField = false.obs;
  bool get showSearchField => _showSearchField.value;
  set showSearchField(bool value) => _showSearchField.value = value;

  /// This variable use for  store current conversationId
  ///
  /// When you tap any convesation on chat list that time store conversationId that chat converstaion
  final RxString _currentConversationId = ''.obs;
  String get currentConversationId => _currentConversationId.value;
  set currentConversationId(String value) =>
      _currentConversationId.value = value;

  /// This variable use for store render screen two column widget in web and tab view
  final Rx<IsRenderConversationScreen> _isRenderScreen =
      IsRenderConversationScreen.none.obs;
  IsRenderConversationScreen get isRenderScreen => _isRenderScreen.value;
  set isRenderScreen(IsRenderConversationScreen value) =>
      _isRenderScreen.value = value;

  /// This variable use for store render screen second column widget
  ///
  /// When you have tap on chat list then render that chat page view
  final Rx<IsRenderChatPageScreen> _isRenderChatPageaScreen =
      IsRenderChatPageScreen.none.obs;
  IsRenderChatPageScreen get isRenderChatPageaScreen =>
      _isRenderChatPageaScreen.value;
  set isRenderChatPageaScreen(IsRenderChatPageScreen value) =>
      _isRenderChatPageaScreen.value = value;

  /// This variabel use for store media list
  ///
  /// In this list you can get image, audio and video messgae of current convesation chat page
  final RxList<IsmChatMessageModel> _mediaList = <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get mediaList => _mediaList;
  set mediaList(List<IsmChatMessageModel> value) => _mediaList.value = value;

  /// This variabel use for store links list
  ///
  /// In this list you can get any type of links messgae of current convesation chat page
  final RxList<IsmChatMessageModel> _mediaListLinks =
      <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get mediaListLinks => _mediaListLinks;
  set mediaListLinks(List<IsmChatMessageModel> value) =>
      _mediaListLinks.value = value;

  /// This variabel use for store documents list
  ///
  /// In this list you can documents messgae of current convesation chat page
  final RxList<IsmChatMessageModel> _mediaListDocs =
      <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get mediaListDocs => _mediaListDocs;
  set mediaListDocs(List<IsmChatMessageModel> value) =>
      _mediaListDocs.value = value;

  /// This variabel use for store bool value
  ///
  /// Our value does not change until the API response comes the set `true`.
  final RxBool _callApiOrNot = true.obs;
  bool get callApiOrNot => _callApiOrNot.value;
  set callApiOrNot(bool value) => _callApiOrNot.value = value;

  /// This variabel use for store show message info
  ///
  /// When we use `web` and `tablet` then acesses this variable show message deliverd or read
  IsmChatMessageModel? message;

  /// This variabel use for store 15 types of emoji
  ///
  /// Emojis comes from package
  ///
  /// When we intnilized this controller
  List<Emoji> reactions = [];

  /// This variabel use for debounceing calling api
  final debounce = IsmChatDebounce();

  /// This variabel use for store bacground image
  ///
  /// When you will be change background image with perticular chat then this list you have use list
  ///
  /// All image comming from project level assets
  List<BackGroundAsset> backgroundImage = [];

  /// This variabel use for store bacground color
  ///
  /// When you will be change background color with perticular chat then this list you have use list
  ///
  /// All image comming from project level assets
  List<BackGroundAsset> backgroundColor = [];

  /// This variabel use for store context of chat page view
  ///
  /// This context use when come mqtt event from other side then show notificaiton
  BuildContext? context;

  /// This variabel use for store context of chat list view
  ///
  /// This context use when tap poup menu of chat list then open drawer of chat list app bar
  BuildContext? isDrawerContext;

  /// This variabel use for store tab controller
  ///
  /// This variable use if `IsmChatProperties.conversationProperties.conversationPosition == IsmChatConversationPosition.tabBar`, then you can handle it
  TabController? tabController;

  /// This variabel use for conversation scrolling controller
  ///
  /// When you have scroll or you want get pagination then you have use it.
  var conversationScrollController = ScrollController();

  /// This variabel use for search conversation scrolling controller
  ///
  /// When you have scroll or you want get pagination then you have use it.
  var searchConversationScrollController = ScrollController();

  /// This variable use for store filter conversation list
  ///
  /// When user add conversaiton `IsmChatProperties.conversationProperties.conversationPredicate` in `IsmChatApp`
  /// get conversaton filter list on conditions `true` or `false`
  List<IsmChatConversationModel> get userConversations => conversations
      .where(IsmChatProperties.conversationProperties.conversationPredicate ??
          (_) => true)
      .toList();

  /// This variable use for store check connnection
  ///
  /// When this controller initilized then set value
  ///
  /// Then we have use check internet connection `wifi` , `ethernet` and `mobile`
  Connectivity? connectivity;

  /// This variable use for store streamSubscription
  ///
  /// This StreamSubscription listen internet `on` or `off` when app in running
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  /// This variable use for check type user name type or not
  ///
  /// This variable listen when change own name
  final RxBool _isUserNameType = false.obs;
  bool get isUserNameType => _isUserNameType.value;
  set isUserNameType(bool value) => _isUserNameType.value = value;

  /// This variable use for check type user email type or not
  ///
  /// This variable listen when change own eamil
  final RxBool _isUserEmailType = false.obs;
  bool get isUserEmailType => _isUserEmailType.value;
  set isUserEmailType(bool value) => _isUserEmailType.value = value;

  /// Observable list for managing skipped forwarded members.
  final _forwardedListSkip = <SelectedMembers>[].obs;
  List<SelectedMembers> get forwardedListSkip => _forwardedListSkip;
  set forwardedListSkip(List<SelectedMembers> value) {
    _forwardedList.value = value;
  }

  /// Observable boolean indicating if the controller has been initialized.
  final RxBool _intilizedContrller = false.obs;
  bool get intilizedContrller => _intilizedContrller.value;
  set intilizedContrller(bool value) {
    _intilizedContrller.value = value;
  }

  final RxInt _currentConversationIndex = 0.obs;
  int get currentConversationIndex => _currentConversationIndex.value;
  set currentConversationIndex(int value) {
    _currentConversationIndex.value = value;
  }

  final conversationView = [
    const IsmChatConversationList(),
    ...IsmChatProperties.conversationProperties.ontherConversationsWidget ?? []
  ];

  final chatPageView = [
    const IsmChatPageView(),
    ...IsmChatProperties.conversationProperties.ontherChatPagesWidget ?? []
  ];

  /// Initializes the controller, sets up internet connectivity, fetches user data, conversations, and background assets.
  @override
  onInit() async {
    super.onInit();
    intilizedContrller = false;
    _isInterNetConnect();
    _generateReactionList();
    var users = await IsmChatConfig.dbWrapper?.userDetailsBox
        .get(IsmChatStrings.userData);
    if (users != null) {
      userDetails = UserDetails.fromJson(users);
    } else {
      await getUserData();
    }
    await getConversationsFromDB();
    await getChatConversations();
    if (Get.isRegistered<IsmChatMqttController>()) {
      final mqttController = Get.find<IsmChatMqttController>();
      await Future.wait([
        mqttController.getChatConversationsUnreadCount(),
        mqttController.getUserMessges(
          senderIds: [
            IsmChatConfig.communicationConfig.userConfig.userId.isNotEmpty
                ? IsmChatConfig.communicationConfig.userConfig.userId
                : userDetails?.userId ?? ''
          ],
        ),
      ]);
    }
    await getBackGroundAssets();
    unawaited(getBlockUser());
    intilizedContrller = true;
    scrollListener();
    sendPendingMessgae();
  }

  /// Cleans up resources when the controller is closed.
  @override
  void onClose() {
    onDispose();
    super.onClose();
  }

  /// Disposes of the controller and its resources.
  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  /// Custom dispose method to clean up specific resources.
  void onDispose() {
    conversationScrollController.dispose();
    searchConversationScrollController.dispose();
    connectivitySubscription?.cancel();
  }

  /// Sets up connectivity listener to monitor internet connection changes.
  void _isInterNetConnect() {
    connectivity = Connectivity();
    connectivitySubscription =
        connectivity?.onConnectivityChanged.listen((event) {
      _sendPendingMessage();
    });
  }

  /// Sends any pending messages if the internet is available.
  void _sendPendingMessage() async {
    if (await IsmChatUtility.isNetworkAvailable) {
      if (currentConversation?.conversationId?.isNotEmpty == true) {
        {
          sendPendingMessgae(
              conversationId: currentConversation?.conversationId ?? '');
        }
      }
    }
  }

  /// Adds scroll listeners to manage pagination for conversations and search results.
  void scrollListener() async {
    conversationScrollController.addListener(
      () async {
        if (conversationScrollController.offset.toInt() ==
            conversationScrollController.position.maxScrollExtent.toInt()) {
          await getChatConversations(
            skip: conversations.length.pagination(),
          );
        }
      },
    );
    searchConversationScrollController.addListener(
      () async {
        if (searchConversationScrollController.offset.toInt() ==
            searchConversationScrollController.position.maxScrollExtent
                .toInt()) {
          await getChatConversations(
            skip: searchConversationList.length.pagination(),
          );
        }
      },
    );
  }

  /// Returns the appropriate widget based on the current render screen state.
  Widget isRenderScreenWidget() {
    switch (isRenderScreen) {
      case IsRenderConversationScreen.none:
        return const SizedBox.shrink();
      case IsRenderConversationScreen.blockView:
        return const IsmChatBlockedUsersView();
      case IsRenderConversationScreen.broadCastListView:
        IsmChatBroadcastBinding().dependencies();
        return const IsmChatBroadCastView();
      case IsRenderConversationScreen.groupUserView:
        return IsmChatCreateConversationView(
          isGroupConversation: true,
          conversationType: IsmChatConversationType.private,
        );
      case IsRenderConversationScreen.createConverstaionView:
        return IsmChatCreateConversationView(
          isGroupConversation: false,
          conversationType: IsmChatConversationType.private,
        );
      case IsRenderConversationScreen.userView:
        return IsmChatUserView();
      case IsRenderConversationScreen.broadcastView:
        return const IsmChatCreateBroadCastView();
      case IsRenderConversationScreen.openConverationView:
        return const IsmChatOpenConversationView();
      case IsRenderConversationScreen.publicConverationView:
        return const IsmChatPublicConversationView();
      // case IsRenderConversationScreen.editbroadCast:
      //   return IsmChatEditBroadcastView();
    }
  }

  /// Returns the appropriate widget based on the current chat page screen state.
  Widget isRenderChatScreenWidget() {
    switch (isRenderChatPageaScreen) {
      case IsRenderChatPageScreen.coversationInfoView:
        return IsmChatConverstaionInfoView();
      case IsRenderChatPageScreen.wallpaperView:
        break;
      case IsRenderChatPageScreen.messgaeInfoView:
        return IsmChatMessageInfo(
          isGroup: currentConversation?.isGroup ?? false,
          message: message!,
        );
      case IsRenderChatPageScreen.groupEligibleView:
        return const IsmChatGroupEligibleUser();
      case IsRenderChatPageScreen.none:
        return const SizedBox.shrink();
      case IsRenderChatPageScreen.coversationMediaView:
        return IsmMedia(
          mediaList: mediaList,
          mediaListDocs: mediaListDocs,
          mediaListLinks: mediaListLinks,
        );
      case IsRenderChatPageScreen.userInfoView:
        return IsmChatUserInfo(
          user: contactDetails,
          conversationId: userConversationId ?? '',
          fromMessagePage: true,
        );
      case IsRenderChatPageScreen.messageSearchView:
        return const IsmChatSearchMessgae();
      case IsRenderChatPageScreen.boradcastChatMessagePage:
        return const IsmChatBoradcastMessagePage();

      case IsRenderChatPageScreen.openChatMessagePage:
        return const IsmChatOpenChatMessagePage();
      case IsRenderChatPageScreen.observerUsersView:
        return IsmChatObserverUsersView(
          conversationId: currentConversation?.conversationId ?? '',
        );
      case IsRenderChatPageScreen.outSideView:
        return IsmChatProperties.conversationProperties.thirdColumnWidget?.call(
              IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context,
              currentConversation!,
            ) ??
            const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  /// Fetches the list of asset files from a JSON file.
  Future<AssetsModel?> getAssetFilesList() async {
    final jsonString = await rootBundle.loadString(
        'packages/isometrik_chat_flutter/assets/assets_backgroundAssets.json');
    final filesList = jsonDecode(jsonString);
    if (filesList != null) {
      return AssetsModel.fromMap(filesList);
    }
    return null;
  }

  /// Retrieves background assets and populates the background image and color lists.
  Future<void> getBackGroundAssets() async {
    var assets = await getAssetFilesList();
    if (assets != null) {
      backgroundImage = assets.images;
      backgroundColor = assets.colors;
    }
  }

  /// Generates a list of emoji reactions for the chat application.
  void _generateReactionList() {
    reactions.clear();
    reactions.addAll(IsmChatEmoji.values
        .expand((typesOfEmoji) => defaultEmojiSet.expand((categoryEmoji) =>
            categoryEmoji.emoji
                .where((emoji) => typesOfEmoji.emojiKeyword == emoji.name)))
        .toList());
  }

  /// This function will be used in [Forward Screen and New conversation screen] to Select or Unselect users
  ///
  ///  `index` : The index of the user in the forwarded list.
  void onForwardUserTap(int index) {
    forwardedList[index].isUserSelected = !forwardedList[index].isUserSelected;
  }

  /// This function will be used in [Forward Screen and New conversation screen] Adds or removes a user from the selected user list based on their selection state.
  ///
  ///  `userDetails`: The user to be selected or deselected.
  void isSelectedUser(UserDetails userDetails) {
    if (selectedUserList.isEmpty) {
      selectedUserList.add(userDetails);
    } else {
      if (selectedUserList.any((e) => e.userId == userDetails.userId)) {
        selectedUserList.removeWhere((e) => e.userId == userDetails.userId);
      } else {
        selectedUserList.add(userDetails);
      }
    }
  }

  /// Unblocks a user based on their opponent ID
  ///
  /// `opponentId`: The ID of the user to unblock.
  /// `isLoading`: Indicates if loading should be shown.
  /// `fromUser` : Indicates if the unblock action is initiated by the user.
  Future<bool> unblockUser({
    required String opponentId,
    required bool isLoading,
    bool fromUser = false,
  }) async {
    final data = await _viewModel.unblockUser(
      opponentId: opponentId,
      isLoading: isLoading,
    );
    if (data?.hasError ?? true) {
      return false;
    }
    unawaited(getBlockUser());
    IsmChatUtility.showToast(IsmChatStrings.unBlockedSuccessfully);
    if (fromUser) {
      return false;
    }
    return true;
  }

  ///  Unblocks a user for web-based chat.
  ///
  /// `opponentId`: The ID of the user to unblock.
  void unblockUserForWeb(String opponentId) {
    if (IsmChatUtility.chatPageControllerRegistered) {
      var conversationId = getConversationId(opponentId);
      final chatPageController = IsmChatUtility.chatPageController;
      if (conversationId == chatPageController.conversation?.conversationId) {
        chatPageController.unblockUser(
          opponentId: opponentId,
          isLoading: false,
          userBlockOrNot: true,
        );
      }
    }
  }

  /// Uploads an image and returns the URL of the uploaded image.
  ///
  /// `imageSource`: The source of the image to upload.
  Future<String> ismUploadImage(ImageSource imageSource) async {
    var file = await IsmChatUtility.pickMedia(imageSource);
    if (file.isEmpty) {
      return '';
    }

    Uint8List? bytes;
    String? extension;
    if (kIsWeb) {
      bytes = await file.first?.readAsBytes();
      extension = 'jpg';
    } else {
      bytes = await file.first?.readAsBytes();
      extension = file.first?.path.split('.').last;
    }
    return await getPresignedUrl(
      extension!,
      bytes!,
      true,
    );
  }

  /// Changes the profile image for a group.
  ///
  /// `imageSource`: The source of the image to upload.
  Future<void> ismChangeImage(ImageSource imageSource) async {
    var file = await IsmChatUtility.pickMedia(imageSource);
    if (file.isEmpty) {
      return;
    }

    final bytes = await file.first?.readAsBytes();
    final fileExtension = file.first?.path.split('.').last;
    await getPresignedUrl(fileExtension ?? '', bytes ?? Uint8List(0));
  }

  /// Retrieves a presigned URL for uploading media.
  ///
  ///  `mediaExtension`: The extension of the media file.
  ///  `bytes`: The bytes of the media file.
  ///  `isLoading`: Indicates if loading should be shown.
  Future<String> getPresignedUrl(
    String mediaExtension,
    Uint8List bytes, [
    bool isLoading = false,
  ]) async {
    final response = await commonController.getPresignedUrl(
        isLoading: true,
        userIdentifier: userDetails?.userIdentifier ?? '',
        mediaExtension: mediaExtension,
        bytes: bytes);

    if (response == null) {
      return '';
    }
    final responseCode = await commonController.updatePresignedUrl(
      presignedUrl: response.presignedUrl,
      bytes: bytes,
      isLoading: isLoading,
    );
    if (responseCode == 200) {
      profileImage = response.mediaUrl ?? '';
    }
    return profileImage;
  }

  /// Fetches a list of non-blocked users for creating chats or forwarding messages.
  ///
  /// Will be used for Create chat and/or Forward message
  ///  `sort`: Sorting order.
  ///  `skip`: Number of users to skip.
  ///  `limi`t: Maximum number of users to return.
  ///  `searchTag`: Search term for filtering users.
  ///  `opponentId`: ID of the opponent to exclude.
  ///  `isLoading`: Indicates if loading should be shown.
  ///  `isGroupConversation`: Indicates if the conversation is a group chat.
  Future<List<SelectedMembers>?> getNonBlockUserList({
    int sort = 1,
    int skip = 0,
    int limit = 20,
    String searchTag = '',
    String? opponentId,
    bool isLoading = false,
    bool isGroupConversation = false,
  }) async {
    if (!callApiOrNot) return null;
    callApiOrNot = false;
    final response = await _viewModel.getNonBlockUserList(
      sort: sort,
      skip: searchTag.isNotEmpty
          ? 0
          : forwardedList.isEmpty
              ? 0
              : forwardedList.length.pagination(),
      limit: limit,
      searchTag: searchTag,
      isLoading: isLoading,
    );

    final users = response?.users ?? [];
    if (users.isEmpty) {
      isLoadResponse = true;
    }
    users.sort((a, b) => a.userName.compareTo(b.userName));

    if (opponentId != null) {
      users.removeWhere((e) => e.userId == opponentId);
    }

    if (searchTag.isEmpty) {
      forwardedList.addAll(List.from(users)
          .map((e) => SelectedMembers(
                isUserSelected: selectedUserList.isEmpty
                    ? false
                    : selectedUserList
                        .any((d) => d.userId == (e as UserDetails).userId),
                userDetails: e as UserDetails,
                isBlocked: false,
              ))
          .toList());
      forwardedListDuplicat = List<SelectedMembers>.from(forwardedList);
    } else {
      forwardedList = List.from(users)
          .map(
            (e) => SelectedMembers(
              isUserSelected: selectedUserList.isEmpty
                  ? false
                  : selectedUserList
                      .any((d) => d.userId == (e as UserDetails).userId),
              userDetails: e as UserDetails,
              isBlocked: false,
            ),
          )
          .toList();
    }

    if (response != null) {
      commonController.handleSorSelectedMembers(
        forwardedList,
      );
    }

    if (response == null && searchTag.isEmpty && isGroupConversation == false) {
      unawaited(getContacts(isLoading: isLoading, searchTag: searchTag));
      callApiOrNot = true;
      return forwardedList;
    }
    callApiOrNot = true;
    return forwardedList;
  }

  /// Clears all messages in a conversation.
  ///
  /// `conversationId`: The ID of the conversation to clear messages from.
  ///  `fromServer`: Indicates if the clear action should be performed on the server.
  Future<void> clearAllMessages(String? conversationId,
      {bool fromServer = true}) async {
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }
    return _viewModel.clearAllMessages(conversationId, fromServer: fromServer);
  }

  /// Updates the current conversation with new details.
  ///
  /// `conversation`: The conversation model to update.
  void updateLocalConversation(IsmChatConversationModel conversation) {
    currentConversation = conversation;
    currentConversationId = conversation.conversationId ?? '';
  }

  /// Deletes a chat based on the conversation ID
  ///
  /// `conversationId`: The ID of the conversation to delete.
  /// `deleteFromServer`: Indicates if the chat should be deleted from the server.
  /// `shouldUpdateLocal`: Indicates if the local database should be updated.
  Future<void> deleteChat(
    String? conversationId, {
    bool deleteFromServer = true,
    bool shouldUpdateLocal = true,
  }) async {
    if (conversationId.isNullOrEmpty) return;

    if (deleteFromServer) {
      final response = await _viewModel.deleteChat(conversationId ?? '');
      if (response?.hasError ?? true) return;
    }
    if (shouldUpdateLocal) {
      await IsmChatConfig.dbWrapper?.removeConversation(conversationId ?? '');
      await getConversationsFromDB();
      if (deleteFromServer) {
        await getChatConversations();
      }
    }
  }

  /// Retrieves conversations from the local database and updates the observable list.
  ///
  /// `searchTag`: Optional search term for filtering conversations.
  Future<void> getConversationsFromDB({
    String? searchTag,
  }) async {
    final dbConversations =
        await IsmChatConfig.dbWrapper?.getAllConversations() ?? [];

    conversations.clear();
    if (dbConversations.isEmpty == true) {
      IsmChatProperties.conversationProperties.conversationListEmptyOrNot
          ?.call(dbConversations.isEmpty);
      return;
    }
    conversations = dbConversations;
    isConversationsLoading = false;
    if (conversations.length <= 1) {
      IsmChatProperties.conversationProperties.conversationListEmptyOrNot
          ?.call(conversations.isEmpty);
      return;
    }
    conversations.sort((a, b) => (b.lastMessageDetails?.sentAt ?? 0)
        .compareTo(a.lastMessageDetails?.sentAt ?? 0));
    final opponentEmptyData = <IsmChatConversationModel>[];
    final opponentData = <IsmChatConversationModel>[];
    for (var x in conversations) {
      if (x.isGroup == false && x.opponentDetails?.userId.isEmpty == true) {
        opponentEmptyData.add(x);
      } else {
        opponentData.add(x);
      }
    }
    opponentData.addAll(opponentEmptyData);
    conversations = opponentData;

    if (searchTag?.isNotEmpty == true) {
      conversations = conversations
          .where((e) =>
              (e.opponentDetails?.userName ?? '')
                  .toLowerCase()
                  .startsWith((searchTag ?? '').toLowerCase()) ||
              (e.opponentDetails?.metaData?.firstName ?? '')
                  .toLowerCase()
                  .startsWith((searchTag ?? '').toLowerCase()) ||
              (e.opponentDetails?.metaData?.lastName ?? '')
                  .toLowerCase()
                  .startsWith((searchTag ?? '').toLowerCase()))
          .toList();
    }

    if (IsmChatConfig.sortConversationWithIdentifier != null) {
      var target = IsmChatConfig.sortConversationWithIdentifier?.call();
      conversations.sort((a, b) {
        if (a.opponentDetails?.userIdentifier == target) {
          return -1;
        }
        if (b.opponentDetails?.userIdentifier == target) {
          return 1;
        }
        return -1;
      });
    }

    IsmChatProperties.conversationProperties.conversationListEmptyOrNot
        ?.call(conversations.isEmpty);
  }

  /// Retrieves the conversation ID for a given user ID.
  ///
  /// `userId`: The ID of the user to find the conversation for.
  String getConversationId(String userId) {
    final conversation = conversations.firstWhere(
        (element) => element.opponentDetails?.userId == userId,
        orElse: IsmChatConversationModel.new);

    if (conversation.conversationId == null) {
      return '';
    }
    return conversation.conversationId ?? '';
  }

  /// Retrieves a conversation model based on the conversation ID.
  ///
  /// `conversationId`: The ID of the conversation to retrieve.
  IsmChatConversationModel? getConversation(String conversationId) {
    final conversation = conversations.firstWhere(
        (element) => element.conversationId == conversationId,
        orElse: IsmChatConversationModel.new);

    if (conversation.conversationId == null) {
      return null;
    }
    return conversation;
  }

  /// Fetches chat conversations from the server and updates the local
  ///
  /// `skip`: Number of conversations to skip.
  /// `origin`: The origin of the API call (e.g., refresh, load more).
  /// `searchTag`: Optional search term for filtering conversations.
  Future<void> getChatConversations({
    int skip = 0,
    ApiCallOrigin? origin,
    String? searchTag,
  }) async {
    if (conversations.isEmpty) {
      isConversationsLoading = true;
    }
    var chats = await _viewModel.getChatConversations(
      skip: skip,
      searchTag: searchTag,
    );

    if (IsmChatProperties.conversationModifier != null) {
      chats = await Future.wait(
        chats.map(
          (e) async => await IsmChatProperties.conversationModifier!(e),
        ),
      );
      await Future.wait(
        chats.map(
          (e) async =>
              await IsmChatConfig.dbWrapper?.createAndUpdateConversation(e),
        ),
      );
    }

    if (origin == ApiCallOrigin.referesh) {
      refreshController.refreshCompleted(
        resetFooterState: true,
      );
      refreshControllerOnEmptyList.refreshCompleted(
        resetFooterState: true,
      );
    } else if (origin == ApiCallOrigin.loadMore) {
      if (chats.isEmpty) {
        refreshController.loadNoData();
        refreshControllerOnEmptyList.loadNoData();
      } else {
        refreshController.loadComplete();
        refreshControllerOnEmptyList.loadComplete();
      }
    }

    await getConversationsFromDB(
      searchTag: searchTag,
    );

    if (conversations.isEmpty) {
      isConversationsLoading = false;
    }
  }

  /// Fetches search results for chat conversations.
  ///
  /// `skip`: Number of conversations to skip.
  /// `origin`: The origin of the API call (e.g., refresh, load more).
  /// `chatLimit`: Maximum number of chat results to return.
  Future<void> getChatSearchConversations({
    int skip = 0,
    ApiCallOrigin? origin,
    int chatLimit = 20,
  }) async {
    if (searchConversationList.isEmpty) {
      isConversationsLoading = true;
    }

    final response = await _viewModel.getChatConversations(
      skip: skip,
      chatLimit: chatLimit,
    );

    searchConversationList = response;

    if (origin == ApiCallOrigin.referesh) {
      searchConversationrefreshController.refreshCompleted(
        resetFooterState: true,
      );
    } else if (origin == ApiCallOrigin.loadMore) {
      searchConversationrefreshController.loadComplete();
    }
    isConversationsLoading = false;
  }

  /// Retrieves a list of blocked users.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  Future<List<UserDetails>> getBlockUser({bool isLoading = false}) async {
    final users = await _viewModel.getBlockUser(
      skip: 0,
      limit: 20,
      isLoading: isLoading,
    );
    if (users != null) {
      blockUsers = users.users;
    } else {
      blockUsers = [];
    }
    return blockUsers;
  }

  /// Fetches user data from the server and updates the local database.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> getUserData({bool isLoading = false}) async {
    final user = await _viewModel.getUserData(isLoading: isLoading);
    if (user != null) {
      userDetails = user;
      if (!kIsWeb) {
        if (userDetails?.metaData?.assetList?.isNotEmpty == true) {
          final assetList = userDetails?.metaData?.assetList?.toList() ?? [];
          final indexOfAsset = assetList
              .indexWhere((e) => e.values.first.srNoBackgroundAssset == 100);
          if (indexOfAsset != -1) {
            final pathName = assetList[indexOfAsset]
                    .values
                    .first
                    .imageUrl
                    ?.split('/')
                    .last ??
                '';
            final filePath = await IsmChatUtility.makeDirectoryWithUrl(
                urlPath: assetList[indexOfAsset].values.first.imageUrl ?? '',
                fileName: pathName);
            assetList[indexOfAsset] = {
              '${assetList[indexOfAsset].keys}': IsmChatBackgroundModel(
                color: assetList[indexOfAsset].values.first.color,
                isImage: assetList[indexOfAsset].values.first.isImage,
                imageUrl: filePath.path,
                srNoBackgroundAssset:
                    assetList[indexOfAsset].values.first.srNoBackgroundAssset,
              )
            };
          }
          userDetails = userDetails?.copyWith(
              metaData: userDetails?.metaData?.copyWith(assetList: assetList));
        }
      }

      await IsmChatConfig.dbWrapper?.userDetailsBox
          .put(IsmChatStrings.userData, userDetails?.toJson() ?? '');
    }
  }

  /// Updates user data on the server.
  ///
  /// `userProfileImageUrl`: The URL of the user's profile image.
  ///  `userName`: The user's name.
  /// `userIdentifier`: The user's identifier.
  /// `metaData`: Additional metadata for the user.
  /// `isloading`: Indicates if loading should be shown.
  Future<void> updateUserData({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    Map<String, dynamic>? metaData,
    bool isloading = false,
  }) async {
    await _viewModel.updateUserData(
      userProfileImageUrl: userProfileImageUrl,
      userName: userName,
      userIdentifier: userIdentifier,
      metaData: metaData,
      isloading: isloading,
    );
  }

  /// Filters suggestions based on the search query.
  ///
  /// `query`: The search query to filter suggestions.
  void onSearch(String query) {
    if (query.trim().isEmpty) {
      suggestions = conversations;
    } else {
      suggestions = conversations
          .where(
            (e) =>
                e.chatName.didMatch(query) ||
                e.lastMessageDetails!.body.didMatch(query),
          )
          .toList();
    }
  }

  /// Updates a conversation's metadata on the server.
  ///
  /// `conversationId`: The ID of the conversation to update.
  /// `metaData`: The new metadata for the conversation.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool isLoading = false,
  }) async {
    final response = await _viewModel.updateConversation(
      conversationId: conversationId,
      metaData: metaData,
      isLoading: isLoading,
    );
    if (response?.hasError == false) {
      await getChatConversations();
    }
  }

  /// Updates the settings of a conversation.
  ///
  /// `conversationId`: The ID of the conversation to update.
  /// `events`: The events to update in the conversation.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> updateConversationSetting({
    required String conversationId,
    required IsmChatEvents events,
    bool isLoading = false,
  }) async {
    await _viewModel.updateConversationSetting(
      conversationId: conversationId,
      events: events,
      isLoading: isLoading,
    );
  }

  /// Sends a forwarded message to specified users.
  ///
  ///  `userIds`: List of user IDs to send the message to.
  /// `body`: The body of the message.
  /// `attachments`: Optional attachments for the message.
  /// `customType`: Optional custom type for the message.
  /// `isLoading`: Indicates if loading should be shown.
  /// `metaData`: Optional metadata for the message.
  Future<void> sendForwardMessage({
    required List<String> userIds,
    required String body,
    List<Map<String, dynamic>>? attachments,
    String? customType,
    bool isLoading = false,
    IsmChatMetaData? metaData,
  }) async {
    final response = await _viewModel.sendForwardMessage(
      userIds: userIds,
      showInConversation: true,
      messageType: IsmChatMessageType.forward.value,
      encrypted: true,
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      body: body,
      notificationBody: body,
      notificationTitle:
          IsmChatConfig.communicationConfig.userConfig.userName ??
              userDetails?.userName ??
              '',
      isLoading: isLoading,
      searchableTags: [body],
      customType: customType,
      attachments: attachments,
      events: {'updateUnreadCount': true, 'sendPushNotification': true},
      metaData: metaData,
    );
    if (response?.hasError == false) {
      IsmChatRoute.goBack();
      await getChatConversations();
    }
  }

  /// Initializes the public and open conversation state.
  ///
  /// `conversationType`: The type of conversation to initialize.
  void intiPublicAndOpenConversation(
      IsmChatConversationType conversationType) async {
    publicAndOpenConversation.clear();
    isLoadResponse = false;
    showSearchField = false;
    callApiOrNot = true;
    await getPublicAndOpenConversation(
      conversationType: conversationType.value,
    );
  }

  /// Fetches public and open conversations based on specified parameters.
  ///
  /// `conversationType`: The type of conversation to fetch.
  /// `searchTag`: Optional search term for filtering conversations.
  /// `sort`: Sorting order.
  /// `skip`: Number of conversations to skip.
  /// `limit`: Maximum number of conversations to return.
  Future<void> getPublicAndOpenConversation({
    required int conversationType,
    String? searchTag,
    int sort = 1,
    int skip = 0,
    int limit = 20,
  }) async {
    if (!callApiOrNot) return;
    callApiOrNot = false;
    final response = await _viewModel.getPublicAndOpenConversation(
      searchTag: searchTag,
      sort: sort,
      skip: skip,
      limit: limit,
      conversationType: conversationType,
    );
    if (response == null || response.isEmpty) {
      isLoadResponse = true;
      publicAndOpenConversation = [];
      return;
    }
    publicAndOpenConversation.addAll(response);
    callApiOrNot = true;
  }

  /// Joins a conversation based on its ID.
  ///
  /// `conversationId`: The ID of the conversation to join.
  /// `isloading`: Indicates if loading should be shown.
  Future<void> joinConversation({
    required String conversationId,
    bool isloading = false,
  }) async {
    final response = await _viewModel.joinConversation(
        conversationId: conversationId, isLoading: isloading);
    if (response != null) {
      IsmChatRoute.goBack();
      await getChatConversations();
    }
  }

  /// Joins an observer to a conversation.
  ///
  /// `conversationId`: The ID of the conversation to join as an observer.
  ///  `isLoading`: Indicates if loading should be shown.
  Future<IsmChatResponseModel?> joinObserver(
          {required String conversationId, bool isLoading = false}) async =>
      await _viewModel.joinObserver(
          conversationId: conversationId, isLoading: isLoading);

  /// Leaves an observer role in a conversation.
  ///
  /// `conversationId`: The ID of the conversation to leave.
  /// `isLoading`: Indicates if loading should be shown.
  Future<void> leaveObserver(
      {required String conversationId, bool isLoading = false}) async {
    final response = await _viewModel.leaveObserver(
        conversationId: conversationId, isLoading: isLoading);
    if (response != null) {}
  }

  /// Navigates to the chat page based on the platform (web or mobile).
  Future<void> goToChatPage() async {
    if (IsmChatResponsive.isWeb(
      IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
    )) {
      if (!IsmChatUtility.chatPageControllerRegistered) {
        IsmChatPageBinding().dependencies();
        return;
      }
      isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      final chatPagecontroller = IsmChatUtility.chatPageController;
      chatPagecontroller.startInit();
      chatPagecontroller.closeOverlay();
      if (chatPagecontroller.showEmojiBoard) {
        chatPagecontroller.toggleEmojiBoard(false, false);
      }
    } else {
      await IsmChatRoute.goToRoute(IsmChatPageView(
        viewTag: IsmChat.i.chatPageTag,
      ));
    }
  }

  /// Retrieves users observing a conversation.
  ///
  /// `conversationId`: The ID of the conversation to get observers from.
  /// `skip`: Number of users to skip.
  /// `limit`: Maximum number of users to return.
  /// `isLoading`: Indicates if loading should be shown.
  /// `searchText`: Optional search term for filtering users.
  Future<List<UserDetails>> getObservationUser({
    required String conversationId,
    int skip = 0,
    int limit = 20,
    bool isLoading = false,
    String? searchText,
  }) async {
    final res = await _viewModel.getObservationUser(
      conversationId: conversationId,
      isLoading: isLoading,
      limit: limit,
      searchText: searchText,
      skip: skip,
    );
    if (res != null) {
      return res;
    }
    return [];
  }

  /// Sends any pending messages stored in the local database.
  ///
  /// `conversationId`: The ID of the conversation to send pending messages for.
  void sendPendingMessgae({String conversationId = ''}) async {
    var messages = IsmChatMessages.from({});

    if (conversationId.isEmpty) {
      final pendingMessages =
          await IsmChatConfig.dbWrapper?.getAllPendingMessages();

      messages.addAll(pendingMessages ?? {});
    } else {
      messages = await IsmChatConfig.dbWrapper
              ?.getMessage(conversationId, IsmChatDbBox.pending) ??
          {};
    }
    if (messages.isEmpty) {
      return;
    }
    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            userDetails?.userName ??
            '';

    for (final x in messages.values) {
      List<Map<String, dynamic>>? attachments;
      if ([
        IsmChatCustomMessageType.image,
        IsmChatCustomMessageType.audio,
        IsmChatCustomMessageType.video,
        IsmChatCustomMessageType.file
      ].contains(x.customType)) {
        final attachment = x.attachments?.first;
        final bytes = File(attachment?.mediaUrl ?? '').readAsBytesSync();
        PresignedUrlModel? presignedUrlModel;
        presignedUrlModel = await commonController.postMediaUrl(
          conversationId: x.conversationId ?? '',
          nameWithExtension: attachment?.name ?? '',
          mediaType: attachment?.attachmentType?.value ?? 0,
          mediaId: attachment?.mediaId ?? '',
          isLoading: false,
          bytes: bytes,
        );

        var mediaUrlPath = '';
        if (presignedUrlModel != null) {
          var response = await commonController.updatePresignedUrl(
            presignedUrl: presignedUrlModel.mediaPresignedUrl,
            bytes: bytes,
            isLoading: false,
          );
          if (response == 200) {
            mediaUrlPath = presignedUrlModel.mediaUrl ?? '';
          }
        }
        var thumbnailUrlPath = '';
        if (IsmChatCustomMessageType.video == x.customType) {
          PresignedUrlModel? presignedUrlModel;
          final nameWithExtension = attachment?.thumbnailUrl?.split('/').last;
          final bytes = File(attachment?.thumbnailUrl ?? '').readAsBytesSync();
          presignedUrlModel = await commonController.postMediaUrl(
            conversationId: x.conversationId ?? '',
            nameWithExtension: nameWithExtension ?? '',
            mediaType: 0,
            mediaId: DateTime.now().millisecondsSinceEpoch.toString(),
            isLoading: false,
            bytes: bytes,
          );
          if (presignedUrlModel != null) {
            final response = await commonController.updatePresignedUrl(
              presignedUrl: presignedUrlModel.thumbnailPresignedUrl,
              bytes: bytes,
              isLoading: false,
            );
            if (response == 200) {
              thumbnailUrlPath = presignedUrlModel.thumbnailUrl ?? '';
            }
          }
        }
        if (mediaUrlPath.isNotEmpty) {
          attachments = [
            {
              'thumbnailUrl': IsmChatCustomMessageType.video == x.customType
                  ? thumbnailUrlPath
                  : mediaUrlPath,
              'size': attachment?.size,
              'name': attachment?.name,
              'mimeType': attachment?.mimeType,
              'mediaUrl': mediaUrlPath,
              'mediaId': attachment?.mediaId,
              'extension': attachment?.extension,
              'attachmentType': attachment?.attachmentType?.value,
            }
          ];
        }
      }
      final isMessageSent = await commonController.sendMessage(
        showInConversation: true,
        encrypted: true,
        events: {'updateUnreadCount': true, 'sendPushNotification': true},
        attachments: attachments,
        mentionedUsers: x.mentionedUsers?.map((e) => e.toMap()).toList(),
        metaData: x.metaData,
        messageType: x.messageType?.value ?? 0,
        customType: x.customType?.name,
        parentMessageId: x.parentMessageId,
        deviceId: x.deviceId ?? '',
        conversationId: x.conversationId ?? '',
        notificationBody: x.body,
        notificationTitle: notificationTitle,
        body: x.body,
        createdAt: x.sentAt,
        isBroadcast: IsmChatUtility.chatPageControllerRegistered
            ? IsmChatUtility.chatPageController.isBroadcast
            : false,
      );
      if (isMessageSent && IsmChatUtility.chatPageControllerRegistered) {
        final controller = IsmChatUtility.chatPageController;
        if (!controller.isBroadcast) {
          controller.didReactedLast = false;
          await controller.getMessagesFromDB(conversationId);
        }
      } else if (isMessageSent) {
        await getChatConversations();
      }
    }
  }

  /// Initializes the state for creating a new conversation.
  ///
  /// `isGroupConversation`: Indicates if the conversation is a group chat.
  void initCreateConversation([bool isGroupConversation = false]) async {
    callApiOrNot = true;
    profileImage = '';
    forwardedList.clear();
    selectedUserList.clear();
    addGrouNameController.clear();
    forwardedList.selectedUsers.clear();
    userSearchNameController.clear();
    showSearchField = false;
    isLoadResponse = false;
    await getNonBlockUserList(
      opponentId: IsmChatConfig.communicationConfig.userConfig.userId,
    );
    if (!isGroupConversation) {
      await getContacts();
    }
  }

  /// Updates the user's profile image.
  ///
  /// `source`: The source of the image to upload.
  void updateUserDetails(ImageSource source) async {
    IsmChatRoute.goBack();
    final imageUrl = await ismUploadImage(source);
    if (imageUrl.isNotEmpty) {
      await updateUserData(
        userProfileImageUrl: imageUrl,
        isloading: true,
      );
      await getUserData(
        isLoading: true,
      );
    }
  }

  /// Requests permission to access contacts.
  Future<void> askPermissions() async {
    if (await IsmChatUtility.requestPermission(Permission.contacts)) {
      fillContact();
    }
  }

  /// List of device fetch contacts...
  List<ContactSyncModel> sendContactSync = [];

  /// use for fast access the name through number
  Map<String, String> hashMapSendContactSync = {};

  /// Fetches and fills the local contacts into a usable model.
  void fillContact() async {
    final localList = [];
    var contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
    hashMapSendContactSync.clear();
    for (final x in contacts) {
      if (x.phones.isNotEmpty) {
        final phone = x.phones.first.number;
        if (!((phone.contains('@')) && (phone.contains('.com'))) &&
            x.displayName.isNotEmpty) {
          if (x.phones.isNotEmpty) {
            if (x.phones.first.number.contains('+')) {
              final code = x.phones.first.number.removeAllWhitespace;
              localList.add(
                ContactSyncModel(
                  contactNo: code.substring(3, code.length),
                  countryCode: code.substring(0, 3),
                  firstName: x.name.first,
                  fullName: '${x.name.first} ${x.name.last}',
                  lastName: x.name.last,
                ),
              );
              hashMapSendContactSync[code.substring(3, code.length)] =
                  '${x.name.first} ${x.name.last}';
              hashMapSendContactSync['${x.name.first} ${x.name.last}'] =
                  code.substring(3, code.length);
            } else if (x.phones.first.normalizedNumber.contains('+')) {
              final code = x.phones.first.normalizedNumber.removeAllWhitespace;
              localList.add(
                ContactSyncModel(
                  contactNo: code.substring(3, code.length),
                  countryCode: code.substring(0, 3),
                  firstName: x.name.first,
                  fullName: '${x.name.first} ${x.name.last}',
                  lastName: x.name.last,
                ),
              );
              hashMapSendContactSync[code.substring(3, code.length)] =
                  '${x.name.first} ${x.name.last}';
              hashMapSendContactSync['${x.name.first} ${x.name.last}'] =
                  code.substring(3, code.length);
            }
          }
        }
      }
    }
    sendContactSync.clear();
    sendContactSync = List.from(localList);
  }

  /// get the contact after filter contacts those registered or not registered basis on (isRegisteredUser)...
  List<ContactSyncModel> getContactSyncUser = [];

  /// Retrieves contacts from the server and updates the forwarded list.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  /// `isRegisteredUser` : Indicates if only registered users should be fetched.
  /// `skip`: Number of contacts to skip.
  /// `limit`: Maximum number of contacts to return.
  /// `searchTag`: Optional search term for filtering contacts.
  Future<void> getContacts({
    bool isLoading = false,
    bool isRegisteredUser = false,
    int skip = 400,
    int limit = 20,
    String searchTag = '',
  }) async {
    if (IsmChatConfig.communicationConfig.userConfig.accessToken != null) {
      final res = await _viewModel.getContacts(
        searchTag: searchTag,
        isLoading: isLoading,
        isRegisteredUser: isRegisteredUser,
        skip: getContactSyncUser.isNotEmpty
            ? getContactSyncUser.length.pagination()
            : 10,
        limit: limit,
      );

      if (res != null && (res.data ?? []).isNotEmpty) {
        getContactSyncUser.addAll(res.data ?? []);
        await removeDBUser();
        final forwardedListLocalList = <SelectedMembers>[];
        for (var e in getContactSyncUser) {
          if (hashMapSendContactSync[e.contactNo ?? ''] != null) {
            forwardedListLocalList.add(
              SelectedMembers(
                localContacts: true,
                isUserSelected: false,
                userDetails: UserDetails(
                    userProfileImageUrl: '',
                    userName: hashMapSendContactSync[e.contactNo ?? ''] ?? '',
                    userIdentifier:
                        '${e.countryCode ?? ''} ${e.contactNo ?? ''}',
                    userId: e.userId ?? '',
                    online: false,
                    lastSeen: DateTime.now().microsecondsSinceEpoch),
                isBlocked: false,
              ),
            );
          }
        }
        forwardedList.addAll(forwardedListLocalList);
      }
      commonController.handleSorSelectedMembers(
        forwardedList,
      );

      update();
    }
  }

  /// Searches local contacts based on the provided search term.
  ///
  /// `search`: The search term to filter local contacts.
  void searchOnLocalContacts(String search) async {
    final filterContacts = sendContactSync
        .where((element) => (element.fullName ?? '').contains(search))
        .toList();
    for (var i in forwardedListSkip) {
      filterContacts.removeWhere((element) => i.userDetails.userIdentifier
          .trim()
          .contains(element.contactNo ?? '*~.'));
    }
    forwardedList.addAll(
      List.from(
        filterContacts.map(
          (e) => SelectedMembers(
            localContacts: true,
            isUserSelected: false,
            userDetails: UserDetails(
                userProfileImageUrl: '',
                userName: hashMapSendContactSync[e.contactNo] ?? '',
                userIdentifier: '${e.countryCode ?? ''} ${e.contactNo}',
                userId: e.userId ?? '',
                online: false,
                lastSeen: DateTime.now().microsecondsSinceEpoch),
            isBlocked: false,
          ),
        ),
      ),
    );
    commonController.handleSorSelectedMembers(
      forwardedList,
    );
  }

  /// Navigates to the contact synchronization page.
  void goToContactSync() async {
    // await askPermissions();
    await Future.delayed(Durations.extralong1);

    await IsmChatRoute.goToRoute(IsmChatCreateConversationView(
      isGroupConversation: false,
      conversationType: IsmChatConversationType.private,
    ));
  }

  /// Removes local users from the forwarded list.
  Future<void> removeDBUser() async {
    forwardedList.removeWhere((element) => element.localContacts == true);
  }

  /// Adds contacts to the server.
  Future<void> addContact({
    bool isLoading = true,
  }) async {
    final res = await _viewModel.addContact(
      isLoading: isLoading,
      payload: ContactSync(
        createdUnderProjectId:
            IsmChatConfig.communicationConfig.projectConfig.projectId,
        data: sendContactSync,
      ).toJson(),
    );
    if (res != null) {}
  }

  /// Replies to stories with a media message.
  ///
  /// `conversationId`: The ID of the conversation to reply in.
  /// `userDetails`: The user details of the person whose story is being replied to.
  /// `storyMediaUrl`: The URL of the story media.
  /// `caption`: Optional caption for the reply.
  /// `sendPushNotification`: Indicates if a push notification should be sent.
  Future<void> replayOnStories({
    required String conversationId,
    required UserDetails userDetails,
    String? storyMediaUrl,
    String? caption,
    bool sendPushNotification = false,
  }) async {
    final chatConversationResponse =
        await IsmChatConfig.dbWrapper?.getConversation(conversationId);
    if (chatConversationResponse == null) {
      final conversation = await commonController.createConversation(
        conversation: currentConversation!,
        userId: [userDetails.userId],
        metaData: currentConversation?.metaData,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              userDetails.userName,
          userDetails.userName
        ],
      );
      conversationId = conversation?.conversationId ?? '';
    }
    IsmChatMessageModel? imageMessage;
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final bytes = await IsmChatUtility.getUint8ListFromUrl(storyMediaUrl ?? '');
    final nameWithExtension = storyMediaUrl?.split('/').last ?? '';
    final mediaId = nameWithExtension.replaceAll(RegExp(r'[^0-9]'), '');
    final extension = nameWithExtension.split('.').last;
    imageMessage = IsmChatMessageModel(
      body: IsmChatStrings.image,
      conversationId: conversationId,
      senderInfo: UserDetails(
          userProfileImageUrl:
              IsmChatConfig.communicationConfig.userConfig.userProfile ?? '',
          userName: IsmChatConfig.communicationConfig.userConfig.userName ?? '',
          userIdentifier:
              IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
          userId: IsmChatConfig.communicationConfig.userConfig.userId,
          online: false,
          lastSeen: 0),
      customType: IsmChatCustomMessageType.image,
      attachments: [
        AttachmentModel(
          attachmentType: IsmChatMediaType.image,
          thumbnailUrl: storyMediaUrl,
          size: bytes.length,
          name: nameWithExtension,
          mimeType: 'image/jpeg',
          mediaUrl: storyMediaUrl,
          mediaId: mediaId,
          extension: extension,
        )
      ],
      deliveredToAll: false,
      messageId: '',
      deviceId: IsmChatConfig.communicationConfig.projectConfig.deviceId,
      messageType: IsmChatMessageType.normal,
      messagingDisabled: false,
      parentMessageId: '',
      readByAll: false,
      sentAt: sentAt,
      sentByMe: true,
      isUploading: true,
      metaData: IsmChatMetaData(
        caption: caption,
      ),
    );

    final notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            userDetails.userName;
    await commonController.sendMessage(
      showInConversation: true,
      encrypted: true,
      events: {
        'updateUnreadCount': true,
        'sendPushNotification': sendPushNotification
      },
      body: imageMessage.body,
      conversationId: imageMessage.conversationId ?? '',
      createdAt: sentAt,
      deviceId: imageMessage.deviceId ?? '',
      messageType: imageMessage.messageType?.value ?? 0,
      notificationBody: imageMessage.body,
      notificationTitle: notificationTitle,
      attachments: [imageMessage.attachments?.first.toMap() ?? {}],
      customType: imageMessage.customType?.value,
      metaData: imageMessage.metaData,
      parentMessageId: imageMessage.parentMessageId,
      isUpdateMesage: false,
    );
  }

  /// Navigates to the broadcast message page with specified members.
  ///
  /// `members`: List of members to include in the broadcast.
  /// `conversationId`: The ID of the conversation for the broadcast.
  void goToBroadcastMessage(List<UserDetails> members, String conversationId) {
    final conversation = IsmChatConversationModel(
      members: members,
      conversationImageUrl: IsmChatAssets.noImage,
      customType: IsmChatStrings.broadcast,
      conversationId: conversationId,
    );

    updateLocalConversation(conversation);
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatRoute.goBack();
      if (!IsmChatUtility.chatPageControllerRegistered) {
        IsmChatPageBinding().dependencies();
      }
      isRenderChatPageaScreen = IsRenderChatPageScreen.boradcastChatMessagePage;
      final chatPagecontroller = IsmChatUtility.chatPageController;
      chatPagecontroller.startInit(isBroadcasts: true);
      chatPagecontroller.closeOverlay();
    } else {
      IsmChatRoute.goToRoute(const IsmChatBoradcastMessagePage());
    }
  }
}
