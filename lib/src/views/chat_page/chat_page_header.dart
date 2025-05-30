import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageHeader extends StatelessWidget implements PreferredSizeWidget {
  IsmChatPageHeader({
    this.onTap,
    super.key,
  });

  final VoidCallback? onTap;

  @override
  Size get preferredSize {
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.chatPageTag)) {
      return Size.fromHeight(IsmChatProperties.chatPageProperties.header?.height
              ?.call(
                  IsmChatConfig.kNavigatorKey.currentContext ??
                      IsmChatConfig.context,
                  Get.find<IsmChatPageController>(tag: IsmChat.i.chatPageTag)
                      .conversation) ??
          IsmChatDimens.appBarHeight);
    }

    return Size.fromHeight(IsmChatDimens.appBarHeight);
  }

  final issmChatConversationsController = IsmChatUtility.conversationController;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => PreferredSize(
          preferredSize: preferredSize,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: IsmChatConfig
                    .chatTheme.chatPageHeaderTheme?.systemUiOverlayStyle ??
                SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: IsmChatConfig.chatTheme.primaryColor ??
                      IsmChatColors.primaryColorLight,
                ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.backgroundColor ??
                    IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: IsmChatDimens.appBarHeight,
                      color: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.backgroundColor ??
                          IsmChatConfig.chatTheme.primaryColor,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (!IsmChatResponsive.isWeb(context)) ...[
                            IconButton(
                              onPressed: () async {
                                var updateLastMessage = false;
                                controller.closeOverlay();
                                if (IsmChat.i.chatPageTag == null) {
                                  IsmChatRoute.goBack<void>();
                                  updateLastMessage =
                                      await controller.updateLastMessage();
                                }
                                IsmChatProperties
                                    .chatPageProperties.header?.onBackTap
                                    ?.call(updateLastMessage);
                              },
                              icon: Icon(
                                IsmChat.i.chatPageTag == null
                                    ? Icons.arrow_back_rounded
                                    : Icons.close_rounded,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            )
                          ] else ...[
                            IsmChatDimens.boxWidth16,
                          ],
                          IsmChatTapHandler(
                            onTap: onTap,
                            child: IsmChatProperties.chatPageProperties.header
                                    ?.profileImageBuilder
                                    ?.call(
                                        context,
                                        controller.conversation,
                                        controller.conversation?.profileUrl ??
                                            '') ??
                                IsmChatImage.profile(
                                  IsmChatProperties.chatPageProperties.header
                                          ?.profileImageUrl
                                          ?.call(
                                              context,
                                              controller.conversation,
                                              controller.conversation
                                                      ?.profileUrl ??
                                                  '') ??
                                      controller.conversation?.profileUrl ??
                                      '',
                                  name: IsmChatProperties
                                          .chatPageProperties.header?.title
                                          ?.call(
                                              context,
                                              controller.conversation,
                                              controller
                                                      .conversation?.chatName ??
                                                  '') ??
                                      controller.conversation?.chatName,
                                  dimensions: IsmChatDimens.fifty,
                                  isNetworkImage: (IsmChatProperties
                                              .chatPageProperties
                                              .header
                                              ?.profileImageUrl
                                              ?.call(
                                                  context,
                                                  controller.conversation,
                                                  controller.conversation
                                                          ?.profileUrl ??
                                                      '') ??
                                          controller.conversation?.profileUrl ??
                                          '')
                                      .isValidUrl,
                                ),
                          ),
                          IsmChatDimens.boxWidth8,
                          _TitleSubTitleWidget(
                            onTap: onTap,
                            controller: controller,
                          ),
                          if (IsmChatProperties
                                  .chatPageProperties.header?.actionBuilder !=
                              null) ...[
                            IsmChatProperties
                                    .chatPageProperties.header?.actionBuilder
                                    ?.call(context, controller.conversation,
                                        false) ??
                                const SizedBox.square()
                          ],
                          _PopupMenuWidget(
                            controller: controller,
                          ),
                        ],
                      ),
                    ),
                    IsmChatProperties.chatPageProperties.header?.bottom
                            ?.call(context, controller.conversation, false) ??
                        const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _TitleSubTitleWidget extends StatelessWidget {
  const _TitleSubTitleWidget({this.onTap, required this.controller});

  final IsmChatPageController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: IsmChatTapHandler(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: IsmChatProperties.chatPageProperties.header?.titleBuilder
                        ?.call(context, controller.conversation,
                            controller.conversation?.chatName ?? '') ??
                    Text(
                      IsmChatProperties.chatPageProperties.header?.title?.call(
                              context,
                              controller.conversation,
                              controller.conversation?.chatName ?? '') ??
                          controller.conversation?.chatName ??
                          '',
                      style: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.titleStyle ??
                          IsmChatStyles.w600White16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              if (IsmChatProperties
                      .chatPageProperties.header?.subtitleBuilder !=
                  null) ...[
                Obx(
                  () =>
                      IsmChatProperties
                          .chatPageProperties.header?.subtitleBuilder
                          ?.call(
                        context,
                        controller.conversation,
                        controller.conversation?.isSomeoneTyping == true,
                      ) ??
                      IsmChatDimens.box0,
                )
              ] else ...[
                (!(controller.conversation?.isChattingAllowed == true))
                    ? IsmChatDimens.box0
                    : Obx(
                        () => controller.conversation?.isSomeoneTyping == true
                            ? Text(
                                controller.conversation?.typingUsers ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.subtileStyle ??
                                    IsmChatStyles.w400White12,
                              )
                            : controller.conversation?.isGroup == true
                                ? SizedBox(
                                    width: IsmChatResponsive.isWeb(context)
                                        ? null
                                        : IsmChatDimens.percentWidth(.55),
                                    child: Text(
                                      controller.conversation?.members
                                                  ?.isNullOrEmpty ==
                                              true
                                          ? controller.isBroadcast
                                              ? '${controller.conversation?.membersCount} ${IsmChatStrings.participants.toUpperCase()}'
                                              : IsmChatStrings.tapInfo
                                          : (controller.conversation?.members ??
                                                  [])
                                              .map(
                                              (e) {
                                                final name =
                                                    '${e.metaData?.firstName ?? ''} ${e.metaData?.lastName ?? ''} ';
                                                if (name.trim().isNotEmpty) {
                                                  return name;
                                                } else {
                                                  return e.userName;
                                                }
                                              },
                                            ).join(', '),
                                      style: IsmChatConfig
                                              .chatTheme
                                              .chatPageHeaderTheme
                                              ?.subtileStyle ??
                                          IsmChatStyles.w400White12,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ))
                                : controller.conversation?.opponentDetails
                                            ?.online ??
                                        false
                                    ? Text(
                                        IsmChatStrings.online,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: IsmChatConfig
                                                .chatTheme
                                                .chatPageHeaderTheme
                                                ?.subtileStyle ??
                                            IsmChatStyles.w400White12,
                                      )
                                    : Text(
                                        controller.conversation?.opponentDetails
                                                        ?.lastSeen !=
                                                    null &&
                                                controller.conversation
                                                        ?.opponentDetails?.lastSeen !=
                                                    0
                                            ? controller.conversation
                                                    ?.opponentDetails?.lastSeen
                                                    ?.toCurrentTimeStirng() ??
                                                ''
                                            : IsmChatStrings.tapInfo,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: IsmChatConfig
                                                .chatTheme
                                                .chatPageHeaderTheme
                                                ?.subtileStyle ??
                                            IsmChatStyles.w400White12,
                                      ),
                      ),
              ]
            ],
          ),
        ),
      );
}

