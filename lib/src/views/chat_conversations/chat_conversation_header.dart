import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatListHeader extends StatelessWidget implements PreferredSizeWidget {
  const IsmChatListHeader({
    super.key,
    this.onSignOut,
    this.height,
    this.width,
    this.profileImage,
    this.title,
    this.titleStyle,
    this.titleColor,
    this.showSearch = true,
    required this.onSearchTap,
    this.actions,
  });

  final Widget? profileImage;
  final String? title;
  final TextStyle? titleStyle;
  final Color? titleColor;
  final bool showSearch;
  final void Function(BuildContext, IsmChatConversationModel, bool) onSearchTap;
  final List<Widget>? actions;
  final VoidCallback? onSignOut;

  /// Defines the height of the IsmChatListHeader
  final double? height;

  final double? width;

  @override
  Size get preferredSize => Size(width ?? IsmChatDimens.percentWidth(.3),
      height ?? IsmChatDimens.appBarHeight);

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        builder: (controller) => AppBar(
          automaticallyImplyLeading: false,
          elevation: IsmChatDimens.appBarElevation,
          title: IsmChatTapHandler(
            onTap: IsmChatResponsive.isWeb(context)
                ? () {
                    controller.isRenderScreen =
                        IsRenderConversationScreen.userView;
                    Scaffold.of(context).openDrawer();
                  }
                : () => IsmChatUtility.openFullScreenBottomSheet(
                      IsmChatUserView(
                        signOutTap: () async {
                          await Get.dialog(IsmChatAlertDialogBox(
                            title: '${IsmChatStrings.logout}?',
                            content: const Text(IsmChatStrings.logoutMessage),
                            actionLabels: const [
                              IsmChatStrings.logout,
                            ],
                            callbackActions: [
                              () {
                                Get.back();
                                onSignOut?.call();
                              },
                            ],
                          ));
                        },
                      ),
                      enableDrag: true,
                      backgroundColor: IsmChatColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(IsmChatDimens.twenty),
                        ),
                      ),
                    ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (profileImage != null)
                  profileImage!
                else
                  IsmChatImage.profile(
                    controller.userDetails?.userProfileImageUrl ?? '',
                    name: controller.userDetails?.userName,
                    dimensions: IsmChatDimens.appBarHeight * 0.8,
                  ),
                IsmChatDimens.boxWidth8,
                Text(
                  title ?? IsmChatStrings.chats,
                  style: titleStyle ??
                      IsmChatStyles.w600Black20.copyWith(
                        color:
                            titleColor ?? IsmChatConfig.chatTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),
          actions: [
            if (showSearch) _SearchAction(onTap: onSearchTap),
            if (IsmChatResponsive.isWeb(context)) _StartMessage(),
            _MoreIcon(onSignOut),
          ],
        ),
      );
}

class _StartMessage extends StatelessWidget {
  _StartMessage();

  final controller = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => IconButton(
      onPressed: () {
        controller.isRenderScreen =
            IsRenderConversationScreen.createConverstaionView;
        Scaffold.of(context).openDrawer();
      },
      icon: Icon(
        Icons.message_rounded,
        color: IsmChatConfig.chatTheme.primaryColor,
      ));
}

class _MoreIcon extends StatelessWidget {
  _MoreIcon(this.onSignOut);

