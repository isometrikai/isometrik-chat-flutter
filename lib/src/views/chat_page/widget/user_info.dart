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
    if (widget.conversationId.isNotEmpty) {
      getMessages();
    }
    if (!conversationController.blockUsers.isNullOrEmpty) {
      isUserBlock = conversationController.blockUsers
          .any((e) => e.userId == widget.user?.userId);
    }
    super.initState();
  }

  void getMessages() async {
    var messages =
        await IsmChatConfig.dbWrapper?.getMessage(widget.conversationId);
    if (messages != null) {
      mediaList = messages.values
          .where((e) => [
                IsmChatCustomMessageType.video,
                IsmChatCustomMessageType.image,
                IsmChatCustomMessageType.audio
              ].contains(e.customType))
          .toList();
      mediaListLinks = messages.values
          .where((e) => [
                IsmChatCustomMessageType.link,
              ].contains(e.customType))
          .toList();
      mediaListDocs = messages.values
          .where((e) => [
                IsmChatCustomMessageType.file,
              ].contains(e.customType))
          .toList();
      setState(() {});
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
                          final conversation = await IsmChatConfig.dbWrapper!
                              .getConversation(
                                  conversationId: widget.user?.userId ?? '');
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
                          controller.startInit();
                          controller.closeOverlay();
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
