import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmChatConversationsController extends GetxController {
  IsmChatConversationsController(this._viewModel);
  final IsmChatConversationsViewModel _viewModel;

  /// This variable use for type group name of group chat
  TextEditingController addGrouNameController = TextEditingController();

  /// This variable use for type user name for searcing feature
  TextEditingController userSearchNameController = TextEditingController();

  /// This variable use for type global for searcing feature
  TextEditingController globalSearchController = TextEditingController();

  /// This variable use for store login user name
  TextEditingController userNameController = TextEditingController();

  /// This variable use for store login user email
  TextEditingController userEmailController = TextEditingController();

  /// This variable use for get all method and varibles from IsmChatCommonController
  IsmChatCommonController get _commonController =>
      Get.find<IsmChatCommonController>();

  // /// This variable use for get all method and varibles from IsmChatDeviceConfig
  // final _deviceConfig = Get.find<IsmChatDeviceConfig>();

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

  /// This variable use for store filete conversation list
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

  /// This variable use for store user messages which is get from local db
  final _userMeessages = <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get userMeessages => _userMeessages;
  set userMeessages(List<IsmChatMessageModel> value) =>
      _userMeessages.value = value;

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

  final _forwardedListSkip = <SelectedMembers>[].obs;
  List<SelectedMembers> get forwardedListSkip => _forwardedListSkip;
  set forwardedListSkip(List<SelectedMembers> value) {
    _forwardedList.value = value;
  }

  final RxBool _intilizedContrller = false.obs;
  bool get intilizedContrller => _intilizedContrller.value;
  set intilizedContrller(bool value) {
    _intilizedContrller.value = value;
  }

  @override
  onInit() async {
    super.onInit();
    intilizedContrller = false;
    _isInterNetConnect();
    await _generateReactionList();
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
      await Get.find<IsmChatMqttController>().getChatConversationsUnreadCount();
    }
    await getBackGroundAssets();
    await getUserMessges(
      senderIds: [
        IsmChatConfig.communicationConfig.userConfig.userId.isNotEmpty
            ? IsmChatConfig.communicationConfig.userConfig.userId
            : userDetails?.userId ?? ''
      ],
    );
    intilizedContrller = true;
    scrollListener();
    sendPendingMessgae();
  }

  @override
  void onClose() {
    onDispose();
    super.onClose();
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void onDispose() {
    conversationScrollController.dispose();
    searchConversationScrollController.dispose();
    connectivitySubscription?.cancel();
  }

  void _isInterNetConnect() {
    connectivity = Connectivity();
    connectivitySubscription =
        connectivity?.onConnectivityChanged.listen((event) {
      _sendPendingMessage();
    });
  }

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
        );
      case IsRenderConversationScreen.createConverstaionView:
        return IsmChatCreateConversationView();
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

  Widget isRenderChatScreenWidget() {
    switch (isRenderChatPageaScreen) {
      case IsRenderChatPageScreen.coversationInfoView:
        return IsmChatConverstaionInfoView();
      case IsRenderChatPageScreen.wallpaperView:
        break;
      case IsRenderChatPageScreen.messgaeInfoView:
        return IsmChatMessageInfo(
          isGroup: currentConversation?.isGroup,
          message: message,
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
          conversationId: userConversationId,
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
        return IsmChatProperties.conversationProperties.thirdColumnWidget
                ?.call(Get.context!, currentConversation!) ??
            const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Future<AssetsModel?> getAssetFilesList() async {
    var jsonString = await rootBundle.loadString(
        'packages/isometrik_flutter_chat/assets/assets_backgroundAssets.json');
    var filesList = jsonDecode(jsonString);
    if (filesList != null) {
      return AssetsModel.fromMap(filesList);
    }
    return null;
  }

  Future<void> getBackGroundAssets() async {
    var assets = await getAssetFilesList();
    if (assets != null) {
      backgroundImage = assets.images;
      backgroundColor = assets.colors;
    }
  }

  Future<void> _generateReactionList() async {
    reactions = await Future.wait(
      IsmChatEmoji.values.map(
        (e) async => (await EmojiPickerUtils()
                .searchEmoji(e.emojiKeyword, defaultEmojiSet))
            .first,
      ),
    );
  }

  /// This function will be used in [Forward Screen and New conversation screen] to Select or Unselect users
  void onForwardUserTap(int index) {
    forwardedList[index].isUserSelected = !forwardedList[index].isUserSelected;
  }

  /// This function will be used in [Forward Screen and New conversation screen] to Select users
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

  /// api to unblock user
  Future<bool> unblockUser({
    required String opponentId,
    required bool isLoading,
    bool fromUser = false,
  }) async {
    var data = await _viewModel.unblockUser(
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

  void unblockUserForWeb(String opponentId) {
    if (Get.isRegistered<IsmChatPageController>()) {
      var conversationId = getConversationId(opponentId);
      final chatPageController = Get.find<IsmChatPageController>();
      if (conversationId == chatPageController.conversation?.conversationId) {
        chatPageController.unblockUser(
          opponentId: opponentId,
          includeMembers: true,
          isLoading: false,
          userBlockOrNot: true,
        );
      }
    }
  }

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

  /// function to pick image for group profile
  Future<void> ismChangeImage(ImageSource imageSource) async {
    var file = await IsmChatUtility.pickMedia(imageSource);
    if (file.isEmpty) {
      return;
    }
    var bytes = await file.first?.readAsBytes();
    var fileExtension = file.first?.path.split('.').last;
    await getPresignedUrl(fileExtension!, bytes!);
  }

  // / get Api for presigned Url.....
  Future<String> getPresignedUrl(
    String mediaExtension,
    Uint8List bytes, [
    bool isLoading = false,
  ]) async {
    var response = await _commonController.getPresignedUrl(
        isLoading: true,
        userIdentifier: userDetails?.userIdentifier ?? '',
        mediaExtension: mediaExtension,
        bytes: bytes);

    if (response == null) {
      return '';
    }
    var responseCode = await _commonController.updatePresignedUrl(
      presignedUrl: response.presignedUrl,
      bytes: bytes,
      isLoading: isLoading,
    );
    if (responseCode == 200) {
      profileImage = response.mediaUrl ?? '';
    }
    return profileImage;
  }

  /// This will be used to fetch all the users associated with the current user
  ///
  /// Will be used for Create chat and/or Forward message
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
    var response = await _viewModel.getNonBlockUserList(
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

    var users = response?.users ?? [];
    if (users.isEmpty) {
      isLoadResponse = true;
    }
    users.sort((a, b) => a.userName.compareTo(b.userName));

    if (opponentId != null) {
      users.removeWhere((e) => e.userId == opponentId);
    }

    if (IsmChatConfig.communicationConfig.userConfig.accessToken != null) {
      users.removeWhere((element) =>
          !RegExp('[A-Z]').hasMatch(element.userName[0].toUpperCase()));
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
      handleList(forwardedList);
    }

    if (response == null && searchTag.isEmpty && isGroupConversation == false) {
      unawaited(getContacts(isLoading: isLoading, searchTag: searchTag));
      callApiOrNot = true;
      return forwardedList;
    }
    callApiOrNot = true;
    return forwardedList;
  }

  void handleList(List<SelectedMembers> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      var tag = list[i].userDetails.userName[0].toUpperCase();
      var isLocal = list[i].localContacts ?? false;
      if (RegExp('[A-Z]').hasMatch(tag) && isLocal == false) {
        list[i].tagIndex = tag;
      } else {
        if (isLocal == true) {
          list[i].tagIndex = '#';
        }
      }
    }

    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(forwardedList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(forwardedList);
  }

  Future<void> clearAllMessages(String? conversationId,
      {bool fromServer = true}) async {
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }
    return _viewModel.clearAllMessages(conversationId, fromServer: fromServer);
  }

  void navigateToMessages(IsmChatConversationModel conversation) {
    currentConversation = conversation;
    currentConversationId = conversation.conversationId ?? '';
  }

  Future<void> deleteChat(
    String? conversationId, {
    bool deleteFromServer = true,
  }) async {
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }
    if (deleteFromServer) {
      var response = await _viewModel.deleteChat(conversationId);
      if (response?.hasError ?? true) {
        return;
      }
    }
    await IsmChatConfig.dbWrapper?.removeConversation(conversationId);
    await getConversationsFromDB();
    if (deleteFromServer) {
      await getChatConversations();
    }
  }

  Future<void> getConversationsFromDB() async {
    var dbConversations = await IsmChatConfig.dbWrapper!.getAllConversations();

    if (dbConversations.isEmpty == true) {
      conversations.clear();
      return;
    }
    conversations.clear();
    conversations = dbConversations;
    isConversationsLoading = false;
    if (conversations.length <= 1) {
      return;
    }
    conversations.sort((a, b) => (b.lastMessageDetails?.sentAt ?? 0)
        .compareTo(a.lastMessageDetails?.sentAt ?? 0));
  }

  String getConversationId(String userId) {
    var conversation = conversations.firstWhere(
        (element) => element.opponentDetails?.userId == userId,
        orElse: IsmChatConversationModel.new);

    if (conversation.conversationId == null) {
      return '';
    }
    return conversation.conversationId!;
  }

  Future<void> getChatConversations(
      {int skip = 0, ApiCallOrigin? origin, int chatLimit = 20}) async {
    if (conversations.isEmpty) {
      isConversationsLoading = true;
    }

    var chats = await _viewModel.getChatConversations(
      skip,
      chatLimit: chatLimit,
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
              await IsmChatConfig.dbWrapper!.createAndUpdateConversation(e),
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
      refreshController.loadComplete();
      refreshControllerOnEmptyList.loadComplete();
    }

    await getConversationsFromDB();
    if (conversations.isEmpty) {
      isConversationsLoading = false;
    }
  }

  Future<void> getChatSearchConversations({
    int skip = 0,
    ApiCallOrigin? origin,
    int chatLimit = 20,
  }) async {
    if (searchConversationList.isEmpty) {
      isConversationsLoading = true;
    }

    var response = await _viewModel.getChatConversations(
      skip,
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

  Future<void> getBlockUser({bool isLoading = false}) async {
    var users = await _viewModel.getBlockUser(
      skip: 0,
      limit: 20,
      isLoading: isLoading,
    );
    if (users != null) {
      blockUsers = users.users;
    } else {
      blockUsers = [];
    }
  }

  Future<void> getUserData({bool isLoading = false}) async {
    var user = await _viewModel.getUserData(isLoading: isLoading);
    if (user != null) {
      userDetails = user;
      if (!kIsWeb) {
        if (userDetails?.metaData?.assetList?.isNotEmpty == true) {
          final assetList = userDetails?.metaData?.assetList?.toList() ?? [];
          final indexOfAsset = assetList
              .indexWhere((e) => e.values.first.srNoBackgroundAssset == 100);
          if (indexOfAsset != -1) {
            final pathName =
                assetList[indexOfAsset].values.first.imageUrl!.split('/').last;
            var filePath = await IsmChatUtility.makeDirectoryWithUrl(
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
          .put(IsmChatStrings.userData, userDetails!.toJson());
    }
  }

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

  /// This will call an API that will notify the sender that the message has been delivered to me using mqtt
  Future<void> pingMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async {
    await _viewModel.pingMessageDelivered(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  Future<void> updateConversation({
    required String conversationId,
    required IsmChatMetaData metaData,
    bool isLoading = false,
  }) async {
    var response = await _viewModel.updateConversation(
      conversationId: conversationId,
      metaData: metaData,
      isLoading: isLoading,
    );
    if (!response!.hasError) {
      await getChatConversations();
    }
  }

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

  Future<void> sendForwardMessage({
    required List<String> userIds,
    required String body,
    List<Map<String, dynamic>>? attachments,
    String? customType,
    bool isLoading = false,
    IsmChatMetaData? metaData,
  }) async {
    var response = await _viewModel.sendForwardMessage(
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
      Get.back();
      await getChatConversations();
    }
  }

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

  Future<void> getPublicAndOpenConversation({
    required int conversationType,
    String? searchTag,
    int sort = 1,
    int skip = 0,
    int limit = 20,
  }) async {
    if (!callApiOrNot) return;
    callApiOrNot = false;
    var response = await _viewModel.getPublicAndOpenConversation(
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

  Future<void> joinConversation({
    required String conversationId,
    bool isloading = false,
  }) async {
    var response = await _viewModel.joinConversation(
        conversationId: conversationId, isLoading: isloading);
    if (response != null) {
      Get.back();
      await getChatConversations();
    }
  }

  Future<IsmChatResponseModel?> joinObserver(
          {required String conversationId, bool isLoading = false}) async =>
      await _viewModel.joinObserver(
          conversationId: conversationId, isLoading: isLoading);

  Future<void> leaveObserver(
      {required String conversationId, bool isLoading = false}) async {
    var response = await _viewModel.leaveObserver(
        conversationId: conversationId, isLoading: isLoading);
    if (response != null) {}
  }

  Future<void> goToChatPage() async {
    if (IsmChatResponsive.isWeb(Get.context!)) {
      if (!Get.isRegistered<IsmChatPageController>()) {
        IsmChatPageBinding().dependencies();
        return;
      }
      isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      final chatPagecontroller = Get.find<IsmChatPageController>();
      chatPagecontroller.startInit();
      chatPagecontroller.closeOverlay();
    } else {
      IsmChatRouteManagement.goToChatPage();
    }
  }

  Future<List<UserDetails>> getObservationUser({
    required String conversationId,
    int skip = 0,
    int limit = 20,
    bool isLoading = false,
    String? searchText,
  }) async {
    var res = await _viewModel.getObservationUser(
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

  void sendPendingMessgae({String conversationId = ''}) async {
    List<IsmChatMessageModel>? messages = [];
    if (conversationId.isEmpty) {
      var pendingMessages =
          await IsmChatConfig.dbWrapper!.getAllPendingMessages();

      messages.addAll(pendingMessages);
    } else {
      messages = await IsmChatConfig.dbWrapper!
          .getMessage(conversationId, IsmChatDbBox.pending);
    }
    if (messages?.isEmpty ?? false || messages == null) {
      return;
    }
    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            userDetails?.userName ??
            '';
    for (var x in messages!) {
      List<Map<String, dynamic>>? attachments;
      if ([
        IsmChatCustomMessageType.image,
        IsmChatCustomMessageType.audio,
        IsmChatCustomMessageType.video,
        IsmChatCustomMessageType.file
      ].contains(x.customType)) {
        var attachment = x.attachments?.first;
        var bytes = File(attachment?.mediaUrl ?? '').readAsBytesSync();
        PresignedUrlModel? presignedUrlModel;
        presignedUrlModel = await _commonController.postMediaUrl(
          conversationId: x.conversationId ?? '',
          nameWithExtension: attachment?.name ?? '',
          mediaType: attachment?.attachmentType?.value ?? 0,
          mediaId: attachment?.mediaId ?? '',
          isLoading: false,
          bytes: bytes,
        );

        var mediaUrlPath = '';
        if (presignedUrlModel != null) {
          var response = await _commonController.updatePresignedUrl(
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
          var nameWithExtension = attachment?.thumbnailUrl?.split('/').last;
          var bytes = File(attachment?.thumbnailUrl ?? '').readAsBytesSync();
          presignedUrlModel = await _commonController.postMediaUrl(
            conversationId: x.conversationId ?? '',
            nameWithExtension: nameWithExtension ?? '',
            mediaType: 0,
            mediaId: DateTime.now().millisecondsSinceEpoch.toString(),
            isLoading: false,
            bytes: bytes,
          );
          if (presignedUrlModel != null) {
            var response = await _commonController.updatePresignedUrl(
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
      var isMessageSent = await _commonController.sendMessage(
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
        isBroadcast: Get.isRegistered<IsmChatPageController>()
            ? Get.find<IsmChatPageController>().isBroadcast
            : false,
      );
      if (isMessageSent && Get.isRegistered<IsmChatPageController>()) {
        final controller = Get.find<IsmChatPageController>();
        if (!controller.isBroadcast) {
          controller.didReactedLast = false;
          await controller.getMessagesFromDB(conversationId);
        }
      } else if (isMessageSent) {
        await getChatConversations();
      }
    }
  }

  Future<void> getUserMessges({
    List<String>? ids,
    List<String>? messageTypes,
    List<String>? customTypes,
    List<String>? attachmentTypes,
    String? showInConversation,
    List<String>? senderIds,
    String? parentMessageId,
    int? lastMessageTimestamp,
    bool? conversationStatusMessage,
    String? searchTag,
    String? fetchConversationDetails,
    bool deliveredToMe = false,
    bool senderIdsExclusive = true,
    int limit = 20,
    int? skip = 0,
    int? sort = -1,
    bool isLoading = false,
  }) async {
    var response = await _viewModel.getUserMessges(
      attachmentTypes: attachmentTypes,
      conversationStatusMessage: conversationStatusMessage,
      customTypes: customTypes,
      deliveredToMe: deliveredToMe,
      fetchConversationDetails: fetchConversationDetails,
      ids: ids,
      lastMessageTimestamp: lastMessageTimestamp,
      limit: limit,
      messageTypes: messageTypes,
      parentMessageId: parentMessageId,
      searchTag: searchTag,
      senderIds: senderIds,
      senderIdsExclusive: senderIdsExclusive,
      showInConversation: showInConversation,
      skip: skip,
      sort: sort,
      isLoading: isLoading,
    );
    if (response != null) {
      userMeessages = response.reversed.toList();
      for (var message in userMeessages) {
        var isSender =
            message.deliveredTo?.any((e) => e.userId == senderIds?.first);
        if (isSender == false) {
          await Future.delayed(
            const Duration(milliseconds: 100),
          );
          await pingMessageDelivered(
            conversationId: message.conversationId ?? '',
            messageId: message.messageId ?? '',
          );
        }
      }
    }
  }

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

  void updateUserDetails(ImageSource source) async {
    Get.back();
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

  /// Ask permission for contacts
  Future<void> askPermissions() async {
    if (await IsmChatUtility.requestPermission(Permission.contacts)) {
      fillContact();
    }
  }

  /// List of device fetch contacts...
  List<ContactSyncModel> sendContactSync = [];

  /// use for fast access the name through number
  Map<String, String> hashMapSendContactSync = {};

  /// get and fill the contact in useable model..
  void fillContact() async {
    final localList = [];
    var contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
    hashMapSendContactSync.clear();
    for (var x in contacts) {
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

  /// to get the contacts..
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
        var forwardedListLocalList = <SelectedMembers>[];
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
      handleList(forwardedList);
      update();
    }
  }

  /// get search based user for local contacts..
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
    handleList(forwardedList);
  }

  void goToContactSync() async {
    // await askPermissions();
    await Future.delayed(Durations.extralong1);
    IsmChatRouteManagement.goToCreateChat(
      isGroupConversation: false,
    );
  }

  /// Use the funciton for the delete the user of local contacts from DB...
  Future<void> removeDBUser() async {
    forwardedList.removeWhere((element) => element.localContacts == true);
  }

  /// for upload and get the filter Users...
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

  Future<void> replayOnStories({
    required String conversationId,
    required UserDetails userDetails,
    String? storyMediaUrl,
    String? caption,
    bool sendPushNotification = false,
  }) async {
    final chatConversationResponse = await IsmChatConfig.dbWrapper!
        .getConversation(conversationId: conversationId);
    if (chatConversationResponse == null) {
      final conversation = await _commonController.createConversation(
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
    var sentAt = DateTime.now().millisecondsSinceEpoch;
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

    var notificationTitle =
        IsmChatConfig.communicationConfig.userConfig.userName ??
            userDetails.userName;
    await _commonController.sendMessage(
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

  void goToBroadcastMessage(List<UserDetails> members, String conversationId) {
    var conversation = IsmChatConversationModel(
      members: members,
      conversationImageUrl: IsmChatAssets.noImage,
      customType: IsmChatStrings.broadcast,
      conversationId: conversationId,
    );

    navigateToMessages(conversation);
    if (IsmChatResponsive.isWeb(Get.context!)) {
      Get.back();
      if (!Get.isRegistered<IsmChatPageController>()) {
        IsmChatPageBinding().dependencies();
      }
      isRenderChatPageaScreen = IsRenderChatPageScreen.boradcastChatMessagePage;
      final chatPagecontroller = Get.find<IsmChatPageController>();
      chatPagecontroller.startInit(isBroadcasts: true);
      chatPagecontroller.closeOverlay();
    } else {
      IsmChatRouteManagement.goToBroadcastMessagePage(
        isBroadcast: true,
      );
    }
  }
}