  final VoidCallback? onSignOut;
  final controller = Get.find<IsmChatConversationsController>();
  @override
  Widget build(BuildContext context) {
    var conversationTypeList =
        IsmChatProperties.conversationProperties.allowedConversations;
    if (conversationTypeList.length != 1 &&
        IsmChatProperties.conversationProperties.conversationPosition ==
            IsmChatConversationPosition.menu) {
      conversationTypeList.remove(IsmChatConversationType.private);
    }
    controller.isDrawerContext = context;
    return PopupMenuButton(
      color: IsmChatColors.whiteColor,
      offset: Offset((IsmChatResponsive.isWeb(context)) ? -180 : 0, 0),
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        color: IsmChatConfig.chatTheme.primaryColor,
      ),
      onSelected: (index) async {
        if (index == 1) {
          if (IsmChatResponsive.isWeb(context)) {
            controller.isRenderScreen =
                IsRenderConversationScreen.broadcastView;
            Scaffold.of(context).openDrawer();
          } else {
            IsmChatRouteManagement.goToCreteBroadcastView();
          }
        } else if (index == 2) {
          if (IsmChatResponsive.isWeb(context)) {
            controller.isRenderScreen = IsRenderConversationScreen.blockView;
            Scaffold.of(context).openDrawer();
          } else {
            IsmChatRouteManagement.goToBlockView();
          }
        } else if (index == 3) {
          if (IsmChatResponsive.isWeb(context)) {
            controller.isRenderScreen =
                IsRenderConversationScreen.broadCastListView;
            Scaffold.of(context).openDrawer();
          } else {
            IsmChatRouteManagement.goToBroadcastListView();
          }
        } else if (index == 4) {
          controller.isRenderScreen = IsRenderConversationScreen.groupUserView;
          Scaffold.of(context).openDrawer();
        } else if (index == 5) {
          await Get.dialog(IsmChatAlertDialogBox(
            title: '${IsmChatStrings.logout}?',
            content: const Text(IsmChatStrings.logoutMessage),
            actionLabels: const [
              IsmChatStrings.logout,
            ],
            callbackActions: [
              () {
                onSignOut?.call();
              },
            ],
          ));
        } else if (IsmChatProperties
                    .conversationProperties.conversationPosition ==
                IsmChatConversationPosition.menu &&
            conversationTypeList.length != 1) {
          conversationTypeList[index - 6].goToRoute();
        }
      },
      itemBuilder: (_) => [
        if (IsmChatResponsive.isWeb(context)) ...[
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  color: IsmChatConfig.chatTheme.primaryColor,
                ),
                IsmChatDimens.boxWidth8,
                const Text(IsmChatStrings.boradcastMessge),
              ],
            ),
          )
        ],
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.no_accounts_rounded,
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
              IsmChatDimens.boxWidth8,
              const Text(IsmChatStrings.blockedUsers),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.view_list_outlined,
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
              IsmChatDimens.boxWidth8,
              const Text(IsmChatStrings.broadcastList),
            ],
          ),
        ),
        if (IsmChatResponsive.isWeb(context)) ...[
          PopupMenuItem(
            value: 4,
            child: Row(
              children: [
                Icon(
                  Icons.diversity_3_outlined,
                  color: IsmChatConfig.chatTheme.primaryColor,
                ),
                IsmChatDimens.boxWidth8,
                const Text(IsmChatStrings.newGroup),
              ],
            ),
          ),
        ],
        if (IsmChatProperties.conversationProperties.conversationPosition ==
                IsmChatConversationPosition.menu &&
            conversationTypeList.length != 1) ...[
          ...conversationTypeList.map(
            (e) => PopupMenuItem(
              value: conversationTypeList.indexOf(e) + 6,
              child: Row(
                children: [
                  Icon(
                    e.icon,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                  IsmChatDimens.boxWidth8,
                  Text(e.conversationType),
                ],
              ),
            ),
          )
        ],
        if (IsmChatResponsive.isWeb(context)) ...[
          PopupMenuItem(
            value: 5,
            child: Row(
              children: [
                Icon(
                  Icons.logout_outlined,
                  color: IsmChatConfig.chatTheme.primaryColor,
                ),
                IsmChatDimens.boxWidth8,
                const Text(IsmChatStrings.logout),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchAction extends StatelessWidget {
  _SearchAction({required this.onTap});

  final void Function(BuildContext, IsmChatConversationModel, bool) onTap;

  final controller = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => IconButton(
        color: IsmChatConfig.chatTheme.primaryColor,
        onPressed: () {
          controller.isConversationsLoading = true;
          controller.searchConversationList.clear();
          IsmChatRouteManagement.goToGlobalSearchView();
        },
        icon: const Icon(Icons.search_rounded),
      );
}
