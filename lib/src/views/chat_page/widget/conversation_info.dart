import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Group / 1:1 conversation info. Colors from [IsmChatThemeResolver.groupInfoFromConfig].
class IsmChatConverstaionInfoView extends StatefulWidget {
  /// Creates a conversation info view widget.
  ///
  /// **Parameters:**
  /// - `conversationId`: Optional conversation ID. If provided, will fetch details for this conversation.
  /// - `conversation`: Optional conversation model. If provided, will use this directly.
  ///                   If both are null, will use the current conversation from chat page controller.
  ///
  /// **Usage:**
  /// - When called from within chat context: `IsmChatConverstaionInfoView()`
  /// - When called from outside: `IsmChatConverstaionInfoView(conversationId: '...', conversation: ...)`
  const IsmChatConverstaionInfoView({
    super.key,
    this.conversationId,
    this.conversation,
  });

  /// Optional conversation ID to fetch details for
  final String? conversationId;

  /// Optional conversation model to display
  final IsmChatConversationModel? conversation;

  @override
  State<IsmChatConverstaionInfoView> createState() =>
      _IsmChatConverstaionInfoViewState();
}

class _IsmChatConverstaionInfoViewState
    extends State<IsmChatConverstaionInfoView> {
  final conversationController = IsmChatUtility.conversationController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _participantsSearchFocusNode = FocusNode();
  final GlobalKey _participantsSearchKey = GlobalKey();

  /// Pull-to-refresh controller — reuses [RefreshHeader] like conversation list /
  /// broadcast views so Group Info stays visually consistent with the rest of the SDK.
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  bool _isUpdatingMute = false;

  @override
  void initState() {
    super.initState();
    _participantsSearchFocusNode.addListener(_handleParticipantsSearchFocus);
  }

  @override
  void dispose() {
    _participantsSearchFocusNode.removeListener(_handleParticipantsSearchFocus);
    _participantsSearchFocusNode.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh: hit conversation-details API so name, admins, members, etc. stay fresh.
  /// Reusable entry point — keep Group Info refresh logic here rather than inlining in the widget tree.
  Future<void> _onPullToRefresh(IsmChatPageController controller) async {
    try {
      await controller.getConverstaionDetails();
    } finally {
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    }
  }

  void _handleParticipantsSearchFocus() {
    if (_participantsSearchFocusNode.hasFocus) {
      _pinSearchBarToTop();
    }
  }

  Future<void> _pinSearchBarToTop() async {
    final searchContext = _participantsSearchKey.currentContext;
    if (searchContext == null) return;
    await Scrollable.ensureVisible(
      searchContext,
      alignment: 0.02,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Prefer "First Last" for display name; fallback to username.
  String _memberDisplayName(UserDetails member) {
    final fullName =
        '${member.metaData?.firstName ?? ''} ${member.metaData?.lastName ?? ''}'
            .trim();
    return fullName.isNotEmpty ? fullName : member.userName;
  }

  /// Mute ON ⇒ `pushNotification: false` on the notifications API.
  Future<void> _onMuteNotificationsChanged(
    IsmChatPageController controller,
    bool isMuted,
  ) async {
    final conversationId = controller.conversation?.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    setState(() => _isUpdatingMute = true);
    try {
      await conversationController.updateConversationNotifications(
        conversationId: conversationId,
        pushNotification: !isMuted,
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingMute = false);
      }
    }
  }

  /// Flat action-row style for Clear chat / Exit group / Delete / Block.
  ///
  /// Host apps often set [ThemeData.textButtonTheme] with a filled
  /// `backgroundColor` (seen as a tan/orange pill). Force transparent so
  /// Group Info actions stay text-only. Reuse this for any similar action
  /// rows on this page instead of leaving TextButton unstyled.
  static final ButtonStyle _flatActionButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    // Keep left-aligned icon+label flush with the card padding.
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        initState: (_) async {
          conversationController.mediaList.clear();
          conversationController.mediaListLinks.clear();
          conversationController.mediaListDocs.clear();

          var controller = IsmChatUtility.chatPageController;

          // If conversation is provided, set it directly
          if (widget.conversation != null) {
            controller.conversation = widget.conversation;
          }

          // If conversationId is provided but conversation is not set, fetch details
          if (widget.conversationId != null &&
              widget.conversationId!.isNotEmpty &&
              widget.conversation == null) {
            // Try to get conversation from controller or database
            final existingConversation = controller.conversationController
                .getConversation(widget.conversationId!);
            if (existingConversation != null) {
              controller.conversation = existingConversation;
            } else {
              // Try to get from database
              final dbConversation = await IsmChatConfig.dbWrapper
                  ?.getConversation(widget.conversationId!);
              if (dbConversation != null) {
                controller.conversation = dbConversation;
              }
            }
          }

          // Fetch conversation details if conversation is set
          if (controller.conversation != null) {
            await controller.getConverstaionDetails();
          }
        },
        builder: (controller) {
          final groupTheme = IsmChatThemeResolver.groupInfoFromConfig(context);
          final isDocumentAllowed = IsmChatProperties
              .chatPageProperties.attachments
              .contains(IsmChatAttachmentType.document);
          final mediaLinksDocsCount = conversationController.mediaList.length +
              conversationController.mediaListLinks.length +
              (isDocumentAllowed
                  ? conversationController.mediaListDocs.length
                  : 0);
          return Scaffold(
            backgroundColor: groupTheme.scaffoldBackgroundColor,
            appBar: IsmChatAppBar(
              height: IsmChatDimens.fiftyFive,
              onBack: !IsmChatResponsive.isWeb(context)
                  ? null
                  : () {
                      IsmChatUtility
                              .conversationController.isRenderChatPageaScreen =
                          IsRenderChatPageScreen.none;
                    },
              title: Text(
                controller.conversation?.isGroup ?? false
                    ? IsmChatStrings.groupInfo
                    : IsmChatStrings.profileInfo,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
              ),
              action: [
                if (controller.conversation?.isGroup ?? false)
                  Padding(
                    padding: EdgeInsets.only(
                        right: IsmChatDimens.five, top: IsmChatDimens.two),
                    child: PopupMenuButton(
                      color: IsmChatColors.whiteColor,
                      icon: Icon(
                        Icons.more_vert,
                        color: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.iconColor ??
                            IsmChatColors.whiteColor,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              IsmChatProperties.conversationInfoAssets
                                      .changeGroupTitleIcon ??
                                  Icon(
                                    Icons.edit,
                                    color: groupTheme.menuIconColor,
                                  ),
                              IsmChatDimens.boxWidth8,
                              const Text(IsmChatStrings.changeGroupTitle)
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              IsmChatProperties.conversationInfoAssets
                                      .changeGroupImageIcon ??
                                  Icon(
                                    Icons.photo,
                                    color: groupTheme.menuIconColor,
                                  ),
                              IsmChatDimens.boxWidth8,
                              const Text(IsmChatStrings.changeGroupPhoto)
                            ],
                          ),
                        ),
                      ],
                      elevation: 2,
                      onSelected: (value) {
                        if (value == 1) {
                          controller.showDialogForChangeGroupTitle();
                        } else {
                          controller.showDialogForChangeGroupProfile();
                        }
                      },
                    ),
                  ),
              ],
            ),
            // Keep participants list visible while typing in search.
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              // Pull-to-refresh → [IsmChatPageController.getConverstaionDetails]
              // so group name / admin / member changes show without leaving the page.
              child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: false,
                header: const RefreshHeader(),
                // AlwaysScrollable so short Group Info content can still be pulled.
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                onRefresh: () => _onPullToRefresh(controller),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: IsmChatDimens.edgeInsets16_0_16_0,
                    child: Column(
                      children: [
                        IsmChatDimens.boxHeight16,
                        IsmChatTapHandler(
                          onTap: controller.conversation?.isGroup ?? false
                              ? () {
                                  controller.showDialogForChangeGroupProfile();
                                }
                              : null,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              IsmChatTapHandler(
                                onTap: () {
                                  // Let host app handle 1-1 user profile taps if provided.
                                  if (controller.conversation?.isGroup !=
                                      true) {
                                    final cb = IsmChatProperties
                                        .chatPageProperties
                                        .onUserConversationInfoTap;
                                    if (cb != null) {
                                      cb.call(context, controller.conversation);
                                      return;
                                    }
                                  }
                                  IsmChatRoute.goToRoute(IsmChatProfilePicView(
                                    userName: controller
                                                .conversation?.isGroup ==
                                            true
                                        ? controller
                                                .conversation
                                                ?.conversationTitle
                                                ?.capitalizeFirst ??
                                            ''
                                        : (() {
                                            final opponent = controller
                                                .conversation?.opponentDetails;
                                            final first =
                                                opponent?.metaData?.firstName ??
                                                    '';
                                            final last =
                                                opponent?.metaData?.lastName ??
                                                    '';
                                            final fullName =
                                                '$first $last'.trim();
                                            return (fullName.isNotEmpty
                                                        ? fullName
                                                        : (opponent?.userName ??
                                                            ''))
                                                    .capitalizeFirst ??
                                                '';
                                          })(),
                                    imageUrl:
                                        controller.conversation?.isGroup == true
                                            ? controller.conversation
                                                    ?.conversationImageUrl ??
                                                ''
                                            : controller
                                                    .conversation
                                                    ?.opponentDetails
                                                    ?.profileUrl ??
                                                '',
                                  ));
                                },
                                child: IsmChatImage.profile(
                                  controller.conversation?.profileUrl ?? '',
                                  dimensions: IsmChatDimens.hundred,
                                  name: controller.conversation?.chatName
                                          .capitalizeFirst ??
                                      '',
                                ),
                              ),
                              if (controller.conversation?.isGroup ?? false)
                                // App override: IsmChatConversationInfoProperties.groupProfileEditIcon
                                IsmChatProperties.conversationInfoAssets
                                        .groupProfileEditIcon ??
                                    CircleAvatar(
                                      radius: IsmChatDimens.forteen,
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: IsmChatDimens.eighteen,
                                      ),
                                    )
                            ],
                          ),
                        ),
                        IsmChatDimens.boxHeight5,
                        IsmChatTapHandler(
                            onTap: controller.conversation?.isGroup ?? false
                                ? () {
                                    controller.groupTitleController.text =
                                        controller.conversation?.chatName ?? '';
                                    controller.showDialogForChangeGroupTitle();
                                  }
                                : () {
                                    final cb = IsmChatProperties
                                        .chatPageProperties
                                        .onUserConversationInfoTap;
                                    if (cb != null) {
                                      cb.call(context, controller.conversation);
                                    }
                                  },
                            child: Text(
                              controller.conversation?.chatName ?? '',
                              textAlign: TextAlign.center,
                              style: groupTheme.primaryTitleTextStyle,
                            )),
                        if (!(controller.conversation?.isGroup ?? false)) ...[
                          Builder(
                            builder: (context) {
                              final identifier = (controller.conversation
                                          ?.opponentDetails?.userIdentifier ??
                                      '')
                                  .trim();
                              if (!GetUtils.isEmail(identifier))
                                return IsmChatDimens.box0;

                              return Text(
                                identifier,
                                style: groupTheme.secondaryTextStyle,
                              );
                            },
                          ),
                        ],
                        if (controller.conversation?.isGroup ?? false) ...[
                          Text(
                            '${controller.conversation?.membersCount} ${IsmChatStrings.participants}',
                            style: groupTheme.captionTextStyle,
                          ),
                        ],
                        IsmChatDimens.boxHeight10,
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.conversation?.isGroup ?? false) ...[
                              Padding(
                                padding: IsmChatDimens.edgeInsets10_5_10_10,
                                child: Text(
                                    '${IsmChatStrings.createdOn} ${controller.conversation?.createdAt?.toLastMessageTimeString} ${IsmChatStrings.by} ${controller.conversation?.createdByUserName}'),
                              ),
                            ],
                            if ((!(controller.conversation?.isGroup ??
                                    false)) &&
                                IsmChatProperties.conversationProperties
                                        .opponentSubTitle !=
                                    null) ...[
                              Container(
                                width: IsmChatDimens.percentWidth(1),
                                padding: IsmChatDimens.edgeInsets16_8_16_8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      IsmChatDimens.sixteen),
                                  color: groupTheme.surfaceBackgroundColor,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      IsmChatStrings.aboutMe,
                                      style: groupTheme.bodyTextStyle,
                                    ),
                                    IsmChatDimens.boxHeight5,
                                    Text(
                                      IsmChatProperties.conversationProperties
                                              .opponentSubTitle
                                              ?.call(
                                                  context,
                                                  controller.conversation
                                                      ?.resolvedOpponentDetails) ??
                                          '',
                                    ),
                                  ],
                                ),
                              ),
                              IsmChatDimens.boxHeight10,
                            ],
                            Container(
                              padding: IsmChatDimens.edgeInsets16_8_16_8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    IsmChatDimens.sixteen),
                                color: groupTheme.surfaceBackgroundColor,
                              ),
                              child: IsmChatTapHandler(
                                onTap: () {
                                  if (IsmChatResponsive.isWeb(context)) {
                                    IsmChatUtility.conversationController
                                            .isRenderChatPageaScreen =
                                        IsRenderChatPageScreen
                                            .coversationMediaView;
                                  } else {
                                    IsmChatRoute.goToRoute(
                                      IsmMedia(
                                        mediaList:
                                            conversationController.mediaList,
                                        mediaListLinks: conversationController
                                            .mediaListLinks,
                                        mediaListDocs: isDocumentAllowed
                                            ? conversationController
                                                .mediaListDocs
                                            : const [],
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // App override: IsmChatConversationInfoProperties.conversationMediaIcon
                                    IsmChatProperties.conversationInfoAssets
                                            .conversationMediaIcon ??
                                        SvgPicture.asset(
                                          IsmChatAssets.gallarySvg,
                                        ),
                                    IsmChatDimens.boxWidth12,
                                    Text(
                                      isDocumentAllowed
                                          ? IsmChatStrings.mediaLinksAndDocs
                                          : IsmChatStrings.mediaLinks,
                                      style: groupTheme.sectionTitleTextStyle,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          '$mediaLinksDocsCount',
                                          style: groupTheme.secondaryTextStyle,
                                        ),
                                        IsmChatDimens.boxWidth4,
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: groupTheme.actionIconColor,
                                          size: IsmChatDimens.fifteen,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IsmChatDimens.boxHeight10,
                            Container(
                              padding: IsmChatDimens.edgeInsets16_8_16_8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    IsmChatDimens.sixteen),
                                color: groupTheme.surfaceBackgroundColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    color: groupTheme.actionIconColor,
                                    size: IsmChatDimens.twentyFour,
                                  ),
                                  IsmChatDimens.boxWidth12,
                                  Expanded(
                                    child: Text(
                                      IsmChatStrings.muteNotifications,
                                      style: groupTheme.sectionTitleTextStyle,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: !(controller.conversation
                                            ?.isPushNotificationEnabled ??
                                        true),
                                    activeTrackColor:
                                        IsmChatConfig.chatTheme.primaryColor,
                                    onChanged: _isUpdatingMute
                                        ? null
                                        : (isMuted) =>
                                            _onMuteNotificationsChanged(
                                              controller,
                                              isMuted,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (controller.conversation?.isGroup ?? false) ...[
                          IsmChatDimens.boxHeight10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: IsmChatDimens.edgeInsets10,
                                child: Text(
                                  '${controller.conversation?.membersCount} ${IsmChatStrings.participants}',
                                  style: groupTheme.sectionTitleTextStyle,
                                ),
                              ),
                              if (controller
                                      .conversation!.usersOwnDetails?.isAdmin ??
                                  false)
                                IconButton(
                                  onPressed: () {
                                    controller.participnatsEditingController
                                        .clear();
                                    if (IsmChatProperties.chatPageProperties
                                            .onAddGroupMembersTap !=
                                        null) {
                                      IsmChatProperties.chatPageProperties
                                          .onAddGroupMembersTap!
                                          .call(
                                        context,
                                        controller.conversation,
                                      );
                                    } else {
                                      if (IsmChatResponsive.isWeb(context)) {
                                        IsmChatUtility.conversationController
                                                .isRenderChatPageaScreen =
                                            IsRenderChatPageScreen
                                                .groupEligibleView;
                                      } else {
                                        IsmChatRoute.goToRoute(
                                            const IsmChatGroupEligibleUser());
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.group_add_outlined,
                                    color: IsmChatConfig.chatTheme.primaryColor,
                                  ),
                                )
                            ],
                          ),
                          Container(
                            key: _participantsSearchKey,
                            child: IsmChatInputField(
                              autofocus: false,
                              focusNode: _participantsSearchFocusNode,
                              hint: 'Search using name or email',
                              fillColor: groupTheme.searchFillColor,
                              hintStyle: groupTheme.searchHintTextStyle,
                              cursorColor: IsmChatConfig.chatTheme.primaryColor,
                              style: groupTheme.inputTextStyle,
                              isShowBorderColor: true,
                              borderColor: groupTheme.dividerColor,
                              controller:
                                  controller.participnatsEditingController,
                              suffixIcon: controller
                                      .participnatsEditingController
                                      .text
                                      .isNotEmpty
                                  ? IsmChatTapHandler(
                                      onTap: () {
                                        controller
                                          ..participnatsEditingController
                                              .clear()
                                          ..onGroupSearch('')
                                          ..update();
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: groupTheme.searchIconColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.search_rounded,
                                      color: groupTheme.searchIconColor,
                                    ),
                              onChanged: (_) {
                                controller
                                  ..onGroupSearch(_)
                                  ..update();
                              },
                            ),
                          ),
                          Obx(
                            () => ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, index) =>
                                  IsmChatDimens.boxWidth4,
                              itemCount: controller.groupMembers.length,
                              itemBuilder: (_, index) {
                                var member = controller.groupMembers[index];
                                return ListTile(
                                  onTap: member.isAdmin
                                      ? (controller
                                                      .conversation
                                                      ?.usersOwnDetails
                                                      ?.isAdmin ??
                                                  false) &&
                                              controller
                                                      .conversation
                                                      ?.usersOwnDetails
                                                      ?.memberId !=
                                                  member.userId
                                          ? () {
                                              IsmChatContextWidget
                                                  .showDialogContext(
                                                content: IsmChatGroupAdminDialog(
                                                    user: member,
                                                    isAdmin: true,
                                                    groupName: controller
                                                            .conversation
                                                            ?.conversationTitle ??
                                                        ''),
                                              );
                                            }
                                          : IsmChatConfig.communicationConfig
                                                      .userConfig.userId ==
                                                  member.userId
                                              ? null
                                              : () async {
                                                  await controller
                                                      .showUserDetails(
                                                    member,
                                                    fromMessagePage: false,
                                                  );
                                                }
                                      : controller.conversation?.usersOwnDetails
                                                  ?.isAdmin ??
                                              false
                                          ? () {
                                              IsmChatContextWidget
                                                  .showDialogContext(
                                                content:
                                                    IsmChatGroupAdminDialog(
                                                  user: member,
                                                  groupName: controller
                                                          .conversation
                                                          ?.conversationTitle ??
                                                      '',
                                                ),
                                              );
                                            }
                                          : IsmChatConfig.communicationConfig
                                                      .userConfig.userId ==
                                                  member.userId
                                              ? null
                                              : () async {
                                                  await controller
                                                      .showUserDetails(
                                                    member,
                                                    fromMessagePage: false,
                                                  );
                                                },
                                  trailing: member.isAdmin
                                      ? Text(
                                          IsmChatStrings.admin,
                                          style: groupTheme.adminBadgeTextStyle
                                              .copyWith(
                                                  color: IsmChatConfig
                                                      .chatTheme.primaryColor),
                                        )
                                      : controller.conversation?.usersOwnDetails
                                                  ?.isAdmin ??
                                              false
                                          ? Icon(
                                              Icons.more_vert,
                                              color: groupTheme.menuIconColor,
                                            )
                                          : null,
                                  title: Text(
                                      IsmChatConfig.communicationConfig
                                                  .userConfig.userId ==
                                              member.userId
                                          ? IsmChatStrings.you
                                          : _memberDisplayName(member),
                                      style: groupTheme.listTileTitleTextStyle),
                                  subtitle: Text(
                                    member.userName,
                                    style: groupTheme.listTileSubtitleTextStyle,
                                  ),
                                  leading: IsmChatImage.profile(
                                    member.profileUrl,
                                    name: _memberDisplayName(member)
                                            .capitalizeFirst ??
                                        '',
                                  ),
                                );
                              },
                            ),
                          ),
                          IsmChatDimens.boxHeight20,
                          Container(
                            padding: IsmChatDimens.edgeInsets10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(IsmChatDimens.sixteen),
                              color: groupTheme.surfaceBackgroundColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  style: _flatActionButtonStyle,
                                  onPressed: () async {
                                    controller
                                        .showDialogForClearChatAndDeleteGroup();
                                  },
                                  // App override: IsmChatConversationInfoProperties.clearChatIcon
                                  icon: IsmChatProperties.conversationInfoAssets
                                          .clearChatIcon ??
                                      Icon(
                                        Icons.clear_all_rounded,
                                        color: groupTheme.menuIconColor,
                                      ),
                                  label: Text(
                                    IsmChatStrings.clearChat,
                                    style: groupTheme.bodyTextStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // IsmChatDimens.boxHeight10,
                                Divider(
                                  thickness: 1,
                                  color: groupTheme.dividerColor
                                      .applyIsmOpacity(.3),
                                ),
                                // IsmChatDimens.boxHeight5,
                                TextButton.icon(
                                  style: _flatActionButtonStyle,
                                  onPressed: controller.showDialogExitButton,
                                  // App override: IsmChatConversationInfoProperties.exitGroupIcon
                                  icon: IsmChatProperties.conversationInfoAssets
                                          .exitGroupIcon ??
                                      const Icon(
                                        Icons.logout_rounded,
                                        color: IsmChatColors.redColor,
                                      ),
                                  label: Text(
                                    IsmChatStrings.exitGroup,
                                    style: IsmChatStyles.w600red16,
                                  ),
                                ),
                                // IsmChatDimens.boxHeight5,
                              ],
                            ),
                          ),
                          IsmChatDimens.boxHeight32,
                        ] else ...[
                          IsmChatDimens.boxHeight32,
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(IsmChatDimens.sixteen),
                              color: groupTheme.surfaceBackgroundColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  style: _flatActionButtonStyle,
                                  onPressed: () async {
                                    final conv = controller.conversation;
                                    await IsmChatConfirmationHelper.present(
                                      IsmChatConfirmationRequest(
                                        type: IsmChatConfirmationType
                                            .clearChatMessages,
                                        title: IsmChatStrings.clearAllMessages,
                                        conversation: conv,
                                        actions: [
                                          IsmChatConfirmationAction(
                                            id: IsmChatConfirmationActionId
                                                .clearChat,
                                            label: IsmChatStrings.clearChat,
                                            onPressed: () =>
                                                controller.clearAllMessages(
                                              conv?.conversationId ?? '',
                                              fromServer: IsmChatConfirmationHelper
                                                  .shouldClearMessagesFromServer(
                                                conv,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    IsmChatRoute.goBack();
                                  },
                                  // App override: IsmChatConversationInfoProperties.clearChatIcon
                                  icon: IsmChatProperties.conversationInfoAssets
                                          .clearChatIcon ??
                                      const Icon(
                                        Icons.clear_all_outlined,
                                        color: IsmChatColors.redColor,
                                      ),
                                  label: Text(
                                    IsmChatStrings.clearChat,
                                    style: IsmChatStyles.w600red16,
                                  ),
                                ),
                                Divider(
                                  height: 0,
                                  thickness: 1,
                                  color: groupTheme.dividerColor
                                      .applyIsmOpacity(.3),
                                ),
                                TextButton.icon(
                                  style: _flatActionButtonStyle,
                                  onPressed: () async {
                                    final conv = controller.conversation;
                                    await IsmChatConfirmationHelper.present(
                                      IsmChatConfirmationRequest(
                                        type:
                                            IsmChatConfirmationType.deleteChat,
                                        title: '${IsmChatStrings.deleteChat}?',
                                        conversation: conv,
                                        actions: [
                                          IsmChatConfirmationAction(
                                            id: IsmChatConfirmationActionId
                                                .deleteChat,
                                            label: IsmChatStrings.deleteChat,
                                            onPressed: () => IsmChatUtility
                                                .conversationController
                                                .deleteChat(
                                              conv?.conversationId ?? '',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    IsmChatRoute.goBack();
                                    IsmChatRoute.goBack();
                                  },
                                  // App override: IsmChatConversationInfoProperties.deleteChatIcon
                                  icon: IsmChatProperties.conversationInfoAssets
                                          .deleteChatIcon ??
                                      const Icon(
                                        Icons.delete_forever_outlined,
                                        color: IsmChatColors.redColor,
                                      ),
                                  label: Text(
                                    IsmChatStrings.deleteChat,
                                    style: IsmChatStyles.w600red16,
                                  ),
                                ),
                                if (controller
                                        .conversation?.isOpponentDetailsEmpty ==
                                    false) ...[
                                  Divider(
                                    height: 0,
                                    thickness: 1,
                                    color: groupTheme.dividerColor
                                        .applyIsmOpacity(.3),
                                  ),
                                  TextButton.icon(
                                    style: _flatActionButtonStyle,
                                    onPressed: () async {
                                      await controller.handleBlockUnblock(true);
                                    },
                                    icon: IsmChatProperties
                                            .conversationInfoAssets
                                            .blockUserIcon ??
                                        const Icon(
                                          Icons.block_outlined,
                                          color: IsmChatColors.redColor,
                                        ),
                                    label: Text(
                                      '${controller.conversation?.isBlockedByMe == true ? IsmChatStrings.unblock : IsmChatStrings.block} ${controller.conversation?.chatName ?? ''}',
                                      style: IsmChatStyles.w600red16,
                                    ),
                                  )
                                ]
                              ],
                            ),
                          ),
                          IsmChatDimens.boxHeight10,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).withUnfocusGestureDetctor(context);
        },
      );
}
