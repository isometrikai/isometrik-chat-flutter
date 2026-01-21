part of '../chat_conversations_controller.dart';

/// Variables mixin for IsmChatConversationsController.
///
/// This mixin contains all observable variables, controllers, and state variables
/// used by the conversations controller. All variables are directly accessible
/// by other mixins since they're all part of the same class.
mixin IsmChatConversationsVariablesMixin on GetxController {
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

  /// This variable tracks if background loading of all contacts is in progress
  final RxBool _isLoadingAllContacts = false.obs;
  bool get isLoadingAllContacts => _isLoadingAllContacts.value;
  set isLoadingAllContacts(bool value) => _isLoadingAllContacts.value = value;

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
  ///
  /// Note: This subscription is cancelled in the controller's dispose lifecycle method.
  // ignore: cancel_subscriptions
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

  /// List of device fetch contacts...
  List<ContactSyncModel> sendContactSync = [];

  /// use for fast access the name through number
  Map<String, String> hashMapSendContactSync = {};

  /// get the contact after filter contacts those registered or not registered basis on (isRegisteredUser)...
  List<ContactSyncModel> getContactSyncUser = [];
}
