import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatUserInfo extends StatefulWidget {
  const IsmChatUserInfo({
    super.key,
    required this.user,
    required this.conversationId,
    required this.fromMessagePage,
  });

  final UserDetails? user;
  final String conversationId;
  final bool fromMessagePage;

  @override
  State<IsmChatUserInfo> createState() => _IsmChatUserInfoState();
}

class _IsmChatUserInfoState extends State<IsmChatUserInfo> {
  List<IsmChatMessageModel> mediaList = [];
  List<IsmChatMessageModel> mediaListLinks = [];
  List<IsmChatMessageModel> mediaListDocs = [];

  final conversationController = IsmChatUtility.conversationController;
  bool isUserBlock = false;
  final argument = Get.arguments as Map<String, dynamic>? ?? {};

  @override
  void initState() {
    super.initState();
    if (widget.conversationId.isNotEmpty) {
      // Try to load from chat page controller first (fastest - already in memory)
      loadMessagesFromController();
      // Then load from local DB (fast)
      getMessagesFromLocal();
    }
    if (!conversationController.blockUsers.isNullOrEmpty) {
      isUserBlock = conversationController.blockUsers
          .any((e) => e.userId == widget.user?.userId);
    }
  }

  /// Loads media messages from chat page controller if conversation is already loaded (fastest)
  void loadMessagesFromController() {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final chatController = IsmChatUtility.chatPageController;
      if (chatController.conversation?.conversationId ==
              widget.conversationId &&
          chatController.messages.isNotEmpty) {
        // Use messages already loaded in memory
        mediaList = chatController.messages
            .where((e) => [
                  IsmChatCustomMessageType.video,
                  IsmChatCustomMessageType.image,
                  IsmChatCustomMessageType.audio
                ].contains(e.customType))
            .toList();
        mediaListLinks = chatController.messages
            .where(
                (e) => [IsmChatCustomMessageType.link].contains(e.customType))
            .toList();
        mediaListDocs = chatController.messages
            .where(
                (e) => [IsmChatCustomMessageType.file].contains(e.customType))
            .toList();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  /// Loads media messages from local database (fast)
  void getMessagesFromLocal() async {
    // If we already have data from controller, skip DB load
    if (mediaList.isNotEmpty ||
        mediaListLinks.isNotEmpty ||
        mediaListDocs.isNotEmpty) {
      return;
    }

    var messages =
        await IsmChatConfig.dbWrapper?.getMessage(widget.conversationId);
    if (messages != null && messages.isNotEmpty) {
      final filteredMedia = messages.values
          .where((e) => [
                IsmChatCustomMessageType.video,
                IsmChatCustomMessageType.image,
                IsmChatCustomMessageType.audio
              ].contains(e.customType))
          .toList();
      final filteredLinks = messages.values
          .where((e) => [IsmChatCustomMessageType.link].contains(e.customType))
          .toList();
      final filteredDocs = messages.values
          .where((e) => [IsmChatCustomMessageType.file].contains(e.customType))
          .toList();

      if (mounted) {
        setState(() {
          mediaList = filteredMedia;
          mediaListLinks = filteredLinks;
          mediaListDocs = filteredDocs;
        });
      }
    } else {
      // If local DB has no data, fetch from API
      await getMessagesFromAPI();
    }
  }

  /// Fetches media messages from API if local count is 0
  Future<void> getMessagesFromAPI() async {
    try {
      // Use chat page view model to fetch messages from API
      final chatPageViewModel = IsmChatPageViewModel(IsmChatPageRepository());

      // Fetch all messages for the conversation (with large limit)
      final allMessages = await chatPageViewModel.getChatMessages(
        conversationId: widget.conversationId,
        lastMessageTimestamp: 0,
        limit: 1000, // Large limit to get all messages
        skip: 0,
        isLoading: false,
      );

      if (allMessages.isNotEmpty && mounted) {
        // Filter messages by custom type
        final filteredMediaList = allMessages
            .where((e) => [
                  IsmChatCustomMessageType.video,
                  IsmChatCustomMessageType.image,
                  IsmChatCustomMessageType.audio
                ].contains(e.customType))
            .toList();

        final filteredLinkList = allMessages
            .where(
                (e) => [IsmChatCustomMessageType.link].contains(e.customType))
            .toList();

        final filteredDocList = allMessages
            .where(
                (e) => [IsmChatCustomMessageType.file].contains(e.customType))
            .toList();

        setState(() {
          mediaList = filteredMediaList;
          mediaListLinks = filteredLinkList;
          mediaListDocs = filteredDocList;
        });
      }
    } catch (e) {
      IsmChatLog.error('Error fetching media messages from API: $e');
    }
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
      tag: IsmChat.i.chatPageTag,
      builder: (controller) => Scaffold(
            backgroundColor: IsmChatColors.whiteColor,
            appBar: IsmChatAppBar(
              onBack: IsmChatResponsive.isWeb(context)
                  ? () {
                      conversationController.isRenderChatPageaScreen =
                          IsRenderChatPageScreen.none;
                    }
                  : null,
              title: Text(
                IsmChatStrings.contactInfo,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
              ),
            ),
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: IsmChatDimens.edgeInsets16_0_16_0,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IsmChatDimens.boxHeight16,
                      IsmChatImage.profile(
                        widget.user?.profileUrl ?? '',
                        dimensions: IsmChatDimens.oneHundredFifty,
                      ),
                      IsmChatDimens.boxHeight5,
                      Text(
                        widget.user?.userName ?? '',
                        style: IsmChatStyles.w600Black27,
                      ),
                      Text(
                        widget.user?.userIdentifier ?? '',
                        style: IsmChatStyles.w500GreyLight17,
                      ),
                      IsmChatDimens.boxHeight16,
                      ListTile(
                        onTap: () {
                          if (IsmChatResponsive.isWeb(context)) {
                            conversationController.mediaList = mediaList;
                            conversationController.mediaListDocs =
                                mediaListDocs;
                            conversationController.mediaListLinks =
                                mediaListLinks;
                            conversationController.isRenderChatPageaScreen =
                                IsRenderChatPageScreen.coversationMediaView;
                          } else {
                            IsmChatRoute.goToRoute(
                              IsmMedia(
                                mediaList: mediaList,
                                mediaListLinks: mediaListLinks,
                                mediaListDocs: mediaListDocs,
                              ),
                            );
                          }
                        },
                        leading: SvgPicture.asset(
                          IsmChatAssets.gallarySvg,
                        ),
                        title: Text(
                          IsmChatStrings.mediaLinksAndDocs,
                          style: IsmChatStyles.w500Black16,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${mediaList.length + mediaListLinks.length + mediaListDocs.length}',
                              style: IsmChatStyles.w500GreyLight17,
                            ),
                            IsmChatDimens.boxWidth4,
                            Icon(
                              Icons.arrow_forward_ios,
                              color: IsmChatColors.greyColorLight,
                              size: IsmChatDimens.fifteen,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          IsmChatUtility.showLoader();
                          IsmChatConversationModel? conversationModel;
                          final conversation = await IsmChatConfig.dbWrapper
                              ?.getConversation(widget.user?.userId ?? '');
                          if (conversation != null) {
                            conversationModel = conversation;
                          } else {
                            conversationModel = IsmChatConversationModel(
                              messagingDisabled: false,
                              isGroup: false,
                              opponentDetails: widget.user,
                              unreadMessagesCount: 0,
                              lastMessageDetails: null,
                              lastMessageSentAt: 0,
                              membersCount: 1,
                              conversationId:
                                  conversationController.getConversationId(
                                widget.user?.userId ?? '',
                              ),
                            );
                          }

                          conversationController
                              .updateLocalConversation(conversationModel);
                          controller.messages.clear();
                          if (widget.fromMessagePage) {
                            IsmChatRoute.goBack();
                          } else {
                            IsmChatRoute.goBack();
                            IsmChatRoute.goBack();
                          }

                          IsmChatUtility.closeLoader();
                          controller.closeOverlay();
                          // Defer initialization to allow UI to render first
                          unawaited(
                              Future.microtask(() => controller.startInit()));
                        },
                        title: Text(
                          IsmChatStrings.message,
                          style: IsmChatStyles.w500Black16,
                        ),
                        leading: Container(
                          height: IsmChatDimens.thirty,
                          width: IsmChatDimens.thirty,
                          decoration: BoxDecoration(
                            color: IsmChatConfig.chatTheme.primaryColor,
                            borderRadius:
                                BorderRadius.circular(IsmChatDimens.five),
                          ),
                          child: Icon(
                            Icons.message_rounded,
                            color: IsmChatColors.whiteColor,
                            size: IsmChatDimens.twenty,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: IsmChatColors.greyColorLight,
                          size: IsmChatDimens.fifteen,
                        ),
                      ),
                      if (IsmChatConfig.communicationConfig.userConfig.userId !=
                          widget.user?.userId) ...[
                        ListTile(
                          onTap: () async {
                            await IsmChatContextWidget.showDialogContext(
                              content: IsmChatAlertDialogBox(
                                title: isUserBlock
                                    ? IsmChatStrings.doWantUnBlckUser
                                    : IsmChatStrings.doWantBlckUser,
                                actionLabels: [
                                  isUserBlock
                                      ? IsmChatStrings.unblock
                                      : IsmChatStrings.block,
                                ],
                                callbackActions: [
                                  () {
                                    IsmChatRoute.goBack();
                                    isUserBlock
                                        ? controller.unblockUser(
                                            opponentId:
                                                widget.user?.userId ?? '',
                                            fromUser: true,
                                            userBlockOrNot: isUserBlock,
                                          )
                                        : controller.blockUser(
                                            opponentId:
                                                widget.user?.userId ?? '',
                                            userBlockOrNot: isUserBlock,
                                          );
                                  },
                                ],
                              ),
                            );
                          },
                          title: Text(
                            isUserBlock
                                ? IsmChatStrings.unblock
                                : IsmChatStrings.block,
                            style: IsmChatStyles.w600red16,
                          ),
                          leading: Container(
                            height: IsmChatDimens.thirty,
                            width: IsmChatDimens.thirty,
                            decoration: BoxDecoration(
                              color: IsmChatColors.redColor,
                              borderRadius:
                                  BorderRadius.circular(IsmChatDimens.five),
                            ),
                            child: Icon(
                              Icons.block_rounded,
                              color: IsmChatColors.whiteColor,
                              size: IsmChatDimens.twenty,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: IsmChatColors.greyColorLight,
                            size: IsmChatDimens.fifteen,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ));
}