class _PopupMenuWidget extends StatelessWidget {
  const _PopupMenuWidget({required this.controller});

  final IsmChatPageController controller;

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
        color:
            IsmChatConfig.chatTheme.chatPageHeaderTheme?.popupBackgroundColor,
        icon: Icon(
          Icons.more_vert,
          color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
              IsmChatColors.whiteColor,
        ),
        shape: IsmChatConfig.chatTheme.chatPageHeaderTheme?.popupShape,
        shadowColor:
            IsmChatConfig.chatTheme.chatPageHeaderTheme?.popupshadowColor,
        itemBuilder: (context) => [
          if (IsmChatProperties.chatPageProperties.features
              .contains(IsmChatFeature.searchMessage)) ...[
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatConfig.chatTheme.primaryColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(
                    IsmChatStrings.search,
                    style: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.popupLableStyle,
                  )
                ],
              ),
            )
          ],
          if (IsmChatProperties.chatPageProperties.features
              .contains(IsmChatFeature.chageWallpaper)) ...[
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(
                    Icons.wallpaper_rounded,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatConfig.chatTheme.primaryColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(
                    IsmChatStrings.wallpaper,
                    style: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.popupLableStyle,
                  )
                ],
              ),
            )
          ],
          if ((!(controller.conversation?.isGroup ?? false)) &&
              controller.conversation?.isOpponentDetailsEmpty == false)
            PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  Icon(
                    Icons.block,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.redColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(
                    controller.conversation?.isBlockedByMe == true
                        ? IsmChatStrings.unBlockUser
                        : IsmChatStrings.blockUser,
                    style: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.popupLableStyle,
                  )
                ],
              ),
            ),
          if (IsmChatProperties.chatPageProperties.features
              .contains(IsmChatFeature.clearChat)) ...[
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.blackColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(
                    IsmChatStrings.clearChat,
                    style: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.popupLableStyle,
                  )
                ],
              ),
            ),
          ],
          if ((controller.conversation?.lastMessageDetails?.customType ==
                      IsmChatCustomMessageType.removeMember &&
                  controller.conversation?.lastMessageDetails?.userId ==
                      IsmChatConfig.communicationConfig.userConfig.userId) ||
              controller.isActionAllowed == true) ...[
            PopupMenuItem(
              value: 5,
              child: Row(
                children: [
                  Icon(
                    Icons.group_off_rounded,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.redColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(
                    IsmChatStrings.deleteGroup,
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.popupLableStyle ??
                        IsmChatStyles.w500Black12
                            .copyWith(color: IsmChatColors.redColor),
                  )
                ],
              ),
            ),
          ],
          if (IsmChatProperties.chatPageProperties.header != null &&
              IsmChatProperties.chatPageProperties.header?.popupItems !=
                  null) ...[
            ...IsmChatProperties.chatPageProperties.header!
                .popupItems!(context, controller.conversation)
                .map(
              (e) => PopupMenuItem(
                value:
                    (IsmChatProperties.chatPageProperties.header?.popupItems!(
                                    context, controller.conversation) ??
                                [])
                            .indexOf(e) +
                        6,
                child: Row(
                  children: [
                    Icon(
                      e.icon,
                      color: e.color,
                    ),
                    IsmChatDimens.boxWidth8,
                    Text(
                      e.label,
                      style: IsmChatConfig
                          .chatTheme.chatPageHeaderTheme?.popupLableStyle,
                    )
                  ],
                ),
              ),
            )
          ]
        ],
        elevation: 2,
        onSelected: (value) {
          if (value == 4 || value == 5) {
            controller.showDialogForClearChatAndDeleteGroup(
                isGroupDelete: value == 5);
          } else if (value == 3) {
            controller.handleBlockUnblock();
          } else if (value == 2) {
            controller.addWallpaper();
          } else if (value == 1) {
            if (IsmChatResponsive.isWeb(context)) {
              Get.find<IsmChatConversationsController>(
                          tag: IsmChat.i.chatListPageTag)
                      .isRenderChatPageaScreen =
                  IsRenderChatPageScreen.messageSearchView;
            } else {
              IsmChatRoute.goToRoute(const IsmChatSearchMessgae());
            }
          } else {
            IsmChatProperties.chatPageProperties.header?.popupItems
                ?.call(context, controller.conversation)[value - 6]
                .onTap(controller.conversation);
          }
        },
      );
}
