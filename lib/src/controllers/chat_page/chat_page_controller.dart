import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
import 'package:isometrik_chat_flutter/src/views/chat_page/widget/profile_change.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_compress/video_compress.dart';

part './mixins/get_message.dart';
part './mixins/group_admin.dart';
part './mixins/send_message.dart';
part './mixins/show_dialog.dart';
part './mixins/taps_controller.dart';
part './mixins/variables.dart';

/// A GetxController that provides common functionality for Isometrik Chat Flutter.
class IsmChatPageController extends GetxController
    with
        IsmChatPageSendMessageMixin,
        IsmChatPageGetMessageMixin,
        IsmChatGroupAdminMixin,
        IsmChatShowDialogMixin,
        IsmChatTapsController,
        GetTickerProviderStateMixin,
        IsmChatPageVariablesMixin {
  IsmChatPageController(this.viewModel);
  final IsmChatPageViewModel viewModel;

  IsmChatConversationsController get conversationController =>
      IsmChatUtility.conversationController;

  IsmChatCommonController get commonController =>
      Get.find<IsmChatCommonController>();

  Widget getNoise(int sentAt, [bool sentByMe = true]) {
    if (!noises.keys.contains(sentAt)) {
      var color = sentByMe ? Colors.white : Colors.grey;
      var noiseList = List.generate(27, (index) => $SingleNoise(color: color));
      var noise = Noises(noises: noiseList);
      noises[sentAt] = noise;
    }
    return noises[sentAt]!;
  }

  GlobalKey getGlobalKey(int sentAt) {
    if (!globalKeys.keys.contains(sentAt)) {
      globalKeys[sentAt] = GlobalKey();
    }
    return globalKeys[sentAt]!;
  }

  MemoryImage getMemoryImage(int sentAt, Uint8List bytes) {
    if (!memoryImage.keys.contains(sentAt)) {
      memoryImage[sentAt] = MemoryImage(bytes);
    }
    return memoryImage[sentAt] ?? MemoryImage(Uint8List(0));
  }

  bool get controllerIsRegister => IsmChatUtility.chatPageControllerRegistered;

  List<Map<String, List<IsmChatMessageModel>>> sortMediaList(
      List<IsmChatMessageModel> messages) {
    var storeMediaImageList = <Map<String, List<IsmChatMessageModel>>>[];
    for (var x in messages) {
      if (x.customType == IsmChatCustomMessageType.date) {
        storeMediaImageList.add({x.body: <IsmChatMessageModel>[]});
        continue;
      }
      var z = storeMediaImageList.last;
      z.forEach((key, value) {
        value.add(x);
      });
    }
    return storeMediaImageList;
  }

  @override
  void onInit() {
    super.onInit();
    startInit();
  }

  void startInit({
    bool isBroadcasts = false,
  }) async {
    chatInputController.clear();
    recordVoice = AudioRecorder();
    isActionAllowed = false;
    _generateReactionList();
    _startAnimated();
    _scrollListener();
    _intputAndFocustNode();

    if (conversationController.currentConversation != null) {
      _currentUser();
      conversation = conversationController.currentConversation;
      await Future.delayed(Duration.zero);
      try {
        final arguments = Get.arguments as Map<String, dynamic>? ?? {};
        isBroadcast = arguments['isBroadcast'] as bool? ?? isBroadcasts;
      } catch (_) {}

      if (conversation?.conversationId?.isNotEmpty == true) {
        await callFunctionsWithConversationId(
          conversation?.conversationId ?? '',
        );
      } else {
        await callFunctions();
      }
      await sendWithOutSideMessage();
      unawaited(updateUnreadMessgaeCount());
    }
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    if (areCamerasInitialized) {
      try {
        _frontCameraController.dispose();
        _backCameraController.dispose();
        cameraController.dispose();
      } catch (_) {}
    }
    conversationDetailsApTimer?.cancel();
    messagesScrollController.dispose();
    searchMessageScrollController.dispose();
    attchmentOverlayEntry?.dispose();
    messageHoldOverlayEntry?.dispose();
    attchmentOverlayEntry?.dispose();
    fabAnimationController?.dispose();
    holdController?.dispose();
    ifTimerMounted();
  }

  _currentUser() {
    currentUser = UserDetails(
      userProfileImageUrl:
          IsmChatConfig.communicationConfig.userConfig.userProfile ?? '',
      userName: IsmChatConfig.communicationConfig.userConfig.userName ?? '',
      userIdentifier:
          IsmChatConfig.communicationConfig.userConfig.userEmail ?? '',
      userId: IsmChatConfig.communicationConfig.userConfig.userId,
      online: false,
      lastSeen: 0,
    );
  }

  _generateReactionList() async {
    reactions.clear();
    reactions.addAll(IsmChatEmoji.values
        .expand((typesOfEmoji) => defaultEmojiSet.expand((categoryEmoji) =>
            categoryEmoji.emoji
                .where((emoji) => typesOfEmoji.emojiKeyword == emoji.name)))
        .toList());
  }

  _getBackGroundAsset() {
    final assets =
        conversationController.userDetails?.metaData?.assetList ?? [];
    final asset = assets
        .where((e) => e.keys.contains(conversation?.conversationId))
        .toList();
    if (asset.isNotEmpty) {
      backgroundColor = asset.first.values.first.color!;
      backgroundImage = asset.first.values.first.imageUrl!;
    } else {
      backgroundColor = '';
      backgroundImage =
          IsmChatProperties.chatPageProperties.backgroundImageUrl ?? '';
    }
  }

  Future<void> callFunctionsWithConversationId(String conversationId) async {
    _getBackGroundAsset();
    if (!isBroadcast) {
      await getMessagesFromDB(conversationId);
      await getConverstaionDetails();
      await getMessageForStatus();
      await getMessagesFromAPI();
      await readAllMessages();
      checkUserStatus();
    } else {
      await getBroadcastMessages(isBroadcast: isBroadcast);
      isMessagesLoading = false;
    }
  }

  Future<void> callFunctions() async {
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      messages.clear();
    }
    if (conversation?.isGroup ?? false) {
      conversation = await commonController.createConversation(
        conversation: conversation!,
        conversationType:
            conversation?.conversationType ?? IsmChatConversationType.private,
        userId: [],
        isGroup: true,
        searchableTags: [
          IsmChatConfig.communicationConfig.userConfig.userName ??
              conversationController.userDetails?.userName ??
              '',
          conversation?.chatName ?? ''
        ],
      );

      await getConverstaionDetails();
      await getMessagesFromAPI();
      checkUserStatus();
    } else {
      if (messages.isEmpty) {
        messages.add(
          IsmChatMessageModel(
            body: '',
            customType: IsmChatCustomMessageType.conversationCreated,
            sentAt: DateTime.now().millisecondsSinceEpoch,
            sentByMe: true,
          ),
        );
        messages =
            _controller.commonController.sortMessages(filterMessages(messages));
      }
    }
    isMessagesLoading = false;
  }

  Future<void> sendWithOutSideMessage() async {
    if (conversation?.outSideMessage != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (conversation?.outSideMessage?.aboutText != null) {
        sendAboutTextMessage(
          conversationId: conversation?.conversationId ?? '',
          userId: conversation?.opponentDetails?.userId ?? '',
          outSideMessage: conversation?.outSideMessage,
          pushNotifications: conversation?.pushNotifications ?? true,
        );
      } else if (!(conversation?.outSideMessage?.imageUrl.isNullOrEmpty ==
          true)) {
        await sendMessageWithImageUrl(
          conversationId: conversation?.conversationId ?? '',
          userId: conversation?.opponentDetails?.userId ?? '',
          caption: conversation?.outSideMessage?.caption,
          imageUrl: conversation?.outSideMessage?.imageUrl ?? '',
        );
      } else if (!(conversation
              ?.outSideMessage?.messageFromOutSide.isNullOrEmpty ==
          true)) {
        chatInputController.text =
            conversation?.outSideMessage?.messageFromOutSide ?? '';
        if (chatInputController.text.isNotEmpty) {
          sendTextMessage(
            conversationId: conversation?.conversationId ?? '',
            userId: conversation?.opponentDetails?.userId ?? '',
            pushNotifications: conversation?.pushNotifications ?? true,
          );
        }
      }
    }
  }

  void onContactSearch(String query) {
    if (query.trim().isEmpty) {
      contactList = searchContactList;
      isLoadingContact = false;
    } else {
      contactList = searchContactList
          .where(
            (e) =>
                (e.contact.displayName.didMatch(query)) ||
                e.contact.phones.first.number.didMatch(query),
          )
          .toList();
      if (contactList.isEmpty) {
        isLoadingContact = true;
      }
    }

    commonController.handleSorSelectedContact(contactList);
  }

  void showMentionsUserList(String value) async {
    if (!conversation!.isGroup!) {
      return;
    }
    showMentionUserList = value.split(' ').last.contains('@');
    if (!showMentionUserList) {
      mentionSuggestions.clear();
      return;
    }
    var query = value.split('@').last;
    mentionSuggestions = groupMembers
        .where((e) => e.userName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void updateMentionUser(String value) {
    final tempList = chatInputController.text.split('@');
    final remainingText = tempList.sublist(0, tempList.length - 1).join('@');
    final updatedText = '$remainingText@${value.capitalizeFirst} ';
    showMentionUserList = false;
    chatInputController.value = chatInputController.value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: updatedText.length,
      ),
    );
  }

  void showReactionUser(
      {required IsmChatMessageModel message,
      required String reactionType,
      required int index}) async {
    userReactionList.clear();
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatContextWidget.showDialogContext(
        content: IsmChatPageDailog(
          child: ImsChatShowUserReaction(
            message: message,
            reactionType: reactionType,
            index: index,
          ),
        ),
      );
    } else {
      await IsmChatContextWidget.showBottomsheetContext(
        content: ImsChatShowUserReaction(
          message: message,
          reactionType: reactionType,
          index: index,
        ),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
      );
    }
  }

  void addWallpaper() async {
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatContextWidget.showDialogContext(
        content: const IsmChatPageDailog(
          child: ImsChatShowWallpaper(),
        ),
      );
    } else {
      await IsmChatContextWidget.showBottomsheetContext(
        content: const ImsChatShowWallpaper(),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IsmChatDimens.ten),
          ),
        ),
      );
    }
  }

  Future<void> getMentionedUserList(String data) async {
    userMentionedList.clear();
    final mentionedList = data.split('@').toList();

    mentionedList.removeWhere((e) => e.trim().isEmpty);

    for (var x = 0; x < groupMembers.length; x++) {
      final checkerLength =
          groupMembers[x].userName.trim().split(' ').first.length;
      if (mentionedList.isNotEmpty) {
        final isMember = mentionedList.where(
          (e) =>
              checkerLength == e.trim().length &&
              groupMembers[x].userName.trim().toLowerCase().contains(
                    e.trim().substring(0, checkerLength).toLowerCase(),
                  ),
        );
        if (isMember.isNotEmpty) {
          userMentionedList.add(
            MentionModel(
              wordCount: groupMembers[x].userName.split(' ').length,
              userId: groupMembers[x].userId,
              order: x,
            ),
          );
        }
      }
    }
  }

  toggleEmojiBoard([
    bool? showEmoji,
    bool focusKeyboard = true,
  ]) {
    if (showEmoji ?? showEmojiBoard) {
      if (focusKeyboard) {
        messageFocusNode.requestFocus();
      }
    } else {
      IsmChatUtility.hideKeyboard();
    }
    showEmojiBoard = showEmoji ?? !showEmojiBoard;
  }

  toggleAttachment() {
    showAttachment = !showAttachment;
  }

  /// This function will be used in [Contact Screen ] to Select or Unselect users
  void onSelectedContactTap(int index, SelectedContact contact) {
    contactList[index].isConotactSelected =
        !contactList[index].isConotactSelected;
    final checkContact =
        contactSelectedList.any((e) => e.contact.id == contact.contact.id);
    if (checkContact) {
      contactSelectedList
          .removeWhere((e) => e.contact.id == contact.contact.id);
    } else {
      contactSelectedList.add(contact);
    }
  }

  void setContatWithSelectedContact() {
    var temContactList = <SelectedContact>[];
    for (final contact in searchContactList) {
      final checkContact =
          contactSelectedList.any((e) => e.contact.id == contact.contact.id);
      contact.isConotactSelected = checkContact;
      temContactList.add(contact);
    }
    contactList.clear();
    contactList = temContactList;
  }

  /// This function will be used in [Add participants Screen] to Select or Unselect users
  void onGrouEligibleUserTap(int index) {
    groupEligibleUser[index].isUserSelected =
        !groupEligibleUser[index].isUserSelected;
  }

  void onBottomAttachmentTapped(
    IsmChatAttachmentType attachmentType,
  ) async {
    switch (attachmentType) {
      case IsmChatAttachmentType.camera:
        final initialize = await initializeCamera();
        if (initialize) {
          IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context)
              ? isCameraView = true
              : IsmChatRoute.goToRoute(const IsmChatCameraView());
        }

        break;
      case IsmChatAttachmentType.gallery:
        webMedia.clear();
        getMedia();
        break;
      case IsmChatAttachmentType.document:
        sendDocument(
          conversationId: conversation?.conversationId ?? '',
          userId: conversation?.opponentDetails?.userId ?? '',
        );
        break;
      case IsmChatAttachmentType.location:
        textEditingController.clear();
        await IsmChatRoute.goToRoute(const IsmChatLocationWidget());
        break;
      case IsmChatAttachmentType.contact:
        contactList.clear();
        contactSelectedList.clear();
        textEditingController.clear();
        isSearchSelect = false;
        isLoadingContact = false;
        if (await IsmChatUtility.requestPermission(Permission.contacts)) {
          unawaited(IsmChatRoute.goToRoute(const IsmChatContactView()));

          var contacts = await FlutterContacts.getContacts(
              withProperties: true, withPhoto: true);
          for (var x in contacts) {
            if (x.phones.isNotEmpty) {
              if (!((x.phones.first.number.contains('@')) &&
                      (x.phones.first.number.contains('.com'))) &&
                  x.displayName.isNotEmpty) {
                final isContactContain = contactList.any((element) =>
                    element.contact.phones.first.number ==
                    x.phones.first.number);
                if (!isContactContain) {
                  contactList.add(
                    SelectedContact(isConotactSelected: false, contact: x),
                  );
                }
              }
            }
          }
          searchContactList = List.from(contactList);
          if (contactList.isEmpty) {
            isLoadingContact = true;
          }
          commonController.handleSorSelectedContact(contactList);
        }

        break;
    }
  }

  void getMedia() async {
    webMedia.clear();
    assetsIndex = 0;
    final result = await IsmChatUtility.pickMedia(
      ImageSource.gallery,
      isVideoAndImage: true,
    );
    if (result.isEmpty) return;
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatUtility.showLoader();
      for (var x in result) {
        final bytes = await x?.readAsBytes();
        final extension = x?.mimeType?.split('/').last;
        final dataSize = IsmChatUtility.formatBytes(bytes?.length ?? 0);
        final platformFile = IsmchPlatformFile(
          name: x?.name ?? '',
          size: bytes?.length,
          bytes: bytes,
          path: x?.path,
          extension: extension,
        );

        if (IsmChatConstants.videoExtensions.contains(extension)) {
          final thumbnailBytes =
              await IsmChatBlob.getVideoThumbnailBytes(bytes ?? Uint8List(0));
          if (thumbnailBytes != null) {
            platformFile.thumbnailBytes = thumbnailBytes;
            webMedia.add(
              WebMediaModel(
                isVideo: true,
                platformFile: platformFile,
                dataSize: dataSize,
              ),
            );
          }
        } else {
          webMedia.add(
            WebMediaModel(
              isVideo: false,
              platformFile: platformFile,
              dataSize: dataSize,
            ),
          );
        }
      }
      IsmChatUtility.closeLoader();
    } else if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatRoute.goToRoute(IsmChatGalleryAssetsView(
        mediaXFile: result,
      ));
    }
  }

  Future<void> selectAssets(List<XFile?> assetList) async {
    textEditingController.clear();
    webMedia.clear();
    assetsIndex = 0;
    for (var file in assetList) {
      final bytes = await file?.readAsBytes();
      var name = '';
      if (kIsWeb) {
        name = file?.name ?? '';
      } else {
        name = (file?.path ?? '').split('/').last;
      }
      final extension = name.split('.').last;
      final dataSize = IsmChatUtility.formatBytes(bytes?.length ?? 0);
      final platformFile = IsmchPlatformFile(
        name: name,
        size: bytes?.length,
        bytes: bytes,
        path: file?.path,
        extension: extension,
      );
      if (IsmChatConstants.videoExtensions.contains(extension)) {
        var thumbnailBytes = Uint8List(0);
        if (kIsWeb) {
          thumbnailBytes =
              await IsmChatBlob.getVideoThumbnailBytes(bytes ?? Uint8List(0)) ??
                  Uint8List(0);
        } else {
          thumbnailBytes = await VideoCompress.getByteThumbnail(
                  file?.path ?? '',
                  quality: 50,
                  position: 1) ??
              Uint8List(0);
        }
        platformFile.thumbnailBytes = thumbnailBytes;
        webMedia.add(
          WebMediaModel(
            isVideo: true,
            platformFile: platformFile,
            dataSize: dataSize,
          ),
        );
      } else {
        webMedia.add(
          WebMediaModel(
            isVideo: false,
            platformFile: platformFile,
            dataSize: dataSize,
          ),
        );
      }
    }
  }

  void onReplyTap(IsmChatMessageModel message) {
    isreplying = true;
    replayMessage = message;
    messageFocusNode.requestFocus();
  }

  void onMenuItemSelected(
    IsmChatFocusMenuType menuType,
    IsmChatMessageModel message,
  ) async {
    switch (menuType) {
      case IsmChatFocusMenuType.info:
        await getMessageInformation(message);

        break;
      case IsmChatFocusMenuType.reply:
        onReplyTap(message);
        break;
      case IsmChatFocusMenuType.forward:
        conversationController.forwardedList.clear();

        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          await IsmChatContextWidget.showDialogContext(
            content: IsmChatPageDailog(
              child: IsmChatForwardView(
                message: message,
                conversation: conversation!,
              ),
            ),
          );
        } else {
          await IsmChatRoute.goToRoute(IsmChatForwardView(
            message: message,
            conversation: conversation!,
          ));
        }

        break;
      case IsmChatFocusMenuType.copy:
        await Clipboard.setData(ClipboardData(text: message.body));
        IsmChatUtility.showToast('Message copied');
        break;
      case IsmChatFocusMenuType.delete:
        await showDialogForMessageDelete(message);
        break;
      case IsmChatFocusMenuType.selectMessage:
        selectedMessage.clear();
        isMessageSeleted = true;
        selectedMessage.add(message);
        break;
    }
  }

  void onMessageSelect(IsmChatMessageModel ismChatChatMessageModel) {
    if (isMessageSeleted) {
      if (selectedMessage.contains(ismChatChatMessageModel)) {
        selectedMessage.removeWhere(
            (e) => e.messageId == ismChatChatMessageModel.messageId);
      } else {
        selectedMessage.add(ismChatChatMessageModel);
      }
      if (selectedMessage.isEmpty) {
        isMessageSeleted = false;
      }
    }
  }

  Future<void> showOverlay(
    BuildContext context,
    IsmChatMessageModel message,
  ) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondary) {
          animation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          );

          return IsmChatFocusMenu(
            message,
            animation: animation,
          );
        },
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: IsmChatConstants.transitionDuration,
        reverseTransitionDuration: IsmChatConstants.transitionDuration,
      ),
    );
  }

  Future<void> showOverlayWeb(
    BuildContext context,
    IsmChatMessageModel message,
    Animation<double> animation,
  ) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    // Get hight of Overlay widget which is rendor on message tap
    var overlayHeight = message.focusMenuList.length * IsmChatDimens.forty +
        (IsmChatProperties.chatPageProperties.features
                .contains(IsmChatFeature.reaction)
            ? IsmChatDimens.percentHeight(.1)
            : 0);

    var isOverFlowing =
        (overlayHeight + offset.dy) > (IsmChatDimens.percentHeight(1));
    var topPosition = offset.dy;
    if (isOverFlowing) {
      topPosition = (IsmChatDimens.percentHeight(1) - overlayHeight) -
          IsmChatDimens.twenty;
    }
    OverlayState? overlayState = Overlay.of(context);
    messageHoldOverlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: message.sentByMe ? null : offset.dx + size.width - 5,
        right: message.sentByMe ? 0 + size.width + 5 : null,
        top: topPosition.isNegative
            ? IsmChatProperties.chatPageProperties.header?.height?.call(
                    IsmChatConfig.kNavigatorKey.currentContext ??
                        IsmChatConfig.context,
                    IsmChatUtility.chatPageController.conversation!) ??
                IsmChatDimens.appBarHeight
            : topPosition,
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              );
              return IsmChatFocusMenu(
                message,
                animation: animation,
              );
            },
          ),
        ),
      ),
    );
    overlayState.insert(messageHoldOverlayEntry!);
  }

  void _scrollListener() async {
    messagesScrollController.addListener(
      () async {
        if (holdController?.isCompleted == true &&
            messageHoldOverlayEntry != null) {
          closeOverlay();
        }
        if (showAttachment) {
          await fabAnimationController?.reverse();
          if (fabAnimationController?.isDismissed == true) {
            attchmentOverlayEntry?.remove();
            // attchmentOverlayEntry = null;
          }
          showAttachment = false;
        }
        if (messagesScrollController.position.pixels.toInt() ==
            messagesScrollController.position.maxScrollExtent.toInt()) {
          canCallCurrentApi = false;
          await getMessagesFromAPI(
            forPagination: true,
            lastMessageTimestamp: 0,
          );
        }
        toggleEmojiBoard(false, false);
        if (IsmChatDimens.percentHeight(1) * 0.3 <
            (messagesScrollController.offset)) {
          showDownSideButton = true;
        } else {
          showDownSideButton = false;
        }
      },
    );

    searchMessageScrollController.addListener(
      () {
        if (searchMessageScrollController.position.pixels.toInt() ==
            searchMessageScrollController.position.maxScrollExtent.toInt()) {
          searchedMessages(textEditingController.text, fromScrolling: true);
        }
      },
    );
  }

  void _intputAndFocustNode() {
    if (IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.audioMessage)) {
      chatInputController.addListener(() {
        showSendButton = chatInputController.text.isNotEmpty;
      });
    } else {
      showSendButton = true;
    }

    messageFocusNode.addListener(
      () {
        if (messageFocusNode.hasFocus) {
          showEmojiBoard = false;
        }
        IsmChatProperties.chatPageProperties.meessageFieldFocusNode?.call(
            IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
            conversation!,
            messageFocusNode.hasFocus);
      },
    );
  }

  void _startAnimated() {
    holdController = AnimationController(
      vsync: this,
      duration: IsmChatConstants.transitionDuration,
    );
    holdAnimation = CurvedAnimation(
      parent: holdController!,
      curve: Curves.easeInOutCubic,
    );
  }

  void closeOverlay() async {
    if (holdController != null && messageHoldOverlayEntry != null) {
      await holdController?.reverse();
      if (holdController?.isDismissed == true) {
        messageHoldOverlayEntry?.remove();
        messageHoldOverlayEntry = null;
      }
    }
    closeAttachmentOverlayForWeb();
  }

  void closeAttachmentOverlayForWeb() async {
    if (fabAnimationController != null && attchmentOverlayEntry != null) {
      await fabAnimationController?.reverse();
      if (fabAnimationController?.isDismissed == true &&
          attchmentOverlayEntry != null) {
        try {
          attchmentOverlayEntry?.remove();
          attchmentOverlayEntry = null;
          showAttachment = !showAttachment;
        } catch (_) {}
      }
    }
  }

  Future<void> scrollDown() async {
    if (!IsmChatUtility.chatPageControllerRegistered) {
      return;
    }
    await messagesScrollController.animateTo(
      0,
      duration: IsmChatConfig.animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }

  void onGroupSearch(String query) {
    if (query.trim().isEmpty) {
      groupMembers = conversation!.members!;
      return;
    }
    groupMembers = conversation!.members!
        .where(
          (e) => [
            e.userName,
            e.userIdentifier,
          ].any(
            (e) => e.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          ),
        )
        .toList();
  }

  void addParticipantSearch(String query) {
    if (query.trim().isEmpty) {
      groupEligibleUser = groupEligibleUserDuplicate;
      return;
    }
    groupEligibleUser = groupEligibleUserDuplicate
        .where(
          (e) =>
              e.userDetails.userName.didMatch(query) ||
              e.userDetails.userIdentifier.didMatch(query),
        )
        .toList();
  }

  void startTimer() {
    forRecordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      var seconds = myDuration.inSeconds + 1;
      myDuration = Duration(seconds: seconds);
    });
  }

  Future<bool> initializeCamera() async {
    if (areCamerasInitialized && !kIsWeb) {
      return true;
    }
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied') {
        await IsmChatContextWidget.showDialogContext(
          content: const IsmChatAlertDialogBox(
            title: IsmChatStrings.cameraPermissionBlock,
            cancelLabel: IsmChatStrings.okay,
          ),
        );
      }
      return false;
    }

    if (_cameras.isNotEmpty) {
      return toggleCamera();
    }
    return true;
  }

  Future<void> leaveGroup({
    required int adminCount,
    required bool isUserAdmin,
  }) async {
    if (adminCount == 1 && isUserAdmin) {
      final members = groupMembers.where((e) => !e.isAdmin).toList();
      final member = members[Random().nextInt(members.length)];
      await makeAdmin(member.userId, member.userName, false);
    }
    final didLeft = await leaveConversation(conversation!.conversationId!);
    if (didLeft) {
      IsmChatRoute.goBack(); // to Chat Page
      IsmChatRoute.goBack(); // to Conversation Page
      await Future.wait([
        IsmChatConfig.dbWrapper!
            .removeConversation(conversation!.conversationId!),
        conversationController.getChatConversations(),
      ]);
    }
  }

  /// Updates the [''] mapping with the latest messages.
  void _generateIndexedMessageList() =>
      indexedMessageList = viewModel.generateIndexedMessageList(messages);

  /// Scroll to the message with the specified id.
  void scrollToMessage(String messageId, {Duration? duration}) async {
    if (indexedMessageList[messageId] != null) {
      await messagesScrollController.scrollToIndex(
        indexedMessageList[messageId]!,
        duration: duration ?? IsmChatConfig.animationDuration,
        preferPosition: AutoScrollPosition.middle,
      );
    } else {
      await getMessagesFromAPI(forPagination: true, lastMessageTimestamp: 0);
    }
  }

  void tapForMediaPreview(IsmChatMessageModel message) async {
    if ([IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
        .contains(message.customType)) {
      final mediaList = messages
          .where((item) =>
              [IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
                  .contains(item.customType) &&
              !(IsmChatProperties.chatPageProperties.isShowMediaMessageBlur
                      ?.call(
                          IsmChatConfig.kNavigatorKey.currentContext ??
                              IsmChatConfig.context,
                          item) ??
                  false))
          .toList();
      if (mediaList.isNotEmpty) {
        final selectedMediaIndex = mediaList.indexOf(message);
        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          {
            await IsmChatRoute.goToRoute(IsmWebMessageMediaPreview(
              previewData: {
                'mediaIndex': selectedMediaIndex,
                'messageData': mediaList,
                'mediaUserName': message.chatName,
                'initiated': message.sentByMe,
                'mediaTime': message.sentAt,
              },
            ));
          }
        } else {
          await IsmChatRoute.goToRoute(IsmMediaPreview(
            mediaIndex: selectedMediaIndex,
            messageData: mediaList,
            mediaUserName: message.chatName,
            initiated: message.sentByMe,
            mediaTime: message.sentAt,
          ));
        }
      }
    } else if (message.customType == IsmChatCustomMessageType.file) {
      var localPath = message.attachments?.first.mediaUrl;
      if (localPath == null) {
        return;
      }
      try {
        if (!kIsWeb) {
          final path = await IsmChatUtility.makeDirectoryWithUrl(
              urlPath: message.attachments?.first.mediaUrl ?? '',
              fileName: message.attachments?.first.name ?? '');

          if (path.path.isNotEmpty) {
            localPath = path.path;
          }
        }

        if (kIsWeb) {
          if (localPath.isValidUrl) {
            IsmChatBlob.fileDownloadWithUrl(localPath);
          } else {
            IsmChatBlob.fileDownloadWithBytes(
              localPath.strigToUnit8List,
              downloadName: message.attachments?.first.name,
            );
          }
        } else {
          await OpenFilex.open(localPath);
        }
      } catch (e) {
        IsmChatLog.error('$e');
      }
    } else if (message.customType == IsmChatCustomMessageType.audio) {
      await IsmChatContextWidget.showDialogContext(
        content: AudioPreview(
          message: message,
        ),
      );
    } else if (message.customType == IsmChatCustomMessageType.contact) {
      await IsmChatRoute.goToRoute(
        IsmChatContactsInfoView(
          contacts: message.contacts,
        ),
      );
    }
  }

  void tapForMediaPreviewWithMetaData(IsmChatMessageModel message) async {
    if ([IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
        .contains(message.metaData?.replyMessage?.parentMessageMessageType)) {
      final mediaList = messages
          .where((item) =>
              [IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
                  .contains(
                      item.metaData?.replyMessage?.parentMessageMessageType) &&
              !(IsmChatProperties.chatPageProperties.isShowMediaMessageBlur
                      ?.call(
                          IsmChatConfig.kNavigatorKey.currentContext ??
                              IsmChatConfig.context,
                          item) ??
                  false))
          .toList();
      final selectedMediaIndex = mediaList.indexOf(message);
      if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
          IsmChatConfig.context)) {
        {
          await IsmChatRoute.goToRoute(IsmWebMessageMediaPreview(
            previewData: {
              'mediaIndex': selectedMediaIndex,
              'messageData': mediaList,
              'mediaUserName': message.chatName,
              'initiated': message.sentByMe,
              'mediaTime': message.sentAt
            },
          ));
        }
      } else {
        await IsmChatRoute.goToRoute(IsmMediaPreview(
          mediaIndex: selectedMediaIndex,
          messageData: mediaList,
          mediaUserName: message.chatName,
          initiated: message.sentByMe,
          mediaTime: message.sentAt,
        ));
      }
    } else if (message.metaData?.replyMessage?.parentMessageMessageType ==
        IsmChatCustomMessageType.file) {
      var localPath = message.attachments?.first.mediaUrl;
      if (localPath == null) {
        return;
      }
      try {
        if (!kIsWeb) {
          final path = await IsmChatUtility.makeDirectoryWithUrl(
              urlPath: message.attachments?.first.mediaUrl ?? '',
              fileName: message.attachments?.first.name ?? '');

          if (path.path.isNotEmpty) {
            localPath = path.path;
          }
        }

        if (kIsWeb) {
          if (localPath.isValidUrl) {
            IsmChatBlob.fileDownloadWithUrl(localPath);
          } else {
            IsmChatBlob.fileDownloadWithBytes(
              localPath.strigToUnit8List,
              downloadName: message.attachments?.first.name,
            );
          }
        } else {
          await OpenFilex.open(localPath);
        }
      } catch (e) {
        IsmChatLog.error('$e');
      }
    } else if (message.customType == IsmChatCustomMessageType.audio) {
      await IsmChatContextWidget.showDialogContext(
        content: AudioPreview(
          message: message,
        ),
      );
    } else if (message.metaData?.replyMessage?.parentMessageMessageType ==
        IsmChatCustomMessageType.contact) {
      await IsmChatRoute.goToRoute(
        IsmChatContactsInfoView(
          contacts: message.contacts,
        ),
      );
    }
  }

  Future<bool> toggleCamera() async {
    areCamerasInitialized = false;

    if (!IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      if (kIsWeb) {
        isFrontCameraSelected = false;
      } else {
        isFrontCameraSelected = !isFrontCameraSelected;
      }
    }

    if (isFrontCameraSelected) {
      _frontCameraController = CameraController(
        _cameras[1],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    } else {
      _backCameraController = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    }

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context) &&
          kIsWeb) {
        final state = await IsmChatBlob.checkPermission('microphone');
        if (state == 'denied') {
          unawaited(IsmChatContextWidget.showDialogContext(
            content: const IsmChatAlertDialogBox(
              title: IsmChatStrings.micePermissionBlock,
              cancelLabel: IsmChatStrings.okay,
            ),
          ));
          return false;
        }
      } else {
        IsmChatLog.error(
            'Camera permission error ${e.code} == ${e.description}');
        await AppSettings.openAppSettings();
        await checkCameraPermission();
      }
    }
    await checkCameraPermission();
    return true;
  }

  Future<void> checkCameraPermission() async {
    if (IsmChatResponsive.isWeb(IsmChatConfig.kNavigatorKey.currentContext ??
            IsmChatConfig.context) &&
        kIsWeb) {
      final state = await IsmChatBlob.checkPermission('camera');
      if (state == 'granted') {
        areCamerasInitialized = true;
      } else {
        areCamerasInitialized = false;
      }
    } else {
      if (await Permission.camera.isGranted) {
        areCamerasInitialized = true;
      } else {
        areCamerasInitialized = false;
      }
    }
  }

  void toggleFlash([FlashMode? mode]) {
    if (mode != null) {
      flashMode = mode;
    } else {
      if (flashMode == FlashMode.off) {
        flashMode = FlashMode.always;
      } else if (flashMode == FlashMode.always) {
        flashMode = FlashMode.auto;
      } else if (flashMode == FlashMode.auto) {
        flashMode = FlashMode.off;
      } else {
        flashMode = FlashMode.torch;
      }
    }
    cameraController.setFlashMode(flashMode);
  }

  Future<bool> updateLastMessage() async {
    if (!didReactedLast) {
      var chatConversation = await IsmChatConfig.dbWrapper
          ?.getConversation(conversation?.conversationId ?? '');
      if (chatConversation != null &&
          chatConversation.messages?.isNotEmpty == true) {
        if (messages.isNotEmpty &&
            messages.last.customType != IsmChatCustomMessageType.removeMember) {
          final lastMessage = messages.last;
          chatConversation = chatConversation.copyWith(
            lastMessageDetails: chatConversation.lastMessageDetails?.copyWith(
              audioOnly: lastMessage.audioOnly,
              meetingId: lastMessage.meetingId,
              meetingType: lastMessage.meetingType,
              callDurations: lastMessage.callDurations,
              sentByMe: lastMessage.sentByMe,
              showInConversation: true,
              senderId: lastMessage.senderInfo?.userId ?? '',
              sentAt: chatConversation
                          .lastMessageDetails?.reactionType?.isNotEmpty ==
                      true
                  ? chatConversation.lastMessageDetails?.sentAt
                  : lastMessage.sentAt,
              senderName: [
                IsmChatCustomMessageType.removeAdmin,
                IsmChatCustomMessageType.addAdmin,
                IsmChatCustomMessageType.memberJoin,
                IsmChatCustomMessageType.memberLeave,
              ].contains(lastMessage.customType)
                  ? lastMessage.userName?.isNotEmpty == true
                      ? lastMessage.userName
                      : lastMessage.initiatorName ?? ''
                  : chatConversation.isGroup ?? false
                      ? lastMessage.senderInfo?.userName
                      : lastMessage.chatName,
              messageType: lastMessage.messageType?.value ?? 0,
              messageId: lastMessage.messageId ?? '',
              conversationId: lastMessage.conversationId ?? '',
              body: lastMessage.body,
              action: lastMessage.action,
              customType: lastMessage.customType,
              readCount: lastMessage.messageId?.isNotEmpty == true
                  ? chatConversation.isGroup ?? false
                      ? lastMessage.readByAll ?? false
                          ? chatConversation.membersCount
                          : lastMessage.lastReadAt?.length
                      : lastMessage.readByAll ?? false
                          ? 1
                          : 0
                  : 0,
              deliveredTo: lastMessage.messageId?.isNotEmpty == true
                  ? lastMessage.deliveredTo
                  : [],
              readBy: lastMessage.messageId?.isNotEmpty == true
                  ? lastMessage.readBy
                  : [],
              deliverCount: lastMessage.messageId?.isNotEmpty == true
                  ? chatConversation.isGroup ?? false
                      ? lastMessage.deliveredToAll ?? false
                          ? chatConversation.membersCount
                          : 0
                      : lastMessage.deliveredToAll ?? false
                          ? 1
                          : 0
                  : 0,
              members: lastMessage.members
                      ?.map((e) => e.memberName ?? '')
                      .toList() ??
                  [],
              initiatorId: lastMessage.initiatorId,
              metaData: lastMessage.metaData,
              isInvalidMessage: lastMessage.isInvalidMessage,
            ),
            unreadMessagesCount: 0,
          );
        }

        await IsmChatConfig.dbWrapper
            ?.saveConversation(conversation: chatConversation);
        await conversationController.getConversationsFromDB();
      }
    } else {
      await conversationController.getChatConversations();
    }

    if (IsmChatUtility.chatPageControllerRegistered) {
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
    }
    unawaited(
        Get.find<IsmChatMqttController>().getChatConversationsUnreadCount());

    return true;
  }

  Future<void> updateUnreadMessgaeCount() async {
    var chatConversation = await IsmChatConfig.dbWrapper
        ?.getConversation(conversation?.conversationId ?? '');
    if (chatConversation != null) {
      chatConversation = chatConversation.copyWith(
        unreadMessagesCount: 0,
      );
      await IsmChatConfig.dbWrapper!
          .saveConversation(conversation: chatConversation);
      await conversationController.getConversationsFromDB();
    }
  }

  Future<void> updateGalleryImage({
    required XFile file,
    required int selectedIndex,
  }) async {
    IsmChatUtility.showLoader();
    final bytes = await file.readAsBytes();
    final fileSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    var name = '';
    if (kIsWeb) {
      name = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      name = file.path.split('/').last;
    }
    final extension = name.split('.').last;
    webMedia[selectedIndex] = WebMediaModel(
      dataSize: fileSize,
      isVideo: false,
      platformFile: IsmchPlatformFile(
        name: name,
        bytes: bytes,
        path: file.path,
        size: bytes.length,
        extension: extension,
      ),
    );
    IsmChatUtility.closeLoader();
  }

  Future<void> cropImage({
    required String url,
    bool forGalllery = false,
    int selectedIndex = 0,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: url,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      if (forGalllery) {
        await updateGalleryImage(
            file: XFile(croppedFile.path), selectedIndex: selectedIndex);
      } else {
        await updateImage(XFile(croppedFile.path));
      }
    }
  }

  Future<void> paintImage({
    required String url,
    bool forGalllery = false,
    int selectedIndex = 0,
  }) async {
    final file = await IsmChatRoute.goToRoute<XFile>(
      IsmChatImagePaintView(
        file: XFile(url),
      ),
    );

    if (file == null) return;
    if (forGalllery) {
      await updateGalleryImage(
          file: XFile(file.path), selectedIndex: selectedIndex);
    } else {
      await updateImage(XFile(file.path));
    }
  }

  void takePhoto() async {
    final file = await cameraController.takePicture();
    XFile? mainFile;
    if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatRoute.goBack();
    }

    if (cameraController.description.lensDirection ==
        CameraLensDirection.front) {
      final imageBytes = await file.readAsBytes();
      final file2 = File(file.path);
      final originalImage = img.decodeImage(imageBytes);
      final fixedImage = img.flipHorizontal(originalImage!);
      final fixedFile = await file2.writeAsBytes(
        img.encodeJpg(fixedImage),
        flush: true,
      );
      mainFile = XFile(
        fixedFile.path,
      );
    } else {
      mainFile = XFile(file.path);
    }

    await updateImage(mainFile);
    if (IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      await IsmChatRoute.goToRoute(const IsmChatImageEditView());
    }
  }

  Future<void> updateImage(XFile file) async {
    IsmChatUtility.showLoader();
    var bytes = await file.readAsBytes();
    bytes = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 60,
    );
    final fileSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    var name = '';
    if (kIsWeb) {
      name = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      name = file.path.split('/').last;
    }
    final extension = name.split('.').last;
    webMedia.clear();
    webMedia.add(
      WebMediaModel(
        dataSize: fileSize,
        isVideo: false,
        platformFile: IsmchPlatformFile(
          name: name,
          bytes: bytes,
          path: file.path,
          size: bytes.length,
          extension: extension,
        ),
      ),
    );
    IsmChatUtility.closeLoader();
  }

  Future<void> readMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await viewModel.readMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  void notifyTyping() {
    if (isTyping) {
      isTyping = false;
      var tickTick = 0;
      Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (tickTick == 0) {
          await viewModel.notifyTyping(
            conversationId: conversation?.conversationId ?? '',
          );
        }
        if (tickTick == 3) {
          isTyping = true;
          timer.cancel();
        }
        tickTick++;
      });
    }
  }

  Future<void> getMessageInformation(
    IsmChatMessageModel message,
  ) async {
    unawaited(Future.wait<dynamic>(
      [
        getMessageReadTime(message),
        getMessageDeliverTime(message),
      ],
    ));
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      conversationController.message = message;
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.messgaeInfoView;
    } else {
      await IsmChatRoute.goToRoute(IsmChatMessageInfo(
        message: message,
        isGroup: conversation?.isGroup ?? false,
      ));
    }
  }

  /// Call function for Get Chat Conversation Detailss
  void checkUserStatus() {
    conversationDetailsApTimer = Timer.periodic(
      const Duration(minutes: 1),
      (Timer t) {
        if (!IsmChatUtility.chatPageControllerRegistered) {
          t.cancel();
          conversationDetailsApTimer?.cancel();
        }
        if (conversation?.conversationId != null ||
            conversation?.conversationId?.isNotEmpty == true) {
          getConverstaionDetails();
        }
      },
    );
  }

  void ifTimerMounted() {
    final isTimer = conversationDetailsApTimer == null
        ? false
        : conversationDetailsApTimer!.isActive;
    if (isTimer) {
      conversationDetailsApTimer!.cancel();
    }
  }

  Future<void> blockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    bool? blokedUser;
    if (IsmChatProperties.chatPageProperties.onCallBlockUnblock != null) {
      blokedUser = await IsmChatProperties.chatPageProperties.onCallBlockUnblock
              ?.call(
                  IsmChatConfig.kNavigatorKey.currentContext ??
                      IsmChatConfig.context,
                  conversation!,
                  userBlockOrNot) ??
          false;
    } else {
      blokedUser = await viewModel.blockUser(
          opponentId: opponentId,
          conversationId: conversation?.conversationId ?? '',
          isLoading: isLoading);
    }

    if (!blokedUser) {
      return;
    }

    IsmChatUtility.showToast(IsmChatStrings.blockedSuccessfully);
    await Future.wait([
      conversationController.getBlockUser(),
      if (fromUser == false) ...[
        getConverstaionDetails(),
        getMessagesFromAPI(),
        conversationController.getChatConversations()
      ]
    ]);
  }

  Future<void> unblockUser({
    required String opponentId,
    bool isLoading = false,
    bool fromUser = false,
    required bool userBlockOrNot,
  }) async {
    bool isUnblockUser;
    if (IsmChatProperties.chatPageProperties.onCallBlockUnblock != null) {
      isUnblockUser =
          await IsmChatProperties.chatPageProperties.onCallBlockUnblock?.call(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context,
                conversation!,
                userBlockOrNot,
              ) ??
              false;
    } else {
      isUnblockUser = await conversationController.unblockUser(
        opponentId: opponentId,
        isLoading: isLoading,
        fromUser: fromUser,
      );
    }
    if (!isUnblockUser) {
      return;
    }
    chatInputController.clear();
    if (fromUser == false) {
      await Future.wait([
        getConverstaionDetails(),
        getMessagesFromAPI(),
        conversationController.getChatConversations()
      ]);
    }
  }

  Future<void> readAllMessages() async {
    await viewModel.readAllMessages(
      conversationId: conversation?.conversationId ?? '',
      timestamp: messages.isNotEmpty
          ? DateTime.now().millisecondsSinceEpoch
          : conversation?.lastMessageSentAt ?? 0,
    );
  }

  Future<void> deleteMessageForEveryone(
    IsmChatMessages messages,
  ) async {
    final pendingMessges = IsmChatMessages.from(messages);
    await viewModel.deleteMessageForEveryone(messages);
    selectedMessage.clear();
    pendingMessges.entries.where((e) => e.value.messageId == '');
    if (pendingMessges.isNotEmpty) {
      await IsmChatConfig.dbWrapper?.removePendingMessage(
          conversation?.conversationId ?? '', pendingMessges);
      await getMessagesFromDB(conversation!.conversationId!);
      selectedMessage.clear();
      isMessageSeleted = false;
    }
    IsmChatUtility.showToast('Deleted your message');
  }

  Future<void> deleteMessageForMe(
    IsmChatMessages messages,
  ) async {
    final pendingMessges = IsmChatMessages.from(messages);
    await viewModel.deleteMessageForMe(messages);
    selectedMessage.clear();
    pendingMessges.entries.where((e) => e.value.messageId == '');
    if (pendingMessges.isNotEmpty) {
      await IsmChatConfig.dbWrapper?.removePendingMessage(
          conversation?.conversationId ?? '', pendingMessges);
      await getMessagesFromDB(conversation?.conversationId ?? '');
      selectedMessage.clear();
      isMessageSeleted = false;
    }
    IsmChatUtility.showToast('Deleted your message');
  }

  bool isAllMessagesFromMe() => selectedMessage.every(
        (e) {
          if (e.sentByMe &&
              e.customType == IsmChatCustomMessageType.deletedForEveryone) {
            return false;
          }
          return e.sentByMe;
        },
      );

  Future<void> clearAllMessages(String conversationId,
      {bool fromServer = true}) async {
    await viewModel.clearAllMessages(
        conversationId: conversationId, fromServer: fromServer);
  }

  Future<void> getLocation(
      {required String latitude,
      required String longitude,
      String searchKeyword = ''}) async {
    predictionList.clear();
    isLocaionSearch = true;
    final response = await viewModel.getLocation(
      latitude: latitude,
      longitude: longitude,
      searchKeyword: searchKeyword,
    );
    isLocaionSearch = false;
    if (response == null || response.isEmpty) {
      return;
    }
    predictionList = response;
  }

  Future<void> deleteReacton({required Reaction reaction}) async {
    var response = await viewModel.deleteReacton(reaction: reaction);
    if (response != null && !response.hasError) {
      await _controller.conversationController.getChatConversations();
    }
  }

  Future<void> showUserDetails(UserDetails userDetails,
      {bool fromMessagePage = true}) async {
    final conversationId = conversationController.getConversationId(
      userDetails.userId,
    );
    final conversationUser =
        await IsmChatConfig.dbWrapper!.getConversation(conversationId);
    UserDetails? user;
    if (conversationUser != null) {
      user = conversationUser.opponentDetails;
    } else {
      user = userDetails;
    }
    conversationController.contactDetails = user;
    conversationController.userConversationId = conversationId;
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.userInfoView;
    } else {
      await IsmChatRoute.goToRoute(
        IsmChatUserInfo(
          conversationId: conversationId,
          user: user!,
          fromMessagePage: fromMessagePage,
        ),
      );
    }
  }

  Future<void> shareMedia(IsmChatMessageModel message) async {
    IsmChatUtility.showLoader();
    final path = await IsmChatUtility.makeDirectoryWithUrl(
        urlPath: message.attachments?.first.mediaUrl ?? '',
        fileName: message.attachments?.first.name ?? '');
    if (path.path.isNotEmpty) {
      final file = XFile(path.path);
      IsmChatUtility.closeLoader();
      final result = await SharePlus.instance.share(ShareParams(
        files: [file],
      ));
      if (result.status == ShareResultStatus.success) {
        IsmChatUtility.showToast('Share your media');
        IsmChatLog.success('File shared: ${result.status}');
        IsmChatRoute.goBack();
      }
    } else {
      IsmChatUtility.closeLoader();
    }
  }

  /// call function for Save Media
  Future<void> saveMedia(IsmChatMessageModel message) async {
    await IsmChatUtility.requestForGallery();
    if ((message.attachments?.first.mediaUrl ?? '').isValidUrl) {
      mediaDownloadProgress = 0;
      snackBarController = Get.showSnackbar(
        GetSnackBar(
          messageText: Obx(() => CustomeSnackBar(
                downloadProgress: mediaDownloadProgress,
                downloadedFileCount: 1,
                noOfFiles: 1,
              )),
        ),
      );
      if (IsmChatConstants.videoExtensions
          .contains(message.attachments?.first.extension)) {
        await IsmChatUtility.downloadMediaFromNetworkPath(
          url: message.attachments?.first.mediaUrl ?? '',
          isVideo: true,
          downloadProgrees: (value) {
            mediaDownloadProgress = value;
          },
        );
      } else {
        await IsmChatUtility.downloadMediaFromNetworkPath(
          url: message.attachments?.first.mediaUrl ?? '',
          downloadProgrees: (value) {
            mediaDownloadProgress = value;
          },
        );
      }
      if (snackBarController != null) {
        await snackBarController?.close();
      }
    } else {
      if (IsmChatConstants.videoExtensions
          .contains(message.attachments?.first.extension)) {
        await IsmChatUtility.downloadMediaFromLocalPath(
          url: message.attachments?.first.mediaUrl ?? '',
          isVideo: true,
        );
      } else {
        await IsmChatUtility.downloadMediaFromLocalPath(
          url: message.attachments?.first.mediaUrl ?? '',
        );
      }
    }
  }

  String getMessageBody(IsmChatMessageModel? replayMessage) {
    if (replayMessage?.customType == IsmChatCustomMessageType.location) {
      return IsmChatStrings.location;
    } else if (replayMessage?.customType == IsmChatCustomMessageType.contact) {
      return IsmChatStrings.contact;
    } else if (replayMessage?.customType ==
        IsmChatCustomMessageType.oneToOneCall) {
      return (replayMessage?.callDurations?.length != 1 ||
              replayMessage?.action == IsmChatActionEvents.meetingCreated.name)
          ? '${replayMessage?.meetingType == 0 ? 'Voice' : 'Video'} call'
          : 'Missed ${replayMessage?.meetingType == 0 ? 'voice' : 'video'} call';
    } else {
      return replayMessage?.body ?? '';
    }
  }

  String? getParentMessageUrl(IsmChatMessageModel? replayMessage) {
    if (replayMessage == null) return null;
    final customType = replayMessage.customType;
    switch (customType) {
      case IsmChatCustomMessageType.audio:
      case IsmChatCustomMessageType.file:
        return replayMessage.attachments?.first.name;
      case IsmChatCustomMessageType.contact:
        return replayMessage.metaData?.contacts?.first.contactIdentifier;
      case IsmChatCustomMessageType.location:
      case IsmChatCustomMessageType.image:
        return replayMessage.attachments?.first.mediaUrl;
      case IsmChatCustomMessageType.video:
        return replayMessage.attachments?.first.thumbnailUrl;
      default:
        return replayMessage.body;
    }
  }

  Future<bool> isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await recordVoice.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      IsmChatLog.success('${encoder.name} is not supported on this platform.');
      IsmChatLog.success('Supported encoders are:');
      for (final e in AudioEncoder.values) {
        if (await recordVoice.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }
    return isSupported;
  }

  void recordDelete() {
    isEnableRecordingAudio = false;
    showSendButton = false;
    forRecordTimer?.cancel();
    seconds = 0;
  }

  Future<void> recordPlayPauseVoice() async {
    if (await recordVoice.isPaused()) {
      await recordVoice.resume();
      isRecordPlay = true;
      forRecordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        seconds++;
      });
    } else {
      await recordVoice.pause();
      isRecordPlay = false;
      forRecordTimer?.cancel();
    }
  }

  void showCloseLoaderForMoble({bool showLoader = true}) {
    final isMobile = !IsmChatResponsive.isMobile(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context);
    if (showLoader) {
      if (isMobile) {
        IsmChatUtility.showLoader();
      }
    } else {
      if (isMobile) {
        IsmChatUtility.closeLoader();
      }
    }
  }
}
