part of '../chat_page_controller.dart';

mixin IsmChatPageVariablesMixin on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  var messageFocusNode = FocusNode();

  var mediaFocusNode = FocusNode();

  var chatInputController = TextEditingController();

  var groupTitleController = TextEditingController();

  var messagesScrollController = AutoScrollController();

  var searchMessageScrollController = ScrollController();

  final textEditingController = TextEditingController();

  final participnatsEditingController = TextEditingController();

  SnackbarController? snackBarController;

  var pageController = PageController();

  var noises = <int, Widget>{};
  var memoryImage = <int, MemoryImage>{};
  var globalKeys = <int, GlobalKey>{};

  final Rx<IsmChatConversationModel?> _conversation =
      Rx<IsmChatConversationModel?>(null);
  IsmChatConversationModel? get conversation => _conversation.value;
  set conversation(IsmChatConversationModel? value) =>
      _conversation.value = value;

  final RxBool _isMessageSent = false.obs;
  bool get isMessageSent => _isMessageSent.value;
  set isMessageSent(bool value) {
    _isMessageSent.value = value;
  }

  final RxBool _isRecordPlay = true.obs;
  bool get isRecordPlay => _isRecordPlay.value;
  set isRecordPlay(bool value) {
    _isRecordPlay.value = value;
  }

  final RxBool _showEmojiBoard = false.obs;
  bool get showEmojiBoard => _showEmojiBoard.value;
  set showEmojiBoard(bool value) => _showEmojiBoard.value = value;

  final RxBool _showAttachment = false.obs;
  bool get showAttachment => _showAttachment.value;
  set showAttachment(bool value) => _showAttachment.value = value;

  final RxBool _isMessagesLoading = true.obs;
  bool get isMessagesLoading => _isMessagesLoading.value;
  set isMessagesLoading(bool value) => _isMessagesLoading.value = value;

  final _messages = <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get messages => _messages;
  set messages(List<IsmChatMessageModel> value) => _messages.value = value;

  final _predictionList = <IsmChatPrediction>[].obs;
  List<IsmChatPrediction> get predictionList => _predictionList;
  set predictionList(List<IsmChatPrediction> value) =>
      _predictionList.value = value;

  final RxBool _isLocaionSearch = false.obs;
  bool get isLocaionSearch => _isLocaionSearch.value;
  set isLocaionSearch(bool value) => _isLocaionSearch.value = value;

  final RxBool _showSendButton = false.obs;
  bool get showSendButton => _showSendButton.value;
  set showSendButton(bool value) => _showSendButton.value = value;

  final RxBool _isreplying = false.obs;
  bool get isreplying => _isreplying.value;
  set isreplying(bool value) => _isreplying.value = value;

  final RxBool _isUpdateController = true.obs;
  bool get isUpdateController => _isUpdateController.value;
  set isUpdateController(bool value) => _isUpdateController.value = value;

  final RxBool _isMemberSearch = false.obs;
  bool get isMemberSearch => _isMemberSearch.value;
  set isMemberSearch(bool value) => _isMemberSearch.value = value;

  final Rx<IsmChatMessageModel?> _replayMessage =
      Rx<IsmChatMessageModel?>(null);
  IsmChatMessageModel? get replayMessage => _replayMessage.value;
  set replayMessage(IsmChatMessageModel? value) => _replayMessage.value = value;

  final RxBool _isSearchSelect = false.obs;
  bool get isSearchSelect => _isSearchSelect.value;
  set isSearchSelect(bool value) => _isSearchSelect.value = value;

  final RxList<UserDetails> _groupMembers = <UserDetails>[].obs;
  List<UserDetails> get groupMembers => _groupMembers;
  set groupMembers(List<UserDetails> value) => _groupMembers.value = value;

  final RxList<UserDetails> _readMessageMembers = <UserDetails>[].obs;
  List<UserDetails> get readMessageMembers => _readMessageMembers;
  set readMessageMembers(List<UserDetails> value) =>
      _readMessageMembers.value = value;

  final RxList<UserDetails> _deliverdMessageMembers = <UserDetails>[].obs;
  List<UserDetails> get deliverdMessageMembers => _deliverdMessageMembers;
  set deliverdMessageMembers(List<UserDetails> value) =>
      _deliverdMessageMembers.value = value;

  final RxList<UserDetails> _mentionSuggestions = <UserDetails>[].obs;
  List<UserDetails> get mentionSuggestions => _mentionSuggestions;
  set mentionSuggestions(List<UserDetails> value) =>
      _mentionSuggestions.value = value;

  final RxList<SelectedContact> _contactList = <SelectedContact>[].obs;
  List<SelectedContact> get contactList => _contactList;
  set contactList(List<SelectedContact> value) => _contactList.value = value;

  final RxList<SelectedContact> _contactSelectedList = <SelectedContact>[].obs;
  List<SelectedContact> get contactSelectedList => _contactSelectedList;
  set contactSelectedList(List<SelectedContact> value) =>
      _contactSelectedList.value = value;

  final RxList<SelectedContact> _searchContactList = <SelectedContact>[].obs;
  List<SelectedContact> get searchContactList => _searchContactList;
  set searchContactList(List<SelectedContact> value) =>
      _searchContactList.value = value;

  CameraController get cameraController =>
      isFrontCameraSelected ? _frontCameraController : _backCameraController;

  final RxBool _areCamerasInitialized = false.obs;
  bool get areCamerasInitialized => _areCamerasInitialized.value;
  set areCamerasInitialized(bool value) => _areCamerasInitialized.value = value;

  final RxBool _isFrontCameraSelected = false.obs;
  bool get isFrontCameraSelected => _isFrontCameraSelected.value;
  set isFrontCameraSelected(bool value) => _isFrontCameraSelected.value = value;

  final RxBool _isRecording = false.obs;
  bool get isRecording => _isRecording.value;
  set isRecording(bool value) => _isRecording.value = value;

  final Rx<FlashMode> _flashMode = Rx<FlashMode>(FlashMode.auto);
  FlashMode get flashMode => _flashMode.value;
  set flashMode(FlashMode value) => _flashMode.value = value;

  final RxString _backgroundImage = ''.obs;
  String get backgroundImage => _backgroundImage.value;
  set backgroundImage(String value) => _backgroundImage.value = value;

  final RxString _backgroundColor = ''.obs;
  String get backgroundColor => _backgroundColor.value;
  set backgroundColor(String value) => _backgroundColor.value = value;

  final RxInt _assetsIndex = 0.obs;
  int get assetsIndex => _assetsIndex.value;
  set assetsIndex(int value) => _assetsIndex.value = value;

  final RxBool _isEnableRecordingAudio = false.obs;
  bool get isEnableRecordingAudio => _isEnableRecordingAudio.value;
  set isEnableRecordingAudio(bool value) =>
      _isEnableRecordingAudio.value = value;

  final RxInt _seconds = 0.obs;
  int get seconds => _seconds.value;
  set seconds(int value) => _seconds.value = value;

  final Rx<Duration> _myDuration = const Duration().obs;
  Duration get myDuration => _myDuration.value;
  set myDuration(Duration value) => _myDuration.value = value;

  final RxBool _isTyping = true.obs;
  bool get isTyping => _isTyping.value;
  set isTyping(bool value) => _isTyping.value = value;

  final RxBool _showDownSideButton = false.obs;
  bool get showDownSideButton => _showDownSideButton.value;
  set showDownSideButton(bool value) => _showDownSideButton.value = value;

  final RxBool _showMentionUserList = false.obs;
  bool get showMentionUserList => _showMentionUserList.value;
  set showMentionUserList(bool value) => _showMentionUserList.value = value;

  /// Keep track of all the auto scroll indices by their respective message's id to allow animating to them.
  final _autoScrollIndexById = <String, int>{}.obs;
  Map<String, int> get indexedMessageList => _autoScrollIndexById;
  set indexedMessageList(Map<String, int> value) =>
      _autoScrollIndexById.value = value;

  final RxBool _isMessageSeleted = false.obs;
  bool get isMessageSeleted => _isMessageSeleted.value;
  set isMessageSeleted(bool value) => _isMessageSeleted.value = value;

  final _selectedMessage = <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get selectedMessage => _selectedMessage;
  set selectedMessage(List<IsmChatMessageModel> value) =>
      _selectedMessage.value = value;

  List<IsmChatBottomSheetAttachmentModel> attachments = [
    const IsmChatBottomSheetAttachmentModel(
      label: 'Camera',
      backgroundColor: Colors.blueAccent,
      icon: Icons.camera_alt_rounded,
      attachmentType: IsmChatAttachmentType.camera,
    ),
    const IsmChatBottomSheetAttachmentModel(
      label: 'Gallery',
      backgroundColor: Colors.purpleAccent,
      icon: Icons.photo_rounded,
      attachmentType: IsmChatAttachmentType.gallery,
    ),
    const IsmChatBottomSheetAttachmentModel(
      label: 'Documents',
      backgroundColor: Colors.pinkAccent,
      icon: Icons.description_rounded,
      attachmentType: IsmChatAttachmentType.document,
    ),
    const IsmChatBottomSheetAttachmentModel(
      label: 'Location',
      backgroundColor: Colors.greenAccent,
      icon: Icons.location_on_rounded,
      attachmentType: IsmChatAttachmentType.location,
    ),
    const IsmChatBottomSheetAttachmentModel(
      label: 'Contact',
      backgroundColor: Colors.orangeAccent,
      icon: Icons.person_outlined,
      attachmentType: IsmChatAttachmentType.contact,
    ),
  ];

  final RxBool _canCallCurrentApi = false.obs;
  bool get canCallCurrentApi => _canCallCurrentApi.value;
  set canCallCurrentApi(bool value) => _canCallCurrentApi.value = value;

  final _groupEligibleUser = <SelectedMembers>[].obs;
  List<SelectedMembers> get groupEligibleUser => _groupEligibleUser;
  set groupEligibleUser(List<SelectedMembers> value) =>
      _groupEligibleUser.value = value;

  final _userReactionList = <UserDetails>[].obs;
  List<UserDetails> get userReactionList => _userReactionList;
  set userReactionList(List<UserDetails> value) =>
      _userReactionList.value = value;

  final RxBool _isVideoVisible = true.obs;
  bool get isVideoVisible => _isVideoVisible.value;
  set isVideoVisible(bool value) => _isVideoVisible.value = value;

  final RxBool _isCameraView = false.obs;
  bool get isCameraView => _isCameraView.value;
  set isCameraView(bool value) => _isCameraView.value = value;

  final RxBool _isActionAllowed = false.obs;
  bool get isActionAllowed => _isActionAllowed.value;
  set isActionAllowed(bool value) => _isActionAllowed.value = value;

  final RxBool _isCoverationApiDetails = true.obs;
  bool get isCoverationApiDetails => _isCoverationApiDetails.value;
  set isCoverationApiDetails(bool value) =>
      _isCoverationApiDetails.value = value;

  final RxList<WebMediaModel> _webMedia = <WebMediaModel>[].obs;
  RxList<WebMediaModel> get webMedia => _webMedia;
  set webMedia(List<WebMediaModel> value) => _webMedia.value = value;

  final Rx<OverlayEntry?> _attchmentOverlayEntry = Rx<OverlayEntry?>(null);
  OverlayEntry? get attchmentOverlayEntry => _attchmentOverlayEntry.value;
  set attchmentOverlayEntry(OverlayEntry? value) =>
      _attchmentOverlayEntry.value = value;

  final Rx<OverlayEntry?> _messageHoldOverlayEntry = Rx<OverlayEntry?>(null);
  OverlayEntry? get messageHoldOverlayEntry => _messageHoldOverlayEntry.value;
  set messageHoldOverlayEntry(OverlayEntry? value) =>
      _messageHoldOverlayEntry.value = value;

  final RxInt _onMessageHoverIndex = 0.obs;
  int get onMessageHoverIndex => _onMessageHoverIndex.value;
  set onMessageHoverIndex(int value) => _onMessageHoverIndex.value = value;

  final Rx<AnimationController?> _fabAnimationController =
      Rx<AnimationController?>(null);
  AnimationController? get fabAnimationController =>
      _fabAnimationController.value;
  set fabAnimationController(AnimationController? value) =>
      _fabAnimationController.value = value;

  final RxBool _isLoadingContact = false.obs;
  bool get isLoadingContact => _isLoadingContact.value;
  set isLoadingContact(bool value) => _isLoadingContact.value = value;

  final RxString _audioPaht = ''.obs;
  String get audioPaht => _audioPaht.value;
  set audioPaht(String value) => _audioPaht.value = value;

  final _searchMessages = <IsmChatMessageModel>[].obs;
  List<IsmChatMessageModel> get searchMessages => _searchMessages;
  set searchMessages(List<IsmChatMessageModel> value) =>
      _searchMessages.value = value;

  final RxBool _isBroadcast = false.obs;
  bool get isBroadcast => _isBroadcast.value;
  set isBroadcast(bool value) => _isBroadcast.value = value;

  final RxInt _mediaDownloadProgress = 0.obs;
  int get mediaDownloadProgress => _mediaDownloadProgress.value;
  set mediaDownloadProgress(int value) {
    _mediaDownloadProgress.value = value;
  }

  late AudioRecorder recordVoice;

  var _cameras = <CameraDescription>[];

  late CameraController _frontCameraController;

  late CameraController _backCameraController;

  LayerLink messageHoldLink = LayerLink();

  Timer? conversationDetailsApTimer;

  Timer? forRecordTimer;

  List<SelectedMembers> groupEligibleUserDuplicate = [];

  List<MentionModel> userMentionedList = [];

  List<Emoji> reactions = [];

  bool didReactedLast = false;

  final Dio dio = Dio();

  final ismChatDebounce = IsmChatDebounce();

  AnimationController? holdController;

  Animation<double>? holdAnimation;

  UserDetails? currentUser;

  bool get hasOverlay =>
      messageHoldOverlayEntry != null || attchmentOverlayEntry != null;
}
